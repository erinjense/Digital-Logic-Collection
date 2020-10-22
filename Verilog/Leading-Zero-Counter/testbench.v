/**
 *  Leading Zero Counter Testbench
 *
 *  Copyright 2020 by Aaron Jense <aaron@jensetech.onmicrosoft.com>
 *  https://www.linkedin.com/in/aaron-jense/
 *
 *  Licensed under GNU General Public License 2.0 only. 
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0 <https://opensource.org/licenses/GPL-2.0>
 *
 **/

`timescale 1ns / 1ps

module top_tb();
  /* DUT_WI_SZ Support: 8, 16, 32, 64 */
  localparam DUT_WI_SZ  = 32;
  localparam DUT_WO_SZ  = $clog2(DUT_WI_SZ)+1;
  
  localparam FILE_ROM_CNT = 2*DUT_WI_SZ+1;
  localparam MAX_CYCLES   = 2*FILE_ROM_CNT-1;
  
  reg clk;
  reg rst_n;
  
  /* DUT Signals */
  reg  [(DUT_WI_SZ-1):0] dut_in;
  wire [(DUT_WO_SZ-1):0] dut_out;
 
  /* TB I/O for DUT Comparison */
  reg [(DUT_WI_SZ-1):0] tb_rom_in  [FILE_ROM_CNT];
  reg [(DUT_WO_SZ-1):0] tb_rom_out [FILE_ROM_CNT];
  
  integer tb_rom_idx;
  integer tb_out;
  
  // Clock
  always #1 clk <= ~clk;
  
  // Reset
  initial begin
    $display("Test Reset");
  	rst_n    = 1'b1;
  	#1 rst_n = 1'b0;
  	#1 rst_n = 1'b1;
  end
 
  // Timeout
  initial
  	#MAX_CYCLES $finish;
 
 // ------------- Stimulus ---------------
  initial begin
    if (DUT_WI_SZ == 64) begin
      $readmemb("tb_lzc_in_64.mem", tb_rom_in);
      $readmemb("tb_lzc_out_64.mem",tb_rom_out);
    end
    else if (DUT_WI_SZ == 32) begin
      $readmemb("tb_lzc_in_32.mem", tb_rom_in);
      $readmemb("tb_lzc_out_32.mem",tb_rom_out);
    end
    else if (DUT_WI_SZ == 16) begin
      $readmemb("tb_lzc_in_16.mem", tb_rom_in);
      $readmemb("tb_lzc_out_16.mem",tb_rom_out);
    end
    else if (DUT_WI_SZ == 8) begin
      $readmemb("tb_lzc_in_8.mem", tb_rom_in);
      $readmemb("tb_lzc_out_8.mem",tb_rom_out);
    end
    else begin
      $display("Invalid DUT_WI_SZ");
      $finish;
    end
  end
  
  // ------------------------------------
  
  // ------------ Driver --------------
  always @(posedge clk or negedge rst_n)
    begin
      
      if (!rst_n) begin
        clk		   <= 0;
        dut_in     <= 0;
        tb_rom_idx <= 0;
      end
      else
      	tb_rom_idx <= tb_rom_idx+1;
      
    end
  
  always @(tb_rom_idx) begin
    dut_in = tb_rom_in[tb_rom_idx];
    tb_out = tb_rom_out[tb_rom_idx];
  end
  // ------------------------------------
  
  // ------------ Monitor --------------
  initial
    $monitor(
      "Test %2d | dut_in: %b | dut_out: %d | tb_out: %0d",
             tb_rom_idx,dut_in, dut_out, tb_out);
  // ------------------------------------
 
  // ------------ Checker --------------
  final begin
  	if (dut_out !== tb_out)
      $display("ERROR: dut: %d != tb: %d",
               dut_out, tb_out);
  end
  always @(posedge clk) begin
    if (dut_out !== tb_out)
      $display("ERROR: dut: %d != tb: %d",
               dut_out, tb_out);
  end
  // ------------------------------------
  
  // ----- DUT  -----
  leading_zero_cnt #(
    .WI_SZ(DUT_WI_SZ),
    .WO_SZ(DUT_WO_SZ)
  ) dut (
    .in(dut_in),
    .out(dut_out)
  );
  // ---------------
  
endmodule: top_tb