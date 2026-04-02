import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/certificate_card.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() =>
      _CertificatesScreenState();
}

class _CertificatesScreenState
    extends State<CertificatesScreen> {
  int _selectedFilter = 0;

  final List<String> _filters = [
    'Tous', 'Certificats', 'Formation', 'Portfolio'
  ];

  // New users start with an empty list — they add their own certificates/CV/portfolio
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 0) { return List.from(_items); }
    final types = [
      null,
      CertificateType.certificate,
      CertificateType.formation,
      CertificateType.portfolio,
    ];
    return _items
        .where((i) => i['type'] == types[_selectedFilter])
        .toList()
        .cast<Map<String, dynamic>>();
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddItemSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [

          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(
                24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(
                bottom: BorderSide(
                    color: c.border, width: 1.24),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.bg,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes Certificats & CV',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_items.length} éléments',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _openAddSheet,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── CV Banner ──
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.gradientBlue,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withValues(alpha: 0.20),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mon CV',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'No CV uploaded yet',
                              style: TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: 0.20),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Update CV Button ──
                GestureDetector(
                  onTap: _openAddSheet,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Mettre à jour le CV',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Filter Chips ──
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24),
              itemCount: _filters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedFilter = index),
                  child: AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? c.textPrimary
                          : c.surface,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? c.textPrimary
                            : c.border,
                      ),
                    ),
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        color: isSelected
                            ? c.surface
                            : c.textSecondary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Certificate List ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 8),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _filtered[index];
                return CertificateCard(
                  title: item['title'] as String,
                  issuer: item['issuer'] as String,
                  date: item['date'] as String,
                  certId: item['certId'] as String?,
                  description:
                      item['description'] as String?,
                  type: item['type'] as CertificateType,
                  iconBg: item['iconBg'] as Color,
                  iconColor: item['iconColor'] as Color,
                  onView: () {},
                  onShare: () {},
                  onDelete: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Item Bottom Sheet ──
class _AddItemSheet extends StatelessWidget {
  const _AddItemSheet();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Stack(
      children: [

        // ── Dimmed backdrop ──
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black.withValues(alpha: 0.50),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // ── Sheet ──
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ──
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ajouter un élément',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c.iconBg,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Ajouter un certificat ──
                _SheetOption(
                  color: AppColors.primaryLight,
                  icon: Icons.workspace_premium_rounded,
                  iconColor: AppColors.primary,
                  label: 'Ajouter un certificat',
                  textColor: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                            Text('Ajouter un certificat'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // ── Ajouter une formation ──
                _SheetOption(
                  color: AppColors.greenLight,
                  icon: Icons.school_rounded,
                  iconColor: AppColors.green,
                  label: 'Ajouter une formation',
                  textColor: AppColors.green,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                            Text('Ajouter une formation'),
                        backgroundColor: AppColors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // ── Ajouter un projet portfolio ──
                _SheetOption(
                  color: AppColors.purpleLight,
                  icon: Icons.code_rounded,
                  iconColor: AppColors.purple,
                  label: 'Ajouter un projet portfolio',
                  textColor: AppColors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Ajouter un projet portfolio'),
                        backgroundColor: AppColors.purple,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sheet Option Widget ──
class _SheetOption extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  const _SheetOption({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}