//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset
	input wire [15:0] ir,
	input wire N,
	input wire Z,
	input wire P,

// Datapath Inputs

 	// PC counter
    output reg PC_ld_register, // loads the value of PC FROM MEMORY
    output reg PC_clr, // clears pc to be 0
    output reg PC_inc, // adds 1 to get to the next instruction
	output reg PC_ld_offset, // loads the value of pc using offset

    // Instruction Register
    output reg IR_ld,

    // readMemMux
    output reg [2:0] readCtrAddr,
	output reg [15:0] ctrAddr,
    // immMux
    output reg immSelect,
    output reg [15:0] immValue,

    // Register File
    output reg [2:0] regFile_r_addr_0, // Read Register File Address 0
    output reg [2:0] regFile_r_addr_1, // Read Register File Address 1
    output reg [2:0] regFile_w_addr_0, // Write Register File Address 0
    output reg regFile_w_en,
    // ALU
    output reg [2:0] selectALU,
    output reg modCond, 

    // regFileWriteMux 
    output reg [2:0] W_dataSelect_RF ,
    output reg [15:0] LOAD_offset,

    // memWriteEn
    output reg memWriteEn,

    // Memory Write Addressing Control
    output reg [1:0] W_addrSelect_M ,
    output reg [15:0] WRITE_offset


	// Add more ports here
);

	// FSM States
	// Add your FSM State values as localparams here
	localparam STATE_INIT = 7'd0;
	localparam STATE_FETCH = 7'd1;
	localparam STATE_DECODE = 7'd2;
	localparam STATE_ADD_PLUS_IMM_LOGIC = 7'd3;
	localparam STATE_ADD_PLUS_REG_LOGIC = 7'd4;
	localparam STATE_AND_PLUS_IMM_LOGIC = 7'd5;
	localparam STATE_AND_PLUS_REG_LOGIC = 7'd6;
	localparam STATE_BR_Read = 7'd7;
	localparam STATE_BRn = 7'd8;
	localparam STATE_BRz = 7'd9;
	localparam STATE_BRzn = 7'd10;
	localparam STATE_BRnp = 7'd11;
	localparam STATE_BRzp = 7'd12;
	localparam STATE_BRp = 7'd13;
	localparam STATE_BRnzp = 7'd14;
	localparam STATE_JMP_Read = 7'd15;
	localparam STATE_JSR_Load_One = 7'd16;
	localparam STATE_JSR_Load_Two = 7'd17;
	localparam STATE_JSRR_Load_One = 7'd18;
	localparam STATE_JSRR_Load_Two = 7'd19;
	localparam STATE_LD_PLUS_Write_One = 7'd20;
	localparam STATE_LD_PLUS_Read_One = 7'd21;
	localparam STATE_LD_PLUS_Mem = 7'd22;
	localparam STATE_LDI_PLUS_Read_One = 7'd23;
	localparam STATE_LDR_PLUS_Read_One = 7'd24;
	localparam STATE_LEA_PLUS_Write_One = 7'd25;
	localparam STATE_NOT_Plus_LOGIC = 7'd26;
	localparam STATE_RET_Read = 7'd27;
	localparam STATE_ST_Read_One = 7'd28;
	localparam STATE_STI_Read_One = 7'd29;
	localparam STATE_STI_Read_Two = 7'd30;
	localparam STATE_STR_Read_One = 7'd31;
	localparam STATE_HALT = 7'd32;

	localparam STATE_ADD_PLUS_IMM_Write = 7'd33;
	localparam STATE_ADD_PLUS_REG_Write = 7'd34;
	localparam STATE_AND_PLUS_IMM_Write = 7'd35;
	localparam STATE_AND_PLUS_REG_Write = 7'd36;
	localparam STATE_NOT_Plus_Write = 7'd37;
	localparam STATE_LD_PLUS_Read_Two = 7'd38;
	localparam STATE_LD_PLUS_Write_Two = 7'd39;
	localparam STATE_LD_PLUS_Read_Three = 7'd40;
	localparam STATE_LDI_PLUS_Read_Two = 7'd41;
	localparam STATE_LDI_PLUS_Read_Three = 7'd42;
	localparam STATE_LDI_PLUS_Read_Four = 7'd43;
	localparam STATE_LDI_PLUS_Write_One = 7'd44;
	localparam STATE_LDI_PLUS_Write_Two = 7'd45;
	localparam STATE_LDR_PLUS_Read_Two = 7'd46;
	localparam STATE_LDR_PLUS_Write_One = 7'd47;
	localparam STATE_LDR_PLUS_Write_Two = 7'd48;
	localparam STATE_LEA_PLUS_Write_Two = 7'd49;

	localparam STATE_ST_Read_Two = 7'd50;
	localparam STATE_ST_Write_One = 7'd51;
	localparam STATE_ST_Write_Two = 7'd52;
	localparam STATE_STI_Read_Three = 7'd53;
	localparam STATE_STI_Read_Four = 7'd54;
	localparam STATE_STI_Write_One = 7'd55;
	localparam STATE_STI_Write_Two = 7'd56;
	localparam STATE_STR_Read_Two = 7'd57;
	localparam STATE_STR_Write_One = 7'd58;
	localparam STATE_STR_Write_Two = 7'd59;
	localparam STATE_JMP_Write = 7'd60;
	localparam STATE_RET_Write = 7'd61;
	localparam STATE_JSR_Write_One = 7'd62;
	localparam STATE_JSR_Write_Two = 7'd63;
	localparam STATE_JSRR_Write_One = 7'd64;
	localparam STATE_JSRR_Write_Two = 7'd65;
	localparam STATE_BR_Write_One = 7'd66;
	localparam STATE_BR_Write_Two = 7'd67;

	localparam STATE_TEST = 7'd68;

	// State, Next State
	reg [6:0] state, next_state;

	// Output Combinational Logic
	always @( * ) begin
		// Set default values for outputs here (prevents implicit latching)

		// Add your output logic here
		case (state)
			STATE_HALT: begin
				PC_clr = 1;
				PC_inc = 0;
				modCond = 0;
			end
			STATE_INIT: begin
				PC_clr = 1;
				PC_inc = 0;
				PC_ld_register = 0;
				PC_ld_offset = 0;
				IR_ld = 0;
				memWriteEn = 0;
				modCond = 1'd0;
				readCtrAddr = 3'd0;
			end
			STATE_FETCH: begin
				PC_clr = 0;
				PC_inc = 1;
				PC_ld_register = 0;
				IR_ld = 1;
				memWriteEn = 0;
				modCond = 1'd0;
				readCtrAddr = 3'd0;
				PC_ld_offset = 0;
			end
			STATE_DECODE: begin
				PC_clr = 0;
				PC_inc = 0;
				PC_ld_register = 0;
				IR_ld = 0;
				memWriteEn = 0;
				modCond = 1'd0;
				readCtrAddr = 3'd0;
				regFile_w_en = 0;
				PC_ld_offset = 0;
			end

			STATE_TEST: begin

			end

			// EXECUTION STATES
