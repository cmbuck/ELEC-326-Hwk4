`define MUX_CNTRL 5
`define NUM_REGS  32
`define REG_WIDTH 32
`define NUM_BITS `NUM_REGS * `REG_WIDTH

/* **************************************************** */
module BIT_REG(Clk, wEnable, d, q);

input Clk;
input wEnable;
input  d;

output reg q;

   always @(negedge Clk)
     begin
	if (wEnable)
	  q <= d;
     end
endmodule // BIT_REG

/* **************************************************** */

module   DeMux_N_1bit(Select, inData, outData);
		 
   input [`MUX_CNTRL-1:0] Select; 
   input inData;  
   output reg [`NUM_REGS-1:0] outData;


   /**************************************************************************************
   *  Input Port                                                                          * 
   *  Select:  Bit number of the desired output wire in "outData"                         * 
   *  inData:  1 bit input signal to be forwarded to selected output wire                 *
   *                                                                                      *
   *  Output Port                                                                         *
   *  outData: 1 bit signal for each  register. The bit number specified by "Select"      *  
   *           should be set to the value of "inData". The remining bits of "outData"     *
   *           should be  set to 0                                                        *
   /**************************************************************************************/
   
   always @(*)
   begin
	outData = (inData << Select);
   end
   
endmodule // DeMux_N_1bit



module Mux_N_Mbit(Select, inData, outData);
  
   input [`MUX_CNTRL-1:0] Select;  
   input [`NUM_BITS-1:0] inData;
   output reg [`REG_WIDTH-1:0] outData;

   /**************************************************************************************
   *  Input Port                                                                          *
   *  inData:  consists of  NUM_REGS groups of signals. Each group is REG_WIDTH bits wide  *
   *               The ith group of REG_WIDTH bits correspond to  register i              *
   *  Select: specifies the group to be selected: between 0 and NUM_REGS-1                *
   *                                                                                      *
   *  Output Port:                                                                        * 
   *  outData: consits of the REG_WIDTH bits of the register specified by "Select"        *
   /***************************************************************************************/
   always @(*)
   begin
	outData = inData[Select * `REG_WIDTH +: `REG_WIDTH];
	//outData <= ( inData >> (Select * `REG_WIDTH) ) && 32'hFFFFFFFF;
   end
   
endmodule // Mux_N_Mbit

module Nbit_Reg(Clk,  wEnable, wData, outVal);

input Clk;
input wEnable;
input  [`REG_WIDTH-1:0] wData;
output [`REG_WIDTH-1:0] outVal;

   /*********************************************************************************    
   * Input Ports:                                                                    *
   * Clk: Periodic clock signal                                                      * 
   *                                                                                 *
   *  wEnable   : Write enable control signal                                        *
   *                   1 : Update register                                           *
   *                   0 : Do not update any registers                               *
   *                                                                                 *
   *  wData      : Data to write                                                     *
   *                                                                                 *  
   *                                                                                 *
   * Output Ports:                                                                   *
   * outVal : Ccontents of register                                                  *
   ***********************************************************************************/ 
	
	genvar i;
		generate
			for (i=0; i < `REG_WIDTH; i = i + 1)
			begin : george
			BIT_REG steve(Clk, wEnable, wData[i], outVal[i]);
			end
		endgenerate
	
endmodule // Nbit_Reg



module S_regFile(Clk, SrcRegA, SrcRegB, DestReg, WriteData, WE, DataA, DataB);

   input Clk;
   input [`MUX_CNTRL-1:0] SrcRegA, SrcRegB; 
   input [`MUX_CNTRL-1:0] DestReg; 
   input [`REG_WIDTH-1:0] WriteData;
   input WE;
   output [`REG_WIDTH-1:0] DataA, DataB; 
  
   
  /***********************************************************************************    
   * Input Ports:                                                                    *
   * Clk: Periodic clock signal  with "posedge" and "negedge"                        * 
   *                                                                                 *
   *  SrcRegA: id of  registerto be read into output port  "DataA"                   *
   *  SrcRegB:  id of register to be read into output port  "DataB"                  *
   *                                                                                 *
   *  WE     : Write enable control signal                                           *
   *                  1 : Write to specified destination register                    *
   *                  0 : Do not update any registers                                *
   *                                                                                 *
   *  DestReg : id of register to updat with "WriteData" if write is enabled         *
   *  WriteData: data to write to registerDestReg"                                   *
   *                                                                                 *  
   *                                                                                 *
   * Output Ports:                                                                   *
   *  DataA : output port with contents of register specified by "SrcRegA"           *
   *  DataB : output port with contents of register specified by "SrcRegB"           *
   ***********************************************************************************/ 
	wire [`NUM_REGS-1:0] weDemuxed;
	//wire [`REG_WIDTH-1:0] regOutputs[`NUM_REGS-1:0];
	wire [`NUM_BITS-1:0] regOutputs;
	
	DeMux_N_1bit demux1(DestReg, WE, weDemuxed);
	
	//make the register bank
	genvar i;
	generate
		for (i=0; i < `NUM_REGS; i = i + 1)
		begin : regBank
		//Nbit_Reg register(Clk, wEnable, WriteData, regOutputs[i]);
		Nbit_Reg register(Clk, wEnable, WriteData, regOutputs[`REG_WIDTH * i +:`REG_WIDTH]);
		end
	endgenerate
	
	Mux_N_Mbit muxA(SrcRegA, regOutputs, DataA);
	Mux_N_Mbit muxB(SrcRegB, regOutputs, DataB);

endmodule // regFile_S




