import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum JobStatus { pending, reviewing, interview, accepted, rejected, withdrawn }

class AppliedJobCard extends StatelessWidget {
  // ── Job Data ──
  final String title;
  final String company;
  final String companyInitial;
  final Color companyBg;
  final Color companyColor;
  final String location;
  final String jobType;
  final String salary;
  final String appliedAgo;
  final int views;

  // ── Application Status ──
  final JobStatus status;
  final String? statusMessage;
  final bool isJobActive; // ✅ Is the job still open?

  // ── Actions ──
  final String? applicationId;
  final VoidCallback? onWithdraw;
  final VoidCallback? onViewOffer;
  final String? recruiterId;
  final VoidCallback? onAvatarTap;

  const AppliedJobCard({
    super.key,
    required this.title,
    required this.company,
    required this.companyInitial,
    required this.companyBg,
    required this.companyColor,
    required this.location,
    required this.jobType,
    required this.salary,
    required this.appliedAgo,
    required this.views,
    required this.status,
    this.statusMessage,
    this.isJobActive = true,
    this.applicationId,
    this.onWithdraw,
    this.onViewOffer,
    this.recruiterId,
    this.onAvatarTap,
  });

  // ── Helpers: Status Labels (English) ──
  String get _statusLabel {
    switch (status) {
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.reviewing:
        return 'Under Review';
      case JobStatus.interview:
        return 'Interview';
      case JobStatus.accepted:
        return 'Accepted';
      case JobStatus.rejected:
        return 'Rejected';
      case JobStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  Color get _statusBg {
    switch (status) {
      case JobStatus.pending:
        return const Color(0xFFF5F5F5);
      case JobStatus.reviewing:
        return AppColors.primaryLight;
      case JobStatus.interview:
        return AppColors.purpleLight;
      case JobStatus.accepted:
        return AppColors.greenLight;
      case JobStatus.rejected:
        return AppColors.redLight;
      case JobStatus.withdrawn:
        return Colors.grey[200]!;
    }
  }

  Color get _statusColor {
    switch (status) {
      case JobStatus.pending:
        return AppColors.lightTextSecondary;
      case JobStatus.reviewing:
        return AppColors.primary;
      case JobStatus.interview:
        return AppColors.purple;
      case JobStatus.accepted:
        return AppColors.green;
      case JobStatus.rejected:
        return AppColors.red;
      case JobStatus.withdrawn:
        return Colors.grey[700]!;
    }
  }

  Color get _statusDot {
    switch (status) {
      case JobStatus.pending:
        return AppColors.lightTextMuted;
      case JobStatus.reviewing:
        return AppColors.primaryDark;
      case JobStatus.interview:
        return AppColors.purple;
      case JobStatus.accepted:
        return AppColors.green;
      case JobStatus.rejected:
        return AppColors.red;
      case JobStatus.withdrawn:
        return Colors.grey[500]!;
    }
  }

  Color? get _messageBg {
    switch (status) {
      case JobStatus.interview:
        return const Color(0xFFFAF5FF);
      case JobStatus.accepted:
        return AppColors.greenLight;
      default:
        return null;
    }
  }

  Color? get _messageColor {
    switch (status) {
      case JobStatus.interview:
        return AppColors.purple;
      case JobStatus.accepted:
        return AppColors.green;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // ✅ تصميم البطاقة المغلقة: خلفية رمادية فاتحة + حدود رمادية
    final cardDecoration = isJobActive
        ? ShapeDecoration(
            color: c.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.24, color: c.border),
              borderRadius: BorderRadius.circular(24),
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
          )
        : ShapeDecoration(
            color: Colors.grey[50]!, // ✅ مضافة !
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.24, color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: [],
          );

    // ✅ ألوان النصوص للبطاقة المغلقة (مضافة ! لضمان نوع Color)
    final titleColor = isJobActive ? c.textPrimary : Colors.grey[600]!;
    final textColor = isJobActive ? c.textSecondary : Colors.grey[500]!;
    final iconColor = isJobActive ? c.textSecondary : Colors.grey[400]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Avatar + Title + Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Avatar
              GestureDetector(
                onTap: isJobActive ? onAvatarTap : null,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isJobActive ? companyBg : companyBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      companyInitial,
                      style: TextStyle(
                        color: isJobActive
                            ? companyColor
                            : companyColor.withOpacity(0.5),
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ✅ Title + Company
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      company,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ✅ Status/Closed Badge
              _buildStatusBadge(c, textColor),
            ],
          ),
          const SizedBox(height: 12),

          // ── Info Grid ──
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.location_on_outlined,
                  text: location,
                  color: textColor,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.work_outline_rounded,
                  text: jobType,
                  color: isJobActive ? AppColors.primary : Colors.grey[400]!,
                  isBold: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  icon: Icons.attach_money_rounded,
                  text: salary,
                  color: textColor,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  icon: Icons.access_time_rounded,
                  text: appliedAgo,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Divider(
            color: isJobActive ? c.border : Colors.grey[300]!,
            thickness: 1.24,
          ),

          // ── Footer: Views + View Offer Button ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_outlined, color: iconColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$views views',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),

              // ✅ زر "View Offer": معطل إذا مغلقة
              isJobActive && onViewOffer != null
                  ? GestureDetector(
                      onTap: onViewOffer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: c.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: c.border, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Offer',
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: c.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200]!,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Closed',
                            style: TextStyle(
                              color: Colors.grey[500]!,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.lock_rounded,
                            size: 10,
                            color: Colors.grey[400]!,
                          ),
                        ],
                      ),
                    ),
            ],
          ),

          // ── Status Message (Interview / Accepted only) ──
          if (statusMessage != null && _messageBg != null && isJobActive) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _messageBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    status == JobStatus.accepted
                        ? Icons.celebration_rounded
                        : Icons.event_rounded,
                    color: _messageColor,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusMessage!,
                      style: TextStyle(
                        color: _messageColor,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ دالة شارة الحالة (بالإنجليزية + ألوان متوافقة)
  Widget _buildStatusBadge(ThemeColors c, Color textColor) {
    // if (!isJobActive) {
    //   return Container(
    //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    //     decoration: BoxDecoration(
    //       color: Colors.grey[200]!,
    //       borderRadius: BorderRadius.circular(100),
    //       border: Border.all(color: Colors.grey[400]!, width: 1),
    //     ),
    //     child: Row(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         Icon(Icons.lock_rounded, size: 12, color: Colors.grey[600]!),
    //         const SizedBox(width: 6),
    //         Text(
    //           'Closed',
    //           style: TextStyle(
    //             color: Colors.grey[700]!,
    //             fontSize: 10,
    //             fontFamily: 'Inter',
    //             fontWeight: FontWeight.w800,
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _statusBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _statusDot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _statusLabel,
            style: TextStyle(
              color: _statusColor,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper: Info Item ──
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isBold;
  const _InfoItem({
    required this.icon,
    required this.text,
    required this.color,
    this.isBold = false,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 12),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    ],
  );
}
