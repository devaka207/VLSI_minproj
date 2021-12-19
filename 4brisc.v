module RISC_4bit (
    input wire clk,
    input wire reset,
    input wire [3:0] instruction,
    output wire [3:0] result
);

// Registers
reg [3:0] pc;           // Program Counter
reg [3:0] ir;           // Instruction Register
reg [3:0] regfile [0:3]; // 4 registers

// ALU signals
reg [3:0] alu_out;
reg zero;

// Control signals
reg reg_write;
reg alu_op;

// Fetch stage
always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 4'b0000;
    else
        pc <= pc + 4'b0001;
    
    ir <= instruction;
end

// Decode and execute stage
always @(posedge clk or posedge reset) begin
    if (reset) begin
        reg_write <= 0;
        alu_op <= 0;
    end
    else begin
        case (ir[3:2])
            2'b00: begin // ADD
                reg_write <= 1;
                alu_op <= 0;
            end
            2'b01: begin // SUB
                reg_write <= 1;
                alu_op <= 1;
            end
            2'b10: begin // AND
                reg_write <= 1;
                alu_op <= 2;
            end
            2'b11: begin // OR
                reg_write <= 1;
                alu_op <= 3;
            end
            default: begin
                reg_write <= 0;
                alu_op <= 0;
            end
        endcase
    end
end

// ALU
always @(posedge clk or posedge reset) begin
    if (reset)
        zero <= 0;
    else
        zero <= (alu_out == 4'b0000);
    
    case (alu_op)
        2'b00: alu_out <= regfile[ir[1:0]] + regfile[ir[3:2]];
        2'b01: alu_out <= regfile[ir[1:0]] - regfile[ir[3:2]];
        2'b10: alu_out <= regfile[ir[1:0]] & regfile[ir[3:2]];
        2'b11: alu_out <= regfile[ir[1:0]] | regfile[ir[3:2]];
        default: alu_out <= 4'b0000;
    endcase
end

// Write-back stage
always @(posedge clk or posedge reset) begin
    if (reset)
        regfile[0] <= 4'b0000;
    else if (reg_write)
        regfile[ir[3:2]] <= alu_out;
end

assign result = regfile[0];

endmodule
