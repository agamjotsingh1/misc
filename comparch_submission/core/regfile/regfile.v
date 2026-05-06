module regfile #(
	parameter BUS_WIDTH=64,
	parameter REGFILE_LEN=6
)(
	input wire clk,
	input wire write_enable,

	// read port #1
	input wire [(REGFILE_LEN - 1):0] read_addr1,  // address
	output wire [(BUS_WIDTH - 1):0] read_data1, // data

	// read port #2
	input wire [(REGFILE_LEN - 1):0] read_addr2,   // address
	output wire [(BUS_WIDTH - 1):0] read_data2, // data

	// write port
	input wire [(REGFILE_LEN - 1):0] write_addr,   // address
	input wire [(BUS_WIDTH - 1):0] write_data  // data
);
	// first 32 registers are x0, x1, x2 ... x31
	// next 32 registers are f0, f1, f2 ... f31
	reg [(BUS_WIDTH - 1):0] reg_array [(2**REGFILE_LEN - 1):0];
	
	always @(negedge clk) begin
		if(write_enable & write_addr != 0) begin
			reg_array[write_addr] <= write_data;
		end
		
		reg_array[0] <= {BUS_WIDTH{1'b0}};
	end

	assign read_data1 = (read_addr1 == 0) ? {BUS_WIDTH{1'b0}} : reg_array[read_addr1];
	assign read_data2 = (read_addr2 == 0) ? {BUS_WIDTH{1'b0}} : reg_array[read_addr2];
endmodule
