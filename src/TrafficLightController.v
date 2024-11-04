module TrafficLightController(
    input wire clk,            // Clock for state transitions
    input wire reset,          // Reset signal to initialize to the initial state
    input wire traffic_A,      // Traffic on Academic Ave
    input wire traffic_B,      // Traffic on Bravado Blvd
    output reg [1:0] LA,       // Output light for Academic (00 = Red, 01 = Yellow, 10 = Green)
    output reg [1:0] LB        // Output light for Bravado (00 = Red, 01 = Yellow, 10 = Green)
);

    // Define states as numerical values
    parameter S0 = 2'b00;  // Academic: Green, Bravado: Red
    parameter S1 = 2'b01;  // Academic: Yellow, Bravado: Red
    parameter S2 = 2'b10;  // Academic: Red, Bravado: Green
    parameter S3 = 2'b11;  // Academic: Red, Bravado: Yellow

    reg [1:0] state, next_state;
    integer yellow_timer;

    // Set initial state on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            yellow_timer <= 0;
        end else begin
            state <= next_state;
        end
    end

    // State transition logic and output light determination
    always @(*) begin
        case (state)
            S0: begin
                LA = 2'b10; // Academic: Green
                LB = 2'b00; // Bravado: Red
                if (!traffic_A)  // If no traffic on Academic
                    next_state = S1;
                else
                    next_state = S0;
            end
            
            S1: begin
                LA = 2'b01; // Academic: Yellow
                LB = 2'b00; // Bravado: Red
                if (yellow_timer >= 5)  // After 5 clock cycles
                    next_state = S2;
                else
                    next_state = S1;
            end
            
            S2: begin
                LA = 2'b00; // Academic: Red
                LB = 2'b10; // Bravado: Green
                if (!traffic_B)  // If no traffic on Bravado
                    next_state = S3;
                else
                    next_state = S2;
            end
            
            S3: begin
                LA = 2'b00; // Academic: Red
                LB = 2'b01; // Bravado: Yellow
                if (yellow_timer >= 5)  // After 5 clock cycles
                    next_state = S0;
                else
                    next_state = S3;
            end
            
            default: begin
                next_state = S0;
            end
        endcase
    end

    // Timer for yellow states
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            yellow_timer <= 0;
        end else if (state == S1 || state == S3) begin
            yellow_timer <= yellow_timer + 1;
        end else begin
            yellow_timer <= 0;
        end
    end

endmodule