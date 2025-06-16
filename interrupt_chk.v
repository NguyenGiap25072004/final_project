task run_test();
    reg [31:0] read_val;
begin
    $display("\n\n--- Starting Test: Comprehensive Interrupt Check ---");

    // === SCENARIO 1: Assertion, W1C Logic, and Masking ===
    $display("\n[SCENARIO] Testing assertion, W1C, and masking");
    timer_reg_write(TCMP0_OFFSET, 100);
    timer_reg_write(TIER_OFFSET, 1);
    timer_reg_write(TCR_OFFSET, 1);
    wait(tim_int === 1'b1);
    $display("[CHECK PASSED] Interrupt asserted.");
    
    $display("[INFO] Attempting to clear TISR by writing 0 (should fail)");
    timer_reg_write(TISR_OFFSET, 0);
    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val[0], 1, "Check TISR[0] remains 1 after writing 0");

    $display("[INFO] Masking interrupt by clearing TIER[0]");
    timer_reg_write(TIER_OFFSET, 0); #1;
    if(tim_int === 1'b0) $display("[CHECK PASSED] Interrupt is masked."); else g_error_count=1;

    $display("[INFO] Un-masking interrupt");
    timer_reg_write(TIER_OFFSET, 1); #1;
    if(tim_int === 1'b1) $display("[CHECK PASSED] Interrupt is re-asserted."); else g_error_count=1;
    
    $display("[INFO] Clearing interrupt by writing 1 to TISR[0]");
    timer_reg_write(TISR_OFFSET, 1); #1;
    if(tim_int === 1'b0) $display("[CHECK PASSED] Interrupt is cleared by W1C."); else g_error_count=1;
    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val[0], 0, "Check TISR[0] is cleared");
    
    // === SCENARIO 2: Multiple Interrupts ===
    $display("\n[SCENARIO] Testing multiple interrupts in sequence");
    timer_reg_write(TCMP0_OFFSET, 200); // Set new compare value
    wait(tim_int === 1'b1);
    $display("[CHECK PASSED] Second interrupt asserted correctly.");
    timer_reg_write(TISR_OFFSET, 1); // Clear it
    timer_reg_write(TCR_OFFSET, 0); // Stop timer
    
    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask
