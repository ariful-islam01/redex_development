import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sign Up Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  bool _isButtonDisabled = true;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateFields);
    _passwordController.addListener(_validateFields);
    _confirmPasswordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to validate fields and enable/disable the Sign Up button
  void _validateFields() {
    setState(() {
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      // Email validation
      _emailError =
      _isValidEmail(email) ? null : "Example: abcd@example.com";

      // Password validation
      _passwordError =
      password.length >= 8 ? null : "Must be 8 characters";

      // Confirm Password validation
      _confirmPasswordError =
      password == confirmPassword ? null : "Passwords must be the same";

      _isButtonDisabled = _firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty ||
          _emailError != null ||
          _passwordError != null ||
          _confirmPasswordError != null;
    });
  }

  bool _isValidEmail(String email) {
    bool a=false;
    if(email.contains('@gmail.com')||email.contains('@yahoo.com')||email.contains('@outlook.com')){
      a=true;
    }
    return a;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up Page'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon at the top
            Image.asset(
              'images/icon.png',
              width: 150.0,
              height: 150.0,
            ),
            SizedBox(height: 24.0),

            // First Name and Last Name fields side by side
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Email field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                hintText: 'Enter your email (@example.com)',
                errorText: _emailError,
              ),
            ),
            SizedBox(height: 16.0),
            // Password field
            TextField(
              controller: _passwordController,
              obscureText: _obscureTextPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                hintText: 'Enter your password',
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureTextPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Confirm Password field
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureTextConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
                errorText: _confirmPasswordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureTextConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: _toggleConfirmPasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 24.0),
            // Sign Up button
            ElevatedButton(
              onPressed: _isButtonDisabled
                  ? null
                  : () {
                // Handle sign-up logic
              },
              child: Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                disabledForegroundColor: Colors.grey.withOpacity(0.38),
                disabledBackgroundColor: Colors.grey.withOpacity(0.12), // Disabled button color
              ),
            ),
            SizedBox(height: 16.0),
            // "Already have an account? Sign in" section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to sign-in page
                  },
                  child: Text("Sign in"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
