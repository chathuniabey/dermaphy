import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'result_page.dart';

class DiseaseSurveyPage extends StatefulWidget {
  final File imageFile;
  final String imagePrediction;
  final String imageConfidence;

  const DiseaseSurveyPage({
    super.key,
    required this.imageFile,
    required this.imagePrediction,
    required this.imageConfidence,
  });

  @override
  State<DiseaseSurveyPage> createState() => _DiseaseSurveyPageState();
}

class _DiseaseSurveyPageState extends State<DiseaseSurveyPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final Map<String, int?> responses = {};
  bool isLoading = false;
  int _currentQuestionIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> questions = [
    {"key": "Itching", "label": "Do you have itching?", "type": "bool", "image": "lib/assets/symptoms/itching.png"},
    {"key": "Redness", "label": "Is the skin red?", "type": "bool", "image": "lib/assets/symptoms/redness.png"},
    {"key": "Flaky/Scaly Patches", "label": "Are there flaky or scaly patches?", "type": "bool", "image": "lib/assets/symptoms/flaky.png"},
    {"key": "Ring-shaped Scaling", "label": "Do you notice ring-shaped scaling?", "type": "bool", "image": "lib/assets/symptoms/ring.png"},
    {"key": "Spreading", "label": "Is the condition spreading?", "type": "bool", "image": "lib/assets/symptoms/spreading.png"},
    {"key": "Blisters/Pus", "label": "Are there blisters or pus?", "type": "bool", "image": "lib/assets/symptoms/blisters.png"},
    {"key": "Dry/Cracked Skin", "label": "Is your skin dry or cracked?", "type": "bool", "image": "lib/assets/symptoms/dry.png"},
    {"key": "Folds Appearance", "label": "Does it appear in skin folds?", "type": "bool", "image": "lib/assets/symptoms/folds.png"},
    {"key": "Swelling", "label": "Do you have swelling?", "type": "bool", "image": "lib/assets/symptoms/swelling.png"},
    {"key": "Painful Lesions", "label": "Are there painful lesions?", "type": "bool", "image": "lib/assets/symptoms/pain.png"},
    {"key": "Lesion Size", "label": "What is the lesion size?", "type": "select", "options": ["Small", "Medium", "Large"], "values": [1, 2, 3]},
    {"key": "Duration", "label": "How long have you had this?", "type": "select", "options": ["< 2 weeks", "2–6 weeks", "> 6 weeks"], "values": [1, 2, 3]},
    {"key": "Severity Level", "label": "What is the severity level?", "type": "select", "options": ["Mild", "Moderate", "Severe"], "values": [1, 2, 3]},
    {"key": "Affected Area", "label": "Where is it affecting?", "type": "select", "options": ["Scalp", "Body", "Hands/Feet"], "values": [0, 1, 2]},
  ];

  Future<void> _submit() async {
    setState(() => isLoading = true);

    try {
      print("Sending responses: ${json.encode(responses)}");

      final url = Uri.parse("https://us-east1-dermaphy.cloudfunctions.net/predict_skin_disease_nlp");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(responses),
      );

      final data = json.decode(response.body);
      final surveyPrediction = data['predicted_disease'];
      final surveyConfidence = data['confidence'] * 1.0;

      bool isMatch = surveyPrediction == widget.imagePrediction;

      final imageConf = double.parse(widget.imageConfidence.replaceAll('%', ''));

      String finalConfidence = isMatch
        ? ((imageConf * 0.8 + surveyConfidence * 0.2).toStringAsFixed(2))
        : imageConf.toStringAsFixed(2);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            imageFile: widget.imageFile,
            diseaseName: surveyPrediction,
            confidence: finalConfidence,
            showBoth: !isMatch,
            imagePrediction: widget.imagePrediction,
            surveyPrediction: surveyPrediction,
            imageConfidence: widget.imageConfidence,
            surveyConfidence: surveyConfidence,
          ),
        ),
      );
    } catch (e) {
      print("Error submitting survey: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting survey')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Card(
          color: Colors.white,
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (question['image'] != null)
                  Image.asset(question['image'], height: 150),
                SizedBox(height: 20),
                Text(
                  question['label'],
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                if (question['type'] == 'bool')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _handleAnswer(question['key'], 1),
                        child: Text("Yes"),
                      ),
                      ElevatedButton(
                        onPressed: () => _handleAnswer(question['key'], 0),
                        child: Text("No"),
                      ),
                    ],
                  ),
                if (question['type'] == 'select')
                  DropdownButtonFormField<int>(
                    value: responses[question['key']],
                    decoration: InputDecoration(labelText: "Select option"),
                    items: List.generate(
                      question['options'].length,
                      (index) => DropdownMenuItem(
                        value: question['values'][index],
                        child: Text(question['options'][index]),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        responses[question['key']] = val;
                        _nextQuestion();
                      });
                    },
                  ),
                SizedBox(height: 20),
                if (_currentQuestionIndex > 0)
                  TextButton(
                    onPressed: _prevQuestion,
                    child: Text("Back"),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAnswer(String key, int value) {
    setState(() {
      responses[key] = value;
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _animationController.forward(from: 0);
      _currentQuestionIndex++;
    } else {
      _submit();
    }
  }

  void _prevQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _animationController.forward(from: 0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    questions.forEach((q) => responses[q['key']] = q['type'] == 'bool' ? 0 : null);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Follow-up Questions")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildQuestionCard(questions[_currentQuestionIndex]),
    );
  }
}
