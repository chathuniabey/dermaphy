import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final File imageFile;
  final String diseaseName;
  final String confidence;

  const ResultPage({
    super.key,
    required this.imageFile,
    required this.diseaseName,
    required this.confidence,
  });

  // 🔠 Correct common spelling issues from model
  String _formatDiseaseName(String name) {
    switch (name.toLowerCase()) {
      case 'ekzama':
        return 'Eczema';
      case 'psorasis':
        return 'Psoriasis';
      case 'ringworm':
        return 'Ringworm';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final correctedDisease = _formatDiseaseName(diseaseName);

    return Scaffold(
      appBar: AppBar(title: Text('Skin Disease Prediction')),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Final Predicted Disease', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(imageFile, height: 200, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 12),
                  Text('Skin Disease', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    correctedDisease,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Confidence: $confidence%",
                    style: TextStyle(fontSize: 18, color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
