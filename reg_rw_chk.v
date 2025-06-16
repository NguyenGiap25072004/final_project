task run_test();
    reg [31:0] read_val;
begin
    $display("\n\n--- Starting Test: Comprehensive Register R/W Check ---");

    // === SCENARIO 1: Walking 1s test on TCMP0 ===
    $display("\n[SCENARIO] Walking 1s test on TCMP0");
    foreach (i from 0 to 31) begin
        timer_reg_write(TCMP0_OFFSET, 1 << i);
        timer_reg_read(TCMP0_OFFSET, read_val);
        check_value(read_val, 1 << i, $sformatf("Walking 1s on TCMP0, bit %0d", i));
    end

    // === SCENARIO 2: Test R/W bits of TCR ===
    $display("\n[SCENARIO] Testing TCR writable bits");
    timer_reg_write(TCR_OFFSET, 32'h0000_0803); // div_val=8, div_en=1, timer_en=1
    timer_reg_read(TCR_OFFSET, read_val);
    check_value(read_val, 32'h0000_0803, "Check R/W for TCR bits");

    // === SCENARIO 3: Test invalid div_val write protection ===
    $display("\n[SCENARIO] Testing invalid div_val write protection");
    timer_reg_write(TCR_OFFSET, 32'h0000_0F03); // Attempt to write invalid div_val=15
    timer_reg_read(TCR_OFFSET, read_val);
    check_value(read_val, 32'h0000_0803, "Check div_val remains unchanged after invalid write");

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask
