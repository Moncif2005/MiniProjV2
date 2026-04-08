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
  // ── Controllers الأساسية (لجميع المستخدمين) ──
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController; // ✅ للهاتف فقط
  late TextEditingController _descController;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;
  late TextEditingController _facebookController;

  // ── Controllers خاصة بالشركة (للمسؤولين فقط) ──
  late TextEditingController _companyNameController; // ✅ لاسم الشركة فقط
  late TextEditingController _companySizeController; // ✅ لحجم الشركة فقط
  late TextEditingController _industryController; // ✅ للصناعة فقط
  late TextEditingController _locationController; // ✅ للموقع فقط

  String? _avatarPath;
  bool _isSaving = false;

  bool get _isRecruiter =>
      context.read<UserProvider>().role == UserRole.recruteur;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);

    // ✅ تهيئة المتحكمات الأساسية
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone); // ✅ هاتف فقط
    _descController = TextEditingController(text: user.bio);
    _githubController = TextEditingController(text: user.github);
    _linkedinController = TextEditingController(text: user.linkedin);
    _facebookController = TextEditingController(text: user.facebook);

    // ✅ تهيئة متحكمات الشركة (من الحقول الجديدة في UserProvider)
    _companyNameController = TextEditingController(
      text: user.name,
    ); // اسم الشركة = name للمسؤول
    _companySizeController = TextEditingController(
      text: user.companySize,
    ); // ✅ حجم الشركة فقط
    _industryController = TextEditingController(
      text: user.industry,
    ); // ✅ صناعة فقط
    _locationController = TextEditingController(
      text: user.location,
    ); // ✅ موقع فقط

    _avatarPath = user.avatarPath;
  }

  @override
  void dispose() {
    // ✅ تفريغ جميع المتحكمات مرة واحدة فقط
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _facebookController.dispose();
    _companyNameController.dispose();
    _companySizeController.dispose();
    _industryController.dispose();
    _locationController.dispose();
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
      if (picked != null && mounted) {
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
  // ✅ التحقق من الاسم المطلوب
  if (_nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name is required'), backgroundColor: AppColors.red),
    );
    return;
  }
  
  setState(() => _isSaving = true);

  try {
    final userProvider = context.read<UserProvider>();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    
    if (uid == null) throw Exception('User not authenticated');

    // ✅ 1. جلب القيم الحالية للمقارنة
    final currentName = userProvider.name;
    final currentEmail = userProvider.email;
    final currentPhone = userProvider.phone;
    final currentBio = userProvider.bio;
    final currentGithub = userProvider.github;
    final currentLinkedin = userProvider.linkedin;
    final currentFacebook = userProvider.facebook;
    final currentAvatar = userProvider.avatarPath;
    final currentLocation = userProvider.location;
    final currentCompanySize = userProvider.companySize;
    final currentIndustry = userProvider.industry;

    // ✅ 2. جلب القيم الجديدة من المتحكمات
    final newName = _isRecruiter 
        ? _companyNameController.text.trim() 
        : _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newBio = _descController.text.trim();
    final newGithub = _githubController.text.trim();
    final newLinkedin = _linkedinController.text.trim();
    final newFacebook = _facebookController.text.trim();
    
    // ✅ القيم الجديدة للشركة (للمسؤول فقط)
    final newLocation = _locationController.text.trim();
    final newCompanySize = _companySizeController.text.trim();
    final newIndustry = _industryController.text.trim();
    
    String? finalPhotoUrl = currentAvatar;
    bool avatarChanged = false;

    // ✅ 3. معالجة الصورة (رفع جديد إذا لزم)
    if (_avatarPath != null && _avatarPath!.isNotEmpty) {
      if (!_avatarPath!.startsWith('http')) {
        // صورة محلية جديدة
        if (currentAvatar == null || !_avatarPath!.contains(currentAvatar)) {
          avatarChanged = true;
        }
      } else if (_avatarPath != currentAvatar) {
        // رابط صورة مختلف
        avatarChanged = true;
        finalPhotoUrl = _avatarPath;
      }
    }

    if (avatarChanged && uid != null) {
      final uploadedUrl = await MediaService.uploadProfileImage(uid, File(_avatarPath!));
      if (uploadedUrl != null) {
        finalPhotoUrl = uploadedUrl;
      } else {
        throw Exception('Failed to upload image');
      }
    }

    // ✅ 4. التحقق مما إذا كانت هناك أي تغييرات حقيقية
    final hasChanges = 
        newName != currentName ||
        newEmail != currentEmail ||
        newPhone != currentPhone ||
        newBio != currentBio ||
        newGithub != currentGithub ||
        newLinkedin != currentLinkedin ||
        newFacebook != currentFacebook ||
        avatarChanged ||
        newLocation != currentLocation ||
        newCompanySize != currentCompanySize ||
        newIndustry != currentIndustry;

    if (hasChanges) {
      // ✅ 5. تحديث Provider محلياً (للتحديث الفوري للواجهة)
      userProvider.updateProfile(
        name: newName,
        email: newEmail,
        phone: newPhone,
        description: newBio,
        github: newGithub,
        linkedin: newLinkedin,
        facebook: newFacebook,
        avatarPath: finalPhotoUrl,
        // ✅ الحقول الجديدة
        location: newLocation,
        companySize: newCompanySize,
        industry: newIndustry,
      );

      // ✅ 6. تحديث Firestore (الحفظ الدائم)
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'displayName': newName,
          'email': newEmail,
          'phone': newPhone,
          'bio': newBio,
          'github': newGithub,
          'linkedin': newLinkedin,
          'facebook': newFacebook,
          // ✅ الحقول الجديدة
          'location': newLocation,
          'companySize': newCompanySize,
          'industry': newIndustry,
          if (avatarChanged && finalPhotoUrl != null) 'photoURL': finalPhotoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      // ✅ 7. [الخطوة الحاسمة] إعادة مزامنة Provider مع المصدر الحقيقي (Firestore)
      // لضمان ظهور التعديلات فوراً عند العودة للبروفايل دون الحاجة لتحديث يدوي
      if (mounted) {
        final updatedDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (updatedDoc.exists) {
          context.read<UserProvider>().updateFromFirestore(updatedDoc.data()!);
        }
      }
    }

    // ✅ 8. إظهار النتيجة والعودة
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
    debugPrint('❌ Save Error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
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
                  // ── Avatar ──
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
                                      ? Image.network(
                                          _avatarPath!,
                                          fit: BoxFit.cover,
                                          loadingBuilder:
                                              (
                                                _,
                                                child,
                                                progress,
                                              ) => progress == null
                                              ? child
                                              : Center(
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
                                                ),
                                          errorBuilder: (_, __, ___) =>
                                              _buildInitials(c, user),
                                        )
                                      : Image.file(
                                          File(_avatarPath!),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _buildInitials(c, user),
                                        ))
                                : _buildInitials(c, user),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _showImagePicker,
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

                  // ── COMPANY INFO (للمسؤول فقط) ──
                  if (_isRecruiter) ...[
                    _SectionLabel(label: 'COMPANY INFO', c: c),
                    const SizedBox(height: 12),
                    _EditCard(
                      c: c,
                      children: [
                        _EditField(
                          c: c,
                          label: 'Company Name',
                          hint: 'Ex: TechCorp Solutions',
                          icon: Icons.business_rounded,
                          controller: _companyNameController,
                        ),
                        _Divider(c: c),
                        _EditField(
                          c: c,
                          label: 'Location',
                          hint: 'Ex: Riyadh, Saudi Arabia',
                          icon: Icons.location_on_outlined,
                          controller: _locationController,
                        ),
                        _Divider(c: c),
                        _EditField(
                          c: c,
                          label: 'Company Size',
                          hint: 'Ex: 50-200 employees',
                          icon: Icons.people_rounded,
                          controller: _companySizeController,
                        ),
                        _Divider(c: c),
                        _EditField(
                          c: c,
                          label: 'Industry',
                          hint: 'Ex: Technology, Healthcare',
                          icon: Icons.language_rounded,
                          controller: _industryController,
                        ),
                        _Divider(c: c),
                        _EditField(
                          c: c,
                          label: 'Email',
                          hint: 'contact@company.com',
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
                  ],

                  // ── PERSONAL INFO (لغير المسؤول) ──
                  if (!_isRecruiter) ...[
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
                  ],

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
                                hintText: _isRecruiter
                                    ? 'Tell us about your company...'
                                    : 'Tell us about yourself...',
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

  Widget _buildInitials(ThemeColors c, UserProvider user) => Container(
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
  );
}

// ── Helper Widgets ──
class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeColors c;
  const _SectionLabel({required this.label, required this.c});
  @override
  Widget build(BuildContext context) => Padding(
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

class _EditCard extends StatelessWidget {
  final List<Widget> children;
  final ThemeColors c;
  const _EditCard({required this.children, required this.c});
  @override
  Widget build(BuildContext context) => Container(
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

class _Divider extends StatelessWidget {
  final ThemeColors c;
  const _Divider({required this.c});
  @override
  Widget build(BuildContext context) =>
      Divider(color: c.border, thickness: 1, height: 0, indent: 66);
}
