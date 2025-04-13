import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'survey_page.dart';

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
      final file = File(pickedFile.path);
      setState(() {
        _selectedImage = file;
      });

      // ⏳ Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      final result = await ApiService.predictDisease(file);

      // ✅ Dismiss loading
      Navigator.of(context).pop();

      if (result != null) {
        final accuracy = double.parse(result['Accuracy'].toString().replaceAll('%', '')) ?? 0;

        if (accuracy > 75) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiseaseSurveyPage(
                imageFile: file,
                imagePrediction: result['Results'],
                imageConfidence: result['Accuracy'],
              ),
            ),
          );
        } else {
          // ⚠️ Show dialog if accuracy is too low
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text("Low Confidence"),
              content: Text(
                "The confidence level for this prediction is too low. "
                "This may be due to poor image quality or unclear skin details.\n\n"
                "Please try uploading a clearer image for better results.",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickImage(source); // retry logic
                  },
                  child: Text("Re-upload", style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          );
        }
      } else {
        // ❌ Error dialog with retry
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Prediction Failed"),
            content: Text("There was a problem sending your image. Please try again."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImage(source); // Retry
                },
                child: Text("Retry"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
            ],
          ),
        );
      }
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.upload),
                label: Text("Open gallery"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text("Take photo"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ],
          )
        ],
      ),
    );
  }
}
