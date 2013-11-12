`define TRUE 1
`define FALSE 0
`define NUM_REGS 32
`define NUM_REGS 32

module processor_TestBench;

   reg  Clk;

   reg [4:0] ReadRegisterA, ReadRegisterB, WriteRegister;
   reg [31:0] WriteData;
   reg 	RegWriteEnable;
   wire [31:0] ReadDataA, ReadDataB;
   
   integer     i = 0, j = 0;
   
   
   S_regFile  myRegFile(Clk, ReadRegisterA, ReadRegisterB, WriteRegister, WriteData, RegWriteEnable, ReadDataA, ReadDataB);

   initial begin
      Clk = 1;
      WriteData = 0;
      WriteRegister = 0;
      RegWriteEnable = `TRUE;
      
      ReadRegisterA = 0;
      ReadRegisterB = `NUM_REGS-1;
   end


   always
   begin
    while ($time < 1000) 
   begin
      #5;      Clk = ~Clk;
   end
      $finish;
end   


   
   always @(negedge Clk) 
    begin
      #1;      $display("Time:%3d  Clk: %d\tWReg: %2d   WVal: %3d", ($time-1), Clk, WriteRegister, WriteData);
	 
       WriteData = WriteData + 1;
       WriteRegister = (WriteRegister +1) % `NUM_REGS;       
	end

   
   
      always @(posedge Clk)
	begin
	   #1;	   $display("Time:%3d  Clk: %d\tAReg: %2d   AVal: %3d", ($time-1), Clk, ReadRegisterA, ReadDataA);
	   $display("Time:%3d  Clk: %d\tBReg: %2d   BVal: %3d", ($time-1), Clk, ReadRegisterB, ReadDataB);
	   $display("*********************************************");
	   
	   ReadRegisterA = (ReadRegisterA+1) % `NUM_REGS;
	   ReadRegisterB = (ReadRegisterB+1) % `NUM_REGS;
	end // always


   
   always @(Clk)
     begin
	if ($time >=  640) RegWriteEnable = `FALSE;
	if ($time >=  960) RegWriteEnable = `TRUE;
   end

endmodule
   