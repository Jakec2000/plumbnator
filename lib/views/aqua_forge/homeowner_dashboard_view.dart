import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_diagnostic_scanner_view.dart';

class HomeownerDashboard extends StatelessWidget {
  final FirebaseFirestore? firestore;
  const HomeownerDashboard({super.key, this.firestore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Digital Twin - Live Sync')),
      body: StreamBuilder<QuerySnapshot>(
        stream: (firestore ?? FirebaseFirestore.instance).collection('alerts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          }
          
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No active alerts in the network. System Nominal.', style: TextStyle(color: Colors.greenAccent)),
            );
          }

          final alerts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final data = alerts[index].data() as Map<String, dynamic>;
              final isCritical = data['status'] == 'critical';
              return Card(
                color: isCritical ? Colors.red.shade900.withValues(alpha: 0.5) : Colors.yellow.shade900.withValues(alpha: 0.5),
                child: ListTile(
                  leading: Icon(isCritical ? Icons.warning : Icons.info_outline, color: isCritical ? Colors.redAccent : Colors.yellowAccent),
                  title: Text(data['title'] ?? 'Anomaly Detected', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('${data['description']} (${data['probability'] ?? '??'}% Prob.)', style: const TextStyle(color: Colors.white70)),
                  trailing: ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(backgroundColor: isCritical ? Colors.red : Colors.orange), 
                    child: const Text('Fix Now', style: TextStyle(color: Colors.white))
                  ),
                ),
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiDiagnosticScanner())),
        icon: const Icon(Icons.document_scanner),
        label: const Text('AI Scan'),
        backgroundColor: Colors.cyanAccent,
      ),
    );
  }
}
