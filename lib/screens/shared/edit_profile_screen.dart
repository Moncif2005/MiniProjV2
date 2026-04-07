import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/services/media_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _descController;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;
  late TextEditingController _facebookController;

  // ✅ جديد: حقول الشركة (تظهر فقط لمسؤولي التوظيف)
  late TextEditingController _companyNameController;
  late TextEditingController _companySizeController;
  late TextEditingController _industryController;

  String? _avatarPath;
  bool _isSaving = false;

  // ✅ مساعد: هل المستخدم مسؤول توظيف؟
  bool get _isRecruiter => context.read<UserProvider>().role == UserRole.recruteur;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);

    _nameController     = TextEditingController(text: user.name);
    _emailController    = TextEditingController(text: user.email);
    _phoneController    = TextEditingController(text: user.phone);
    _descController     = TextEditingController(text: user.bio);
    _githubController   = TextEditingController(text: user.github);
    _linkedinController = TextEditingController(text: user.linkedin);
    _facebookController = TextEditingController(text: user.facebook);
    _avatarPath         = user.avatarPath;
    
    // ✅ تهيئة حقول الشركة (نستخدم حقول موجودة مؤقتاً للتخزين)
    _companyNameController = TextEditingController(text: user.name);
    _companySizeController = TextEditingController(text: user.phone);
    _industryController    = TextEditingController(text: user.github);
    
    debugPrint('👤 EditProfile: Loaded bio="${user.bio}", avatar="${user.avatarPath}", isRecruiter=$_isRecruiter');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
    // ✅ تفريغ متحكمات الشركة الجديدة
    _companyNameController.dispose();
    _companySizeController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked != null) {
        setState(() => _avatarPath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImagePicker() {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est requis'), backgroundColor: AppColors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userProvider = context.read<UserProvider>();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      // ✅ جلب القيم الحالية للمقارنة
      final currentName = userProvider.name;
      final currentEmail = userProvider.email;
      final currentPhone = userProvider.phone;
      final currentBio = userProvider.bio;
      final currentGithub = userProvider.github;
      final currentLinkedin = userProvider.linkedin;
      final currentFacebook = userProvider.facebook;
      final currentAvatar = userProvider.avatarPath;

      // القيم الجديدة
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      final newPhone = _phoneController.text.trim();
      final newBio = _descController.text.trim();
      final newGithub = _githubController.text.trim();
      final newLinkedin = _linkedinController.text.trim();
      final newFacebook = _facebookController.text.trim();
      
      String? finalPhotoUrl = currentAvatar;
      bool avatarChanged = false;

      // ✅ التحقق من تغيير الصورة
      if (_avatarPath != null && _avatarPath!.isNotEmpty) {
        if (!_avatarPath!.startsWith('http')) {
          if (currentAvatar == null || !_avatarPath!.contains(currentAvatar)) {
            avatarChanged = true;
            debugPrint('🆕 New local image detected');
          }
        } else if (_avatarPath != currentAvatar) {
          avatarChanged = true;
          finalPhotoUrl = _avatarPath;
        }
      }

      // ✅ رفع الصورة إذا تغيرت
      if (avatarChanged && uid != null) {
        debugPrint('⬆️ Uploading to Cloudinary...');
        final uploadedUrl = await MediaService.uploadProfileImage(uid, File(_avatarPath!));
        if (uploadedUrl != null) {
          finalPhotoUrl = uploadedUrl;
        } else {
          throw Exception('فشل رفع الصورة');
        }
      }

      // ✅ التحقق من وجود أي تغييرات
      final hasChanges = 
          newName != currentName ||
          newEmail != currentEmail ||
          newPhone != currentPhone ||
          newBio != currentBio ||
          newGithub != currentGithub ||
          newLinkedin != currentLinkedin ||
          newFacebook != currentFacebook ||
          avatarChanged;

      if (hasChanges) {
        debugPrint('💾 Changes detected, updating...');
        
        // تحديث الـ Provider
        userProvider.updateProfile(
          name: _isRecruiter ? _companyNameController.text.trim() : newName,
          email: newEmail,
          phone: _isRecruiter ? _companySizeController.text.trim() : newPhone,
          description: newBio,
          github: _isRecruiter ? _industryController.text.trim() : newGithub,
          linkedin: newLinkedin,
          facebook: newFacebook,
          avatarPath: finalPhotoUrl,
        );

        // تحديث Firestore
        if (uid != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'displayName': _isRecruiter ? _companyNameController.text.trim() : newName,
            'email': newEmail,
            'phone': _isRecruiter ? _companySizeController.text.trim() : newPhone,
            'bio': newBio,
            'github': _isRecruiter ? _industryController.text.trim() : newGithub,
            'linkedin': newLinkedin,
            'facebook': newFacebook,
            if (avatarChanged && finalPhotoUrl != null) 'photoURL': finalPhotoUrl,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          debugPrint('✅ Firestore updated');
        }
      } else {
        debugPrint('ℹ️ No changes detected (Tokens saved! 💰)');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasChanges ? 'Profile updated ✓' : 'No changes to save'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      debugPrint('❌ Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(14)),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Edit Profile', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ],
                ),
                GestureDetector(
                  onTap: _isSaving ? null : _save,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: _isSaving ? c.border : AppColors.primary, borderRadius: BorderRadius.circular(14)),
                    child: _isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar ──
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 3)),
                          child: ClipOval(
                            child: _avatarPath != null && _avatarPath!.isNotEmpty
                                ? (_avatarPath!.startsWith('http')
                                    ? Image.network(_avatarPath!, fit: BoxFit.cover,
                                        loadingBuilder: (_, child, progress) {
                                          if (progress == null) return child;
                                          return Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null, color: AppColors.primary));
                                        },
                                        errorBuilder: (_, __, ___) => _buildInitials(c, user))
                                    : Image.file(File(_avatarPath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitials(c, user)))
                                : _buildInitials(c, user),
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () { debugPrint('📸 Camera tapped'); _showImagePicker(); },
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: c.surface, width: 2)),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: _showImagePicker,
                      child: const Text('Change Photo', style: TextStyle(color: AppColors.primary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── PERSONAL INFO ──
                  _SectionLabel(label: _isRecruiter ? 'COMPANY INFO' : 'PERSONAL INFO', c: c),
                  const SizedBox(height: 12),
                  _EditCard(
                    c: c,
                    children: [
                      _EditField(
                        c: c,
                        label: _isRecruiter ? 'Company Name' : 'Full Name',
                        hint: _isRecruiter ? 'Ex: TechCorp Solutions' : 'Alex Thompson',
                        icon: _isRecruiter ? Icons.business_rounded : Icons.person_outline_rounded,
                        controller: _isRecruiter ? _companyNameController : _nameController,
                      ),
                      _Divider(c: c),
                      _EditField(
                        c: c,
                        label: 'Email',
                        hint: 'alex@example.com',
                        icon: Icons.mail_outline_rounded,
                        controller: _emailController,
                        keyboard: TextInputType.emailAddress,
                      ),
                      _Divider(c: c),
                      _EditField(
                        c: c,
                        label: _isRecruiter ? 'Company Size' : 'Phone',
                        hint: _isRecruiter ? 'Ex: 50-200 employees' : '+213 555 123 456',
                        icon: _isRecruiter ? Icons.people_rounded : Icons.phone_outlined,
                        controller: _isRecruiter ? _companySizeController : _phoneController,
                        keyboard: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── ABOUT (يظهر للجميع) ──
                  _SectionLabel(label: 'ABOUT', c: c),
                  const SizedBox(height: 12),
                  _EditCard(
                    c: c,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _descController,
                              maxLines: 4,
                              maxLength: 200,
                              style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter'),
                              decoration: InputDecoration(
                                hintText: _isRecruiter ? 'Tell us about your company...' : 'Tell us about yourself...',
                                hintStyle: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                counterStyle: TextStyle(color: c.textMuted, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── INDUSTRY (يظهر فقط للمسؤولين) ──
                  if (_isRecruiter) ...[
                    _SectionLabel(label: 'INDUSTRY', c: c),
                    const SizedBox(height: 12),
                    _EditCard(
                      c: c,
                      children: [
                        _EditField(
                          c: c,
                          label: 'Industry',
                          hint: 'Ex: Technology & Software',
                          icon: Icons.language_rounded,
                          controller: _industryController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── SOCIAL LINKS (يظهر للجميع) ──
                  _SectionLabel(label: 'SOCIAL LINKS', c: c),
                  const SizedBox(height: 12),
                  _EditCard(
                    c: c,
                    children: [
                      _EditField(c: c, label: 'GitHub', hint: 'github.com/username', icon: Icons.code_rounded, iconBg: c.iconBg, iconColor: c.textSecondary, controller: _githubController, keyboard: TextInputType.url),
                      _Divider(c: c),
                      _EditField(c: c, label: 'LinkedIn', hint: 'linkedin.com/in/username', icon: Icons.work_outline_rounded, iconBg: const Color(0xFFE8F4FD), iconColor: const Color(0xFF0077B5), controller: _linkedinController, keyboard: TextInputType.url),
                      _Divider(c: c),
                      _EditField(c: c, label: 'Facebook', hint: 'facebook.com/username', icon: Icons.facebook_rounded, iconBg: const Color(0xFFE7F0FF), iconColor: const Color(0xFF1877F2), controller: _facebookController, keyboard: TextInputType.url),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: Build initials avatar ──
  Widget _buildInitials(ThemeColors c, UserProvider user) {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(user.initials, style: const TextStyle(color: AppColors.primary, fontSize: 32, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Helper Widgets ──
class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeColors c;
  const _SectionLabel({required this.label, required this.c});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 4), child: Text(label, style: TextStyle(color: c.textMuted, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w900, letterSpacing: 1.2)));
}
class _EditCard extends StatelessWidget {
  final List<Widget> children;
  final ThemeColors c;
  const _EditCard({required this.children, required this.c});
  @override
  Widget build(BuildContext context) => Container(decoration: ShapeDecoration(color: c.surface, shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(20)), shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1), BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1))]), child: Column(children: children));
}
class _EditField extends StatelessWidget {
  final ThemeColors c;
  final String label;
  final String hint;
  final IconData icon;
  final Color? iconBg;
  final Color? iconColor;
  final TextEditingController controller;
  final TextInputType keyboard;
  const _EditField({required this.c, required this.label, required this.hint, required this.icon, required this.controller, this.iconBg, this.iconColor, this.keyboard = TextInputType.text});
  @override
  Widget build(BuildContext context) {
    final bg = iconBg ?? AppColors.primaryLight;
    final color = iconColor ?? AppColors.primary;
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 18)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600, letterSpacing: 0.3)), const SizedBox(height: 4), TextField(controller: controller, keyboardType: keyboard, style: TextStyle(color: c.textPrimary, fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: c.textMuted, fontSize: 15, fontFamily: 'Inter'), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))]))]));
  }
}
class _Divider extends StatelessWidget {
  final ThemeColors c;
  const _Divider({required this.c});
  @override
  Widget build(BuildContext context) => Divider(color: c.border, thickness: 1, height: 0, indent: 66);
}

// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:minipr/services/media_service.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import '../../theme/app_colors.dart';
// import '../../providers/user_provider.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   late TextEditingController _nameController;
//   late TextEditingController _emailController;
//   late TextEditingController _phoneController;
//   late TextEditingController _descController; // ← للـ bio
//   late TextEditingController _githubController;
//   late TextEditingController _linkedinController;
//   late TextEditingController _facebookController;

//   String? _avatarPath;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     final user = Provider.of<UserProvider>(context, listen: false);

//     _nameController     = TextEditingController(text: user.name);
//     _emailController    = TextEditingController(text: user.email);
//     _phoneController    = TextEditingController(text: user.phone);
//     _descController     = TextEditingController(text: user.bio); // ✅ التصحيح هنا
//     _githubController   = TextEditingController(text: user.github);
//     _linkedinController = TextEditingController(text: user.linkedin);
//     _facebookController = TextEditingController(text: user.facebook);
//     _avatarPath         = user.avatarPath;
    
//     debugPrint('👤 EditProfile: Loaded bio="${user.bio}", avatar="${user.avatarPath}"');
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _descController.dispose();
//     _githubController.dispose();
//     _linkedinController.dispose();
//     _facebookController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final picker = ImagePicker();
//       final picked = await picker.pickImage(
//         source: source,
//         imageQuality: 80,
//         maxWidth: 512,
//         maxHeight: 512,
//       );
//       if (picked != null) {
//         setState(() => _avatarPath = picked.path);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Could not pick image: $e'),
//             backgroundColor: AppColors.red,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }

