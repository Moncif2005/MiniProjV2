import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';

class ChooseRoleScreen extends StatefulWidget {
  final String uid;
  const ChooseRoleScreen({super.key, required this.uid});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  int _selected = 0; // 0=etudiant, 1=enseignant, 2=recruteur
  bool _isSaving = false; // ✅ Fix 2: prevents double-tap race condition

  static const _roles = [
    _RoleOption(
      label: 'Student',
      subtitle: 'Learn new skills & find jobs',
      icon: Icons.school_rounded,
      color: AppColors.primary,
    ),
    _RoleOption(
      label: 'Teacher',
      subtitle: 'Create courses & teach students',
      icon: Icons.cast_for_education_rounded,
      color: AppColors.green,
    ),
    _RoleOption(
      label: 'Recruiter',
      subtitle: 'Post jobs & find talent',
      icon: Icons.business_center_rounded,
      color: AppColors.purple,
    ),
  ];

  Future<void> _confirmRole() async {
    // ✅ Fix 2: guard against double-tap
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final roleStrings = ['etudiant', 'enseignant', 'recruteur'];
    try {
      // ✅ Fix 4: get the current Firebase user so we can include their
      // Google profile data (name, email, photoUrl) in the Firestore write.
      final firebaseUser = FirebaseAuth.instance.currentUser;

      // ✅ Fix 4: use set+merge so this works whether the doc already exists
      // (glitch path) or not (fresh path), and fills all profile fields.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set({
        'role': roleStrings[_selected],
        'email': firebaseUser?.email ?? '',
        'name': firebaseUser?.displayName ?? '',
        'firstName':
            (firebaseUser?.displayName ?? '').split(' ').first,
        'photoUrl': firebaseUser?.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge keeps any existing fields intact

      // AuthWrapper will now detect the signed-in user with a valid role
      // and route correctly — no manual pushNamed needed.
      // But we still push to /home to trigger AuthWrapper's rebuild.
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save role. Please try again.'),
          backgroundColor: AppColors.red,
        ));
        setState(() => _isSaving = false); // re-enable on error
      }
    }
    // Note: no finally reset of _isSaving — if success we navigate away anyway
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'One last step 👋',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us who you are so we can personalize your experience.',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 40),

              // Role cards
              ...List.generate(_roles.length, (i) {
                final role = _roles[i];
                final active = _selected == i;
                return GestureDetector(
                  onTap: _isSaving ? null : () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: active
                          ? role.color.withValues(alpha: 0.08)
                          : c.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? role.color : c.border,
                        width: active ? 2 : 1.24,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: role.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child:
                              Icon(role.icon, color: role.color, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role.label,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                role.subtitle,
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? role.color : Colors.transparent,
                            border: Border.all(
                              color: active ? role.color : c.border,
                              width: 2,
                            ),
                          ),
                          child: active
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // ✅ Fix 2: disabled while saving
                  onPressed: _isSaving ? null : _confirmRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roles[_selected].color,
                    disabledBackgroundColor:
                        _roles[_selected].color.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOption {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _RoleOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
