//======================================================================
// Datapath for PUnC LC3 Processor
//======================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"

module PUnCDatapath(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// DEBUG Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data,

//----------------------------------------------------------------------
// Controller outputs
//----------------------------------------------------------------------

    // PC counter
    input wire PC_ld_register, // loads the value of PC FROM MEMORY
    input wire PC_ld_offset,
    input wire PC_clr, // clears pc to be 0
    input wire PC_inc, // adds 1 to get to the next instruction

    // Instruction Register
    input wire IR_ld,

    // readMemMux
    input wire [2:0] readCtrAddr,
    input wire [15:0] ctrAddr,

    // immMux
    input wire immSelect,
    input wire [15:0] immValue,

    // Register File
    input wire [2:0] regFile_r_addr_0, // Read Register File Address 0
    input wire [2:0] regFile_r_addr_1, // Read Register File Address 1
    input wire [2:0] regFile_w_addr_0, // Write Register File Address 0
    input wire regFile_w_en,
    // ALU
    input wire [2:0] selectALU,
    input wire modCond, 

    // regFileWriteMux 
    input wire [2:0] W_dataSelect_RF ,
    input wire [15:0] LOAD_offset,

    // Memory
    input wire memWriteEn,

    // Memory Write Addressing Control
    input wire [1:0] W_addrSelect_M ,
    input wire [15:0] WRITE_offset,


//----------------------------------------------------------------------
// Controller input
//----------------------------------------------------------------------
// Condition Flags
    output reg N,
    output reg Z,
    output reg P,

// Intruction Register, accessed also by the controller
    output reg  [15:0] ir

);

//----------------------------------------------------------------------
// Local Wires
//----------------------------------------------------------------------


//----------------------------------------------------------------------
// Local Registers
//----------------------------------------------------------------------




reg  [15:0] pc; // PC counter

// ALU
reg [15:0] ALU_A; // ALU inputs
reg [15:0] ALU_B; // ALU input
reg [15:0] ALU_Output;

// Register File
wire [15:0] regFile_r_data_0;
wire [15:0] regFile_r_data_1;
reg [15:0] regFile_w_data;


// Memory
wire [15:0] mem_r_data_0_readSignal; // Read signal out of memory
reg [15:0] mem_r_addr_0_readSignal; // Read address out of memory

reg [15:0] mem_w_addr_0; // Write address in of memory

// Assign PC debug net
assign pc_debug_data = pc;


//======================================================================

//======================================================================
// Modules
//======================================================================

//----------------------------------------------------------------------
// Memory Module
//----------------------------------------------------------------------

// 1024-entry 16-bit memory (connect other ports)
Memory mem(
    .clk      (clk),
    .rst      (rst),
    .r_addr_0 (mem_r_addr_0_readSignal),
    .r_addr_1 (mem_debug_addr),
    .w_addr   (mem_w_addr_0),
    .w_data   (ALU_Output),
    .w_en     (memWriteEn),
    .r_data_0 (mem_r_data_0_readSignal),
    .r_data_1 (mem_debug_data)
);

//----------------------------------------------------------------------
// Register File Module
//----------------------------------------------------------------------

// 8-entry 16-bit register file (connect other ports)
RegisterFile rfile(
    .clk      (clk),
    .rst      (rst),
    .r_addr_0 (regFile_r_addr_0),
    .r_addr_1 (regFile_r_addr_1),
    .r_addr_2 (rf_debug_addr),
    .w_addr   (regFile_w_addr_0),
    .w_data   (regFile_w_data),
    .w_en     (regFile_w_en),
    .r_data_0 (regFile_r_data_0),
    .r_data_1 (regFile_r_data_1),
    .r_data_2 (rf_debug_data)
);
//======================================================================


//======================================================================
// Program Counter/Instruction
//======================================================================