//   void _showImagePicker() {
//     if (!mounted) return;
    
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       builder: (context) => SafeArea(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.photo_library),
//               title: const Text('Choose from Gallery'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.gallery);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.camera_alt),
//               title: const Text('Take a Photo'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _pickImage(ImageSource.camera);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// Future<void> _save() async {
//   if (_nameController.text.trim().isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Le nom est requis'), backgroundColor: AppColors.red),
//     );
//     return;
//   }

//   setState(() => _isSaving = true);

//   try {
//     final userProvider = context.read<UserProvider>();
//     final uid = FirebaseAuth.instance.currentUser?.uid;
    
//     // ✅ 1. جلب القيم الحالية من الـ Provider للمقارنة
//     final currentName = userProvider.name;
//     final currentEmail = userProvider.email;
//     final currentPhone = userProvider.phone;
//     final currentBio = userProvider.bio;
//     final currentGithub = userProvider.github;
//     final currentLinkedin = userProvider.linkedin;
//     final currentFacebook = userProvider.facebook;
//     final currentAvatar = userProvider.avatarPath;

//     // القيم الجديدة من الحقول
//     final newName = _nameController.text.trim();
//     final newEmail = _emailController.text.trim();
//     final newPhone = _phoneController.text.trim();
//     final newBio = _descController.text.trim();
//     final newGithub = _githubController.text.trim();
//     final newLinkedin = _linkedinController.text.trim();
//     final newFacebook = _facebookController.text.trim();
    
