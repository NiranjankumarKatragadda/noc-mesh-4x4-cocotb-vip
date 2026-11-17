`default_nettype none
module noc_mesh_4x4 (
  input wire clk, input wire rst_n,
  input wire [15:0] in_valid, output wire [15:0] in_ready, input wire [511:0] in_data,
  output wire [15:0] out_valid, input wire [15:0] out_ready, output wire [511:0] out_data
);
  wire [4:0] iv [0:15], ir [0:15], ov [0:15], orr [0:15];
  wire [159:0] id [0:15], od [0:15];
  genvar gx, gy;
  generate for (gy=0; gy<4; gy=gy+1) begin : g_y
    for (gx=0; gx<4; gx=gx+1) begin : g_x
      localparam integer IDX = gy*4 + gx;
      assign iv[IDX][0] = in_valid[IDX]; assign in_ready[IDX] = ir[IDX][0]; assign id[IDX][31:0] = in_data[IDX*32 +: 32];
      assign out_valid[IDX] = ov[IDX][0]; assign orr[IDX][0] = out_ready[IDX]; assign out_data[IDX*32 +: 32] = od[IDX][31:0];
      if (gy>0) begin assign iv[IDX][1]=ov[(gy-1)*4+gx][3]; assign orr[(gy-1)*4+gx][3]=ir[IDX][1]; assign id[IDX][63:32]=od[(gy-1)*4+gx][127:96]; end else begin assign iv[IDX][1]=0; assign id[IDX][63:32]=0; assign orr[IDX][1]=1; end
      if (gx<3) begin assign iv[IDX][2]=ov[gy*4+gx+1][4]; assign orr[gy*4+gx+1][4]=ir[IDX][2]; assign id[IDX][95:64]=od[gy*4+gx+1][159:128]; end else begin assign iv[IDX][2]=0; assign id[IDX][95:64]=0; assign orr[IDX][2]=1; end
      if (gy<3) begin assign iv[IDX][3]=ov[(gy+1)*4+gx][1]; assign orr[(gy+1)*4+gx][1]=ir[IDX][3]; assign id[IDX][127:96]=od[(gy+1)*4+gx][63:32]; end else begin assign iv[IDX][3]=0; assign id[IDX][127:96]=0; assign orr[IDX][3]=1; end
      if (gx>0) begin assign iv[IDX][4]=ov[gy*4+gx-1][2]; assign orr[gy*4+gx-1][2]=ir[IDX][4]; assign id[IDX][159:128]=od[gy*4+gx-1][95:64]; end else begin assign iv[IDX][4]=0; assign id[IDX][159:128]=0; assign orr[IDX][4]=1; end
      noc_router #(.CUR_X(gx[1:0]), .CUR_Y(gy[1:0])) u_r (.clk(clk), .rst_n(rst_n), .in_valid(iv[IDX]), .in_ready(ir[IDX]), .in_data(id[IDX]), .out_valid(ov[IDX]), .out_ready(orr[IDX]), .out_data(od[IDX]));
    end
  end endgenerate
endmodule
`default_nettype wire
