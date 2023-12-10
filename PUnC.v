//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------

    // PC counter
    wire PC_ld_register; // loads the value of PC FROM MEMORY
    wire PC_clr; // clears pc to be 0
    wire PC_inc; // adds 1 to get to the next instruction
	wire PC_ld_offset;
    // Instruction Register
    wire IR_ld;

    // readMemMux
    wire [2:0] readCtrAddr;
	wire [15:0] ctrAddr;

    // immMux
    wire immSelect;
    wire [15:0] immValue;

    // Register File
    wire [2:0] regFile_r_addr_0; // Read Register File Address 0
    wire [2:0] regFile_r_addr_1; // Read Register File Address 1
	wire [2:0] regFile_w_addr_0; // Write Register File Address 0
	wire regFile_w_en;
	// ALU
	wire [2:0] selectALU;
	wire modCond;

	// regFileWriteMux 
	wire [2:0] W_dataSelect_RF;
	wire [15:0] LOAD_offset;

	// memWriteEn
	wire memWriteEn;

	// Memory Write Addressing Control
	wire [1:0] W_addrSelect_M;
	wire [15:0] WRITE_offset;


	wire [15:0] ir;
	wire N;
	wire Z;
	wire P;

	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk             (clk),
		.rst             (rst),

		.ir (ir),
		.N(N),
		.Z(Z),
		.P(P),
		.PC_ld_register(PC_ld_register),
		.PC_clr(PC_clr),
		.PC_inc(PC_inc),
		.IR_ld(IR_ld),
		.readCtrAddr(readCtrAddr),
		.immSelect(immSelect),
		.immValue(immValue),
		.regFile_r_addr_0(regFile_r_addr_0),
		.regFile_r_addr_1(regFile_r_addr_1),
		.regFile_w_addr_0(regFile_w_addr_0),
		
		.regFile_w_en(regFile_w_en),
		.selectALU(selectALU),
		.modCond(modCond), 

		.W_dataSelect_RF(W_dataSelect_RF),
		.LOAD_offset(LOAD_offset),

		.memWriteEn(memWriteEn),

		.W_addrSelect_M(W_addrSelect_M),
		.WRITE_offset(WRITE_offset),
		.ctrAddr(ctrAddr),
		.PC_ld_offset(PC_ld_offset)
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk             (clk),
		.rst             (rst),

		.mem_debug_addr   (mem_debug_addr),
		.rf_debug_addr    (rf_debug_addr),
		.mem_debug_data   (mem_debug_data),
		.rf_debug_data    (rf_debug_data),
		.pc_debug_data    (pc_debug_data),

		.ir (ir),
		.N(N),
		.Z(Z),
		.P(P),
		.PC_ld_register(PC_ld_register),
		.PC_clr(PC_clr),
		.PC_inc(PC_inc),
		.IR_ld(IR_ld),
		.readCtrAddr(readCtrAddr),
		.immSelect(immSelect),
		.immValue(immValue),
		.regFile_r_addr_0(regFile_r_addr_0),
		.regFile_r_addr_1(regFile_r_addr_1),
		.regFile_w_addr_0(regFile_w_addr_0),
		
		.regFile_w_en(regFile_w_en),
		.selectALU(selectALU),
		.modCond(modCond), 

		.W_dataSelect_RF(W_dataSelect_RF),
		.LOAD_offset(LOAD_offset),

		.memWriteEn(memWriteEn),

		.W_addrSelect_M(W_addrSelect_M),
		.WRITE_offset(WRITE_offset),
		.ctrAddr(ctrAddr),
		.PC_ld_offset(PC_ld_offset)
		);

endmodule
