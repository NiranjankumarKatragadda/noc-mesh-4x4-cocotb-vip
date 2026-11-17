`default_nettype none
module noc_router #(parameter [1:0] CUR_X=0, parameter [1:0] CUR_Y=0) (
  input wire clk, input wire rst_n,
  input wire [4:0] in_valid, output wire [4:0] in_ready, input wire [159:0] in_data,
  output reg [4:0] out_valid, input wire [4:0] out_ready, output reg [159:0] out_data
);
  reg [4:0] ib_v; reg [31:0] ib_d [0:4]; reg [2:0] rr_r;
  assign in_ready = ~ib_v;
  reg [2:0] req_port [0:4]; reg [4:0] grant; reg [2:0] win_in [0:4]; reg [4:0] out_has_win;
  integer i, o, k; reg [2:0] idx;
  always @(*) begin
    for (i=0; i<5; i=i+1) begin
      if (ib_d[i][31:30] > CUR_X) req_port[i]=3'd2; else if (ib_d[i][31:30] < CUR_X) req_port[i]=3'd4;
      else if (ib_d[i][29:28] > CUR_Y) req_port[i]=3'd3; else if (ib_d[i][29:28] < CUR_Y) req_port[i]=3'd1;
      else req_port[i]=3'd0;
    end
    grant = 5'd0; out_has_win = 5'd0;
    for (o=0; o<5; o=o+1) begin
      win_in[o] = 3'd0;
      if (!out_valid[o] || out_ready[o]) begin
        for (k=0; k<5; k=k+1) begin
          idx = ({1'b0, rr_r} + k[3:0]) % 4'd5;
          if (!out_has_win[o] && ib_v[idx] && (req_port[idx] == o[2:0])) begin
            out_has_win[o]=1'b1; win_in[o]=idx; grant[idx]=1'b1;
          end
        end
      end
    end
  end
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin ib_v<=0; out_valid<=0; out_data<=0; rr_r<=0; for (i=0;i<5;i=i+1) ib_d[i]<=0; end
    else begin
      rr_r <= (rr_r == 3'd4) ? 3'd0 : (rr_r + 3'd1);
      for (i=0; i<5; i=i+1) begin
        if (in_valid[i] && in_ready[i]) begin ib_v[i]<=1'b1; ib_d[i]<=in_data[i*32 +: 32]; end
        else if (grant[i]) ib_v[i]<=1'b0;
      end
      for (o=0; o<5; o=o+1) begin
        if (out_has_win[o]) begin out_valid[o]<=1'b1; out_data[o*32 +: 32]<=ib_d[win_in[o]]; end
        else if (out_ready[o]) out_valid[o]<=1'b0;
      end
    end
  end
endmodule
`default_nettype wire
