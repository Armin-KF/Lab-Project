`timescale 1ns / 1ps
`include "TrafficLightController.v"  // اطمینان از وجود ماژول TrafficLightController

module TrafficLightController_tb();

    // سیگنال‌های ورودی
    reg clk;                     // سیگنال کلاک
    reg reset;                   // سیگنال ریست
    reg traffic_A;               // سیگنال ترافیک از مسیر A
    reg traffic_B;               // سیگنال ترافیک از مسیر B
    wire [1:0] LA;               // خروجی چراغ مسیر A
    wire [1:0] LB;               // خروجی چراغ مسیر B

    // نمونه‌ای از ماژول TrafficLightController
    TrafficLightController UUT (
        .clk(clk),
        .reset(reset),
        .traffic_A(traffic_A),
        .traffic_B(traffic_B),
        .LA(LA),
        .LB(LB)
    );

    // تولید سیگنال کلاک
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // کلاک با دوره 10 نانوثانیه
    end

    initial begin
        // پیکربندی برای ثبت سیگنال‌ها در GTKWave
        $dumpfile("TrafficLightController_tb.vcd");
        $dumpvars(0, TrafficLightController_tb);

        // تنظیمات اولیه
        reset = 1;               // فعال کردن ریست
        traffic_A = 0;           // ترافیک مسیر A غیرفعال
        traffic_B = 0;           // ترافیک مسیر B غیرفعال
        #10;

        reset = 0;               // غیرفعال کردن ریست
        #10;

        // سناریوی 1: ترافیک در مسیر A وجود دارد
        traffic_A = 1;           // ترافیک مسیر A فعال
        #50;                     // انتظار برای تغییر وضعیت چراغ

        // سناریوی 2: ترافیک در مسیر B وجود دارد
        traffic_A = 0;           // غیرفعال کردن ترافیک مسیر A
        traffic_B = 1;           // فعال کردن ترافیک مسیر B
        #50;                     // انتظار برای تغییر وضعیت چراغ

        // سناریوی 3: هیچ ترافیکی وجود ندارد
        traffic_B = 0;           // غیرفعال کردن ترافیک مسیر B
        #50;                     // انتظار برای تغییر وضعیت چراغ

        // پایان شبیه‌سازی
        #10 $finish;
    end

endmodule
