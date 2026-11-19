# 4×4 XY-Routing NoC Mesh Cocotb VIP

[[https://github.com/NiranjankumarKatragadda/noc-mesh-4x4-cocotb-vip/actions/workflows/ci.yml/badge.svg]](https://github.com/NiranjankumarKatragadda/noc-mesh-4x4-cocotb-vip/actions/workflows/ci.yml)

Synthesizable 16-tile 2D-Mesh Network-on-Chip (`src/noc_mesh_4x4.v`, `src/noc_router.v`) with 5-port XY dimension-order routing, round-robin arbitration, and registered input/output buffering, verified across all 16 tiles with **Cocotb** on **Verilator** and **Icarus Verilog**.

## Quick start
    make -C tb SIM=verilator
    make -C tb SIM=icarus

## Need something similar?
NK Verif Labs offers custom Cocotb VIPs, dual-sim CI, and RTL-to-GDSII services ([nk-verif-labs](https://github.com/nk-verif-labs)). Email **nkveriflabs@gmail.com**.