//======================================================================

// ALU OPERATIONS
			STATE_ADD_PLUS_REG_LOGIC: begin
				regFile_w_en = 0;
				regFile_w_addr_0 = ir[11:9];
				regFile_r_addr_0 = ir[8:6];
				regFile_r_addr_1 = ir[2:0];
				selectALU = 3'd0;
				W_dataSelect_RF = 3'd0;
				modCond = 1'd1;
				immSelect = 0;
			end
			STATE_ADD_PLUS_REG_Write: begin
				regFile_w_en = 1;
			end
			
			STATE_ADD_PLUS_IMM_LOGIC: begin
				regFile_w_en = 0;
				regFile_w_addr_0 = ir[11:9];
				regFile_r_addr_0 = ir[8:6];
				selectALU = 3'd0;
				W_dataSelect_RF = 3'd0;
				modCond = 1'd1;
				immSelect = 1;
				if (ir[4] == 1) begin
					immValue = 16'b1111111111100000 | ir[4:0];
				end
				else begin
					immValue =  16'd0 | ir[4:0];
				end 
			end
			STATE_ADD_PLUS_IMM_Write: begin
				regFile_w_en = 1;
			end
			
			STATE_AND_PLUS_IMM_LOGIC: begin
				regFile_w_en = 0;
				regFile_w_addr_0 = ir[11:9];
				regFile_r_addr_0 = ir[8:6];
				selectALU = 3'd1;
				W_dataSelect_RF = 3'd0;
				modCond = 1'd1;
				immSelect = 1;
				if (ir[4] == 1) begin
					immValue = 16'b1111111111100000 | ir[4:0];
				end
				else begin
					immValue =  16'd0 | ir[4:0];
				end 
			end
			STATE_AND_PLUS_IMM_Write: begin
				regFile_w_en = 1;
			end
			

			STATE_AND_PLUS_REG_LOGIC: begin
				regFile_w_en = 0;
				regFile_w_addr_0 = ir[11:9];
				regFile_r_addr_0 = ir[8:6];
				regFile_r_addr_1 = ir[2:0];
				selectALU = 3'd1;
				W_dataSelect_RF = 3'd0;
				modCond = 1'd1;
				immSelect = 0;
			end
			STATE_AND_PLUS_REG_Write: begin
				regFile_w_en = 1;
			end

			STATE_NOT_Plus_LOGIC: begin
				regFile_w_en = 0;
				regFile_w_addr_0 = ir[11:9];
				regFile_r_addr_0 = ir[8:6];
				selectALU = 3'd2;
				W_dataSelect_RF = 3'd0;
				modCond = 1'd1;
				immSelect = 0;
			end
			STATE_NOT_Plus_Write: begin
				regFile_w_en = 1;
			end
