module TrafficLightController(
    input wire clk,            // کلاک برای تغییر حالت‌ها
    input wire reset,          // سیگنال ریست برای بازنشانی به حالت اولیه
    input wire traffic_A,      // ترافیک در Academic Ave
    input wire traffic_B,      // ترافیک در Bravado Blvd
    output reg [1:0] LA,       // خروجی چراغ Academic (00 = قرمز، 01 = زرد، 10 = سبز)
    output reg [1:0] LB        // خروجی چراغ Bravado (00 = قرمز، 01 = زرد، 10 = سبز)
);

    // تعریف حالات به صورت مقادیر عددی
    parameter S0 = 2'b00;  // Academic: سبز، Bravado: قرمز
    parameter S1 = 2'b01;  // Academic: زرد، Bravado: قرمز
    parameter S2 = 2'b10;  // Academic: قرمز، Bravado: سبز
    parameter S3 = 2'b11;  // Academic: قرمز، Bravado: زرد

    reg [1:0] state, next_state;
    integer yellow_timer;

    // تنظیم حالت اولیه در زمان ریست
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            yellow_timer <= 0;
        end else begin
            state <= next_state;
        end
    end

    // منطق انتقال حالات و تعیین خروجی چراغ‌ها
    always @(*) begin
        case (state)
            S0: begin
                LA = 2'b10; // Academic: سبز
                LB = 2'b00; // Bravado: قرمز
                if (!traffic_A)  // اگر ترافیک در Academic وجود ندارد
                    next_state = S1;
                else
                    next_state = S0;
            end
            
            S1: begin
                LA = 2'b01; // Academic: زرد
                LB = 2'b00; // Bravado: قرمز
                if (yellow_timer >= 5)  // بعد از 5 ثانیه
                    next_state = S2;
                else
                    next_state = S1;
            end
            
            S2: begin
                LA = 2'b00; // Academic: قرمز
                LB = 2'b10; // Bravado: سبز
                if (!traffic_B)  // اگر ترافیک در Bravado وجود ندارد
                    next_state = S3;
                else
                    next_state = S2;
            end
            
            S3: begin
                LA = 2'b00; // Academic: قرمز
                LB = 2'b01; // Bravado: زرد
                if (yellow_timer >= 5)  // بعد از 5 ثانیه
                    next_state = S0;
                else
                    next_state = S3;
            end
        endcase
    end

    // تایمر برای حالت‌های زرد
    always @(posedge clk) begin
        if (state == S1 || state == S3) begin
            yellow_timer <= yellow_timer + 1;
        end else begin
            yellow_timer <= 0;
        end
    end

endmodule
