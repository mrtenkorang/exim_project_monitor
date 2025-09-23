// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../core/models/user_model.dart';
// import '../../../../core/widgets/custom_text_field.dart';
// import '../../../../core/services/auth_service.dart';
// import '../../../core/repositories/user_repository.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//   String? _selectedRole = 'field_collector';
//   String? _selectedZone;
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   // Sample zones - in a real app, this would come from an API or database
//   final List<String> _zones = [
//     'Zone 1 - Northern Region',
//     'Zone 2 - Ashanti Region',
//     'Zone 3 - Eastern Region',
//     'Zone 4 - Brong-Ahafo Region',
//     'Zone 5 - Western Region',
//   ];
//
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_passwordController.text != _confirmPasswordController.text) {
//       setState(() {
//         _errorMessage = 'Passwords do not match';
//       });
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final authService = context.read<AuthService>();
//       final userRepo = context.read<UserRepository>();
//
//       // Check if username is available
//       final usernameAvailable = await userRepo.usernameExists(_usernameController.text.trim());
//       if (usernameAvailable) {
//         setState(() {
//           _errorMessage = 'Username is already taken';
//           _isLoading = false;
//         });
//         return;
//       }
//
//       // Create new user
//       final newUser = User(
//         id: 'user_${DateTime.now().millisecondsSinceEpoch}',
//         // username: _usernameController.text.trim(),
//         email: _emailController.text.trim(),
//         fullName: _fullNameController.text.trim(),
//         role: _selectedRole!,
//         // zoneId: _selectedRole == 'field_collector' ? _selectedZone : null,
//         // phoneNumber: _phoneController.text.trim(),
//         isActive: false, createdAt: DateTime.now(), updatedAt: DateTime.now(), // New users need admin approval
//       );
//
//       // In a real app, you would send this to your backend
//       await userRepo.addUser(newUser);
//
//       // For demo purposes, we'll auto-login as admin
//       if (mounted) {
//         Navigator.of(context).pushReplacementNamed('/login');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Registration successful! Please wait for admin approval.'),
//             duration: Duration(seconds: 5),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Registration failed: ${e.toString()}';
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Account'),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Logo and Title
//                 Icon(
//                   Icons.agriculture,
//                   size: 80,
//                   color: theme.colorScheme.primary,
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Create Your Account',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Error Message
//                 if (_errorMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 16.0),
//                     child: Text(
//                       _errorMessage!,
//                       style: TextStyle(color: theme.colorScheme.error),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//
//                 // Full Name
//                 CustomTextField(
//                   controller: _fullNameController,
//                   label: 'Full Name',
//                   hint: 'Enter your full name',
//                   prefixIcon: Icons.person_outline,
//                   keyboardType: TextInputType.name,
//                   textCapitalization: TextCapitalization.words,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your full name';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Email
//                 CustomTextField(
//                   controller: _emailController,
//                   label: 'Email',
//                   hint: 'Enter your email',
//                   prefixIcon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Phone
//                 CustomTextField(
//                   controller: _phoneController,
//                   label: 'Phone Number',
//                   hint: 'Enter your phone number',
//                   prefixIcon: Icons.phone_outlined,
//                   keyboardType: TextInputType.phone,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your phone number';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Username
//                 CustomTextField(
//                   controller: _usernameController,
//                   label: 'Username',
//                   hint: 'Enter your username',
//                   prefixIcon: Icons.person_outline,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please choose a username';
//                     }
//                     if (value.length < 4) {
//                       return 'Username must be at least 4 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Password
//                 CustomTextField(
//                   controller: _passwordController,
//                   label: 'Password',
//                   hint: 'Enter your password',
//                   prefixIcon: Icons.lock_outline,
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a password';
//                     }
//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 16),
//
//                 // Confirm Password
//                 CustomTextField(
//                   controller: _confirmPasswordController,
//                   label: 'Confirm Password',
//                   hint: 'Confirm your password',
//                   prefixIcon: Icons.lock_outline,
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please confirm your password';
//                     }
//                     if (value != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Role Selection
//                 DropdownButtonFormField<String>(
//                   value: _selectedRole,
//                   decoration: const InputDecoration(
//                     labelText: 'Role',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.work_outline),
//                   ),
//                   items: const [
//                     DropdownMenuItem(
//                       value: 'field_collector',
//                       child: Text('Field Collector'),
//                     ),
//                     DropdownMenuItem(
//                       value: 'qa_qc',
//                       child: Text('QA/QC Officer'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedRole = value;
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select a role';
//                     }
//                     return null;
//                   },
//                 ),
//
//                 // Zone Selection (only for field collectors)
//                 if (_selectedRole == 'field_collector') ...[
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     value: _selectedZone,
//                     decoration: const InputDecoration(
//                       labelText: 'Assigned Zone',
//                       border: OutlineInputBorder(),
//                       prefixIcon: Icon(Icons.location_on_outlined),
//                     ),
//                     hint: const Text('Select your zone'),
//                     items: _zones.map((zone) {
//                       return DropdownMenuItem(
//                         value: zone,
//                         child: Text(zone),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedZone = value;
//                       });
//                     },
//                     validator: (value) {
//                       if (_selectedRole == 'field_collector' && (value == null || value.isEmpty)) {
//                         return 'Please select a zone';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//
//                 const SizedBox(height: 32),
//
//                 // Register Button
//                 FilledButton(
//                   onPressed: _isLoading ? null : _register,
//                   style: FilledButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text('CREATE ACCOUNT'),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 // Login Link
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text('Already have an account?'),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pushReplacementNamed('/login');
//                       },
//                       child: const Text('Sign In'),
//                     ),
//                   ],
//                 ),
//
//                 // Terms and Conditions
//                 Padding(
//                   padding: const EdgeInsets.only(top: 16.0),
//                   child: Text(
//                     'By creating an account, you agree to our Terms of Service and Privacy Policy',
//                     textAlign: TextAlign.center,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
