import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import 'auth_providers.dart';
import 'auth_repository.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .register(_name.text, _email.text, _password.text);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = authErrorMessage(e));
    } catch (_) {
      setState(() => _error = 'Could not save your profile. Check your Firestore rules.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => context.go('/sign-in'),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Back to sign in'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set up your account, then add your first course.',
                      style: TextStyle(fontSize: 15, color: kMuted, height: 1.6),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _name,
                      style: const TextStyle(color: kInk),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outlined, color: kMuted, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: kInk),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: kMuted, size: 20),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      style: const TextStyle(color: kInk),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: 'At least 6 characters',
                        helperStyle: TextStyle(color: kMuted),
                        prefixIcon: Icon(Icons.lock_outlined, color: kMuted, size: 20),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Use at least 6 characters'
                          : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kError.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kError.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: kError, fontSize: 13),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1A1200),
                              ),
                            )
                          : const Text('Create account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
