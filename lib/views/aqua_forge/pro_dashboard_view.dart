import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'vr_training_view.dart';

class ProDashboard extends StatelessWidget {
  const ProDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Dispatcher Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vrpano),
            tooltip: 'VR Training',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VrTrainingModule())),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobs').where('status', isEqualTo: 'dispatched').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No active dispatches. Stand by.', style: TextStyle(color: Colors.grey, fontSize: 18)),
            );
          }

          final jobs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final jobDoc = jobs[index];
              final data = jobDoc.data() as Map<String, dynamic>;
              
              return Card(
                color: Colors.blue.shade900.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.blueAccent, width: 1), borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data['title'] ?? 'Emergency Dispatch', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                          const Icon(Icons.plumbing, color: Colors.blueAccent),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Location: ${data['location'] ?? 'Unknown'}', style: const TextStyle(color: Colors.white70)),
                      Text('Urgency: ${data['urgency']?.toString().toUpperCase() ?? 'ROUTINE'}', style: TextStyle(color: data['urgency'] == 'critical' ? Colors.redAccent : Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showComplianceDialog(context, jobDoc.id),
                          icon: const Icon(Icons.verified),
                          label: const Text('Complete & Verify Compliance'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12)
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    );
  }

  void _showComplianceDialog(BuildContext context, String jobId) {
    bool pressureCheck = false;
    bool watermarkCheck = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: const Text('AS/NZS 3500 Compliance', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('You must verify the following Australian standards before marking this job complete:', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Static pressure does not exceed 500 kPa (AS/NZS 3500.1)', style: TextStyle(color: Colors.white, fontSize: 13)),
                    value: pressureCheck,
                    activeColor: Colors.greenAccent,
                    checkColor: Colors.black,
                    onChanged: (bool? value) {
                      setState(() { pressureCheck = value ?? false; });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('All replaced fittings possess a valid WaterMark certification', style: TextStyle(color: Colors.white, fontSize: 13)),
                    value: watermarkCheck,
                    activeColor: Colors.greenAccent,
                    checkColor: Colors.black,
                    onChanged: (bool? value) {
                      setState(() { watermarkCheck = value ?? false; });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  onPressed: (pressureCheck && watermarkCheck) ? () async {
                    Navigator.of(dialogContext).pop();
                    
                    // Mark job as completed in Firestore to trigger Web3 UI on Dashboard
                    try {
                      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
                        'status': 'completed',
                        'complianceVerified': true,
                        'completedAt': FieldValue.serverTimestamp()
                      });
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Compliance Verified! Web3 Warranty Unlocked.', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green)
                        );
                      }
                    } catch (e) {
                      debugPrint('Error updating job status: $e');
                    }
                  } : null, // Disabled until both checked
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                  child: const Text('Sign Off & Complete'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
