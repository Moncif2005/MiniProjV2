import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../services/offers_service.dart';

class JobCard extends StatelessWidget {
  final String? title;
  final String? company;
  final String? type;
  final String? salary;
  final String? location;
  final VoidCallback? onBookmark;
  final VoidCallback? onTap;

  final Map<String, dynamic>? offer;
  final bool isRecruiter;
  final bool isOwner;
  final VoidCallback? onApply;
  final VoidCallback? onWithdraw;
  final VoidCallback? onManage;

  final VoidCallback? onAvatarTap;

  const JobCard({
    super.key,
    this.title,
    this.company,
    this.type,
    this.salary,
    this.location,
    this.onBookmark,
    this.onTap,
    this.offer,
    this.isRecruiter = false,
    this.isOwner = false,
    this.onApply,
    this.onWithdraw,
    this.onManage,
    this.onAvatarTap,
  });

  bool get _isDynamic => offer != null;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final displayTitle = _isDynamic ? offer!['title'] ?? 'Untitled' : title ?? 'Untitled';
    final displayCompany = _isDynamic ? offer!['company'] ?? 'Company' : company ?? 'Company';
    final displayType = _isDynamic ? offer!['jobType'] ?? type ?? 'Full-time' : type ?? 'Full-time';
    final displaySalary = _isDynamic ? offer!['salary'] ?? salary ?? 'Negotiable' : salary ?? 'Negotiable';
    final displayLocation = _isDynamic ? offer!['location'] ?? location ?? 'Remote' : location ?? 'Remote';
    
    final companyBg = _isDynamic ? Color(offer!['companyBgColor'] ?? 4293848063) : AppColors.primaryLight;
    final companyColor = _isDynamic ? Color(offer!['companyColor'] ?? 4283322870) : AppColors.primary;
    final companyInitial = _isDynamic ? (offer!['companyInitial'] ?? 'C') : (displayCompany.isNotEmpty ? displayCompany[0].toUpperCase() : 'J');
    final isActive = _isDynamic ? (offer!['isActive'] ?? true) : true;
    final applicantsCount = _isDynamic ? offer!['applicationsCount'] : null;

    return GestureDetector(
      onTap: !_isDynamic ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(20)),
          shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: companyBg.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(companyInitial, style: TextStyle(color: companyColor, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700))),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayTitle, style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(displayCompany, style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
                    ],
                  ),
                ),
                if (_isDynamic)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: isActive ? AppColors.greenLight : AppColors.redLight, borderRadius: BorderRadius.circular(100)),
                    child: Text(isActive ? 'Active' : 'Closed', style: TextStyle(color: isActive ? AppColors.green : AppColors.red, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 8,
              children: [
                _DetailChip(icon: Icons.location_on_outlined, text: displayLocation, color: c.textSecondary),
                _DetailChip(icon: Icons.attach_money_rounded, text: displaySalary, color: AppColors.green),
                _DetailChip(icon: Icons.schedule_rounded, text: displayType, color: AppColors.purple),
                if (_isDynamic && applicantsCount != null) _DetailChip(icon: Icons.people_outline_rounded, text: '$applicantsCount applicants', color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 16),
            if (_isDynamic && offer!['description'] != null && offer!['description'].toString().isNotEmpty) ...[
              Text(offer!['description'].toString().length > 100 ? '${offer!['description'].toString().substring(0, 100)}...' : offer!['description'], style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter', height: 1.4)),
              const SizedBox(height: 16),
            ],
            // ── Actions ──
            Row(
              children: [
                if (_isDynamic) ...[
                  // ✅ زر Manage: يظهر فقط إذا كان onManage موجوداً
                  if (isRecruiter && isOwner && onManage != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onManage, // ✅ مباشر وبسيط
                        icon: const Icon(Icons.manage_accounts_rounded, size: 18),
                        label: const Text('Manage', style: TextStyle(fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.purple, side: BorderSide(color: AppColors.purple), minimumSize: const Size(double.infinity, 44)),
                      ),
                    ),
                  // ✅ الطالب/المعلم: زر التقديم
                  if (!isRecruiter)
                    Expanded(
                      child: FutureBuilder<bool>(
                        future: _hasApplied(context),
                        builder: (ctx, snap) {
                          if (snap.connectionState == ConnectionState.waiting) return SizedBox(height: 44, child: OutlinedButton(onPressed: null, child: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))));
                          bool applied = snap.data ?? false;
                          return applied
                              ? OutlinedButton.icon(onPressed: onWithdraw, icon: const Icon(Icons.cancel_rounded, size: 18), label: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.w600)), style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: BorderSide(color: AppColors.red), minimumSize: const Size(double.infinity, 44)))
                              : FilledButton.icon(onPressed: onApply, icon: const Icon(Icons.send_rounded, size: 18), label: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.w600)), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 44)));
                        },
                      ),
                    ),
                ] else if (onBookmark != null) ...[
                  const Spacer(),
                  IconButton(onPressed: onBookmark, icon: const Icon(Icons.bookmark_border_rounded), color: c.textSecondary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _hasApplied(BuildContext context) async {
    if (!_isDynamic) return false;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      return await OffersService().hasUserAppliedToJob(applicantId: user.uid, offerId: offer!['id']);
    } catch (e) {
      return false;
    }
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _DetailChip({required this.icon, required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(text, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500))]);
}