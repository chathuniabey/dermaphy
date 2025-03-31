import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../widgets/bottom_nav.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  String? selectedGender;
  DateTime? selectedDOB;
  bool _isEmailValid = true;

  final _formKey = GlobalKey<FormState>();

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'gender': selectedGender ?? 'Not specified',
        'dob': selectedDOB != null ? DateFormat('yyyy-MM-dd').format(selectedDOB!) : 'Not specified',
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const BottomNav()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup failed: $e")));
    }
  }

  Future<void> _selectDOB() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDOB = picked;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white60),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('lib/assets/images/app_logo.jpg', height: 120),
              SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration("Full Name"),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),

              TextFormField(
                controller: emailController,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration("Email").copyWith(
                  errorText: _isEmailValid ? null : 'Enter a valid email address',
                ),
                onChanged: (value) {
                  final isValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(value.trim());
                  setState(() {
                    _isEmailValid = isValid;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email is required';
                  if (!_isEmailValid) return 'Enter a valid email address';
                  return null;
                },
              ),

              TextFormField(
                controller: passwordController,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration("Password"),
                obscureText: true,
                validator: (value) => value != null && value.length < 6 ? 'Minimum 6 characters' : null,
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedGender,
                dropdownColor: Colors.teal.shade700,
                style: TextStyle(color: Colors.white),
                decoration: _inputDecoration("Gender"),
                items: ['Male', 'Female', 'Other'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedGender = value),
                validator: (value) => value == null ? 'Select gender' : null,
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDOB != null
                          ? "Date of Birth: ${DateFormat('yyyy-MM-dd').format(selectedDOB!)}"
                          : "No DOB selected",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectDOB,
                    child: Text("Pick Date", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),

              SizedBox(height: 30),
              ElevatedButton(
                onPressed: signup,
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
