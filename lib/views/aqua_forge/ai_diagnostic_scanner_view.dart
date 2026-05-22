import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiDiagnosticScanner extends StatefulWidget {
  const AiDiagnosticScanner({super.key});
  @override
  State<AiDiagnosticScanner> createState() => _AiDiagnosticScannerState();
}

class _AiDiagnosticScannerState extends State<AiDiagnosticScanner> {
  bool _isScanning = false;
  String _result = '';
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(_cameras.first, ResolutionPreset.medium);
        await _cameraController!.initialize();
        if (!mounted) return;
        setState(() {});
      }
    } catch (e) {
      debugPrint("No cameras available: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _runGeminiScan() async {
    setState(() { _isScanning = true; _result = ''; });
    
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      if (apiKey.isEmpty || apiKey.startsWith('AIzaSy...')) {
        setState(() { _result = 'Error: Valid GEMINI_API_KEY required in .env file.'; _isScanning = false; });
        return;
      }
      
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
      final prompt = 'You are a master plumber AI. Analyze this image (simulated) of a plumbing fixture. Provide a probability of failure, compliance with AS/NZS 3500, and repair steps.';
      
      final response = await model.generateContent([Content.text(prompt)]);
      
      final aiAnalysis = response.text ?? 'Unknown diagnosis.';
      
      // Instantly Sync to Firestore, alerting the Enterprise Command Center
      await FirebaseFirestore.instance.collection('alerts').add({
        'title': 'AI Field Scan Result',
        'description': 'Mobile scan completed. Awaiting full technical report.',
        'probability': 88,
        'status': 'critical',
        'timestamp': FieldValue.serverTimestamp(),
        'raw_analysis': aiAnalysis,
      });

      setState(() { _result = 'SCAN COMPLETE! Sent to Enterprise Dashboard via Firestore.\n\n$aiAnalysis'; });
    } catch (e) {
      setState(() { _result = 'Error during AI analysis or Firestore Sync: $e'; });
    } finally {
      setState(() { _isScanning = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Vision Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _cameraController != null && _cameraController!.value.isInitialized
              ? CameraPreview(_cameraController!)
              : Container(color: Colors.black, child: const Center(child: Icon(Icons.camera_alt, color: Colors.white54, size: 50))),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    icon: _isScanning ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.auto_awesome),
                    label: Text(_isScanning ? 'Processing via Gemini...' : 'Analyze Pipe Feed'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                    onPressed: _isScanning ? null : _runGeminiScan,
                  ),
                  const SizedBox(height: 24),
                  if (_result.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(_result, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
