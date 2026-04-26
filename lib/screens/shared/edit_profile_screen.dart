import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:minipr/services/media_service.dart';

import 'package:provider/provider.dart';

import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';

import '../../providers/user_provider.dart';
import '../../l10n/app_localizations.dart';

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
  late TextEditingController _companyNameController;
  late TextEditingController _companySizeController;
  late TextEditingController _industryController;
  late TextEditingController _locationController;

  String? _avatarPath;
  bool _isSaving = false;

  bool get _isRecruiter =>
      context.read<UserProvider>().role == UserRole.recruteur;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _descController = TextEditingController(text: user.bio);
    _githubController = TextEditingController(text: user.github);
    _linkedinController = TextEditingController(text: user.linkedin);
    _facebookController = TextEditingController(text: user.facebook);
    _companyNameController = TextEditingController(text: user.name);
    _companySizeController = TextEditingController(text: user.companySize);
    _industryController = TextEditingController(text: user.industry);
    _locationController = TextEditingController(text: user.location);
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
      if (mounted) _showSnack('Could not pick image: $e', AppColors.red);
    }
  }

  void _showImagePicker() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final c = context.colors;
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: c.border, width: 1.24),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Change Profile Photo',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _SheetOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from Gallery',
                  c: c,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                Divider(color: c.border, height: 0, thickness: 1, indent: 64),
                _SheetOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take a Photo',
                  c: c,
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _save() async {
    final newName = _isRecruiter
        ? _companyNameController.text.trim()
        : _nameController.text.trim();
    if (newName.isEmpty) {
      _showSnack('Name is required', AppColors.red);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final userProvider = context.read<UserProvider>();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final currentAvatar = userProvider.avatarPath;
      String? finalPhotoUrl = currentAvatar;
      bool avatarChanged = false;

      if (_avatarPath != null && _avatarPath!.isNotEmpty) {
        if (!_avatarPath!.startsWith('http')) {
          if (currentAvatar == null || !_avatarPath!.contains(currentAvatar)) {
            avatarChanged = true;
          }
        } else if (_avatarPath != currentAvatar) {
          avatarChanged = true;
          finalPhotoUrl = _avatarPath;
        }
      }

      if (avatarChanged) {
        final uploadedUrl =
            await MediaService.uploadProfileImage(uid, File(_avatarPath!));
        if (uploadedUrl != null) {
          finalPhotoUrl = uploadedUrl;
        } else {
          throw Exception('Failed to upload image');
        }
      }

      final newEmail = _emailController.text.trim();
      final newPhone = _phoneController.text.trim();
      final newBio = _descController.text.trim();
      final newGithub = _githubController.text.trim();
      final newLinkedin = _linkedinController.text.trim();
      final newFacebook = _facebookController.text.trim();
      final newLocation = _locationController.text.trim();
      final newCompanySize = _companySizeController.text.trim();
      final newIndustry = _industryController.text.trim();

      final hasChanges = newName != userProvider.name ||
          newEmail != userProvider.email ||
          newPhone != userProvider.phone ||
          newBio != userProvider.bio ||
          newGithub != userProvider.github ||
          newLinkedin != userProvider.linkedin ||
          newFacebook != userProvider.facebook ||
          avatarChanged ||
          newLocation != userProvider.location ||
          newCompanySize != userProvider.companySize ||
          newIndustry != userProvider.industry;

      if (hasChanges) {
        userProvider.updateProfile(
          name: newName,
          email: newEmail,
          phone: newPhone,
          description: newBio,
          github: newGithub,
          linkedin: newLinkedin,
          facebook: newFacebook,
          avatarPath: finalPhotoUrl,
          location: newLocation,
          companySize: newCompanySize,
          industry: newIndustry,
        );

        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'displayName': newName,
          'email': newEmail,
          'phone': newPhone,
          'bio': newBio,
          'github': newGithub,
          'linkedin': newLinkedin,
          'facebook': newFacebook,
          'location': newLocation,
          'companySize': newCompanySize,
          'industry': newIndustry,
          if (avatarChanged && finalPhotoUrl != null) 'photoURL': finalPhotoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          final updatedDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (updatedDoc.exists) {
            context.read<UserProvider>().updateFromFirestore(updatedDoc.data()!);
          }
        }
      }

      if (mounted) {
        _showSnack(
          hasChanges ? 'Profile updated successfully' : 'No changes to save',
          AppColors.green,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Save Error: $e');
      if (mounted) _showSnack('Error: $e', AppColors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── Header ──
          _Header(c: c, isSaving: _isSaving, onSave: _save),

          // ── Scrollable body ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar section ──
                  _AvatarSection(
                    c: c,
                    isDark: isDark,
                    avatarPath: _avatarPath,
                    user: user,
                    onTap: _showImagePicker,
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Company or Personal info ──
                        if (_isRecruiter) ...[
                          _SectionHeader(
                            label: 'COMPANY INFO',
                            icon: Icons.business_rounded,
                            color: AppColors.purple,
                            c: c,
                          ),
                          const SizedBox(height: 12),
                          _FieldCard(c: c, children: [
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Company Name', hint: 'e.g. TechCorp Solutions',
                              icon: Icons.business_rounded,
                              iconColor: AppColors.purple, iconBg: AppColors.purpleLight,
                              controller: _companyNameController,
                            ),
                            _FieldDivider(c: c),
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Location', hint: 'e.g. Algiers, Algeria',
                              icon: Icons.location_on_outlined,
                              iconColor: AppColors.orange, iconBg: const Color(0xFFFFF0E8),
                              controller: _locationController,
                            ),
                            _FieldDivider(c: c),
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Company Size', hint: 'e.g. 50–200 employees',
                              icon: Icons.people_outline_rounded,
                              iconColor: AppColors.green, iconBg: AppColors.greenLight,
                              controller: _companySizeController,
                            ),
                            _FieldDivider(c: c),
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Industry', hint: 'e.g. Technology, Healthcare',
                              icon: Icons.category_outlined,
                              iconColor: AppColors.primary, iconBg: AppColors.primaryLight,
                              controller: _industryController,
                            ),
                          ]),
                          const SizedBox(height: 10),
                          _FieldCard(c: c, children: [
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Email', hint: 'contact@company.com',
                              icon: Icons.mail_outline_rounded,
                              iconColor: AppColors.primary, iconBg: AppColors.primaryLight,
                              controller: _emailController,
                              keyboard: TextInputType.emailAddress,
                            ),
                            _FieldDivider(c: c),
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Phone', hint: '+213 6xx xxx xxx',
                              icon: Icons.phone_outlined,
                              iconColor: AppColors.green, iconBg: AppColors.greenLight,
                              controller: _phoneController,
                              keyboard: TextInputType.phone,
                            ),
                          ]),
                        ] else ...[
                          _SectionHeader(
                            label: 'PERSONAL INFO',
                            icon: Icons.person_outline_rounded,
                            color: AppColors.primary,
                            c: c,
                          ),
                          const SizedBox(height: 12),
                          _FieldCard(c: c, children: [
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Full Name', hint: 'Your full name',
                              icon: Icons.person_outline_rounded,
                              iconColor: AppColors.primary, iconBg: AppColors.primaryLight,
                              controller: _nameController,
                            ),
                            _FieldDivider(c: c),
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Email', hint: 'you@example.com',
                              icon: Icons.mail_outline_rounded,
                              iconColor: AppColors.purple, iconBg: AppColors.purpleLight,
                              controller: _emailController,
                              keyboard: TextInputType.emailAddress,
                            ),
                            _FieldDivider(c: c),
                            _Field(
                              c: c, isDark: isDark,
                              label: 'Phone', hint: '+213 6xx xxx xxx',
                              icon: Icons.phone_outlined,
                              iconColor: AppColors.green, iconBg: AppColors.greenLight,
                              controller: _phoneController,
                              keyboard: TextInputType.phone,
                            ),
                          ]),
                        ],

                        const SizedBox(height: 24),

                        // ── Bio ──
                        _SectionHeader(
                          label: 'ABOUT',
                          icon: Icons.edit_note_rounded,
                          color: AppColors.orange,
                          c: c,
                        ),
                        const SizedBox(height: 12),
                        _BioCard(
                          c: c, isDark: isDark,
                          controller: _descController,
                          isRecruiter: _isRecruiter,
                        ),

                        const SizedBox(height: 24),

                        // ── Social links ──
                        _SectionHeader(
                          label: 'SOCIAL LINKS',
                          icon: Icons.link_rounded,
                          color: AppColors.green,
                          c: c,
                        ),
                        const SizedBox(height: 12),
                        _FieldCard(c: c, children: [
                          _Field(
                            c: c, isDark: isDark,
                            label: 'GitHub', hint: 'github.com/username',
                            icon: Icons.code_rounded,
                            iconColor: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F),
                            iconBg: isDark ? const Color(0xFF21262D) : const Color(0xFFF0F6FF),
                            controller: _githubController,
                            keyboard: TextInputType.url,
                          ),
                          _FieldDivider(c: c),
                          _Field(
                            c: c, isDark: isDark,
                            label: 'LinkedIn', hint: 'linkedin.com/in/username',
                            icon: Icons.work_outline_rounded,
                            iconColor: const Color(0xFF0077B5),
                            iconBg: const Color(0xFFE8F4FD),
                            controller: _linkedinController,
                            keyboard: TextInputType.url,
                          ),
                          _FieldDivider(c: c),
                          _Field(
                            c: c, isDark: isDark,
                            label: 'Facebook', hint: 'facebook.com/username',
                            icon: Icons.facebook_rounded,
                            iconColor: const Color(0xFF1877F2),
                            iconBg: const Color(0xFFE7F0FF),
                            controller: _facebookController,
                            keyboard: TextInputType.url,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final ThemeColors c;
  final bool isSaving;
  final VoidCallback onSave;
  const _Header({required this.c, required this.isSaving, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: ShapeDecoration(
                color: c.bg,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: c.border, width: 1.24),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).editProfile,
                    style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 19,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800)),
                Text(AppLocalizations.of(context).updatePersonalInfo,
                    style: TextStyle(
                        color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
              ],
            ),
          ),
          GestureDetector(
            onTap: isSaving ? null : onSave,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                gradient: isSaving
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF2B7FFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isSaving ? AppColors.primaryLight : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSaving
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, color: Colors.white, size: 15),
                        const SizedBox(width: 6),
                        Text(AppLocalizations.of(context).save,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final ThemeColors c;
  final bool isDark;
  final String? avatarPath;
  final UserProvider user;
  final VoidCallback onTap;
  const _AvatarSection({
    required this.c,
    required this.isDark,
    required this.avatarPath,
    required this.user,
    required this.onTap,
  });

  Widget _buildImage() {
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      if (avatarPath!.startsWith('http')) {
        return Image.network(avatarPath!, fit: BoxFit.cover, width: 100, height: 100,
            loadingBuilder: (_, child, p) => p == null ? child : _initials(),
            errorBuilder: (_, __, ___) => _initials());
      } else {
        return Image.file(File(avatarPath!), fit: BoxFit.cover, width: 100, height: 100,
            errorBuilder: (_, __, ___) => _initials());
      }
    }
    return _initials();
  }

  Widget _initials() => Container(
        width: 100, height: 100,
        color: AppColors.primaryLight,
        child: Center(
          child: Text(user.initials,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 34,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 28, bottom: 28),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 106,
                height: 106,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.6),
                      AppColors.purple.withOpacity(0.5),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.surface,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(child: _buildImage()),
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.purple]),
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryLight.withOpacity(0.12)
                    : AppColors.primaryLight.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(AppLocalizations.of(context).changePhoto,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final ThemeColors c;
  const _SectionHeader(
      {required this.label, required this.icon, required this.color, required this.c});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: c.textMuted,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1)),
      ],
    );
  }
}