//     String? finalPhotoUrl = currentAvatar;
//     bool avatarChanged = false;

//     // ✅ 2. التحقق: هل الصورة جديدة ومختلفة عن الحالية؟
//     if (_avatarPath != null && _avatarPath!.isNotEmpty) {
//       if (!_avatarPath!.startsWith('http')) {
//         // صورة محلية جديدة ≠ الصورة الحالية
//         if (currentAvatar == null || !_avatarPath!.contains(currentAvatar)) {
//           avatarChanged = true;
//           debugPrint('🆕 New local image detected, will upload...');
//         }
//       } else if (_avatarPath != currentAvatar) {
//         // رابط جديد مختلف عن الرابط المخزن
//         avatarChanged = true;
//         finalPhotoUrl = _avatarPath;
//         debugPrint('🆕 New cloud image URL detected');
//       }
//     }

//     // ✅ 3. رفع الصورة فقط إذا تغيرت
//     if (avatarChanged && uid != null) {
//       debugPrint('⬆️ Uploading new image to Cloudinary...');
//       final uploadedUrl = await MediaService.uploadProfileImage(uid, File(_avatarPath!));
//       if (uploadedUrl != null) {
//         finalPhotoUrl = uploadedUrl;
//       } else {
//         throw Exception('فشل رفع الصورة');
//       }
//     }

//     // ✅ 4. التحقق: هل تغير أي حقل نصي؟
//     final hasChanges = 
//         newName != currentName ||
//         newEmail != currentEmail ||
//         newPhone != currentPhone ||
//         newBio != currentBio ||
//         newGithub != currentGithub ||
//         newLinkedin != currentLinkedin ||
//         newFacebook != currentFacebook ||
//         avatarChanged; // إذا تغيرت الصورة يعتبر تغييراً

//     if (hasChanges) {
//       debugPrint('💾 Changes detected, updating Firestore...');
      
//       // تحديث الـ Provider (للتحديث الفوري في الواجهة)
//       userProvider.updateProfile(
//         name: newName,
//         email: newEmail,
//         phone: newPhone,
//         description: newBio,
//         github: newGithub,
//         linkedin: newLinkedin,
//         facebook: newFacebook,
//         avatarPath: finalPhotoUrl,
//       );

