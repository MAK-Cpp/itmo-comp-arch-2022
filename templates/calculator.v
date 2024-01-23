//-----------------[ gates ]------------------//

module not_gate(in, out);
  input in;
  output out;

  supply1 vdd;
  supply0 gnd;

  pmos pmos1(out, vdd, in);
  nmos nmos1(out, gnd, in);
endmodule

module nand_gate(in1, in2, out);
  input in1;
  input in2;
  output out;

  supply0 gnd;
  supply1 pwr;

  wire nmos1_out;

  pmos pmos1(out, pwr, in1);
  pmos pmos2(out, pwr, in2);
  nmos nmos1(nmos1_out, gnd, in1);
  nmos nmos2(out, nmos1_out, in2);
endmodule

module nor_gate(in1, in2, out);
  input in1;
  input in2;
  output out;

  supply0 gnd;
  supply1 pwr;

  wire pmos1_out;

  pmos pmos1(pmos1_out, pwr, in1);
  pmos pmos2(out, pmos1_out, in2);
  nmos nmos1(out, gnd, in1);
  nmos nmos2(out, gnd, in2);
endmodule

module and_gate(in1, in2, out);
  input in1;
  input in2;
  output out;

  wire nand_out;

  nand_gate nand_gate1(in1, in2, nand_out);
  not_gate not_gate1(nand_out, out);
endmodule

module or_gate(in1, in2, out);
  input in1;
  input in2;
  output out;

  wire nor_out;

  nor_gate nor_gate1(in1, in2, nor_out);
  not_gate not_gate1(nor_out, out);
endmodule

module xor_gate(in1, in2, out);
  input in1;
  input in2;
  output out;

  wire not_in1;
  wire not_in2;
  wire and_out1;
  wire and_out2;
  wire or_out1;

  not_gate not_gate1(in1, not_in1);
  not_gate not_gate2(in2, not_in2);
  and_gate and_gate1(in1, not_in2, and_out1);
  and_gate and_gate2(not_in1, in2, and_out2);
  or_gate or_gate1(and_out1, and_out2, out);
endmodule

module binary_multiplexer_gate(zero_in, one_in, f, out);
  input zero_in;
  input one_in;
  input f;
  output out;

  pmos pmos1(out, zero_in, f);
  nmos nmos1(out, one_in, f);
endmodule

module two_to_four_decoder(f, out);
  input [1:0] f;
  output [3:0] out;

  wire [1:0] not_f;

  not_gate not1(f[0], not_f[0]);
  not_gate not2(f[1], not_f[1]);

  nor_gate nor1(f[0], f[1], out[0]);
  and_gate and1(f[0], not_f[1], out[1]);
  and_gate and2(not_f[0], f[1], out[2]);
  and_gate and3(f[0], f[1], out[3]);
endmodule

module quaternary_multiplexer_gate(a, b, c, d, f, out);
  input a; // 00
  input b; // 01
  input c; // 10
  input d; // 11
  input [1:0] f;
  output out;

  wire [3:0] decoded_f;
  two_to_four_decoder decode(f, decoded_f);

  wire [3:0] ands;
  and_gate and1(a, decoded_f[0], ands[0]);
  and_gate and2(b, decoded_f[1], ands[1]);
  and_gate and3(c, decoded_f[2], ands[2]);
  and_gate and4(d, decoded_f[3], ands[3]);

  wire [1:0] ors;
  or_gate or1(ands[0], ands[1], ors[0]);
  or_gate or2(ors[0], ands[2], ors[1]);
  or_gate or3(ors[1], ands[3], out);
endmodule

module full_summator_gate(c_in, a, b, c_out, s);
  input c_in;
  input a;
  input b;
  output c_out;
  output s;

  wire a_xor_b;
  wire a_and_b;
  wire a_and_c_in;
  wire b_and_c_in;
  wire or_res;

  xor_gate xor_gate1(a, b, a_xor_b);
  xor_gate xor_gate2(a_xor_b, c_in, s);

  and_gate and_gate1(a, b, a_and_b);
  and_gate and_gate2(a, c_in, a_and_c_in);
  and_gate and_gate3(b, c_in, b_and_c_in);
  or_gate or_gate1(a_and_b, a_and_c_in, or_res);
  or_gate or_gate2(or_res, b_and_c_in, c_out);  
endmodule

//-----------------[ gates ]------------------//

module not_4(in, out);
  input [3:0] in;
  output [3:0] out;

  not_gate not_gate1(in[0], out[0]);
  not_gate not_gate2(in[1], out[1]);
  not_gate not_gate3(in[2], out[2]);
  not_gate not_gate4(in[3], out[3]);
endmodule

module and_4(a, b, out);
  input [3:0] a;
  input [3:0] b;
  output [3:0] out;

  and_gate and1(a[0], b[0], out[0]);
  and_gate and2(a[1], b[1], out[1]);
  and_gate and3(a[2], b[2], out[2]);
  and_gate and4(a[3], b[3], out[3]);
endmodule

module or_4(a, b, out);
  input [3:0] a;
  input [3:0] b;
  output [3:0] out;

  or_gate or1(a[0], b[0], out[0]);
  or_gate or2(a[1], b[1], out[1]);
  or_gate or3(a[2], b[2], out[2]);
  or_gate or4(a[3], b[3], out[3]);
endmodule

module binary_multiplexer_4(zero_in, one_in, f, out);
  input [3:0] zero_in;
  input [3:0] one_in;
  input f;
  output [3:0] out;

  binary_multiplexer_gate binary_multiplexer_gate1(zero_in[0], one_in[0], f, out[0]);
  binary_multiplexer_gate binary_multiplexer_gate2(zero_in[1], one_in[1], f, out[1]);
  binary_multiplexer_gate binary_multiplexer_gate3(zero_in[2], one_in[2], f, out[2]);
  binary_multiplexer_gate binary_multiplexer_gate4(zero_in[3], one_in[3], f, out[3]);
