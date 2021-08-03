`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2021 01:24:54 PM
// Design Name: 
// Module Name: VentingFSM_LessStates
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


module VentingFSM_LessStates(
        input c5,c10,c25,
        input clk,reset_n,
        input item_taken,
        output r5,r10,r20,
        output dispense,
        output [3:0]current
    );
    
    localparam s0 = 0, s1=1,s2=2,s3=3,s4=4,s5=5,s6=6;
    
    reg[3:0] state_next,state_reg;
    
    always@(posedge clk,negedge reset_n) begin
        if(~reset_n)
            state_reg = s0;
        else
            state_reg = state_next;
    end
    
    reg [3:0] x = 4'dx;
    wire [3:0] y;
    
    wire add5 = (state_reg == s3);
    wire add10 = (state_reg == s2);
    wire add25 = (state_reg == s1);
    always@(*) begin
        x = 4'd0;
        casex({add5,add10,add25})
            3'b100: x = 4'd1;
            3'b010: x = 4'd2;
            3'b001: x = 4'd5;
            default: x = 4'd0;
        endcase        
    end
    
    wire selfReset;    
    assign selfReset = (state_reg == s6);         
    accumulator_generic #(4) bank(
         .x(x),
         .op_set(0),
         .reset_n(reset_n&(~selfReset)),
         .clk(clk), 
         .load(add5 ^ add10 ^ add25),
         .y(y)
    );    
    
    

    
    always@(*) begin
        case(state_reg)
            s0: case({c5,c10,c25})
                    3'b100: state_next = s3;
                    3'b010: state_next = s2;
                    3'b001: state_next = s1;
                    default: state_next = s0;
                endcase     
            s1,s2,s3: state_next = s4;
            s4: state_next = (y >= 5) ? s5 : s0;
            s5: state_next = (item_taken) ? s6 : s5;
            s6: state_next = s0;       
        endcase    
    end
    
    wire[3:0] rm;
    assign rm = (dispense) ? y - 5 : 0;
    assign r20 = rm[2];
    assign r10 = rm[1];
    assign r5 = rm[0];
    assign dispense = (state_reg == s5);
    assign current = y;
    
endmodule