//       // تحديث Firestore فعلياً
//       if (uid != null) {
//         await FirebaseFirestore.instance.collection('users').doc(uid).update({
//           'displayName': newName,
//           'email': newEmail,
//           'phone': newPhone,
//           'bio': newBio,
//           'github': newGithub,
//           'linkedin': newLinkedin,
//           'facebook': newFacebook,
//           if (avatarChanged && finalPhotoUrl != null) 'photoURL': finalPhotoUrl,
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//         debugPrint('✅ Firestore updated successfully');
//       }
//     } else {
//       debugPrint('ℹ️ No changes detected, skipping Firestore update (Tokens saved! 💰)');
//       // حتى لو لم تتغير البيانات، نحدث الواجهة محلياً لضمان تطابق الحقول
//       userProvider.updateProfile(
//         name: newName, email: newEmail, phone: newPhone,
//         description: newBio, github: newGithub, linkedin: newLinkedin,
//         facebook: newFacebook, avatarPath: finalPhotoUrl,
//       );
//     }

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(hasChanges ? 'Profile updated ✓' : 'No changes to save'),
//           backgroundColor: AppColors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//       Navigator.pop(context);
//     }

//   } catch (e) {
//     debugPrint('❌ Error in _save: $e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
//       );
//     }
//   } finally {
//     if (mounted) setState(() => _isSaving = false);
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;
//     final user = context.watch<UserProvider>();

