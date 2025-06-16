task run_test();
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] count_before, count_after;
begin
    $display("\n\n--- Starting Test: Comprehensive Debug Mode Check ---");

    // === SCENARIO 1: Halt and Resume ===
    $display("\n[SCENARIO] Verifying counter halt and resume");
    timer_reg_write(TCR_OFFSET, 1); // Enable timer
    #(100 * CLK_PERIOD);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    count_before = {32'b0, read_val_lo};
    
    $display("[INFO] Activating debug mode...");
    dbg_mode = 1;
    #(100 * CLK_PERIOD);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    count_after = {32'b0, read_val_lo};
    check_value(count_after, count_before, "Check counter is frozen during debug mode");
    
    $display("[INFO] De-activating debug mode...");
    dbg_mode = 0;
    #(100 * CLK_PERIOD);
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    count_after = {32'b0, read_val_lo};
    if (count_after > count_before) $display("[CHECK PASSED] Counter resumed.");
    else begin $display("[CHECK FAILED] Counter did not resume."); g_error_count=1; end
    
    // === SCENARIO 2: Interrupt assertion during debug ===
    $display("\n[SCENARIO] Verifying interrupt triggers during debug mode");
    timer_reg_write(TCMP0_OFFSET, count_after + 50);
    timer_reg_write(TIER_OFFSET, 1);
    dbg_mode = 1; // Enter debug mode BEFORE interrupt condition is met
    timer_reg_write(TDR0_OFFSET, count_after + 50); // Manually write to trigger match
    
    timer_reg_read(TISR_OFFSET, read_val);
    check_value(read_val[0], 1, "Check interrupt status bit is set even in debug mode");
    
    #1;
    if(tim_int === 1'b1) $display("[CHECK PASSED] Interrupt pin is active as TIER is enabled.");
    else begin $display("[CHECK FAILED] Interrupt pin not active."); g_error_count=1; end
    
    timer_reg_write(TCR_OFFSET, 0); dbg_mode=0;

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask
