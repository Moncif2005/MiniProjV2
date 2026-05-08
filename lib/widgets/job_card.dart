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

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'remote':
        return AppColors.cyan;
      case 'part-time':
        return AppColors.purple;
      case 'full-time':
        return AppColors.green;
      case 'hybrid':
        return AppColors.orange;
      case 'contract':
        return AppColors.pink;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDark;

    // Data resolution
    final displayTitle = _isDynamic
        ? offer!['title'] ?? 'Untitled'
        : title ?? 'Untitled';
    final displayCompany = _isDynamic
        ? offer!['company'] ?? 'Company'
        : company ?? 'Company';
    final displayType = _isDynamic
        ? offer!['jobType'] ?? type ?? 'Full-time'
        : type ?? 'Full-time';
    final displaySalary = _isDynamic
        ? offer!['salary'] ?? salary ?? 'Negotiable'
        : salary ?? 'Negotiable';
    final displayLocation = _isDynamic
        ? offer!['location'] ?? location ?? 'Remote'
        : location ?? 'Remote';

    // Colors & Logo - with safe defaults
    final companyBg = _isDynamic
        ? Color(offer!['companyBgColor'] ?? 4293848063)
        : AppColors.primaryLight;
    final companyColor = _isDynamic
        ? Color(offer!['companyColor'] ?? 4283322870)
        : AppColors.primary;
    final companyInitial = _isDynamic
        ? (offer!['companyInitial'] ?? 'C')
        : (displayCompany.isNotEmpty ? displayCompany[0].toUpperCase() : 'J');
    final companyLogo = _isDynamic ? offer!['companyLogo'] as String? : null;

    final isActive = _isDynamic ? (offer!['isActive'] ?? true) : true;
    final status = _isDynamic ? offer!['status'] as String? : null;
    final applicantsCount = _isDynamic ? offer!['applicationsCount'] : null;
    final typeColor = _typeColor(displayType);

    return GestureDetector(
      onTap: !_isDynamic ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border, width: 1.5),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Accent bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [typeColor, typeColor.withOpacity(0.4)],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: companyBg.withOpacity(isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: companyColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: companyLogo != null && companyLogo.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.network(
                                    companyLogo,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        companyInitial,
                                        style: TextStyle(
                                          color: companyColor,
                                          fontSize: 20,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    companyInitial,
                                    style: TextStyle(
                                      color: companyColor,
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayTitle,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              displayCompany,
                              style: TextStyle(
                                color: c.textSecondary,
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isDynamic) _buildStatusBadges(c, isActive, status),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ✅ Job Detail Pills (Fixed: Salary without icon to avoid redundancy)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DetailPill(
                        icon: Icons.schedule_rounded,
                        text: displayType,
                        color: typeColor,
                      ),
                      // ✅ الراتب: بدون أيقونة لتجنب التكرار مع رمز العملة في النص
                      _DetailPill(
                        icon: null,
                        text: displaySalary,
                        color: AppColors.green,
                      ),
                      _DetailPill(
                        icon: Icons.location_on_outlined,
                        text: displayLocation,
                        color: AppColors.primary,
                      ),
                      if (_isDynamic && applicantsCount != null)
                        _DetailPill(
                          icon: Icons.people_outline_rounded,
                          text: '$applicantsCount applicants',
                          color: AppColors.purple,
                        ),
                    ],
                  ),

                  // ✅ Description with "Read More" logic
                  if (_isDynamic &&
                      offer!['description'] != null &&
                      offer!['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    // ✅ الجديد (واضح ومقروء):
                    _ExpandableText(
                      text: offer!['description'].toString(),
                      color: c.textSecondary, // ← أغمق وأفضل للقراءة
                      maxLines: 3,
                    ),
                  ],

                  const SizedBox(height: 16),
                  Divider(color: c.border, thickness: 1, height: 1),
                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    children: [
                      if (_isDynamic) ...[
                        if (isRecruiter && isOwner && onManage != null)
                          Expanded(
                            child: _ActionButton(
                              label: 'Manage',
                              icon: Icons.manage_accounts_rounded,
                              color: AppColors.lightBg,
                              onTap: onManage,
                              filled: false,
                            ),
                          ),
                        if (!isRecruiter)
                          Expanded(
                            child: FutureBuilder<bool>(
                              future: _hasApplied(context),
                              builder: (ctx, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                    height: 44,
                                    child: Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: c.primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                final applied = snap.data ?? false;
                                return applied
                                    ? _ActionButton(
                                        label: 'Withdraw',
                                        icon: Icons.cancel_rounded,
                                        color: AppColors.red,
                                        onTap: onWithdraw,
                                        filled: false,
                                      )
                                    : _ActionButton(
                                        label: 'Apply Now',
                                        icon: Icons.send_rounded,
                                        color: c.primary,
                                        onTap: onApply,
                                        filled: true,
                                      );
                              },
                            ),
                          ),
                      ] else if (onBookmark != null) ...[
                        const Spacer(),
                        IconButton(
                          onPressed: onBookmark,
                          icon: Icon(
                            Icons.bookmark_border_rounded,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadges(ThemeColors c, bool isActive, String? status) {
    if (!isRecruiter) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == 'pending')
          _StatusBadge(
            label: 'Pending',
            color: AppColors.orange,
            icon: Icons.pending_rounded,
          ),
        if (status == 'rejected')
          _StatusBadge(
            label: 'Rejected',
            color: AppColors.red,
            icon: Icons.cancel_rounded,
          ),
        // ✅ إضافة حالة 'Active' للموافقة
        if (status == 'approved' || (status == null && isActive))
          _StatusBadge(
            label: 'Active',
            color: AppColors.green,
            icon: Icons.check_circle_rounded,
          ),
      ],
    );
  }

  Future<bool> _hasApplied(BuildContext context) async {
    if (!_isDynamic) return false;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      return await OffersService().hasUserAppliedToJob(
        applicantId: user.uid,
        offerId: offer!['id'],
      );
    } catch (e) {
      return false;
    }
  }
}

// ── Action button ──
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool filled;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.purple,
          borderRadius: BorderRadius.circular(12),
          // border: filled
          //     ? null
          //     : Border.all(color: color.withOpacity(0.6), width: 1.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : color,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status badge ──
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    margin: const EdgeInsets.only(left: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

// ── Detail pill (Fixed: Handles null icon safely) ──
class _DetailPill extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;
  const _DetailPill({this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      // ✅ زيادة padding قليلاً عندما لا توجد أيقونة لتحقيق التوازن البصري
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 14 : 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ التحقق من null قبل بناء الأيقونة لمنع الخطأ
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── NEW: Expandable Text Widget ──
class _ExpandableText extends StatefulWidget {
  final String text;
  final Color color;
  final int maxLines;
  const _ExpandableText({
    required this.text,
    required this.color,
    this.maxLines = 3,
  });

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // إذا كان النص قصيراً، اعرضه مباشرة بدون زر
    if (widget.text.length < 120) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.color,
            fontSize: 12,
            fontFamily: 'Inter',
            height: 1.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: _expanded ? null : widget.maxLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.color,
              fontSize: 12,
              fontFamily: 'Inter',
              height: 1.5,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _expanded ? 'Show less' : 'Read more',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
