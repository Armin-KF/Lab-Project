`timescale 1ns / 1ps
`include "TrafficLightController.v"

module TrafficLightController_tb();

    // Input signals
    reg clk;                     // Clock signal
    reg reset;                   // Reset signal
    reg traffic_A;               // Traffic signal from Academic Ave
    reg traffic_B;               // Traffic signal from Bravado Blvd
    wire [1:0] LA;               // Output light for Academic Ave
    wire [1:0] LB;               // Output light for Bravado Blvd

    
    TrafficLightController UUT (
        .clk(clk),
        .reset(reset),
        .traffic_A(traffic_A),
        .traffic_B(traffic_B),
        .LA(LA),
        .LB(LB)
    );

    // Generate clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with a period of 10 nanoseconds
    end

    integer file;
    initial begin
        
        $dumpfile("TrafficLightController_tb.vcd");
        $dumpvars(0, TrafficLightController_tb);

        
        file = $fopen("traffic_data.csv", "w");
        $fwrite(file, "time,traffic_A,traffic_B,LA,LB\n");

        // Initial settings
        reset = 1;               // Activate reset
        traffic_A = 0;           // Deactivate traffic on Academic Ave
        traffic_B = 0;           // Deactivate traffic on Bravado Blvd
        #10;

        reset = 0;               // Deactivate reset
        #10;

        // Scenario 1: Traffic on Academic Ave
        traffic_A = 1;           // Activate traffic on Academic Ave
        #50;
        $fwrite(file, "%0d,%0d,%0d,%0d,%0d\n", $time, traffic_A, traffic_B, LA, LB);

        // Scenario 2: Traffic on Bravado Blvd
        traffic_A = 0;           // Deactivate traffic on Academic Ave
        traffic_B = 1;           // Activate traffic on Bravado Blvd
        #50;
        $fwrite(file, "%0d,%0d,%0d,%0d,%0d\n", $time, traffic_A, traffic_B, LA, LB);

        // Scenario 3: No traffic
        traffic_B = 0;           // Deactivate traffic on Bravado Blvd
        #50;
        $fwrite(file, "%0d,%0d,%0d,%0d,%0d\n", $time, traffic_A, traffic_B, LA, LB);

        // End simulation
        #10 $finish;
        $fclose(file);
    end

endmodule