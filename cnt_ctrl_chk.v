// Test case for counter control modes (100% Verilog-2001 compatible)
task run_test();
    reg [31:0] read_val_lo, read_val_hi;
    reg [63:0] count_before, count_after, count_delta;
    integer    ticks_to_wait;
    integer    i;
    reg [63:0] last_count_val;
begin
    $display("\n\n--- Starting Test: Counter Control with Division (Robust) ---");

    $display("\n[SCENARIO] Testing with div_val = 4. Waiting for 10 counter ticks.");
    
    // 1. Reset and configure timer
    timer_reg_write(TCR_OFFSET, 0);
    timer_reg_write(TDR0_OFFSET, 0);
    timer_reg_write(TDR1_OFFSET, 0);
    timer_reg_write(TCR_OFFSET, (4 << 8) | 3); // div_val=4, div_en=1, timer_en=1
    
    // 2. Read initial value
    timer_reg_read(TDR0_OFFSET, read_val_lo);
    timer_reg_read(TDR1_OFFSET, read_val_hi);
    count_before = {read_val_hi, read_val_lo};
    last_count_val = count_before;
    
    // 3. Wait for the counter to increment exactly 10 times
    ticks_to_wait = 10;
    for (i = 0; i < ticks_to_wait; i = i + 1) begin
        // Pure Verilog equivalent of @(posedge clk iff condition)
        while (u_timer.count2reg == last_count_val) begin
            @(posedge clk);
        end
        last_count_val = u_timer.count2reg;
        $display("[INFO] Tick %0d/%0d detected. Counter value: %0d", i+1, ticks_to_wait, last_count_val);
    end
    
    // 4. Stop timer and read final value
    timer_reg_write(TCR_OFFSET, 0);
    count_after = last_count_val; // We already have the last value

    // 5. Check if the delta is exactly the number of ticks we waited for
    count_delta = count_after - count_before;
    check_value(count_delta, ticks_to_wait, "Check number of increments in division mode");

    if (g_error_count == 0) $display("--- TEST PASSED ---");
    else $display("--- TEST FAILED ---");
end
endtask