//----------------------------------------------------------------------
// PC counter - Points to the area in memory we are reading the 
// instruction from
//----------------------------------------------------------------------
always @(posedge clk) 
begin
    if (PC_ld_register == 1) 
    begin
        pc = regFile_r_data_0;
    end
    if (PC_ld_offset == 1)
    begin
        pc = pc + WRITE_offset;
    end
    if (PC_clr == 1)
    begin
        pc <= 16'd0;
    end
    if (PC_inc == 1)
    begin
        pc <= (pc + 16'd1);
    end
end



//----------------------------------------------------------------------
// IR - holds the current instruction
//----------------------------------------------------------------------
always @(*) 
begin
    if (IR_ld == 1) begin
        ir = mem_r_data_0_readSignal;
    end
end

//======================================================================

//----------------------------------------------------------------------
// readMemMux - Controls what is read into memory
//----------------------------------------------------------------------
always @(posedge clk) 
begin
    if (readCtrAddr == 3'd0) begin
        mem_r_addr_0_readSignal = pc;
    end
    if (readCtrAddr == 3'd1) begin
        mem_r_addr_0_readSignal = ALU_Output; // NOT SURE
    end
    if (readCtrAddr == 3'd2) begin
       mem_r_addr_0_readSignal = LOAD_offset + pc;
    end
    if (readCtrAddr == 3'd3) begin
        mem_r_addr_0_readSignal = mem_r_data_0_readSignal; 
    end
    if (readCtrAddr == 3'd4) begin
        mem_r_addr_0_readSignal = regFile_r_data_0 + LOAD_offset;
    end
    if (readCtrAddr == 3'd5) begin
        mem_r_addr_0_readSignal = mem_r_addr_0_readSignal;
    end
end

//----------------------------------------------------------------------
// immMux - Controls if an immediateValue is used or if a register file
//          value is used.
//----------------------------------------------------------------------
always @(posedge clk) 
begin
    if (immSelect == 0) begin
        ALU_B = regFile_r_data_1;
    end
    if (immSelect == 1) begin
        ALU_B = immValue;
    end
    ALU_A = regFile_r_data_0;
end

//----------------------------------------------------------------------
// ALU - Does the arithmetic operations
//----------------------------------------------------------------------
always @(*) 
begin
    if (selectALU == 3'd0) begin             // 0: Addition
        ALU_Output = ALU_A + ALU_B;     
    end
    if (selectALU == 3'd1) begin             // 1: Bitwise AND
        ALU_Output = (ALU_A) & (ALU_B);
    end
    if (selectALU == 3'd2) begin             // 2: Bitwise NOT
        ALU_Output = ~(ALU_A);
    end
    if (selectALU == 3'd3) begin             // 3: Write Condition Set?
        //
    end
    if (selectALU == 3'd4) begin
        ALU_Output = ALU_A;
    end
end

//----------------------------------------------------------------------
// N, Z, P Flags - Does the arithmetic operations
//----------------------------------------------------------------------
always @(posedge clk) 
begin
    if (modCond == 1) begin
        if (ALU_Output[15] == 1) begin
            N = 1;
            Z = 0;
            P = 0;
        end
        else if (ALU_Output == 16'd0) begin
            N = 0;
            Z = 1;
            P = 0;
        end
        else if (ALU_Output[15] == 0) begin
            N = 0;
            Z = 0;
            P = 1;
        end
    end
end

//----------------------------------------------------------------------
// regFileWriteMux - Controls what is written to the register file
//----------------------------------------------------------------------
always @(posedge clk) 
begin
    if (W_dataSelect_RF == 2'd0) begin
       regFile_w_data = ALU_Output;
    end
    if (W_dataSelect_RF == 2'd1) begin
       regFile_w_data = mem_r_data_0_readSignal;
    end
    if (W_dataSelect_RF == 2'd2) begin
       regFile_w_data = pc;
    end
    if (W_dataSelect_RF == 2'd3) begin
       regFile_w_data = LOAD_offset + pc;
    end
end

//----------------------------------------------------------------------
// memWriteMux - Controls what is written to the memory
//----------------------------------------------------------------------
always @(posedge clk) 
begin
    if (W_addrSelect_M == 2'd0) begin
       mem_w_addr_0 = WRITE_offset + pc;
    end
    if (W_addrSelect_M == 2'd1) begin
       mem_w_addr_0 = regFile_r_data_0 + WRITE_offset;
    end
    if (W_addrSelect_M == 2'd2) begin
       mem_w_addr_0 = mem_r_data_0_readSignal;
    end
    if (W_addrSelect_M == 2'd3) begin
       mem_w_addr_0 = mem_w_addr_0;
    end
end

endmodule
