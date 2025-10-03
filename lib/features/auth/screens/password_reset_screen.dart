import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _resetSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  _resetSent ? 'Check Your Email' : 'Forgot Your Password?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_resetSent) ..._buildResetSentContent(theme)
                else ..._buildResetForm(theme),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResetForm(ThemeData theme) {
    return [
      Text(
        'Enter your email address and we\'ll send you a link to reset your password.',
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      CustomTextField(
        controller: _emailController,
        label: 'Email Address',
        hint: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
        prefixIcon: Icons.email_outlined,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
      const SizedBox(height: 24),
      PrimaryButton(
        onTap: (){},
        isLoading: _isLoading,
        child: const Text('Send Reset Link'),
      ),
      ];
  }

  List<Widget> _buildResetSentContent(ThemeData theme) {
    return [
      Text(
        'We\'ve sent password reset instructions to your email address. Please check your inbox and follow the instructions to reset your password.',
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      Icon(
        Icons.mark_email_read_outlined,
        size: 64,
        color: theme.colorScheme.primary,
      ),
      const SizedBox(height: 32),
      PrimaryButton(
        onTap: () => Navigator.of(context).pop(),
        child: const Text('Back to Login'),
      ),
    ];
  }
}
