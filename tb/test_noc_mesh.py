import random, cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_noc_mesh_xy_all_to_all(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.rst_n.value = 0; dut.in_valid.value = 0; dut.in_data.value = 0; dut.out_ready.value = 0xFFFF
    await Timer(40, units="ns"); dut.rst_n.value = 1; await RisingEdge(dut.clk)
    exp = {i: set() for i in range(16)}
    pending = [[] for _ in range(16)]
    for s in range(16):
        for k in range(3):
            dx, dy = (s + k + 1) % 4, ((s // 4) + k + 1) % 4
            dst = dy * 4 + dx
            flit = (dx << 30) | (dy << 28) | ((s << 16) | (k << 8) | 0xA5)
            pending[s].append(flit); exp[dst].add(flit)
    got = {i: set() for i in range(16)}
    for _ in range(200):
        iv, idata = 0, 0
        for s in range(16):
            if pending[s]:
                iv |= (1 << s); idata |= (pending[s][0] << (s * 32))
        dut.in_valid.value = iv; dut.in_data.value = idata
        await RisingEdge(dut.clk)
        ir, ov, od = int(dut.in_ready.value), int(dut.out_valid.value), int(dut.out_data.value)
        for s in range(16):
            if (iv & (1 << s)) and (ir & (1 << s)): pending[s].pop(0)
            if ov & (1 << s): got[s].add((od >> (s * 32)) & 0xFFFFFFFF)
        if all(got[i] == exp[i] for i in range(16)): break
    rem=sum(len(x) for x in pending); print("PENDING:", rem, [(i, hex(list(exp[i]-got[i])[0])) for i in range(16) if exp[i]-got[i]]); assert got == exp
    dut._log.info("PASS: 48 XY-routed packets delivered across all 16 4x4 NoC tiles!")
