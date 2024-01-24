module main_decoder(opcode, memto_reg, mem_write, branch, alu_src, reg_dst, reg_write, link, alu_op);
    input [5:0] opcode;
    output memto_reg;
    output mem_write;
    output [1:0] branch;
    output alu_src;
    output [1:0] reg_dst;
    output reg_write;
    output link;
    output [1:0] alu_op;

    wire a, b, c, d, e, f;
    assign a = opcode[5];
    assign b = opcode[4];
    assign c = opcode[3];
    assign d = opcode[2];
    assign e = opcode[1];
    assign f = opcode[0];
    wire not_a, not_b, not_c, not_d, not_e, not_f;
    assign not_a = ~a;
    assign not_b = ~b;
    assign not_c = ~c;
    assign not_d = ~d;
    assign not_e = ~e;
    assign not_f = ~f;

    // RegWrite
    assign reg_write = not_b & (not_c & not_d & (not_a & not_e & not_f | e & f) | not_a & c & not_e & not_f);
    // RegDst
    wire reg_dst_buffer;
    assign reg_dst_buffer = not_a & not_b & not_c & not_d;
    assign reg_dst[1] = reg_dst_buffer & e;
    assign reg_dst[0] = reg_dst_buffer & not_e & not_f;
    // Link
    assign link = reg_dst[1] & f;
    // ALUSrc
    assign alu_src = not_b & (a & not_d & e & f | not_a & c & not_e & not_f);
    // Branch
    wire [2:0] branch_buffer;
    assign branch_buffer[2] = not_d & e;
    assign branch_buffer[1] = d & not_e;
    assign branch_buffer[0] = not_a & not_b & not_c;
    assign branch[1] = branch_buffer[0] & (branch_buffer[1] & not_f | branch_buffer[2]);
    assign branch[0] = branch_buffer[0] & (branch_buffer[1] & f | branch_buffer[2]);
    // MemWrite & MemtoReg
    wire mem_buffer;
    assign mem_buffer = a & not_b & not_d & e & f;
    assign mem_write = mem_buffer & c;
    assign memto_reg = mem_buffer & not_c;
    // ALUOp
    assign alu_buffer = not_a & not_b & not_e;
    assign alu_op[1] = alu_buffer & not_f & (not_c & not_d | c & d);
    assign alu_op[0] = alu_buffer & d & (not_f | not_c);
endmodule

module alu_decoder(funct, alu_op, alu_control);
    input [5:0] funct;
    input [1:0] alu_op;
    output [2:0] alu_control;
    wire x, y, a, b, c, d, e, f;
    assign x = alu_op[1];
    assign y = alu_op[0];
    assign a = funct[5];
    assign b = funct[4];
    assign c = funct[3];
    assign d = funct[2];
    assign e = funct[1];
    assign f = funct[0];
    wire not_x, not_y, not_a, not_b, not_c, not_d, not_e, not_f;
    assign not_x = ~x;
    assign not_y = ~y;
    assign not_a = ~a;
    assign not_b = ~b;
    assign not_c = ~c;
    assign not_d = ~d;
    assign not_e = ~e;
    assign not_f = ~f;

    assign alu_control[2] = not_x & y | x & not_y & a & not_b & not_d & e & not_f;
    assign alu_control[1] = not_x | x & not_y & a & not_b & not_d & not_f & (not_c | e);
    assign alu_control[0] = x & not_y & a & not_b & (not_c & d & not_e & f | c & not_d & e & not_f);
endmodule

module control_unit(opcode, funct, memto_reg, mem_write, branch, alu_src, reg_dst, reg_write, link, alu_control);
    input [5:0] opcode, funct;
    output memto_reg;
    output mem_write;
    output [1:0] branch;
    output alu_src;
    output [1:0] reg_dst;
    output reg_write;
    output link;
    output [2:0] alu_control;

    wire [1:0] alu_op;

    main_decoder m_d(opcode, memto_reg, mem_write, branch, alu_src, reg_dst, reg_write, link, alu_op);
    alu_decoder a_d(funct, alu_op, alu_control);
endmodule