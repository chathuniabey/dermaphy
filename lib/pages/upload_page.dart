import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'survey_page.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _onContinue() async {
    if (_selectedImage == null) return;

    bool isValid = await _checkIfSkinImage(_selectedImage!);

    if (!isValid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Invalid Image"),
          content: Text("The image does not appear to show a skin condition. "
              "Please upload a clear image of the affected skin area."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            )
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    final result = await ApiService.predictDisease(_selectedImage!);

    Navigator.of(context).pop(); // Close loader

    if (result != null) {
      final accuracy = double.tryParse(result['Accuracy'].toString().replaceAll('%', '')) ?? 0;

      if (accuracy > 50) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseSurveyPage(
              imageFile: _selectedImage!,
              imagePrediction: result['Results'],
              imageConfidence: result['Accuracy'],
            ),
          ),
        );
      } else {
        _showLowConfidenceDialog();
      }
    } else {
      _showPredictionFailedDialog();
    }
  }

  void _showLowConfidenceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Low Confidence"),
        content: Text("The prediction confidence is too low. Try using a clearer skin image."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          )
        ],
      ),
    );
  }

  void _showPredictionFailedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Prediction Failed"),
        content: Text("Something went wrong. Please try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  Future<bool> _checkIfSkinImage(File file) async {
    final inputImage = InputImage.fromFile(file);
    final labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
    final labels = await labeler.processImage(inputImage);

    for (final label in labels) {
      final text = label.label.toLowerCase();
      if (text.contains('skin') ||
          text.contains('dermatology') ||
          text.contains('rash') ||
          text.contains('eczema') ||
          text.contains('psoriasis') ||
          text.contains('disease') ||
          text.contains('infection')) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Your Image')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
            ),
            child: Column(
              children: [
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 200)
                    : Image.asset('lib/assets/common/image_upload.jpg', height: 200),
                SizedBox(height: 10),
                Text(_selectedImage == null ? "Image Not Chosen" : "Image Selected"),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (_selectedImage == null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: Icon(Icons.upload),
                  label: Text("Open Gallery"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: Icon(Icons.camera_alt),
                  label: Text("Take Photo"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedImage = null),
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text("Delete", style: TextStyle(color: Colors.red)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.white,),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _onContinue,
                  icon: Icon(Icons.check_circle, color: Colors.green),
                  label: Text("Continue", style: TextStyle(color: Colors.green)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.white,),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
