const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

exports.telemetryReceiver = onRequest(async (request, response) => {
  try {
    // 1. Accept only POST requests with JSON body
    if (request.method !== "POST") {
      response.status(405).send("Method Not Allowed");
      return;
    }

    const telemetry = request.body;
    
    // Minimal validation
    if (!telemetry.node_id || telemetry.pressure_psi === undefined) {
      response.status(400).send("Invalid payload structure.");
      return;
    }

    const pressure = parseFloat(telemetry.pressure_psi);
    const flow = parseFloat(telemetry.flow_rate_lpm);

    console.log(`Received telemetry from ${telemetry.node_id}: Pressure=${pressure} PSI, Flow=${flow} LPM`);

    // 2. Autonomous Analysis Logic
    // If pressure drops significantly (< 25 PSI) while flow remains high (> 10 LPM), it indicates a burst pipe.
    if (pressure < 25.0 && flow > 10.0) {
      console.log(`CRITICAL ANOMALY DETECTED for ${telemetry.node_id}. Triggering Auto-Dispatcher.`);

      const jobsRef = admin.firestore().collection("jobs");
      
      const newJob = {
        title: "Autonomous Emergency: Catastrophic Rupture",
        location: `IoT Sector ${telemetry.node_id}`,
        urgency: "critical",
        time: "IMMEDIATE RESPONSE REQUIRED",
        status: "triage",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        ai_confidence: 99.9,
        telemetry_snapshot: {
          pressure_psi: pressure,
          flow_lpm: flow
        }
      };

      // 3. Inject Job into Firestore
      await jobsRef.add(newJob);
      
      response.status(200).send("Telemetry received. Anomaly detected. Fleet dispatched.");
    } else {
      // Normal reading
      response.status(200).send("Telemetry received. System nominal.");
    }
  } catch (error) {
    console.error("Error processing telemetry:", error);
    response.status(500).send("Internal Server Error");
  }
});
