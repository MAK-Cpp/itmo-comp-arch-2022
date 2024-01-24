`include "util.v"
`include "control_unit.v"

module mips_cpu(clk, pc, pc_new, instruction_memory_a, instruction_memory_rd, data_memory_a, data_memory_rd, data_memory_we, data_memory_wd,
                register_a1, register_a2, register_a3, register_we3, register_wd3, register_rd1, register_rd2);
  // сигнал синхронизации
  input clk;
  // текущее значение регистра PC
  inout [31:0] pc;
  // новое значение регистра PC (адрес следующей команды)
  output [31:0] pc_new;
  // we для памяти данных
  output data_memory_we; // = MemWrite
  // адреса памяти и данные для записи памяти данных
  output [31:0] instruction_memory_a, data_memory_a, data_memory_wd;
  // данные, полученные в результате чтения из памяти
  inout [31:0] instruction_memory_rd, data_memory_rd;
  // we3 для регистрового файла
  output register_we3; // = RegWrite
  // номера регистров
  output [4:0] register_a1, register_a2, register_a3;
  // данные для записи в регистровый файл
  output [31:0] register_wd3;
  // данные, полученные в результате чтения из регистрового файла
  inout [31:0] register_rd1, register_rd2;

  // IMPLEMENTATION

  // pass pc to read instruction into instruction_memory_rd
  assign instruction_memory_a = pc;
  // pass data from rd2 to write to memory
  assign data_memory_wd = register_rd2;

  // consts
  wire [31:0] instruction;
  assign instruction = instruction_memory_rd;
  wire [31:0] calc_pc;
  wire [5:0] op, funct;
  wire [4:0] rs, rt, rd, shamt;
  wire [15:0] imm;
  wire [25:0] addr;
  wire [31:0] four;
  wire pc_src;
  wire [31:0] result;
  assign four = 32'd4;
  assign op = instruction[31:26];
  assign rs = instruction[25:21];
  assign rt = instruction[20:16];
  assign rd = instruction[15:11];
  assign shamt = instruction[10:6];
  assign funct = instruction[5:0];
  assign imm = instruction[15:0];
  assign addr = instruction[25:0];

  // control unit
  
  wire memto_reg;
  // wire mem_write; = data_memory_we
  wire [1:0] branch;
  wire alu_src;
  wire [1:0] reg_dst;
  // wire reg_write; = register_we3
  wire link;
  wire [2:0] alu_control;

  control_unit ctrl_unit(op, funct, memto_reg, data_memory_we, branch, alu_src, reg_dst, register_we3, link, alu_control);

  // PC

  wire [31:0] pc_plus_4, pc_plus_8;
  adder pc_add1(pc, four, pc_plus_4);
  adder pc_add2(pc_plus_4, four, pc_plus_8);
  mux2_32 pc_mux1(pc_plus_4, calc_pc, pc_src, pc_new);
  mux2_32 pc_mux2(result, pc_plus_8, link, register_wd3);

  // register file

  assign register_a1 = rs;
  assign register_a2 = rt;
  wire [4:0] r1;
  assign r1 = 5'b11111;
  mux4_5 rf_mux1(rt, rd, r1, r1, reg_dst, register_a3);
  
  wire [31:0] sign_imm;
  sign_extend rf_ext1(imm, sign_imm); // cast 16 bit const to 32 bit
  wire [31:0] moved_sign_imm;
  shl_2 rf_shift1(sign_imm, moved_sign_imm);
  wire [31:0] calc_branch_pc; // if const is for branch address
  adder rf_add1(moved_sign_imm, pc_plus_4, calc_branch_pc);

  wire [31:0] calc_jump_pc;
  assign calc_new_ps = {4'b0000, addr, 2'b00}; // if it j-type command
  
  mux2_32 rf_mux2(calc_branch_pc, calc_jump_pc, reg_dst[1], calc_pc); // choose which address to use

  // data memory

  wire [31:0] operand_a, operand_b;
  assign operand_a = register_rd1;
  mux2_32 dm_mux1(register_rd2, sign_imm, alu_src, operand_b);
  wire [31:0] alu_result;
  assign data_memory_a = alu_result;
  wire zero;
  alu_32 dm_alu(operand_a, operand_b, alu_control, alu_result, zero);
  assign pc_src = branch[1] & zero | branch[0] & (~zero);
  mux2_32 dm_mux2(alu_result, data_memory_rd, memto_reg, result);
  // TODO: delete initial begin ... end
  // initial begin
  //     $monitor("opcode=%b reg_write=%b reg_dst=%b link=%b alu_src=%b branch=%b mem_write=%b memto_reg=%b alu_control=%b", op, register_we3, reg_dst, link, alu_src, branch, data_memory_we, memto_reg, alu_control);
  // end
endmodule
