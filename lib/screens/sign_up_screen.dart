import 'dart:convert';

import 'package:project_uas/utils/GentaRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // TODO: 1. Deklarasi Variable
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _errorText = '';
  bool _isSignIN = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> register(String name, String userName, String email,
      String password, String passwordConfirmation) async {
    try {
      setState(() {
        _isLoading = true;
      });
      Map<String, String> body = {
        'name': name,
        'username': userName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      http.Response? res = await GentaRequest().post("/register", "", body);
      setState(() {
        _isLoading = false;
      });
      print('Response: ${res?.body}');

      if (res != null) {
        var data = jsonDecode(res.body);

        if (data is Map<String, dynamic>) {
          if (data.containsKey('name') && data['name'] != null) {
            Navigator.pushNamed(context, '/mainScreen');
            _showDialog(context, 'Success',
                '${data["name"] ?? "Registration Successful"}, Selamat Datang!');
          } else {
            _showDialog(context, 'Error',
                '${data["message"] ?? "Unknown error occurred."}');
          }
        } else {
          _showDialog(
              context, 'Error', 'Invalid response format. Please try again.');
        }
      } else {
        _showDialog(context, 'Error',
            'Cannot connect to the server. Please try again.');
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _isLoading = false;
        _errorText = 'Network error. Please try again.';
      });
      _showDialog(context, 'Error', 'Connection timeout. Please try again.');
    }
  }

  void _signUp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String username = _usernameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validasi input
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorText = 'Semua kolom harus diisi.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorText = 'Kata sandi dan konfirmasi kata sandi tidak cocok.';
      });
      return;
    }

    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[0-9]')) ||
        !password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_]'))) {
      setState(() {
        _errorText =
            'Minimal 8 karakter, Kombinasi [A-Z], [a-z], [0-9], [!@#-%^&*(),.?":{}|<>_].';
      });
      return;
    }

    try {
      final encrypt.Key key =
          encrypt.Key.fromLength(32); // Tetap random, tetapi simpan.
      final encrypt.IV iv = encrypt.IV.fromLength(16);

      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      final encryptedUsername = encrypter.encrypt(username, iv: iv);
      final encryptedEmail = encrypter.encrypt(email, iv: iv);
      final encryptedPassword = encrypter.encrypt(password, iv: iv);

      // Simpan data yang terenkripsi dan kunci ke SharedPreferences
      await prefs.setString('username', encryptedUsername.base64);
      await prefs.setString('email', encryptedEmail.base64);
      await prefs.setString('password', encryptedPassword.base64);
      await prefs.setString('key', key.base64);
      await prefs.setString('iv', iv.base64);

      print('Registration successful!');
      print('Encrypted Data:');
      print('Username: ${encryptedUsername.base64}');
      print('Email: ${encryptedEmail.base64}');
      print('Password: ${encryptedPassword.base64}');
      print('Key: ${key.base64}');
      print('IV: ${iv.base64}');

      // Navigasi ke halaman login
      Navigator.pushReplacementNamed(context, '/signIn');
    } catch (e) {
      print('Encryption or saving failed: $e');
      setState(() {
        _errorText = 'Terjadi kesalahan saat proses registrasi.';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: 2 Pasang APP BAr
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      // TODO: 3 Pasang BOdy
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              child: Column(
                // TODO: 4 Atur MainAxisAlignment dan CrossAxisAlignment
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('Images/BookList.png'),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // TODO: 5 Pasang TextFormField
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _errorText.isNotEmpty ? _errorText : null,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureConfirmPassword,
                  ),
                  // TODO: 7 Pasang ElevatedButton Sign in
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Call the login function when the button is pressed
                      register(
                          _usernameController.text,
                          _usernameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _confirmPasswordController.text);
                    },
                    child: const Text('Sign Up'),
                  ),
                  // TODO: 8 Pasang ElevatedButton Register
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: 'Sudah punya Akun?',
                      style: const TextStyle(
                          fontSize: 16, color: Colors.deepPurple),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' Masuk Disini',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 203, 149, 239),
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/signIn');
                            },
                        ),
                      ],
                    ),
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
