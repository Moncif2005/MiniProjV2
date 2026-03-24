import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CertificateType { certificate, formation, portfolio }

class CertificateCard extends StatelessWidget {
  final String title;
  final String issuer;
  final String date;
  final String? certId;
  final String? description;
  final CertificateType type;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onView;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const CertificateCard({
    super.key,
    required this.title,
    required this.issuer,
    required this.date,
    this.certId,
    this.description,
    required this.type,
    required this.iconBg,
    required this.iconColor,
    this.onView,
    this.onShare,
    this.onDelete,
  });

  String get _typeLabel {
    switch (type) {
      case CertificateType.certificate: return 'Certificat';
      case CertificateType.formation:   return 'Formation';
      case CertificateType.portfolio:   return 'Portfolio';
    }
  }

  Color get _typeBg {
    switch (type) {
      case CertificateType.certificate: return AppColors.primaryLight;
      case CertificateType.formation:   return AppColors.greenLight;
      case CertificateType.portfolio:   return AppColors.purpleLight;
    }
  }

  Color get _typeColor {
    switch (type) {
      case CertificateType.certificate: return AppColors.primary;
      case CertificateType.formation:   return AppColors.green;
      case CertificateType.portfolio:   return AppColors.purple;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Title + Badge ──
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _typeBg,
                        borderRadius:
                            BorderRadius.circular(100),
                      ),
                      child: Text(
                        _typeLabel,
                        style: TextStyle(
                          color: _typeColor,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ── Issuer ──
                Row(
                  children: [
                    Icon(Icons.business_rounded,
                        color: c.textSecondary, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      issuer,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 13,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ── Date + ID ──
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: c.textMuted, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: c.textMuted,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (certId != null) ...[
                      Text(' • ',
                          style: TextStyle(
                              color: c.textMuted,
                              fontSize: 12)),
                      Flexible(
                        child: Text(
                          'ID: $certId',
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),

                // ── Description ──
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // ── Actions ──
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onView,
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: c.bg,
                            borderRadius:
                                BorderRadius.circular(14),
                            border: Border.all(
                                color: c.border,
                                width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.link_rounded,
                                  size: 12,
                                  color: c.textPrimary),
                              const SizedBox(width: 4),
                              Text(
                                'Voir le lien',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onShare,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.share_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}