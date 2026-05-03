import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/units_service.dart';
import '../services/groups_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _role = 'Student';
  bool _loading = false;
  bool _loadingGoogle = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || pass.isEmpty) {
      _snack('Please enter email & password');
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await AuthService.instance.signIn(email, pass);
      await _loadData();
      _navigate(user.role);
    } on FirebaseAuthException catch (e) {
      _snack(_friendlyError(e.code));
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loadingGoogle = true);

    try {
      final user = await AuthService.instance.signInWithGoogle();
      await _loadData();
      _navigate(user.role);
    } on FirebaseAuthException catch (e) {
      _snack(_friendlyError(e.code));
    } catch (e) {
      _snack('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      TaskService.instance.load(),
      UnitsService.instance.loadAll(),
      GroupsService.instance.load(),
    ]);
  }

  void _navigate(UserRole role) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  String _friendlyError(String code) => switch (code) {
        'user-not-found' => 'No account found with that email.',
        'wrong-password' => 'Incorrect password.',
        'invalid-email' => 'Invalid email format.',
        'user-disabled' => 'This account has been disabled.',
        'invalid-credential' => 'Invalid email or password.',
        _ => 'Invalid email or password.',
      };

  @override
  Widget build(BuildContext context) {
    final busy = _loading || _loadingGoogle;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset('assets/cihe_logo.png', width: 120, height: 120),
            const SizedBox(height: 24),
            const Text(
              'Student Task Management',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: DropdownButton<String>(
                value: _role,
                isExpanded: true,
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                dropdownColor: const Color(0xFF1A1A1A),
                items: const [
                  DropdownMenuItem(
                    value: 'Student',
                    child: Text('Student'),
                  ),
                  DropdownMenuItem(
                    value: 'Lecturer',
                    child: Text('Lecturer'),
                  ),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('University Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco('Password').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: busy ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7BFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (AuthService.supportsGoogle) ...[
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFF3A3A3A))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Color(0xFF8A8A8A)),
                    ),
                  ),
                  Expanded(child: Divider(color: Color(0xFF3A3A3A))),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: busy ? null : _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3A3A3A)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: _loadingGoogle
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.g_mobiledata,
                          size: 26,
                          color: Colors.white70,
                        ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _snack('Check your email inbox for a reset link.'),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: Color(0xFF8A8A8A)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: Color(0xFF8A8A8A)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Color(0xFF4A7BFF)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF0F0F0F),
      hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: Color(0xFF3A3A3A)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
        borderSide: BorderSide(color: Color(0xFF4A7BFF)),
      ),
    );
  }
}
