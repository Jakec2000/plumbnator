import time
import random
import json
# import paho.mqtt.client as mqtt

# Mock MQTT Client Setup
BROKER = "mqtt.aquaforge.ai"
PORT = 8883
TOPIC = "sensors/telemetry"

def generate_telemetry():
    """Simulates real-time sensor data from AquaForge clamp-on sensors."""
    flow_rate = round(random.uniform(2.5, 12.0), 2) # Liters per minute
    pressure = round(random.uniform(40.0, 70.0), 1) # PSI
    acoustic_anomaly = random.uniform(0.0, 1.0) # 0 to 1 scale of noise anomalies (cavitation/leaks)
    
    # Introduce random fault for demonstration
    if random.random() > 0.95:
        acoustic_anomaly = round(random.uniform(0.7, 0.99), 2)
        print(">> WARNING: High Acoustic Anomaly Detected (Potential Leak/Corrosion)")

    payload = {
        "device_id": "AQF-SENSOR-9982",
        "property_id": "HOME-12345",
        "timestamp": int(time.time()),
        "flow_rate_lpm": flow_rate,
        "pressure_psi": pressure,
        "acoustic_anomaly": acoustic_anomaly,
        "battery_level": 92.5
    }
    return json.dumps(payload)

if __name__ == "__main__":
    print(f"Connecting to AquaForge Edge at {BROKER}:{PORT}...")
    # client = mqtt.Client(client_id="mock-sensor")
    # client.connect(BROKER, PORT)
    
    print("Starting telemetry broadcast...")
    try:
        while True:
            data = generate_telemetry()
            print(f"PUB [{TOPIC}]: {data}")
            # client.publish(TOPIC, data)
            time.sleep(5) # Send every 5 seconds
    except KeyboardInterrupt:
        print("\nHalting telemetry.")
