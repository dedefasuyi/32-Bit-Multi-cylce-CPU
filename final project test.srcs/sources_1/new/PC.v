`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Oluwademilade Fasuyi
// 
// Create Date: 04/18/2023 04:39:59 PM
// Design Name: 
// Module Name: PC
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


module sccomputer(clk,clrn,pc,inst,alu,memout);
    input clk,clrn;
    output [31:0] pc;
    output [31:0] inst;
    output [31:0] alu;
    output [31:0] memout;
    wire [31:0] inst;
    wire [31:0] pc;
    wire [31:0] alu;
    wire [31:0] memout;
    wire [31:0] data;
    wire wmem;
    
    CPU sccpu(clk,clrn,inst,memout,pc,wmem,alu,data);
    scinstmem inst_mem(pc,inst);
    scdatamem dmem(clk,dataout,datain,addr,we);
    
endmodule

module CPU(clk,clrn,inst,mem,pc,wmem,alu_out,data);
    
    input clk,clrn;         
    input [31:0] inst;      
    input [31:0] mem;       
    output [31:0] pc;       
    output [31:0] alu_out;  
    output [31:0] data;     
    output wmem;               
    
    wire [5:0] op = inst[31:26];
    wire [4:0] rs = inst[25:21];
    wire [4:0] rt = inst[20:16];
    wire [4:0] rd = inst[15:11];
    wire [5:0] func = inst[05:00];
    wire [15:0] imm = inst[15:00];
    wire [25:0] addr = inst[25:00];      
    
    wire [3:0] aluc;
    wire [1:0] pcsrc;
    wire wreg,regrt,m2reg,shift,aluimm,sext,z,jal; 
    
    wire [31:0] sa = {27'b0,inst[10:06]};
    wire [31:0] p4;  
    wire [31:0] nxpc,pc; 
    wire [31:0] write_data;
    wire [31:0] qa,qb;
    wire [31:0] alua;
    wire [31:0] imm_32;
    wire [31:0] alub;
    wire [31:0] alu_out;
    wire [31:0] imm_shift = {imm_32[29:0],2'b00};
    wire [31:0] branchOut;
    wire [31:0] jpc = {p4[31:28],addr,2'b00};
    wire [4:0] wn;
    wire [4:0] jal_datain;
    wire [31:0] mux_Writedata;
    
    program_counter pc_reg(nxpc,clk,clrn,pc);     
    
    adder pc_add(pc,p4);
    
    control cntrol_reg(op,func,aluc,regrt,pcsrc,wreg,aluimm,wmem,m2reg,shift,z,sext,jal);  
    
    Mux_regfile muxToRegfile(rd,rt,regrt,jal_datain); 
    
    Mux_JalToWn muxToWn(jal_datain,jal,wn);     
    
    regfile registerfile(rs,rt,wn,write_data,wreg,qa,qb,clk);   
    
    Mux_Alua muxToAlua(qa,sa,shift,alua);      
    
    SignExtend signEx16to32(imm,sext,imm_32);   
        
    Mux_Alub muxToAlub(qb,imm_32,aluimm,alub);   
    
    ALU alu_reg(aluc,alua,alub,alu_out,z);        
    
    Mux_WData muxToData(alu_out,mem,m2reg,mux_Writedata);
    
    Mux_JalToWdata muxToWdata(mux_Writedata,p4,jal,write_data);
    
    branch_adder branch_add(p4,imm_shift,branchOut);    
    
    Mux4to1 mux4(p4,branchOut,qa,jpc,pcsrc,nxpc); 
    
    assign data = qb;   
endmodule

module program_counter(prPC,clk,clrn,pc);
    input [31:0] prPC;
    input clk;
    input clrn;
    output reg [31:0] pc;
    
    always@(posedge clk or posedge clrn)
    begin 
        if(clrn == 1)
            pc <= 0;
        else 
            pc <= prPC;
    end
endmodule

module adder(pc,p4);
    input [31:0]pc;
    output reg [31:0] p4;
    always@(*)begin
        p4 <= pc + 4;
        end
endmodule

module control(ALUOp,FuncCode,aluc,regrt,pcsrc,wreg,aluimm,wmem,m2reg,shift,z,sext,jal);
    input  [5:0] ALUOp;
    input  [5:0] FuncCode;
    input  z;
    output reg regrt, wreg,aluimm,wmem,m2reg,shift,sext,jal;
    output reg [3:0] aluc;
    output reg [1:0] pcsrc;
                 
always@(*)
begin
    case(ALUOp)
    6'b000000:begin
        case(FuncCode)
            6'b100000:begin    
                wreg <= 1;
                regrt <= 0;
                jal <= 0; 
                m2reg <= 0;
                shift <= 0;
                aluimm <= 0;
                sext <= 0;
                aluc <= 4'b0000;
                wmem <= 0;
                pcsrc <= 2'b00;
                
                        end
            6'b100010:begin      
                wreg <= 1;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 0;
                sext <= 0;
                aluc <= 4'b0100;  
                wmem <= 0; 
                pcsrc <= 2'b00; 
                        end 
            6'b100100:begin  
                wreg <= 1;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 0;
                sext <= 0;
                aluc <= 4'b0001; 
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
            6'b100101:begin    
                wreg <= 1;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 0; 
                sext <= 0;  
                aluc <= 4'b0101; 
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
            6'b100110:begin   
                wreg <= 1;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 0; 
                sext <= 0;
                aluc <= 4'b0010; 
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
            6'b000000:begin    
                wreg <= 1;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 1;
                aluimm <= 0;
                sext <= 0;        
                aluc <= 4'b0011;  
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
            6'b000010:begin    
                wreg <= 1;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 1;
                aluimm <= 0; 
                sext <= 0;
                aluc <= 4'b0111;  
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
            6'b000011:begin    
                wreg <= 1;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 1;
                aluimm <= 0; 
                sext <= 0;
                aluc <= 4'b1111;
                wmem <= 0;
                pcsrc <= 2'b00;       
                        end

             6'b001000:begin     
                        wreg <= 0;
                        regrt <= 0;
                        jal <= 0;
                        m2reg <= 0;
                        shift <= 0;
                        aluimm <= 0;
                        sext <= 0;
                        aluc <= 4'b0000;
                        wmem <= 0;
                        pcsrc <= 2'b10;
                                end 
           
        endcase
        end
    
            6'b001000:begin  
                wreg <= 1;
                regrt <= 1;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 1;
                sext <= 1;
                aluc <= 4'b0000;
                wmem <= 0;
                pcsrc <= 2'b00;    
                        end
    
            6'b001100:begin  
                wreg <= 1;
                regrt <= 1;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 1;
                sext <= 0;
                aluc <= 4'b0001;
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
    
            6'b001101:begin  
                wreg <= 1;
                regrt <= 1;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 1;
                sext <= 0;
                aluc <= 4'b0101;
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
    
            6'b001110:begin  
                wreg <= 1;
                regrt <= 1;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 1;
                sext <= 0;
                aluc <= 4'b0010;
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
    
            6'b100011:begin
                wreg <= 1;
                regrt <= 1;
                jal <= 0;
                m2reg <= 1;
                shift <= 0;
                aluimm <= 1;
                sext <= 1;
                aluc <= 4'b0000;
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
    
            6'b101011:begin 
                wreg <= 0;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 1;
                sext <= 1;
                aluc <= 4'b0000;
                wmem <= 1;
                pcsrc <= 2'b00;
                        end
    
            6'b000100:begin 
                wreg <= 0;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 0; 
                sext <= 1; 
                aluc <= 4'b0010; 
                wmem <= 0;
                case(z)
                    0:pcsrc <= 2'b00;
                    1:pcsrc <= 2'b01; 
                endcase
                        end
            6'b000101:begin 
                wreg <= 0;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 0;
                sext <= 1;
                aluc <= 4'b0010;
                wmem <= 0;
                case(z)
                    0:pcsrc <= 2'b01;
                    1:pcsrc <= 2'b00;
                endcase
                        end
                        
            6'b001111:begin 
                wreg <= 1;
                regrt <= 1;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 1;
                sext <= 0;
                aluc <= 4'b0110;
                wmem <= 0;
                pcsrc <= 2'b00;
                        end
    
            6'b000010:begin 
                wreg <= 0;
                regrt <= 0;
                jal <= 0;
                m2reg <= 0;
                shift <= 0;
                aluimm <= 0;
                sext <= 0;
                aluc <= 4'b0000;
                wmem <= 0;
                pcsrc <= 2'b11;
                        end
                        
            6'b000011:begin  
                 wreg <= 1;
                 regrt <= 0;
                 jal <= 1;
                 m2reg <= 0;
                 shift <= 0;
                 aluimm <= 0;
                 sext <= 0;
                 aluc <= 4'b0000;
                 wmem <= 0;
                 pcsrc <= 2'b11;
                       end
         
    endcase
end
endmodule

module Mux_regfile(rd,rt,sel,mux_out);
    input [4:0] rd;
    input [4:0] rt;
    input sel;
    output reg [4:0] mux_out;
    always@(*)begin
    case(sel)
        0:mux_out <= rd;
        1:mux_out <= rt;
        endcase
        end
endmodule

module Mux_JalToWn(mux_in,jal,mux_out);
input [4:0] mux_in;
input jal;
output reg [4:0] mux_out;
always@(*)begin
case(jal)
    0:mux_out <= mux_in;
    1:mux_out <= 5'b11111;
    endcase         
end  
endmodule

module regfile(rna,rnb,wn,d,we,qa,qb,clk);
 
 input   [31:0] d;  
 input   [4:0] rna;
 input   [4:0] rnb;
 input   [4:0] wn;  
 input    we; 
 input    clk;
 output [31:0] qa, qb; 
 reg    [31:0] RAM [0:31]; 

 initial begin
                   RAM[0] = 32'h00000000;
                   RAM[1] = 32'hA00000AA;
                   RAM[2] = 32'h10000011;
                   RAM[3] = 32'h20000022;
                   RAM[4] = 32'h30000033;
                   RAM[5] = 32'h40000044;
                   RAM[6] = 32'h50000055;
                   RAM[7] = 32'h60000066;
                   RAM[8] = 32'h70000077;
                   RAM[9] = 32'h80000088;
                   RAM[10] = 32'h90000099;
             end


 assign qa = (rna == 0)? 0 : RAM[rna]; 
 assign qb = (rna == 0)? 0 : RAM[rnb]; 
 
 always@(posedge clk)
 begin     
 if ((wn!= 0)&& we)   
    RAM[wn] <= d; 
 end       
endmodule

module Mux_Alua(qa,sa,sel,mux_out);
   input [31:0] qa;
   input [31:0] sa;
   input sel;
   output reg [31:0] mux_out;
   always@(*)begin
   case(sel)
        0:mux_out <= qa;
        1:mux_out <= sa;
        endcase         
   end  
endmodule

module SignExtend(immIn,sext,immOut);
    input [15:0] immIn;
    input sext;
    output reg [31:0] immOut;
    always@(*)begin
        case(sext)
            0:immOut <= {16'b0000000000000000,immIn[15:0]};
            1:immOut <= {{16{immIn[15]}},immIn[15:0]};
            endcase
            end
endmodule

module Mux_Alub(qb,imm,sel,mux_out);
   input [31:0] qb;
   input [31:0] imm;
   input sel;
   output reg [31:0] mux_out;
   always@(*)begin
   case(sel)
        0:mux_out <= qb;
        1:mux_out <= imm;
        endcase         
   end  
endmodule

module ALU(ALUctl,qa,qb,ALUOut,z);
input [3:0] ALUctl;
input [31:0] qa,qb;
output reg [31:0] ALUOut;
output z;
assign z = (ALUOut==0); 

always@(ALUctl,qa,qb)
begin
case(ALUctl)
    4'b0000:ALUOut <= qa + qb;      
    4'b0100:ALUOut <= qa - qb;      
    4'b0001:ALUOut <= qa & qb;     
    4'b0101:ALUOut <= qa | qb;      
    4'b0010:ALUOut <= qa ^ qb;    
    4'b0011:ALUOut <= qb << qa;    
    4'b0111:ALUOut <= qb >> qa;    
    4'b0110:ALUOut <= qb << 16;     
    default:ALUOut <= 0;
    
    endcase
    end
endmodule

module Mux_WData(aluOut,do,sel,write_data);
    input [31:0] aluOut;
    input [31:0] do;
    input sel;
    output reg [31:0] write_data;
always@(*)begin
case(sel)
     0:write_data <= aluOut;
     1:write_data <= do;
     endcase         
end  
endmodule

module Mux_JalToWdata(write_data,p4,jal,mux_dataout);
input [31:0] write_data;
input [31:0] p4;
input jal;
output reg [31:0] mux_dataout;
always@(*)begin
case(jal)
    0:mux_dataout <= write_data;
    1:mux_dataout <= p4;
    endcase         
end  
endmodule

module branch_adder(p4,imm,branchOut);
    input [31:0] p4;
    input [31:0] imm;
    output reg [31:0] branchOut;
    always@(*)begin
        branchOut <= p4 + imm;
        end 
endmodule

module Mux4to1(p4,bpc,qa,jpc,pcsrc,nextPC);
    input [31:0] p4;
    input [31:0] bpc;
    input [31:0] qa;
    input [31:0] jpc;
    input [1:0] pcsrc;
    output reg [31:0] nextPC;
    
    always@(*)begin
        case(pcsrc)
            2'b00: nextPC = p4;
            2'b01: nextPC = bpc;
            2'b10: nextPC = qa;
            2'b11: nextPC = jpc;
        endcase
     end
endmodule

module scinstmem(a,inst);
   input [31:0] a;
   output [31:0] inst;
   wire [31:0] ram [0:31];
   
   assign ram[5'h00] =  32'h3c010000;
   assign ram[5'h01] =  32'h34240050;  
   assign ram[5'h02] =  32'h20050004; 
   assign ram[5'h03] =  32'h0c000018;
   assign ram[5'h04] =  32'hac820000; 
   assign ram[5'h05] =  32'h8c890000;   
   assign ram[5'h06] =  32'h01244022;   
   assign ram[5'h07] =  32'h20050003; 
   assign ram[5'h08] =  32'h20a5ffff; 
   assign ram[5'h09] =  32'h34a8ffff;  
   assign ram[5'h0A] =  32'h39085555;  
   assign ram[5'h0B] =  32'h2009ffff;   
   assign ram[5'h0C] =  32'h312affff;   
   assign ram[5'h0D] =  32'h01493025; 
   assign ram[5'h0E] =  32'h01494026;  
   assign ram[5'h0F] =  32'h01463824;  
   assign ram[5'h10] =  32'h10a00001;     
   assign ram[5'h11] =  32'h08000008;     
   assign ram[5'h12] =  32'h2005ffff;     
   assign ram[5'h13] =  32'h000543c0;     
   assign ram[5'h14] =  32'h00084400;     
   assign ram[5'h15] =  32'h00084403;     
   assign ram[5'h16] =  32'h000843c2;     
   assign ram[5'h17] =  32'h08000017;     
   assign ram[5'h18] =  32'h00004020;     
   assign ram[5'h19] =  32'h8c890000;     
   assign ram[5'h1A] =  32'h20840004;     
   assign ram[5'h1B] =  32'h01094020;     
   assign ram[5'h1C] =  32'h20a5ffff;     
   assign ram[5'h1D] =  32'h14a0fffb;     
   assign ram[5'h1E] =  32'h00081000;     
   assign ram[5'h1F] =  32'h03e00008;   
   assign inst = ram[a[6:2]];
   endmodule

module scdatamem (clk,dataout,datain,addr,we); // data memory, ram
    input clk; // clock
    input we; // write enable
    input [31:0] datain; // data in (to memory)
    input [31:0] addr; // ram address
    output [31:0] dataout; // data out (from memory)
    reg [31:0] ram [0:31]; // ram cells: 32 words * 32 bits 
    assign dataout = ram[addr[6:2]]; // use word address to read ram
    always @ (posedge clk)
        if (we) ram[addr[6:2]] = datain; // use word address to write ram
    integer i;
    initial begin // initialize memory
        for (i = 0; i < 32; i = i + 1)
            ram[i] = 0;
        // ram[word_addr] = data // (byte_addr) 
        ram[5'h14] = 32'h000000a3; // (50hex) 
        ram[5'h15] = 32'h00000027; // (54hex) 
        ram[5'h16] = 32'h00000079; // (58hex) 
        ram[5'h17] = 32'h00000115; // (5chex) 
        // ram[5'h18] should be 0x00000258, the sum stored by sw instruction
    end
endmodule