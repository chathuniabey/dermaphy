import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final File imageFile;
  final String diseaseName;
  final String confidence;
  final bool showBoth;
  final String? imagePrediction;
  final String? surveyPrediction;
  final String? imageConfidence;
  final double? surveyConfidence;

  const ResultPage({
    super.key,
    required this.imageFile,
    required this.diseaseName,
    required this.confidence,
    this.showBoth = false,
    this.imagePrediction,
    this.surveyPrediction,
    this.imageConfidence,
    this.surveyConfidence,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Skin Disease Prediction')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Card(
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Final Predicted Disease', style: TextStyle(fontSize: 18)),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(imageFile, height: 200, fit: BoxFit.cover),
                ),
                SizedBox(height: 10),
                Text('Skin Disease', style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  diseaseName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                SizedBox(height: 6),
                Text(
                  "Final Confidence: $confidence%",
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),

                SizedBox(height: 20),
                Divider(),
                Text("🔍 Image Prediction: ${imagePrediction ?? 'N/A'}", style: TextStyle(fontSize: 16)),
                Text("Confidence: ${imageConfidence ?? 'N/A'}%"),
                SizedBox(height: 10),
                Text("📝 Survey Prediction: ${surveyPrediction ?? 'N/A'}", style: TextStyle(fontSize: 16)),
                Text("Confidence: ${(surveyConfidence ?? 0.0 * 100).toStringAsFixed(2)}%"),

                if (showBoth) ...[
                  SizedBox(height: 10),
                  Text(
                    "⚠️ The predictions from the image and questionnaire do not match.",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "We recommend consulting a medical professional for an accurate diagnosis.",
                      style: TextStyle(color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],


                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('Continue'),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
