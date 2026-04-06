import 'dart:io';
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

  String? _avatarPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // ✅ استخدم Provider.of بدلاً من context.read هنا لتجنب أخطاء السياق
    final user = Provider.of<UserProvider>(context, listen: false);

    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _descController = TextEditingController(text: user.description);
    _githubController = TextEditingController(text: user.github);
    _linkedinController = TextEditingController(text: user.linkedin);
    _facebookController = TextEditingController(text: user.facebook);
    _avatarPath = user.avatarPath;
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
    super.dispose();
  }

  // ── Pick image from gallery or camera ──
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

  // ── Show image source picker ──
void _showImagePicker() {
  if (!mounted) return;
  
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white, // ✅ لون صريح بدلاً من الاعتماد على theme
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
  // ── Save ──
  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nom est requis'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userProvider = context.read<UserProvider>();
      final uid = FirebaseAuth.instance.currentUser?.uid; // ✅ نحصل على الـ uid
      String? finalPhotoUrl = userProvider.avatarPath;

      // ✅ المنطق الجديد: إذا كانت الصورة مسار محلي (جديدة)، ارفعها أولاً
      if (_avatarPath != null &&
          _avatarPath!.isNotEmpty &&
          !_avatarPath!.startsWith('http')) {
        if (uid != null) {
          final uploadedUrl = await MediaService.uploadProfileImage(
            uid,
            File(_avatarPath!),
          );
          if (uploadedUrl != null) {
            finalPhotoUrl = uploadedUrl; // ✅ نستخدم الرابط السحابي الجديد
          } else {
            throw Exception('Failed to upload image');
          }
        }
      }

      // ✅ تحديث البروفايدر بالبيانات والرابط النهائي
      userProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        description: _descController.text.trim(),
        github: _githubController.text.trim(),
        linkedin: _linkedinController.text.trim(),
        facebook: _facebookController.text.trim(),
        avatarPath: finalPhotoUrl, // ✅ الرابط السحابي أو المحلي
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully ✓'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.bg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // ── Save Button ──
                GestureDetector(
                  onTap: _isSaving ? null : _save,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _isSaving ? c.border : AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                  // ── Avatar Section ──
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                _avatarPath != null && _avatarPath!.isNotEmpty
                                ? (_avatarPath!.startsWith('http')
                                      // ✅ رابط سحابي (من Cloudinary)
                                      ? Image.network(
                                          _avatarPath!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (_, child, progress) {
                                            if (progress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    progress.expectedTotalBytes !=
                                                        null
                                                    ? progress.cumulativeBytesLoaded /
                                                          (progress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                    : null,
                                                color: AppColors.primary,
                                              ),
                                            );
                                          },
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: AppColors.primaryLight,
                                                child: Center(
                                                  child: Text(
                                                    user.initials,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 32,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        )
                                      // ✅ مسار محلي (مختار حديثاً)
                                      : Image.file(
                                          File(_avatarPath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: AppColors.primaryLight,
                                                child: Center(
                                                  child: Text(
                                                    user.initials,
                                                    style: const TextStyle(
                                                      color: AppColors.primary,
                                                      fontSize: 32,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        ))
                                // ✅ لا توجد صورة: اعرض الأحرف الأولى
                                : Container(
                                    color: AppColors.primaryLight,
                                    child: Center(
                                      child: Text(
                                        user.initials,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 32,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior
                                .opaque, // ✅ يضمن استقبال اللمس حتى لو كانت الخلفية شفافة
                            onTap: () {
                              // ✅ إضافة طباعة للتأكد من وصول اللمس
                              debugPrint('📸 Camera icon tapped');
                              _showImagePicker();
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: c.surface, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
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
                      child: const Text(
                        'Change Photo',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── PERSONAL INFO ──
                  _SectionLabel(label: 'PERSONAL INFO', c: c),
                  const SizedBox(height: 12),
                  _EditCard(
                    c: c,
                    children: [
                      _EditField(
                        c: c,
                        label: 'Full Name',
                        hint: 'Alex Thompson',
                        icon: Icons.person_outline_rounded,
                        controller: _nameController,
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
                        label: 'Phone',
                        hint: '+213 555 123 456',
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                        keyboard: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── ABOUT ──
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
                            Text(
                              'Description',
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _descController,
                              maxLines: 4,
                              maxLength: 200,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tell us about yourself...',
                                hintStyle: TextStyle(
                                  color: c.textMuted,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                counterStyle: TextStyle(
                                  color: c.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── SOCIAL LINKS ──
                  _SectionLabel(label: 'SOCIAL LINKS', c: c),
                  const SizedBox(height: 12),
                  _EditCard(
                    c: c,
                    children: [
                      _EditField(
                        c: c,
                        label: 'GitHub',
                        hint: 'github.com/username',
                        icon: Icons.code_rounded,
                        iconBg: c.iconBg,
                        iconColor: c.textSecondary,
                        controller: _githubController,
                        keyboard: TextInputType.url,
                      ),
                      _Divider(c: c),
                      _EditField(
                        c: c,
                        label: 'LinkedIn',
                        hint: 'linkedin.com/in/username',
                        icon: Icons.work_outline_rounded,
                        iconBg: const Color(0xFFE8F4FD),
                        iconColor: const Color(0xFF0077B5),
                        controller: _linkedinController,
                        keyboard: TextInputType.url,
                      ),
                      _Divider(c: c),
                      _EditField(
                        c: c,
                        label: 'Facebook',
                        hint: 'facebook.com/username',
                        icon: Icons.facebook_rounded,
                        iconBg: const Color(0xFFE7F0FF),
                        iconColor: const Color(0xFF1877F2),
                        controller: _facebookController,
                        keyboard: TextInputType.url,
                      ),
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
}

// ── Section Label ──
class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeColors c;

  const _SectionLabel({required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: c.textMuted,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Edit Card Container ──
class _EditCard extends StatelessWidget {
  final List<Widget> children;
  final ThemeColors c;

  const _EditCard({required this.children, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ── Edit Field Row ──
class _EditField extends StatelessWidget {
  final ThemeColors c;
  final String label;
  final String hint;
  final IconData icon;
  final Color? iconBg;
  final Color? iconColor;
  final TextEditingController controller;
  final TextInputType keyboard;

  const _EditField({
    required this.c,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.iconBg,
    this.iconColor,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final bg = iconBg ?? AppColors.primaryLight;
    final color = iconColor ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // ── Icon ──
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),

          // ── Input ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: keyboard,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: c.textMuted,
                      fontSize: 15,
                      fontFamily: 'Inter',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Thin Divider ──
class _Divider extends StatelessWidget {
  final ThemeColors c;
  const _Divider({required this.c});

  @override
  Widget build(BuildContext context) {
    return Divider(color: c.border, thickness: 1, height: 0, indent: 66);
  }
}

// ── Image Picker Option ──
class _PickerOption extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border, width: 1.24),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: c.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
