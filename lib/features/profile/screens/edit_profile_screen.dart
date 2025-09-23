// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../../core/models/user_model.dart';
// import '../../../../core/services/auth_service.dart';
// import '../../../../theme/app_theme.dart';
// import '../../../../widgets/common/primary_button.dart';
// import '../../../../widgets/forms/form_text_field.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   final User user;
//
//   const EditProfileScreen({
//     super.key,
//     required this.user,
//   });
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.user.displayName ?? '');
//     _emailController = TextEditingController(text: widget.user.email);
//     // _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final authService = context.read<AuthService>();
//       // TODO: Implement profile update
//       await Future.delayed(const Duration(seconds: 1)); // Simulate network call
//
//       if (mounted) {
//         // Update user data in the auth service
//         final updatedUser = widget.user.copyWith(
//           displayName: _nameController.text.trim(),
//           // email: _emailController.text.trim(), // Email updates might require verification
//           // phoneNumber: _phoneController.text.trim().isNotEmpty
//           //     ? _phoneController.text.trim()
//           //     : null,
//           updatedAt: DateTime.now(),
//         );
//
//         // Update the user in the auth service
//         // This would typically be done through an API call
//         await authService.updateUser(updatedUser);
//
//         if (mounted) {
//           Navigator.of(context).pop();
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile updated successfully')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to update profile. Please try again.';
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
//         title: const Text('Edit Profile'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _isLoading ? null : _saveProfile,
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 16),
//               Center(
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundImage: widget.user.photoUrl != null
//                           ? NetworkImage(widget.user.photoUrl!)
//                           : null,
//                       child: widget.user.photoUrl == null
//                           ? Text(
//                               widget.user.displayName?.isNotEmpty == true
//                                   ? widget.user.displayName![0].toUpperCase()
//                                   : widget.user.email[0].toUpperCase(),
//                               style: theme.textTheme.headlineMedium?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             )
//                           : null,
//                     ),
//                     Positioned(
//                       right: 0,
//                       bottom: 0,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.primary,
//                           shape: BoxShape.circle(),
//                           border: Border.all(
//                             color: theme.scaffoldBackgroundColor,
//                             width: 2,
//                           ),
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.camera_alt, size: 20),
//                           color: Colors.white,
//                           onPressed: () {
//                             // TODO: Implement image picker
//                           },
//                           padding: EdgeInsets.zero,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),
//               FormTextField(
//                 controller: _nameController,
//                 label: 'Full Name',
//                 hint: 'Enter your full name',
//                 prefixIcon: Icons.person_outline,
//                 textCapitalization: TextCapitalization.words,
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               FormTextField(
//                 controller: _emailController,
//                 label: 'Email',
//                 hint: 'Enter your email',
//                 keyboardType: TextInputType.emailAddress,
//                 prefixIcon: Icons.email_outlined,
//                 enabled: false, // Email updates might require verification
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+').hasMatch(value)) {
//                     return 'Please enter a valid email address';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               FormTextField(
//                 controller: _phoneController,
//                 label: 'Phone Number',
//                 hint: 'Enter your phone number',
//                 keyboardType: TextInputType.phone,
//                 prefixIcon: Icons.phone_outlined,
//                 validator: (value) {
//                   if (value != null && value.isNotEmpty) {
//                     // Basic phone number validation (adjust as needed)
//                     if (!RegExp(r'^[0-9+\-\s()]{10,20}$').hasMatch(value)) {
//                       return 'Please enter a valid phone number';
//                     }
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               if (_errorMessage != null)
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 16.0),
//                   child: Text(
//                     _errorMessage!,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.error,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               PrimaryButton(
//                 onPressed: _isLoading ? null : _saveProfile,
//                 child: _isLoading
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : const Text('Save Changes'),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