// LOADS
			STATE_LD_PLUS_Read_One: begin
				regFile_w_en = 0;
				if (ir[8] == 1) begin
					LOAD_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				readCtrAddr = 3'd2;

			end
			STATE_LD_PLUS_Read_Two: begin
				if (ir[8] == 1) begin
					LOAD_offset = 16'b1111111000000000 | ir[8:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				readCtrAddr = 3'd2;
			end
			STATE_LD_PLUS_Write_One: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = ir[11:9];
				W_dataSelect_RF = 3'd1;
				readCtrAddr = 3'd2;

			end
			STATE_LD_PLUS_Write_Two: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = ir[11:9];
				W_dataSelect_RF = 3'd1;
				readCtrAddr = 3'd0;
			end


			STATE_LDI_PLUS_Read_One: begin
				regFile_w_en = 0;
				if (ir[8] == 1) begin
					LOAD_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				readCtrAddr = 3'd2;
			end
			STATE_LDI_PLUS_Read_Two: begin
				regFile_w_en = 0;
				if (ir[8] == 1) begin
					LOAD_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				readCtrAddr = 3'd2;
			end
			STATE_LDI_PLUS_Read_Three: begin
				readCtrAddr = 3'd2;
			end
			STATE_LDI_PLUS_Read_Four: begin
				readCtrAddr = 3'd2;
			end
			STATE_LDI_PLUS_Write_One: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = ir[11:9];
				W_dataSelect_RF = 3'd1;
				readCtrAddr = 3'd3;
			end
			STATE_LDI_PLUS_Write_Two: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = ir[11:9];
				W_dataSelect_RF = 3'd1;
				readCtrAddr = 3'd0;
			end


			STATE_LDR_PLUS_Read_One: begin
				regFile_w_en = 0;
				if (ir[5] == 1) begin
					LOAD_offset = 16'b1111111111000000 | ir[5:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				readCtrAddr = 3'd4;
				regFile_r_addr_0 = ir[8:6];

			end
			STATE_LDR_PLUS_Read_Two: begin
				regFile_w_en = 0;

				if (ir[5] == 1) begin
					LOAD_offset = 16'b1111111111000000 | ir[5:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[5:0];
				end 
				readCtrAddr = 3'd4;
				regFile_r_addr_0 = ir[8:6];
			end
			STATE_LDR_PLUS_Write_One: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = ir[11:9];
				W_dataSelect_RF = 3'd1;
				readCtrAddr = 3'd4;
				regFile_r_addr_0 = ir[8:6];
			end
			STATE_LDR_PLUS_Write_Two: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = ir[11:9];
				W_dataSelect_RF = 3'd1;
				readCtrAddr = 3'd4;
				regFile_r_addr_0 = ir[8:6];
			end


			STATE_LEA_PLUS_Write_One: begin
				regFile_w_en = 1;
				if (ir[8] == 1) begin
					LOAD_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				regFile_w_addr_0 = ir[11:9];
				W_dataSelect_RF = 3'd3;

			end
			STATE_LEA_PLUS_Write_Two: begin
				regFile_w_en = 1;
				if (ir[8] == 1) begin
					LOAD_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				regFile_w_addr_0 = ir[11:9];
				W_dataSelect_RF = 3'd3;
			end

