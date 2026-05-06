module div #(
    parameter BUS_WIDTH=64,
    parameter ALU_CONTROL_WIDTH=2
)(
    input wire clk,
    input wire [(BUS_WIDTH - 1):0] in1,
    input wire [(BUS_WIDTH - 1):0] in2,

    /* 
       00 -> div (quotient) 
       01 -> divu (quotient - unsigned division) 
       10 -> rem (remainder) 
       11 -> remu (remainder - unsigned division) 
    */
    input wire [(ALU_CONTROL_WIDTH - 1):0] control,

    output reg [(BUS_WIDTH - 1):0] out
);

    wire [(BUS_WIDTH - 1):0] quotient_signed, quotient_unsigned;
    wire [(BUS_WIDTH - 1):0] remainder_signed, remainder_unsigned;
    
    wire[(2*BUS_WIDTH - 1):0] signed_out;
    wire[(2*BUS_WIDTH - 1):0] unsigned_out;

    if(BUS_WIDTH == 64) begin
        div_signed_gen div_signed_instance (
            .aclk(clk),
            .s_axis_divisor_tvalid(1'b1),
            .s_axis_divisor_tdata(in2),
            .s_axis_dividend_tvalid(1'b1),
            .s_axis_dividend_tdata(in1),
            .m_axis_dout_tdata(signed_out)
        );


        div_unsigned_gen div_unsigned_instance (
            .aclk(clk),
            .s_axis_divisor_tvalid(1'b1),
            .s_axis_divisor_tdata(in2),
            .s_axis_dividend_tvalid(1'b1),
            .s_axis_dividend_tdata(in1),
            .m_axis_dout_tdata(unsigned_out)
        );
    end
    else if(BUS_WIDTH == 32) begin
        div_signed32_gen div_signed_instance (
            .aclk(clk),
            .s_axis_divisor_tvalid(1'b1),
            .s_axis_divisor_tdata(in2),
            .s_axis_dividend_tvalid(1'b1),
            .s_axis_dividend_tdata(in1),
            .m_axis_dout_tdata(signed_out)
        );

        div_unsigned32_gen div_unsigned_instance (
            .aclk(clk),
            .s_axis_divisor_tvalid(1'b1),
            .s_axis_divisor_tdata(in2),
            .s_axis_dividend_tvalid(1'b1),
            .s_axis_dividend_tdata(in1),
            .m_axis_dout_tdata(unsigned_out)
        );
    end

    assign quotient_signed =  signed_out[(2*BUS_WIDTH - 1):(BUS_WIDTH)];
    assign remainder_signed = signed_out[(BUS_WIDTH - 1):0];
    
    assign quotient_unsigned =  unsigned_out[(2*BUS_WIDTH - 1):(BUS_WIDTH)];
    assign remainder_unsigned = unsigned_out[(BUS_WIDTH - 1):0];
    
    always @(*) begin
        case (control)
            // div
            2'b00: begin
                if(in2 == 0) out = {BUS_WIDTH{1'b1}};
                else out = quotient_signed;
            end

            // divu
            2'b01: begin
                if(in2 == 0) out = {BUS_WIDTH{1'b1}};
                else out = quotient_unsigned;
            end

            // rem
            2'b10: begin
                if(in2 == 0) out = in1;
                else out = remainder_signed;
            end

            // remu
            2'b11: begin
                if(in2 == 0) out = in1;
                else out = remainder_unsigned;
            end
            
            default: out = {BUS_WIDTH{1'b0}};
        endcase
    end
endmodule