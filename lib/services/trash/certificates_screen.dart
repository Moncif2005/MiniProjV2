import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/certificate_card.dart';
import '../../../services/certificates_service.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  int _selectedFilter = 0;
  final _service = CertificatesService();
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  final List<String> _filters = ['Tous', 'Certificats', 'Formation', 'Portfolio'];

  PortfolioItemType? get _activeType {
    switch (_selectedFilter) {
      case 1: return PortfolioItemType.certificate;
      case 2: return PortfolioItemType.formation;
      case 3: return PortfolioItemType.portfolio;
      default: return null;
    }
  }

  List<PortfolioItem> _applyFilter(List<PortfolioItem> all) {
    final type = _activeType;
    if (type == null) return all;
    return all.where((i) => i.type == type).toList();
  }

  CertificateType _toCertType(PortfolioItemType t) {
    switch (t) {
      case PortfolioItemType.formation:   return CertificateType.formation;
      case PortfolioItemType.portfolio:   return CertificateType.portfolio;
      case PortfolioItemType.certificate: return CertificateType.certificate;
    }
  }

  Color _iconBgFor(PortfolioItemType t) {
    switch (t) {
      case PortfolioItemType.formation:   return AppColors.greenLight;
      case PortfolioItemType.portfolio:   return AppColors.purpleLight;
      case PortfolioItemType.certificate: return AppColors.primaryLight;
    }
  }

  Color _iconColorFor(PortfolioItemType t) {
    switch (t) {
      case PortfolioItemType.formation:   return AppColors.green;
      case PortfolioItemType.portfolio:   return AppColors.purple;
      case PortfolioItemType.certificate: return AppColors.primary;
    }
  }

  void _openAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        onAdd: (type, title, issuer, date, certId, description) async {
          final uid = _uid;
          if (uid == null) return;
          await _service.addItem(
            uid: uid, type: type, title: title,
            issuer: issuer, date: date, certId: certId,
            description: description,
          );
        },
      ),
    );
  }

  Future<void> _deleteItem(String itemId) async {
    final uid = _uid;
    if (uid == null) return;
    await _service.deleteItem(uid, itemId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Élément supprimé'),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c   = context.colors;
    final uid = _uid;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [

          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: uid != null
                      ? StreamBuilder<List<PortfolioItem>>(
                          stream: _service.streamPortfolio(uid),
                          builder: (context, snap) {
                            final count = snap.data?.length ?? 0;
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Mes Certificats & CV',
                                  style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                              Text('$count élément${count > 1 ? 's' : ''}',
                                  style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                            ]);
                          },
                        )
                      : Text('Mes Certificats & CV',
                          style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ),
                GestureDetector(
                  onTap: _openAddSheet,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
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
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.gradientBlue),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.description_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mon CV', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                    Text('CV_2026.pdf', style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontFamily: 'Inter')),
                  ]),
                ]),
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.download_rounded, color: Colors.white, size: 16),
                ),
              ]),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _openAddSheet,
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.upload_outlined, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('Mettre à jour le CV', style: TextStyle(color: AppColors.primary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),

          // ── Filter Chips ──
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? c.textPrimary : c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? c.textPrimary : c.border),
                    ),
                    child: Text(_filters[index],
                        style: TextStyle(color: isSelected ? c.surface : c.textSecondary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Firebase Stream ──
          Expanded(
            child: uid == null
                ? Center(child: Text('Non connecté', style: TextStyle(color: c.textMuted)))
                : StreamBuilder<List<PortfolioItem>>(
                    stream: _service.streamPortfolio(uid),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final filtered = _applyFilter(snap.data ?? []);
                      if (filtered.isEmpty) {
                        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.workspace_premium_outlined, color: c.textMuted, size: 48),
                          const SizedBox(height: 16),
                          Text('Aucun élément', style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _openAddSheet,
                            child: Text('Ajouter un élément', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                          ),
                        ]));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return CertificateCard(
                            title:       item.title,
                            issuer:      item.issuer,
                            date:        item.date,
                            certId:      item.certId,
                            description: item.description,
                            type:        _toCertType(item.type),
                            iconBg:      _iconBgFor(item.type),
                            iconColor:   _iconColorFor(item.type),
                            onView:      () {},
                            onShare:     () {},
                            onDelete:    () => _deleteItem(item.id),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Add Item Bottom Sheet ─────────────────────────────────────────────────────
class _AddItemSheet extends StatefulWidget {
  final Future<void> Function(PortfolioItemType type, String title, String issuer, String date, String? certId, String? description) onAdd;
  const _AddItemSheet({required this.onAdd});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  PortfolioItemType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Stack(children: [
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(color: Colors.black.withValues(alpha: 0.50), width: double.infinity, height: double.infinity),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Ajouter un élément', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(width: 32, height: 32,
                    decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.close_rounded, size: 16, color: c.textSecondary)),
              ),
            ]),
            const SizedBox(height: 24),
            _SheetOption(
              color: AppColors.primaryLight, icon: Icons.workspace_premium_rounded,
              iconColor: AppColors.primary, label: 'Ajouter un certificat', textColor: AppColors.primary,
              onTap: () async {
                Navigator.pop(context);
                await widget.onAdd(PortfolioItemType.certificate, 'Nouveau certificat', 'Émetteur', '2026', null, null);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Certificat ajouté'), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating));
                }
              },
            ),
            const SizedBox(height: 12),
            _SheetOption(
              color: AppColors.greenLight, icon: Icons.school_rounded,
              iconColor: AppColors.green, label: 'Ajouter une formation', textColor: AppColors.green,
              onTap: () async {
                Navigator.pop(context);
                await widget.onAdd(PortfolioItemType.formation, 'Nouvelle formation', 'Établissement', '2026', null, null);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Formation ajoutée'), backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating));
                }
              },
            ),
            const SizedBox(height: 12),
            _SheetOption(
              color: AppColors.purpleLight, icon: Icons.code_rounded,
              iconColor: AppColors.purple, label: 'Ajouter un projet portfolio', textColor: AppColors.purple,
              onTap: () async {
                Navigator.pop(context);
                await widget.onAdd(PortfolioItemType.portfolio, 'Nouveau projet', 'Projet personnel', '2026', null, null);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Projet ajouté'), backgroundColor: AppColors.purple, behavior: SnackBarBehavior.floating));
                }
              },
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _SheetOption extends StatelessWidget {
  final Color color, iconColor, textColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetOption({required this.color, required this.icon, required this.iconColor, required this.label, required this.textColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: textColor, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
