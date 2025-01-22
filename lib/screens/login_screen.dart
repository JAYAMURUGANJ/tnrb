import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constant.dart';
import 'home_screen.dart'; // Replace with the actual import path for HomeScreen

// Default credentials
final String defaultUsername = 'tnrb2025';
final String defaultPassword = 'Tnrb@2025';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController =
      TextEditingController(text: defaultUsername);
  final TextEditingController _passwordController =
      TextEditingController(text: defaultPassword);
  final _formKey = GlobalKey<FormState>();
  late bool _isPasswordVisible;
  late String errorMessage;

  @override
  void initState() {
    _isPasswordVisible = false;
    errorMessage = '';
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Show error dialog when invalid credentials
  Future<void> showErrorDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Login Failed"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> login(BuildContext context) async {
    if (_usernameController.text == defaultUsername &&
        _passwordController.text == defaultPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        errorMessage = 'Invalid username or password';
      });
      // Show the error dialog
      await showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Theme.of(context).secondaryHeaderColor,
              Theme.of(context).secondaryHeaderColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                const LoginLogoWidget(),
                const SizedBox(height: 30),
                _buildUsernameField(),
                const SizedBox(height: 10),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildLoginButton(context),
                const SizedBox(height: 10),
                const Spacer(),
                const LoginFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Username text field with validation
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        labelText: 'Username',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your username';
        }
        return null;
      },
    );
  }

  // Password text field with visibility toggle
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      obscureText: !_isPasswordVisible,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  // Login button
  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          login(context);
        }
      },
      child: const Text(
        'Login',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}

class LoginLogoWidget extends StatelessWidget {
  const LoginLogoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Hero(
          tag: const ValueKey('app-logo'),
          child: Image.asset(Assets.logo,
              height: 160), // Replace with correct path to logo
        ),
        Text(
          "TNRB QR Scanner",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const Text(
          "LOGIN",
          style: TextStyle(fontSize: 35),
        ),
      ],
    );
  }
}

class LoginFooter extends StatefulWidget {
  const LoginFooter({
    super.key,
  });

  @override
  State<LoginFooter> createState() => _LoginFooterState();
}

class _LoginFooterState extends State<LoginFooter> {
  late Future<String> appVersion;

  @override
  void initState() {
    super.initState();
    appVersion = getAppVersion(); // Make sure this is an async operation
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<String>(
        future: appVersion,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text(
              "@TNRB | Version: ${snapshot.data}",
              style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
            );
          }
        },
      ),
    );
  }
}

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  return version;
}