class _FieldCard extends StatelessWidget {
  final List<Widget> children;
  final ThemeColors c;
  const _FieldCard({required this.children, required this.c});

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
                color: Color(0x14000000),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: -1),
          ],
        ),
        child: Column(children: children),
      );
}

class _Field extends StatelessWidget {
  final ThemeColors c;
  final bool isDark;
  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final TextEditingController controller;
  final TextInputType keyboard;

  const _Field({
    required this.c,
    required this.isDark,
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.controller,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: isDark ? iconColor.withOpacity(0.15) : iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: c.textMuted,
                        fontSize: 11,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3)),
                const SizedBox(height: 3),
                TextField(
                  controller: controller,
                  keyboardType: keyboard,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                        color: c.textMuted,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400),
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

class _BioCard extends StatelessWidget {
  final ThemeColors c;
  final bool isDark;
  final TextEditingController controller;
  final bool isRecruiter;
  const _BioCard(
      {required this.c,
      required this.isDark,
      required this.controller,
      required this.isRecruiter});

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
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
              spreadRadius: -1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.orange.withOpacity(0.15)
                        : const Color(0xFFFFF0E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.edit_note_rounded, color: AppColors.orange, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).description,
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600)),
                    Text(AppLocalizations.of(context).max200,
                        style: TextStyle(
                            color: c.textMuted, fontSize: 11, fontFamily: 'Inter')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border, width: 1),
              ),
              child: TextField(
                controller: controller,
                maxLines: 4,
                maxLength: 200,
                style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    height: 1.6),
                decoration: InputDecoration(
                  hintText: isRecruiter
                      ? 'Describe your company, values and mission...'
                      : 'Tell us about yourself, your skills and goals...',
                  hintStyle: TextStyle(
                      color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  counterStyle:
                      TextStyle(color: c.textMuted, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldDivider extends StatelessWidget {
  final ThemeColors c;
  const _FieldDivider({required this.c});
  @override
  Widget build(BuildContext context) =>
      Divider(color: c.border, thickness: 1, height: 0, indent: 68);
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeColors c;
  final VoidCallback onTap;
  const _SheetOption(
      {required this.icon, required this.label, required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