// STORES
			STATE_ST_Read_One: begin
				regFile_w_en = 0;
				regFile_r_addr_0= ir[11:9];
			end
			STATE_ST_Read_Two: begin
				regFile_w_en = 0;
				memWriteEn = 0;
				regFile_r_addr_0= ir[11:9];

				W_addrSelect_M = 2'd0;
				if (ir[8] == 1) begin
					WRITE_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					WRITE_offset =  16'd0 | ir[8:0];
				end

				selectALU = 3'd4;
			end
			STATE_ST_Write_One: begin
				memWriteEn = 1;
				W_addrSelect_M = 2'd0;
				regFile_r_addr_0 = ir[11:9];
				if (ir[8] == 1) begin
					WRITE_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					WRITE_offset =  16'd0 | ir[8:0];
				end
				selectALU = 3'd4;

			end
			STATE_ST_Write_Two: begin
				memWriteEn = 1;
				W_addrSelect_M = 2'd0;
				regFile_r_addr_0= ir[11:9];

				if (ir[8] == 1) begin
					WRITE_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					WRITE_offset =  16'd0 | ir[8:0];
				end
				selectALU = 3'd4;

			end



			STATE_STI_Read_One: begin
				regFile_w_en = 0;
				if (ir[8] == 1) begin
					LOAD_offset = 16'b1111111000000000 | ir[8:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				readCtrAddr = 3'd2;
			end
			STATE_STI_Read_Two: begin
				regFile_w_en = 0;
				if (ir[8] == 1) begin
					LOAD_offset = 16'b1111111100000000 | ir[8:0];
				end
				else begin
					LOAD_offset =  16'd0 | ir[8:0];
				end 
				readCtrAddr = 3'd5;
			end
			STATE_STI_Read_Three: begin
				readCtrAddr = 3'd5;
			end
			STATE_STI_Read_Four: begin
				readCtrAddr = 3'd5;
			end
			STATE_STI_Write_One: begin
				memWriteEn = 1;
				W_addrSelect_M = 2'd2;
				regFile_r_addr_0 = ir[11:9];
				selectALU = 3'd4;
			end
			STATE_STI_Write_Two: begin
				memWriteEn = 1;
				W_addrSelect_M = 2'd2;
				regFile_r_addr_0 = ir[11:9];
				selectALU = 3'd4;
			end



			STATE_STR_Read_One: begin
				memWriteEn = 0;
				regFile_w_en = 0;
				regFile_r_addr_0= ir[8:6];
			end
			STATE_STR_Read_Two: begin
				regFile_w_en = 0;
				memWriteEn = 0;
				regFile_r_addr_0= ir[8:6];

				W_addrSelect_M = 2'd1;

				if (ir[5] == 1) begin
					WRITE_offset = 16'b1111111111000000 | ir[5:0];
				end
				else begin
					WRITE_offset =  16'd0 | ir[8:0];
				end 
				selectALU = 3'd4;

			end
			STATE_STR_Write_One: begin
				memWriteEn = 1;
				regFile_r_addr_0= ir[11:9];

				W_addrSelect_M = 2'd0;

				if (ir[5] == 1) begin
					WRITE_offset = 16'b1111111111000000 | ir[5:0];
				end
				else begin
					WRITE_offset =  16'd0 | ir[5:0];
				end 
				selectALU = 3'd4;
			end
			STATE_STR_Write_Two: begin
				
				memWriteEn = 1;
				regFile_r_addr_0= ir[11:9];

				W_addrSelect_M = 2'd0;

				if (ir[5] == 1) begin
					WRITE_offset = 16'b1111111111000000 | ir[5:0];
				end
				else begin
					WRITE_offset =  16'd0 | ir[5:0];
				end 
				selectALU = 3'd4;

			end

