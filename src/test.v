module TrafficLightController_tb;

    // ورودی‌ها به عنوان رجیستر تعریف می‌شوند
    reg clk;
    reg reset;
    reg traffic_A;
    reg traffic_B;

    // خروجی‌ها به عنوان wire تعریف می‌شوند
    wire [1:0] LA;
    wire [1:0] LB;

    // نمونه‌سازی از ماژول اصلی
    TrafficLightController uut (
        .clk(clk),
        .reset(reset),
        .traffic_A(traffic_A),
        .traffic_B(traffic_B),
        .LA(LA),
        .LB(LB)
    );

    // تولید کلاک با پریود 10 واحد زمانی
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // تست اولیه برای ریست و شروع چرخه چراغ‌ها
    initial begin
        // اعمال سیگنال ریست
        reset = 1;
        traffic_A = 1;  // فرض می‌کنیم ابتدا ترافیک در Academic وجود دارد
        traffic_B = 0;
        #10;
        reset = 0;
        
        // نمایش حالت‌ها در زمان‌های مختلف
        #50 traffic_A = 0; // بعد از مدتی، ترافیک در Academic کم می‌شود
        #100 traffic_B = 1; // ترافیک در Bravado افزایش می‌یابد
        #50 traffic_B = 0;  // ترافیک در Bravado کم می‌شود
        #200 $stop;         // پایان شبیه‌سازی
    end

    // نمایش خروجی چراغ‌ها در کنسول
    initial begin
        $monitor("Time=%0d : LA=%b, LB=%b", $time, LA, LB);
    end

endmodule
