// модуль, который реализует расширенение
// 16-битной знаковой константы до 32-битной
module sign_extend(in, out);
  input [15:0] in;
  output [31:0] out;

  assign out = {{16{in[15]}}, in};
endmodule

// модуль, который реализует побитовый сдвиг числа
// влево на 2 бита
module shl_2(in, out);
  input [31:0] in;
  output [31:0] out;

  assign out = {in[29:0], 2'b00};
endmodule

// 32 битный сумматор
module adder(a, b, out);
  input [31:0] a, b;
  output [31:0] out;

  assign out = a + b;
endmodule

// 32-битный мультиплексор
module mux2_32(d0, d1, a, out);
  input [31:0] d0, d1;
  input a;
  output [31:0] out;
  assign out = a ? d1 : d0;
endmodule

module mux4_32(d0, d1, d2, d3, a, out);
  input [31:0] d0, d1, d2, d3;
  input [1:0] a;
  output [31:0] out;
  assign out = a[1] ? (a[0] ? d3 : d2) : (a[0] ? d1 : d0);
endmodule

module alu_32(a, b, control, out, zero);
  input [31:0] a, b;
  input [2:0] control;
  output [31:0] out;
  output zero;

  assign zero = (out == 0);
  wire [31:0] bb;
  mux2_32 mux1(b, ~b, control[2], bb);
  wire [31:0] sum;
  adder add1(a, bb, sum);
  mux4_32 mux2({31'b0, sum[31]}, sum, a | bb, a & bb, control[1:0], out);
endmodule

module mux4_5(d0, d1, d2, d3, a, out);
  input [4:0] d0, d1, d2, d3;
  input [1:0] a;
  output [4:0] out;
  assign out = a[1] ? (a[0] ? d3 : d2) : (a[0] ? d1 : d0);
endmodule

// 5 - битный мультиплексор
module mux2_5(d0, d1, a, out);
  input [4:0] d0, d1;
  input a;
  output [4:0] out;
  assign out = a ? d1 : d0;
endmodule
