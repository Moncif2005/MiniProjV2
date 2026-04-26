import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class ChooseRoleScreen extends StatefulWidget {
  final String uid;
  const ChooseRoleScreen({super.key, required this.uid});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  int _selected = 0; // 0=etudiant, 1=enseignant, 2=recruteur
  bool _isSaving = false;

  final _roleValues = ['etudiant', 'enseignant', 'recruteur'];
  final _roleColors = [AppColors.primary, AppColors.green, AppColors.purple];
  final _roleIcons = [
    Icons.school_rounded,
    Icons.cast_for_education_rounded,
    Icons.business_center_rounded,
  ];

  Future<void> _confirmRole() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .set({
        'role': _roleValues[_selected],
        'email': firebaseUser?.email ?? '',
        'name': firebaseUser?.displayName ?? '',
        'firstName': (firebaseUser?.displayName ?? '').split(' ').first,
        'photoUrl': firebaseUser?.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${AppLocalizations.of(context).error}. ${AppLocalizations.of(context).back}'),
          backgroundColor: AppColors.red,
        ));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final roles = [
      _RoleOption(label: AppLocalizations.of(context).roleStudent, subtitle: AppLocalizations.of(context).studentSubtitle, icon: _roleIcons[0], color: _roleColors[0]),
      _RoleOption(label: AppLocalizations.of(context).roleTeacher, subtitle: AppLocalizations.of(context).teacherSubtitle, icon: _roleIcons[1], color: _roleColors[1]),
      _RoleOption(label: AppLocalizations.of(context).roleRecruiter, subtitle: AppLocalizations.of(context).recruiterSubtitle, icon: _roleIcons[2], color: _roleColors[2]),
    ];

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).oneLastStep,
                style: TextStyle(
                  color: c.textPrimary, fontSize: 28, fontFamily: 'Inter', fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).personalizeExperience,
                style: TextStyle(color: c.textSecondary, fontSize: 16, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 40),

              ...List.generate(roles.length, (i) {
                final role = roles[i];
                final active = _selected == i;
                return GestureDetector(
                  onTap: _isSaving ? null : () => setState(() => _selected = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: active ? role.color.withValues(alpha: 0.08) : c.surface,
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
                          child: Icon(role.icon, color: role.color, size: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(role.label,
                                  style: TextStyle(
                                    color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700,
                                  )),
                              const SizedBox(height: 2),
                              Text(role.subtitle,
                                  style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter')),
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
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
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
                  onPressed: _isSaving ? null : _confirmRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roleColors[_selected],
                    disabledBackgroundColor: _roleColors[_selected].withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          AppLocalizations.of(context).getStarted,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700,
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
  const _RoleOption({required this.label, required this.subtitle, required this.icon, required this.color});
}