endmodule

module quaternary_multiplexer_4(a, b, c, d, f, out);
  input [3:0] a;
  input [3:0] b;
  input [3:0] c;
  input [3:0] d;
  input [1:0] f;
  output [3:0] out;

  quaternary_multiplexer_gate mult1(a[0], b[0], c[0], d[0], f, out[0]);
  quaternary_multiplexer_gate mult2(a[1], b[1], c[1], d[1], f, out[1]);
  quaternary_multiplexer_gate mult3(a[2], b[2], c[2], d[2], f, out[2]);
  quaternary_multiplexer_gate mult4(a[3], b[3], c[3], d[3], f, out[3]);
endmodule

module full_summator_4(c_in, a, b, c_out, s);
  input c_in;
  input [3:0] a;
  input [3:0] b;
  output c_out;
  output [3:0] s;

  wire [2:0] c_outs;

  full_summator_gate full_summator_gate1(c_in, a[0], b[0], c_outs[0], s[0]);
  full_summator_gate full_summator_gate2(c_outs[0], a[1], b[1], c_outs[1], s[1]);
  full_summator_gate full_summator_gate3(c_outs[1], a[2], b[2], c_outs[2], s[2]);
  full_summator_gate full_summator_gate4(c_outs[2], a[3], b[3], c_out, s[3]);
endmodule

module left_bit_shift(in, shamt, out);
  input [3:0] in;
  input[1:0] shamt;
  output [3:0] out;

  supply0 gnd;

  quaternary_multiplexer_gate mult1(in[3], in[2], in[1], in[0], shamt, out[3]);
  quaternary_multiplexer_gate mult2(in[2], in[1], in[0], gnd, shamt, out[2]);
  quaternary_multiplexer_gate mult3(in[1], in[0], gnd, gnd, shamt, out[1]);
  quaternary_multiplexer_gate mult4(in[0], gnd, gnd, gnd, shamt, out[0]);
endmodule

module right_bit_shift(in, shamt, out);
  input [3:0] in;
  input[1:0] shamt;
  output [3:0] out;

  supply0 gnd;

  quaternary_multiplexer_gate mult1(in[3], gnd, gnd, gnd, shamt, out[3]);
  quaternary_multiplexer_gate mult2(in[2], in[3], gnd, gnd, shamt, out[2]);
  quaternary_multiplexer_gate mult3(in[1], in[2], in[3], gnd, shamt, out[1]);
  quaternary_multiplexer_gate mult4(in[0], in[1], in[2], in[3], shamt, out[0]);
endmodule

module right_bit_shift_with_padding(in, shamt, out);
  input [3:0] in;
  input[1:0] shamt;
  output [3:0] out;

  quaternary_multiplexer_gate mult1(in[3], in[3], in[3], in[3], shamt, out[3]);
  quaternary_multiplexer_gate mult2(in[2], in[3], in[3], in[3], shamt, out[2]);
  quaternary_multiplexer_gate mult3(in[1], in[2], in[3], in[3], shamt, out[1]);
  quaternary_multiplexer_gate mult4(in[0], in[1], in[2], in[3], shamt, out[0]);
endmodule

module alu(a, b, control, res);
  input [3:0] a, b; // Операнды
  input [2:0] control; // Управляющие сигналы для выбора операции

  output [3:0] res; // Результат
  // TODO: implementation
  wire [3:0] not_b;
  not_4 not1(b, not_b);

  wire [3:0] choosen_b;
  binary_multiplexer_4 mult1(b, not_b, control[2], choosen_b);

  wire [3:0] ans_0;
  and_4 and1(a, choosen_b, ans_0);

  wire [3:0] ans_1;
  or_4 or1(a, choosen_b, ans_1);

  wire c_out;
  wire [3:0] ans_2;
  full_summator_4 summator1(control[2], a, choosen_b, c_out, ans_2);

  wire [3:0] ans_3;
  supply1 pwr;
  right_bit_shift shift1(ans_2, {pwr, pwr}, ans_3);

  quaternary_multiplexer_4 mult2(ans_0, ans_1, ans_2, ans_3, control[1:0], res);
endmodule

module d_latch(clk, d, we, q);
  input clk; // Сигнал синхронизации
  input d; // Бит для записи в ячейку
  input we; // Необходимо ли перезаписать содержимое ячейки

  output reg q; // Сама ячейка
  // Изначально в ячейке хранится 0
  initial begin
    q <= 0;
  end
  // Значение изменяется на переданное на спаде сигнала синхронизации
  always @ (negedge clk) begin
    if (we) begin
      q <= d;
    end
  end
endmodule

module register_file(clk, rd_addr, we_addr, we_data, rd_data);
  input clk; // Сигнал синхронизации
  input [1:0] rd_addr, we_addr; // Номера регистров для чтения и записи
  input [3:0] we_data; // Данные для записи в регистровый файл

  output [3:0] rd_data; // Данные, полученные в результате чтения из регистрового файла
  // TODO: implementation
endmodule

module calculator(clk, rd_addr, immediate, we_addr, control, rd_data);
  input clk; // Сигнал синхронизации
  input [1:0] rd_addr; // Номер регистра, из которого берется значение первого операнда
  input [3:0] immediate; // Целочисленная константа, выступающая вторым операндом
  input [1:0] we_addr; // Номер регистра, куда производится запись результата операции
  input [2:0] control; // Управляющие сигналы для выбора операции

  output [3:0] rd_data; // Данные из регистра c номером 'rd_addr', подающиеся на выход
  // TODO: implementation
endmodule