//     return Scaffold(
//       backgroundColor: c.bg,
//       body: Column(
//         children: [
//           // ── App Bar ──
//           Container(
//             padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
//             decoration: BoxDecoration(
//               color: c.surface,
//               border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Container(
//                         width: 36,
//                         height: 36,
//                         decoration: BoxDecoration(
//                           color: c.bg,
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Icon(
//                           Icons.arrow_back_ios_new_rounded,
//                           size: 16,
//                           color: c.textPrimary,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Text(
//                       'Edit Profile',
//                       style: TextStyle(
//                         color: c.textPrimary,
//                         fontSize: 18,
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 GestureDetector(
//                   onTap: _isSaving ? null : _save,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     decoration: BoxDecoration(
//                       color: _isSaving ? c.border : AppColors.primary,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: _isSaving
//                         ? const SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Text(
//                             'Save',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontFamily: 'Inter',
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // ── Scrollable Content ──
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Avatar Section ──
//                   Center(
//                     child: Stack(
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: AppColors.primary, width: 3),
//                           ),
//                           child: ClipOval(
//                             child: _avatarPath != null && _avatarPath!.isNotEmpty
//                                 ? (_avatarPath!.startsWith('http')
//                                     ? Image.network(
//                                         _avatarPath!,
//                                         fit: BoxFit.cover,
//                                         loadingBuilder: (_, child, progress) {
//                                           if (progress == null) return child;
//                                           return Center(
//                                             child: CircularProgressIndicator(
//                                               value: progress.expectedTotalBytes != null
//                                                   ? progress.cumulativeBytesLoaded / 
//                                                     (progress.expectedTotalBytes ?? 1)
//                                                   : null,
//                                               color: AppColors.primary,
//                                             ),
//                                           );
//                                         },
//                                         errorBuilder: (_, __, ___) => _buildInitials(c, user),
//                                       )
//                                     : Image.file(
//                                         File(_avatarPath!),
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (_, __, ___) => _buildInitials(c, user),
//                                       ))
//                                 : _buildInitials(c, user),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 0,
//                           right: 0,
//                           child: GestureDetector(
//                             behavior: HitTestBehavior.opaque,
//                             onTap: () {
//                               debugPrint('📸 Camera icon tapped');
//                               _showImagePicker();
//                             },
//                             child: Container(
//                               width: 32,
//                               height: 32,
//                               decoration: BoxDecoration(
//                                 color: AppColors.primary,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: c.surface, width: 2),
//                               ),
//                               child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Center(
//                     child: GestureDetector(
//                       onTap: _showImagePicker,
//                       child: const Text(
//                         'Change Photo',
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontSize: 14,
//                           fontFamily: 'Inter',
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   // ── PERSONAL INFO ──
//                   _SectionLabel(label: 'PERSONAL INFO', c: c),
//                   const SizedBox(height: 12),
//                   _EditCard(
//                     c: c,
//                     children: [
//                       _EditField(c: c, label: 'Full Name', hint: 'Alex Thompson', icon: Icons.person_outline_rounded, controller: _nameController),
//                       _Divider(c: c),
//                       _EditField(c: c, label: 'Email', hint: 'alex@example.com', icon: Icons.mail_outline_rounded, controller: _emailController, keyboard: TextInputType.emailAddress),
//                       _Divider(c: c),
//                       _EditField(c: c, label: 'Phone', hint: '+213 555 123 456', icon: Icons.phone_outlined, controller: _phoneController, keyboard: TextInputType.phone),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // ── ABOUT ──
//                   _SectionLabel(label: 'ABOUT', c: c),
//                   const SizedBox(height: 12),
//                   _EditCard(
//                     c: c,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Description', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
//                             const SizedBox(height: 8),
//                             TextField(
//                               controller: _descController,
//                               maxLines: 4,
//                               maxLength: 200,
//                               style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter'),
//                               decoration: InputDecoration(
//                                 hintText: 'Tell us about yourself...',
//                                 hintStyle: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.zero,
//                                 counterStyle: TextStyle(color: c.textMuted, fontSize: 11),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),

//                   // ── SOCIAL LINKS ──
//                   _SectionLabel(label: 'SOCIAL LINKS', c: c),
//                   const SizedBox(height: 12),
//                   _EditCard(
//                     c: c,
//                     children: [
//                       _EditField(c: c, label: 'GitHub', hint: 'github.com/username', icon: Icons.code_rounded, iconBg: c.iconBg, iconColor: c.textSecondary, controller: _githubController, keyboard: TextInputType.url),
//                       _Divider(c: c),
//                       _EditField(c: c, label: 'LinkedIn', hint: 'linkedin.com/in/username', icon: Icons.work_outline_rounded, iconBg: const Color(0xFFE8F4FD), iconColor: const Color(0xFF0077B5), controller: _linkedinController, keyboard: TextInputType.url),
//                       _Divider(c: c),
//                       _EditField(c: c, label: 'Facebook', hint: 'facebook.com/username', icon: Icons.facebook_rounded, iconBg: const Color(0xFFE7F0FF), iconColor: const Color(0xFF1877F2), controller: _facebookController, keyboard: TextInputType.url),
//                     ],
//                   ),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Helper: Build initials avatar ──
//   Widget _buildInitials(ThemeColors c, UserProvider user) {
//     return Container(
//       color: AppColors.primaryLight,
//       child: Center(
//         child: Text(
//           user.initials,
//           style: const TextStyle(color: AppColors.primary, fontSize: 32, fontFamily: 'Inter', fontWeight: FontWeight.w700),
//         ),
//       ),
//     );
//   }
// }

// // ── Helper Widgets (SectionLabel, EditCard, EditField, Divider) ──
// // (نفس الكود الأصلي - لم يتغير)
// class _SectionLabel extends StatelessWidget {
//   final String label;
//   final ThemeColors c;
//   const _SectionLabel({required this.label, required this.c});
//   @override
//   Widget build(BuildContext context) {
//     return Padding(padding: const EdgeInsets.only(left: 4), child: Text(label, style: TextStyle(color: c.textMuted, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w900, letterSpacing: 1.2)));
//   }
// }
// class _EditCard extends StatelessWidget {
//   final List<Widget> children;
//   final ThemeColors c;
//   const _EditCard({required this.children, required this.c});
//   @override
//   Widget build(BuildContext context) {
//     return Container(decoration: ShapeDecoration(color: c.surface, shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(20)), shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1), BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1))]), child: Column(children: children));
//   }
// }
// class _EditField extends StatelessWidget {
//   final ThemeColors c;
//   final String label;
//   final String hint;
//   final IconData icon;
//   final Color? iconBg;
//   final Color? iconColor;
//   final TextEditingController controller;
//   final TextInputType keyboard;
//   const _EditField({required this.c, required this.label, required this.hint, required this.icon, required this.controller, this.iconBg, this.iconColor, this.keyboard = TextInputType.text});
//   @override
//   Widget build(BuildContext context) {
//     final bg = iconBg ?? AppColors.primaryLight;
//     final color = iconColor ?? AppColors.primary;
//     return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 18)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600, letterSpacing: 0.3)), const SizedBox(height: 4), TextField(controller: controller, keyboardType: keyboard, style: TextStyle(color: c.textPrimary, fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: c.textMuted, fontSize: 15, fontFamily: 'Inter'), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))]))]));
//   }
// }
// class _Divider extends StatelessWidget {
//   final ThemeColors c;
//   const _Divider({required this.c});
//   @override
//   Widget build(BuildContext context) {
//     return Divider(color: c.border, thickness: 1, height: 0, indent: 66);
//   }
// }