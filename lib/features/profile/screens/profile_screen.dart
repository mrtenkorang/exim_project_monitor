// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../../../../widgets/common/section_header.dart';
//
// import '../../../../core/models/user_model.dart';
// import '../../../../core/services/auth_service.dart';
// import '../../../../theme/app_theme.dart';
// import '../../../core/widgets/primary_button.dart';
// import 'edit_profile_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   Future<void> _updateProfilePicture() async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 85,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
//
//       if (image != null && mounted) {
//         setState(() => _isLoading = true);
//         // TODO: Implement profile picture upload
//         await Future.delayed(const Duration(seconds: 1)); // Simulate upload
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile picture updated')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to update profile picture';
//         });
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   Future<void> _signOut() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Sign Out'),
//         content: const Text('Are you sure you want to sign out?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(
//               foregroundColor: Theme.of(context).colorScheme.error,
//             ),
//             child: const Text('SIGN OUT'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed == true && mounted) {
//       await context.read<AuthService>().logout();
//       if (mounted) {
//         Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final user = context.watch<AuthService>().currentUser;
//
//     if (user == null) {
//       return const Center(child: Text('User not found'));
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Profile'),
//         // actions: [
//         //   IconButton(
//         //     icon: const Icon(Icons.edit_outlined),
//         //     onPressed: () => _navigateToEditProfile(context, user),
//         //   ),
//         // ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Center(
//               child: Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
//                     child: user.photoUrl == null
//                         ? Text(
//                             (user.fullName ?? user.email)
//                                 .split(' ')
//                                 .map((n) => n.isNotEmpty ? n[0] : '')
//                                 .join('')
//                                 .toUpperCase(),
//                             style: TextStyle(fontSize: 24),
//                           )
//                         : null,
//                   ),
//                   if (!_isLoading)
//                     Positioned(
//                       right: 0,
//                       bottom: 0,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.primary,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: theme.scaffoldBackgroundColor,
//                             width: 2,
//                           ),
//                         ),
//                         child: IconButton(
//                           icon: const Icon(Icons.camera_alt, size: 20),
//                           color: Colors.white,
//                           onPressed: _updateProfilePicture,
//                           padding: EdgeInsets.zero,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               user.fullName ?? 'No Name',
//               style: theme.textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             if (user.fullName != null) ...[
//               const SizedBox(height: 4),
//               Text(
//                 user.email,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.hintColor,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//             const SizedBox(height: 32),
//             _buildSection(
//               context,
//               title: 'Account',
//               children: [
//                 _buildListTile(
//                   context,
//                   icon: Icons.email_outlined,
//                   title: 'Email',
//                   subtitle: user.email,
//                   onTap: () {},
//                 ),
//                 _buildListTile(
//                   context,
//                   icon: Icons.phone_outlined,
//                   title: 'Phone',
//                   // subtitle: user.phoneNumber ?? 'Not set',
//                   onTap: () {},
//                 ),
//                 _buildListTile(
//                   context,
//                   icon: Icons.lock_outline,
//                   title: 'Change Password',
//                   onTap: () => _navigateToChangePassword(context),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             _buildSection(
//               context,
//               title: 'Preferences',
//               children: [
//                 _buildListTile(
//                   context,
//                   icon: Icons.language_outlined,
//                   title: 'Language',
//                   subtitle: 'English',
//                   onTap: () {},
//                 ),
//                 _buildListTile(
//                   context,
//                   icon: Icons.dark_mode_outlined,
//                   title: 'Theme',
//                   subtitle: 'System',
//                   onTap: () {},
//                 ),
//                 _buildListTile(
//                   context,
//                   icon: Icons.notifications_outlined,
//                   title: 'Notifications',
//                   onTap: () {},
//                 ),
//               ],
//             ),
//             const SizedBox(height: 32),
//             if (_errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: Text(
//                   _errorMessage!,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.error,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             PrimaryButton(
//               onPressed: _signOut,
//               child: const Text('Sign Out'),
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSection(
//     BuildContext context, {
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SectionHeader(title: title),
//         const SizedBox(height: 8),
//         Card(
//           child: Column(
//             children: children
//                 .map((e) => [
//                       e,
//                       if (e != children.last) const Divider(height: 1),
//                     ])
//                 .expand((e) => e)
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildListTile(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     VoidCallback? onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: Theme.of(context).primaryColor),
//       title: Text(title),
//       subtitle: subtitle != null ? Text(subtitle) : null,
//       trailing: onTap != null
//           ? const Icon(Icons.chevron_right, color: Colors.grey)
//           : null,
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       minVerticalPadding: 0,
//       dense: true,
//     );
//   }
//
//   // void _navigateToEditProfile(BuildContext context, User user) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => EditProfileScreen(user: user),
//   //     ),
//   //   );
//   // }
//
//   void _navigateToChangePassword(BuildContext context) {
//     // TODO: Implement change password navigation
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Change password functionality coming soon')),
//     );
//   }
// }
