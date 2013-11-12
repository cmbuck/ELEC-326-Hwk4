`define NUM_REGS 32
`define REG_WIDTH 32
`define MUX_CNTRL 5   // Number of bits to specify a register
/*
  Register File consists of NUM_REGS registers eachS REG_WIDTH bits wide.
  Update register "DestReg"  with new value "WriteData" if "WE" is 1 
  SrcRegA and SrcRegB are the ids of the two read registers 
  Ports DataA and DataB hold the values of the two read registers
*/

   module B_regFile(Clk, SrcRegA, SrcRegB, DestReg, WriteData, WE, DataA, DataB);

   input Clk;
   input [`MUX_CNTRL-1:0] SrcRegA, SrcRegB;
   input [`MUX_CNTRL-1:0] DestReg;
   input [`REG_WIDTH-1:0] WriteData;
   input WE;
   output [`REG_WIDTH-1:0] DataA, DataB;

   reg [`REG_WIDTH-1:0]    REG_FILE [0:`NUM_REGS-1];  // Create required Register File
		   
   integer 			i,j;
   
   
    
always @(negedge Clk)
       begin 
	if (WE) 
    	  REG_FILE[DestReg] <=  WriteData;
        end

   assign   DataA = REG_FILE[SrcRegA];
   assign   DataB = REG_FILE[SrcRegB];
   

endmodule
