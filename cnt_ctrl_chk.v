task run_test();
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] count_before, count_after, count_delta, expected_delta;
begin
    $display("\n\n--- Starting Test: Comprehensive Counting Mode Check ---");
    
    // === SCENARIO 1: On-the-fly mode switching ===
    $display("\n[SCENARIO] Switching counting mode while timer is running");
    timer_reg_write(TDR0_OFFSET, 0); timer_reg_write(TDR1_OFFSET, 0);
    timer_reg_write(TCR_OFFSET, 1); // Start in normal mode
    #(100 * CLK_PERIOD);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    count_before = {32'b0, read_val_lo};
    check_value(count_before, 100, "Check count in normal mode is correct");

    $display("[INFO] Switching to division mode (div_val=4, div by 16)");
    timer_reg_write(TCR_OFFSET, (4 << 8) | 3); // Switch to div_en=1, div_val=4
    #(160 * CLK_PERIOD);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    count_after = {32'b0, read_val_lo};
    count_delta = count_after - count_before;
    expected_delta = 160 / 16;
    check_value(count_delta, expected_delta, "Check count delta after switching to division mode");

    // === SCENARIO 2: On-the-fly div_val change ===
    $display("\n[SCENARIO] Changing div_val while in division mode");
    $display("[INFO] Changing division from div by 16 to div by 2 (div_val=1)");
    timer_reg_write(TCR_OFFSET, (1 << 8) | 3); // Change div_val to 1
    count_before = count_after;
    #(100 * CLK_PERIOD);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    count_after = {32'b0, read_val_lo};
    count_delta = count_after - count_before;
    expected_delta = 100 / 2;
    check_value(count_delta, expected_delta, "Check count delta after changing div_val");
    
    timer_reg_write(TCR_OFFSET, 0);

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask
