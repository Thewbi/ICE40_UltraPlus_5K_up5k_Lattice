// light up the leds according to a counter to cycle through every one
// Source: https://github.com/damdoy/ice40_ultraplus_examples/blob/master/leds/leds.v
module top(
    /*input [3:0] SW,*/
    input clk,
    output LED_R, output LED_G, output LED_B,
	input RX,
  	output TX,
    output spi_cs
);

    assign spi_cs = 1; // it is necessary to turn off the SPI flash chip

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

    /* local parameters */
    //localparam clk_freq = 12_000_000; // 12MHz
    localparam clk_freq = 42_000_000; // 42MHz
    //localparam baud = 57600;
    localparam baud = 115200;

    /* instantiate the rx1 module */
    reg rx1_ready;
    reg [7:0] rx1_data;
    uart_rx #(clk_freq, baud) urx1 (
        .clk(clk_42mhz),
        .rx(RX),
        .rx_ready(rx1_ready),
        .rx_data(rx1_data),
    );

    /* instantiate the tx1 module */
    reg tx1_start;
    reg [7:0] tx1_data;
    reg tx1_busy;
    uart_tx #(clk_freq, baud) utx1 (
        .clk(clk_42mhz),
        .tx_start(tx1_start),
        .tx_data(tx1_data),
        .tx(TX),
        .tx_busy(tx1_busy)
    );

    // Send the received data immediately back

    reg [7:0] data_buf;
    reg data_flag = 0;
    reg data_check_busy = 0;
    always @(posedge clk_42mhz)
    begin
        // we got a new data strobe
        // let's save it and set a flag
        if (rx1_ready && ~data_flag)
        begin
            data_buf <= rx1_data;
            data_flag <= 1;
            data_check_busy <= 1;
        end
        // new data flag is set let's try to send it
        if (data_flag)
        begin
            // First check if the previous transmission is over
            if (data_check_busy)
            begin
                if (~tx1_busy)
                begin
                    data_check_busy <= 0;
                end
            end
            else
            begin // try to send waiting for busy to go high to make sure
                if (~tx1_busy)
                begin
                    tx1_data <= data_buf;
                    tx1_start <= 1'b1;
                    //LEDR_N <= ~data_buf[0];
                    //LEDG_N <= ~data_buf[1];
                end
                else
                begin // Yey we did it!
                    tx1_start <= 1'b0;
                    data_flag <= 0;
                end
            end
        end
    end

    // // Loopback the TX and RX lines with no processing
    // // Useful as a sanity check ;-)
    // assign TX = RX;

    //
    // LED Blinky
    //

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