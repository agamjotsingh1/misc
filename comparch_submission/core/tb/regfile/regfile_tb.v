`timescale 1ns / 1ps

module regfile_tb;
    reg clk;
    reg write_enable;
    reg [5:0] read_addr1, read_addr2, write_addr;
    reg [63:0] write_data;
    wire [63:0] read_data1, read_data2;
    
    // Instantiate the register file
    regfile uut (
        .clk(clk),
        .write_enable(write_enable),
        .read_addr1(read_addr1),
        .read_data1(read_data1),
        .read_addr2(read_addr2),
        .read_data2(read_data2),
        .write_addr(write_addr),
        .write_data(write_data)
    );
    
    // Clock generation - 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        write_enable = 0;
        write_addr = 0;
        write_data = 0;
        read_addr1 = 0;
        read_addr2 = 0;
        
        $display("Starting regfile test...");
        
        @(posedge clk);
        
        // Write x1
        write_enable = 1;
        write_addr = 6'd1;
        write_data = 64'hAAAAAAAAAAAAAAAA;
        @(posedge clk);
        
        // Write x2
        write_addr = 6'd2;
        write_data = 64'h5555555555555555;
        @(posedge clk);
        
        // Write x3
        write_addr = 6'd3;
        write_data = 64'hDEADBEEFCAFEBABE;
        @(posedge clk);
        
        // Read x1, x2
        write_enable = 0;
        read_addr1 = 6'd1;
        read_addr2 = 6'd2;
        @(posedge clk);
        
        // Read x3, x0
        read_addr1 = 6'd3;
        read_addr2 = 6'd0;
        @(posedge clk);
        
        // Write x4, read x1
        write_enable = 1;
        write_addr = 6'd4;
        write_data = 64'h1234567890ABCDEF;
        read_addr1 = 6'd1;
        read_addr2 = 6'd4;
        @(posedge clk);
        
        // Read x4
        write_enable = 0;
        read_addr1 = 6'd4;
        @(posedge clk);
        
        // Try write x0
        write_enable = 1;
        write_addr = 6'd0;
        write_data = 64'hFFFFFFFFFFFFFFFF;
        read_addr1 = 6'd0;
        @(posedge clk);
        
        // Verify x0
        write_enable = 0;
        @(posedge clk);
        
        #20;
        $display("Test complete.");
        $finish;
    end
    
    // Waveform dump
    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars(0, regfile_tb);
    end
    
endmodule

