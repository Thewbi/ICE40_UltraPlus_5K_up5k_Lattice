// light up the leds according to a counter to cycle through every one
// Source: https://github.com/damdoy/ice40_ultraplus_examples/blob/master/leds/leds.v
module top(/*input [3:0] SW,*/ input clk, output LED_R, output LED_G, output LED_B);

    wire clk_42mhz;
    // assign clk_42mhz = CLK;

    // source: https://github.com/icebreaker-fpga/icebreaker-verilog-examples/blob/main/icebreaker/pll_uart/pll_uart_mirror.v
    SB_PLL40_PAD #(
        .DIVR(4'b0000),
        // 42MHz
        .DIVF(7'b0110111),
        .DIVQ(3'b100),
        .FILTER_RANGE(3'b001),
        .FEEDBACK_PATH("SIMPLE"),
        .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
        .FDA_FEEDBACK(4'b0000),
        .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
        .FDA_RELATIVE(4'b0000),
        .SHIFTREG_DIV_MODE(2'b00),
        .PLLOUT_SELECT("GENCLK"),
        .ENABLE_ICEGATE(1'b0)
    ) usb_pll_inst (
        .PACKAGEPIN(clk),
        .PLLOUTCORE(clk_42mhz),
        //.PLLOUTGLOBAL(),
        .EXTFEEDBACK(),
        .DYNAMICDELAY(),
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .LATCHINPUTVALUE(),
        //.LOCK(),
        //.SDI(),
        //.SDO(),
        //.SCLK()
    );

    reg [25:0] counter;

    assign LED_R = ~counter[23];
    assign LED_G = ~counter[24];
    assign LED_B = ~counter[25];

    initial begin
        counter = 0;
    end

    //always @(posedge clk)
    always @(posedge clk_42mhz)
    begin
        counter <= counter + 1;
    end

endmodule // top