task run_test();
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] count_before, count_after, count_delta;
begin
    $display("\n\n--- Starting Test: Comprehensive Counter Functionality Check ---");

    // === SCENARIO 1: timer_en toggling check ===
    $display("\n[SCENARIO] Rapidly toggling timer_en");
    timer_reg_write(TCR_OFFSET, 1); // Enable
    #(10 * CLK_PERIOD);
    timer_reg_write(TCR_OFFSET, 0); // Disable
    #(20 * CLK_PERIOD);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    check_value(read_val_lo, 10, "Check counter stops exactly at 10");

    // === SCENARIO 2: Overflow check ===
    $display("\n[SCENARIO] Testing counter overflow");
    timer_reg_write(TDR0_OFFSET, 32'hFFFF_FFFF);
    timer_reg_write(TDR1_OFFSET, 32'h0);
    timer_reg_write(TCR_OFFSET, 1); // Enable
    #(2 * CLK_PERIOD); // Wait for 2 increments
    timer_reg_write(TCR_OFFSET, 0); // Disable
    timer_reg_read(TDR1_OFFSET, read_val_hi);
    check_value(read_val_hi, 1, "Check TDR1 becomes 1 after TDR0 overflows");

    // === SCENARIO 3: Write while running ===
    $display("\n[SCENARIO] Overwriting counter value while it is running");
    timer_reg_write(TCR_OFFSET, 1); // Enable
    #(100 * CLK_PERIOD);
    timer_reg_write(TDR0_OFFSET, 5000); // Write new value
    #(10 * CLK_PERIOD);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    if (read_val_lo >= 5008 && read_val_lo <= 5012)
        $display("[CHECK PASSED] Counter correctly jumped to new value.");
    else begin
        $display("[CHECK FAILED] Counter did not jump correctly. Value: %d", read_val_lo);
        g_error_count = 1;
    end
    timer_reg_write(TCR_OFFSET, 0);

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask
