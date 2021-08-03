`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2021 12:24:16 PM
// Design Name: 
// Module Name: VentingMachine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module VentingMachine(
        input clk,reset_n,p5,p10,p25,pitemTaken,
        output [7:0]AN,
        output DP,
        output [6:0]sseg,
        output r5,r10,r20,
        output R0,B0,G0
    );
    
    wire c5,c10,c25,item_taken,dispense;
    
    Keyboardlike_Button button1(
         .clk(clk),
         .in(p5),
         .out(c5)
    );
    
    Keyboardlike_Button button2(
         .clk(clk),
         .in(p10),
         .out(c10)
    );
     
    Keyboardlike_Button button3(
         .clk(clk),
         .in(p25),
         .out(c25)
    );
    
    Keyboardlike_Button button4(
         .clk(clk),
         .in(pitemTaken),
         .out(item_taken)
    );
    
    wire[3:0] current;
    
    VentingFSM_LessStates FSM(
         .c5(c5),
         .c10(c10),
         .c25(c25),
         .clk(clk),
         .reset_n(reset_n),
         .item_taken(item_taken),
         .r5(r5),
         .r10(r10),
         .r20(r20),
         .dispense(dispense),
         .current(current)
    );
    

    wire [11:0]BCDcur,BCDrm;    
    wire [8:0]rmpenny,penny;
    
    assign rmpenny = (current - 5) * 5;
    assign penny =  current * 5;
    
    bin2bcd b2brm(
      .binary ((dispense)? rmpenny : {8{1'b0}}),
      .BCD(BCDrm)
    );
    

    bin2bcd b2bcur(
     .binary(penny),
     .BCD(BCDcur)
    );
    
    assign B0 = 1'b0;
    assign R0 = ~dispense;
    assign G0 = dispense;
    
    sseg_driver #(.DesiredHz(10000),.ClockHz(100_000_000)) driver
    (
         .clk(clk),
         .reset_n(reset_n),
         .i0({1'b1,BCDcur[3:0],1'b1}),
         .i1({1'b1,BCDcur[7:4],1'b1}),
         .i2({1'b1,BCDcur[11:8],1'b1}),
         .i3('b0),
         .i4({1'b1,BCDrm[3:0],1'b1}),
         .i5({1'b1,BCDrm[7:4],1'b1}),
         .i6({1'b1,BCDrm[11:8],1'b1}),
         .i7('b0),         //numbers
         .AN(AN),                             //seven-segment selector output
         .DP(DP),
         .sseg(sseg)
    );
    
    

endmodule
