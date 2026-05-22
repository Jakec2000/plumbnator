/**
 * AquaForge AI - Hardware Node Firmware (ESP32)
 * Connects to physical Flow and Pressure sensors.
 * Beams live telemetry to Firebase Cloud via REST.
 */

#include <WiFi.h>
#include <HTTPClient.h>

// ---------------------------------------------------------
// HARDWARE CONFIGURATION
// ---------------------------------------------------------
#define FLOW_SENSOR_PIN 34       // Digital Input (Interrupt) for Hall Effect Flow Meter
#define PRESSURE_SENSOR_PIN 35   // Analog Input for 0-5V Pressure Transducer
#define NODE_ID "AQF-ESP32-992"

// ---------------------------------------------------------
// NETWORK & CLOUD CONFIGURATION
// ---------------------------------------------------------
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Target Firebase Cloud Function or REST Endpoint
const char* firebaseUrl = "https://plumbforge-ai.web.app/api/telemetry"; // Replace with actual Cloud Function URL

// ---------------------------------------------------------
// GLOBAL VARIABLES
// ---------------------------------------------------------
volatile int flowPulseCount = 0;
float flowRate = 0.0;
unsigned int flowMilliLitres = 0;
unsigned long totalMilliLitres = 0;

unsigned long oldTime = 0;
unsigned long transmitTimer = 0;
const int TRANSMIT_INTERVAL = 5000; // Transmit every 5 seconds

// ---------------------------------------------------------
// INTERRUPT SERVICE ROUTINE (ISR)
// ---------------------------------------------------------
// This triggers every time the Hall Effect sensor detects a pulse (rotation of the water meter wheel)
void IRAM_ATTR pulseCounter() {
  flowPulseCount++;
}

// ---------------------------------------------------------
// SETUP
// ---------------------------------------------------------
void setup() {
  Serial.begin(115200);
  
  // Initialize Hardware Pins
  pinMode(FLOW_SENSOR_PIN, INPUT_PULLUP);
  pinMode(PRESSURE_SENSOR_PIN, INPUT);
  
  // Attach Interrupt to Flow Sensor Pin (Rising Edge)
  attachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN), pulseCounter, RISING);

  // Initialize WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected.");
  Serial.println("AquaForge Node Armed.");
  
  oldTime = millis();
  transmitTimer = millis();
}

// ---------------------------------------------------------
// MAIN LOOP
// ---------------------------------------------------------
void loop() {
  // 1. READ SENSORS EVERY SECOND
  if ((millis() - oldTime) > 1000) {
    detachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN));
    
    // Calculate Flow Rate (Liters per minute) - Note: 7.5 is a common calibration factor for YF-S201 sensors
    flowRate = ((1000.0 / (millis() - oldTime)) * flowPulseCount) / 7.5;
    
    oldTime = millis();
    flowPulseCount = 0; // Reset pulse count
    
    attachInterrupt(digitalPinToInterrupt(FLOW_SENSOR_PIN), pulseCounter, RISING);
    
    // Calculate Pressure (PSI)
    // Assuming a standard 3-wire 5V transducer where 0.5V = 0 PSI and 4.5V = max PSI (e.g., 100 PSI)
    int rawAnalog = analogRead(PRESSURE_SENSOR_PIN);
    float voltage = rawAnalog * (3.3 / 4095.0); // ESP32 uses 3.3V ADC with 12-bit resolution
    // Convert voltage to PSI (Simplified linear map, calibration required)
    float currentPsi = (voltage - 0.5) * (100.0 / 4.0);
    if (currentPsi < 0) currentPsi = 0; // Prevent negative readings

    Serial.printf("Flow: %.2f L/min | Pressure: %.2f PSI\n", flowRate, currentPsi);
    
    // 2. TRANSMIT TO CLOUD EVERY 5 SECONDS
    if ((millis() - transmitTimer) > TRANSMIT_INTERVAL) {
      if (WiFi.status() == WL_CONNECTED) {
        HTTPClient http;
        http.begin(firebaseUrl);
        http.addHeader("Content-Type", "application/json");

        // Construct JSON Payload
        String payload = "{\"node_id\":\"" + String(NODE_ID) + "\",";
        payload += "\"flow_rate_lpm\":" + String(flowRate, 2) + ",";
        payload += "\"pressure_psi\":" + String(currentPsi, 2) + "}";

        // Execute POST Request
        int httpResponseCode = http.POST(payload);
        
        if (httpResponseCode > 0) {
          Serial.printf("Telemetry TX Success. Code: %d\n", httpResponseCode);
        } else {
          Serial.printf("Telemetry TX Error: %s\n", http.errorToString(httpResponseCode).c_str());
        }
        
        http.end();
      }
      transmitTimer = millis();
    }
  }
}
