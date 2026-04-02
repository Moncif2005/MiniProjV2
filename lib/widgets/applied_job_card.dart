import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum JobStatus {
  pending, reviewing, interview, accepted, rejected
}

class AppliedJobCard extends StatelessWidget {
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
  final JobStatus status;
  final String? statusMessage;
  final VoidCallback? onViewOffer;

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
    this.onViewOffer,
  });

  String get _statusLabel {
    switch (status) {
      case JobStatus.pending:   return 'En attente';
      case JobStatus.reviewing: return 'En révision';
      case JobStatus.interview: return 'Entretien';
      case JobStatus.accepted:  return 'Accepté';
      case JobStatus.rejected:  return 'Refusé';
    }
  }

  Color get _statusBg {
    switch (status) {
      case JobStatus.pending:   return const Color(0xFFF5F5F5);
      case JobStatus.reviewing: return AppColors.primaryLight;
      case JobStatus.interview: return AppColors.purpleLight;
      case JobStatus.accepted:  return AppColors.greenLight;
      case JobStatus.rejected:  return AppColors.redLight;
    }
  }

  Color get _statusColor {
    switch (status) {
      case JobStatus.pending:   return AppColors.lightTextSecondary;
      case JobStatus.reviewing: return AppColors.primary;
      case JobStatus.interview: return AppColors.purple;
      case JobStatus.accepted:  return AppColors.green;
      case JobStatus.rejected:  return AppColors.red;
    }
  }

  Color get _statusDot {
    switch (status) {
      case JobStatus.pending:   return AppColors.lightTextMuted;
      case JobStatus.reviewing: return AppColors.primaryDark;
      case JobStatus.interview: return AppColors.purple;
      case JobStatus.accepted:  return AppColors.green;
      case JobStatus.rejected:  return AppColors.red;
    }
  }

  Color? get _messageBg {
    switch (status) {
      case JobStatus.interview: return const Color(0xFFFAF5FF);
      case JobStatus.accepted:  return AppColors.greenLight;
      default:                  return null;
    }
  }

  Color? get _messageColor {
    switch (status) {
      case JobStatus.interview: return AppColors.purple;
      case JobStatus.accepted:  return AppColors.green;
      default:                  return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: companyBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        companyInitial,
                        style: TextStyle(
                          color: companyColor,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.business_rounded,
                              color: c.textSecondary,
                              size: 12),
                          const SizedBox(width: 4),
                          Text(
                            company,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 13,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // ── Status Badge ──
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
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
              ),
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
                    color: c.textSecondary),
              ),
              Expanded(
                child: _InfoItem(
                    icon: Icons.work_outline_rounded,
                    text: jobType,
                    color: AppColors.primary,
                    isBold: true),
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
                    color: c.textSecondary),
              ),
              Expanded(
                child: _InfoItem(
                    icon: Icons.access_time_rounded,
                    text: appliedAgo,
                    color: c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Divider(color: c.border, thickness: 1.24),

          // ── Footer ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      color: c.textSecondary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$views vues',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onViewOffer,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: c.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Voir l'offre",
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
              ),
            ],
          ),

          // ── Status Message ──
          if (statusMessage != null && _messageBg != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
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
}

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
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight:
                isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}