// BRANCHING
			STATE_JMP_Read: begin
				regFile_r_addr_0= ir[8:6];
			end
			STATE_JMP_Write: begin
				PC_ld_register = 1;
			end

			STATE_RET_Read: begin
				regFile_r_addr_0= ir[8:6];
			end
			STATE_RET_Write: begin
				PC_ld_register = 1;
			end

			STATE_JSR_Load_One: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = 3'd7;
				W_dataSelect_RF = 2;
			end
			STATE_JSR_Load_Two: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = 3'd7;
				W_dataSelect_RF = 2;
			end
			STATE_JSR_Write_One: begin
				if (ir[10] == 1) begin
					WRITE_offset = 16'b1111100000000000 | ir[10:0];
				end
				else begin
					WRITE_offset =  16'd0 | ir[10:0];
				end 
			end
			STATE_JSR_Write_Two: begin
				PC_ld_offset = 1;
			end

			STATE_JSRR_Load_One: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = 3'd7;
				W_dataSelect_RF = 2;
			end
			STATE_JSRR_Load_Two: begin
				regFile_w_en = 1;
				regFile_w_addr_0 = 3'd7;
				W_dataSelect_RF = 2;
			end
			STATE_JSRR_Write_One: begin
				regFile_r_addr_0= ir[8:6];
			end
			STATE_JSRR_Write_Two: begin
				PC_ld_register = 1;
			end

			STATE_BR_Read: begin
				WRITE_offset= ir[8:0];
				if (ir[8] == 1) begin
					WRITE_offset = (16'b1111111100000000 | ir[8:0]);
				end
				else begin
					WRITE_offset =  (16'd0 | ir[8:0]);
				end 
			end
			STATE_BR_Write_One: begin
				PC_ld_offset = 1;
			end

		endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		// Set default value for next state here
		next_state = STATE_FETCH;

		// Add your next-state logic here
		case (state)
			STATE_INIT: begin
				next_state = STATE_FETCH;
			end
			STATE_FETCH: begin
				next_state = STATE_DECODE;
			end
			STATE_ADD_PLUS_IMM_LOGIC: begin
				next_state = STATE_ADD_PLUS_IMM_Write;
			end
			STATE_ADD_PLUS_IMM_Write: begin
				next_state = STATE_FETCH;
			end
			

			STATE_ADD_PLUS_REG_LOGIC: begin
				next_state = STATE_ADD_PLUS_REG_Write;
			end
			STATE_ADD_PLUS_REG_Write: begin
				next_state = STATE_FETCH;
			end

			STATE_AND_PLUS_IMM_LOGIC: begin
				next_state = STATE_AND_PLUS_IMM_Write;
			end
			STATE_AND_PLUS_IMM_Write: begin
				next_state = STATE_FETCH;
			end


			STATE_AND_PLUS_REG_LOGIC: begin
				next_state = STATE_AND_PLUS_REG_Write;
			end
			STATE_AND_PLUS_REG_Write: begin
				next_state = STATE_FETCH;
			end


			STATE_BR_Read: begin
				next_state = STATE_BR_Write_One;
			end
			STATE_BR_Write_One: begin
				next_state = STATE_BR_Write_Two;
			end
			STATE_BR_Write_Two: begin
				next_state = STATE_FETCH;
			end
			STATE_BRn: begin
				if (N == 1) begin
					next_state = STATE_BR_Read;
				end
				else begin
					next_state = STATE_FETCH;
				end
			end
			STATE_BRz: begin
				if (Z == 1) begin
					next_state = STATE_BR_Read;
				end
				else begin
					next_state = STATE_FETCH;
				end
			end
			STATE_BRp: begin
				if (P == 1) begin
					next_state = STATE_BR_Read;
				end
				else begin
					next_state = STATE_FETCH;
				end
			end
			STATE_BRzn: begin
				if (Z == 1 || N == 1) begin
					next_state = STATE_BR_Read;
				end
				else begin
					next_state = STATE_FETCH;
				end
			end
			STATE_BRnp: begin
				if (N == 1 || P == 1) begin
					next_state = STATE_BR_Read;
				end
				else begin
					next_state = STATE_FETCH;
				end
			end
			STATE_BRzp: begin
				if (Z == 1 || P == 1) begin
					next_state = STATE_BR_Read;
				end
				else begin
					next_state = STATE_FETCH;
				end
			end
			STATE_BRnzp: begin
				if (N == 1 || Z == 1 || P == 1) begin
					next_state = STATE_BR_Read;
				end
				else begin
					next_state = STATE_FETCH;
				end
			end


			STATE_JMP_Read: begin
				next_state = STATE_JMP_Write;
			end
			STATE_JMP_Write: begin
				next_state = STATE_FETCH;
			end
			
			

			STATE_JSR_Load_One: begin
				next_state = STATE_JSR_Load_Two;
			end
			STATE_JSR_Load_Two: begin
				next_state = STATE_JSR_Write_One;
			end
			STATE_JSR_Write_One: begin
				next_state = STATE_JSR_Write_Two;
			end
			STATE_JSR_Write_Two: begin
				next_state = STATE_FETCH;
			end
			
			
			STATE_JSRR_Load_One: begin
				next_state = STATE_JSRR_Load_Two;
			end
			STATE_JSRR_Load_Two: begin
				next_state = STATE_JSRR_Write_One;
			end
			STATE_JSRR_Write_One: begin
				next_state = STATE_JSRR_Write_Two;
			end
			STATE_JSRR_Write_Two: begin
				next_state = STATE_FETCH;
			end

			
			STATE_LD_PLUS_Read_One: begin
				next_state = STATE_LD_PLUS_Read_Two;
			end
			STATE_LD_PLUS_Read_Two: begin
				next_state = STATE_LD_PLUS_Write_One;
			end
			STATE_LD_PLUS_Write_One: begin
				next_state = STATE_LD_PLUS_Write_Two;
			end
			STATE_LD_PLUS_Write_Two: begin
				next_state = STATE_FETCH;
			end


			STATE_LDI_PLUS_Read_One: begin
				next_state = STATE_LDI_PLUS_Read_Two;
			end
			STATE_LDI_PLUS_Read_Two: begin
				next_state = STATE_LDI_PLUS_Read_Three;
			end
			STATE_LDI_PLUS_Read_Three: begin
				next_state = STATE_LDI_PLUS_Read_Four;
			end
			STATE_LDI_PLUS_Read_Four: begin
				next_state = STATE_LDI_PLUS_Write_One;
			end
			STATE_LDI_PLUS_Write_One: begin
				next_state = STATE_LDI_PLUS_Write_Two;
			end

			STATE_LDR_PLUS_Read_One: begin
				next_state = STATE_LDR_PLUS_Read_Two;
			end
			STATE_LDR_PLUS_Read_Two: begin
				next_state = STATE_LDR_PLUS_Write_One;
			end
			STATE_LDR_PLUS_Write_One: begin
				next_state = STATE_LDR_PLUS_Write_Two;
			end
			STATE_LDR_PLUS_Write_Two: begin
				next_state = STATE_FETCH;
			end

			STATE_LEA_PLUS_Write_One: begin
				next_state = STATE_LEA_PLUS_Write_Two;
			end
			STATE_LEA_PLUS_Write_Two: begin
				next_state = STATE_FETCH;
			end


			STATE_NOT_Plus_LOGIC: begin
				next_state = STATE_NOT_Plus_Write;
			end
			STATE_NOT_Plus_Write: begin
				next_state = STATE_FETCH;
			end


			STATE_RET_Read: begin
				next_state = STATE_RET_Write;
			end
			STATE_RET_Write: begin
				next_state = STATE_FETCH;
			end

			
			STATE_ST_Read_One: begin
				next_state = STATE_ST_Read_Two;
			end
			STATE_ST_Read_Two: begin
				next_state = STATE_ST_Write_One;
			end
			STATE_ST_Write_One: begin
				next_state = STATE_ST_Write_Two;
			end
			STATE_ST_Write_Two: begin
				next_state = STATE_FETCH;
			end

			
			STATE_STI_Read_One: begin
				next_state = STATE_STI_Read_Two;
			end
			STATE_STI_Read_Two: begin
				next_state = STATE_STI_Read_Three;
			end
			STATE_STI_Read_Three: begin
				next_state = STATE_STI_Read_Four;
			end
			STATE_STI_Read_Four: begin
				next_state = STATE_STI_Write_One;
			end
			STATE_STI_Write_One: begin
				next_state = STATE_STI_Write_Two;
			end
			STATE_STI_Write_Two: begin
				next_state = STATE_FETCH;
			end


			STATE_STR_Read_One: begin
				next_state = STATE_STR_Read_Two;
			end
			STATE_STR_Read_Two: begin
				next_state = STATE_STR_Write_One;
			end
			STATE_STR_Write_One: begin
				next_state = STATE_STR_Write_Two;
			end
			STATE_STR_Write_Two: begin
				next_state = STATE_FETCH;
			end


			STATE_HALT: begin
				next_state = STATE_HALT;
			end

			STATE_DECODE: begin
				case (ir[15:12])
					4'b0001: begin
						if (ir[5] == 0) begin
							next_state = STATE_ADD_PLUS_REG_LOGIC;
						end
						else begin
							next_state = STATE_ADD_PLUS_IMM_LOGIC;
						end
					end
					4'b0101: begin
						if (ir[5] == 0) begin
							next_state = STATE_AND_PLUS_REG_LOGIC;
						end
						else begin
							next_state = STATE_AND_PLUS_IMM_LOGIC;
						end
					end
					4'b0000: begin
						if (ir[11] == 0 && ir[10] == 0 && ir[9] == 0) begin
							next_state = STATE_BR_Read;
						end
						else if (ir[11] == 1 && ir[10] == 0 && ir[9] == 0) begin
							next_state = STATE_BRn;
						end
						else if (ir[11] == 0 && ir[10] == 1 && ir[9] == 0) begin
							next_state = STATE_BRz;
						end
						else if (ir[11] == 0 && ir[10] == 0 && ir[9] == 1) begin
							next_state = STATE_BRp;
						end
						else if (ir[11] == 1 && ir[10] == 1 && ir[9] == 0) begin
							next_state = STATE_BRzn;
						end
						else if (ir[11] == 0 && ir[10] == 1 && ir[9] == 1) begin
							next_state = STATE_BRzp;
						end
						else if (ir[11] == 1 && ir[10] == 0 && ir[9] == 1) begin
							next_state = STATE_BRnp;
						end
						else begin
							next_state = STATE_BRnzp;
						end
					end
					4'b1100: begin
						if (ir[8] == 1 && ir[7] == 1 && ir[6] == 1) begin
							next_state = STATE_RET_Read;
						end
						else begin
							next_state = STATE_JMP_Read;
						end
					end
					4'b0100: begin
						if (ir[11] == 1) begin
							next_state = STATE_JSR_Load_One;
						end
						else begin
							next_state = STATE_JSRR_Load_One;
						end
					end
					4'b0010: begin
						next_state = STATE_LD_PLUS_Read_One;
					end
					4'b1010: begin
						next_state = STATE_LDI_PLUS_Read_One;
					end
					4'b0110: begin
						next_state = STATE_LDR_PLUS_Read_One;
					end
					4'b1110: begin
						next_state = STATE_LEA_PLUS_Write_One;
					end
					4'b1001: begin
						next_state = STATE_NOT_Plus_LOGIC;
					end
					4'b0011: begin
						next_state = STATE_ST_Read_One;
					end
					4'b1011: begin
						next_state = STATE_STI_Read_One;
					end
					4'b0111: begin
						next_state = STATE_STR_Read_One;
					end
					4'b1111: begin
						next_state = STATE_HALT;
					end
				endcase
			end
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			state <= STATE_INIT;
		end
		else begin
			state <= next_state;
		end
	end

endmodule
