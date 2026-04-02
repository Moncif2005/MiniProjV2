import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OfferCard extends StatelessWidget {
  final String title;
  final String company;
  final String companyInitial;
  final Color companyBg;
  final Color companyColor;
  final String location;
  final String postedAgo;
  final String salary;
  final String jobType;
  final VoidCallback onApply;

  const OfferCard({
    super.key,
    required this.title,
    required this.company,
    required this.companyInitial,
    required this.companyBg,
    required this.companyColor,
    required this.location,
    required this.postedAgo,
    required this.salary,
    required this.jobType,
    required this.onApply, required Null Function() onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Row ──
          Row(
            children: [
              // Company avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: companyBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    companyInitial,
                    style: TextStyle(
                      color: companyColor,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
              Text(
                postedAgo,
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Tags Row ──
          Row(
            children: [
              _Tag(
                label: location,
                icon: Icons.location_on_outlined,
                bgColor: c.bg,
                textColor: c.textSecondary,
              ),
              const SizedBox(width: 8),
              _Tag(
                label: jobType,
                icon: Icons.work_outline_rounded,
                bgColor: AppColors.primaryLight,
                textColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _Tag(
                label: salary,
                icon: Icons.attach_money_rounded,
                bgColor: AppColors.greenLight,
                textColor: AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Apply Button ──
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Now',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const _Tag({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
