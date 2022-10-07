Prior to running any experiments, please check if the following files exist in the same directory.

ALU.vhd
BranchTable.vhd
Data_Memory.vhd
decode.vhd
Execution.vhd
fetch.vhd
Instruction_Memory.vhd
pipeline.vhd
PipelineTB.vhd
PredController.vhd
PredEvalu.vhd
WriteBack.vhd
testbench_full_signals.tcl
testbench.tcl
program.txt

How to run:
1. Unzip the content of this zip file into a directory that you wish.
2. Copy the binary code of instructions that you want to run into file program.txt
3. Open modelsim and change directory to the directory you used.
4. Use command  source testbench.tcl  , or use  testbench_full_signals.tcl if you wish to see all the available debug signals.
5. When the run is completed, you can check the generated memory.txt and register_file.txt for details of relevant values.
