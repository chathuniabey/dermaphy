import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static const String _endpoint = 'https://us-east1-dermaphy.cloudfunctions.net/disease_predict';

  static Future<Map<String, dynamic>?> predictDisease(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_endpoint));
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: basename(imageFile.path),
      ));

      var response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(res.body);

        // ✅ Save to Firestore
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance.collection('predictions').add({
            'uid': uid,
            'disease': result['Results'],
            'confidence': result['Accuracy'],
            'timestamp': Timestamp.now(),
          });
        }

        return result;
      } else {
        print("Prediction failed: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("API error: $e");
      return null;
    }
  }
}
