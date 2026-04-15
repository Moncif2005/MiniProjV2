import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/portfolio_cert_service.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart'; // قد نحتاجه لجلب بيانات المستخدم المعروض

class PublicPortfolioScreen extends StatefulWidget {
  final String userId; // ✅ نحتاج لمعرف الشخص الذي نتصفح بورتفوليو الخاص به
  const PublicPortfolioScreen({super.key, required this.userId});

  @override
  State<PublicPortfolioScreen> createState() => _PublicPortfolioScreenState();
}

class _PublicPortfolioScreenState extends State<PublicPortfolioScreen> {
  final _portfolioService = PortfolioCertService();
  String _activeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(widget.userId).get(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              return Text(
                "${data?['firstName'] ?? 'Portfolio'} ${data?['lastName'] ?? ''}",
                style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              );
            }
            return const Text('Portfolio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── 1. Filter Chips (للعرض العام) ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _PublicFilterChip(label: 'All', filter: 'all', active: _activeFilter, onSelect: (v) => setState(() => _activeFilter = v)),
                const SizedBox(width: 12),
                _PublicFilterChip(label: 'Projects', filter: 'project', active: _activeFilter, onSelect: (v) => setState(() => _activeFilter = v)),
                const SizedBox(width: 12),
                _PublicFilterChip(label: 'Certificates', filter: 'external_cert', active: _activeFilter, onSelect: (v) => setState(() => _activeFilter = v)),
              ],
            ),
          ),

          // ── 2. Stream of Public Portfolio Items ──
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // ✅ هنا الفرق: نجلب بيانات userId الممرر، وليس المستخدم الحالي
              stream: _portfolioService.getPortfolioStream(widget.userId), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Failed to load portfolio', style: TextStyle(color: AppColors.red)));
                }

                var items = snapshot.data ?? [];

                // Apply filter
                if (_activeFilter != 'all') {
                  items = items.where((i) => i['type'] == _activeFilter).toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.folder_open_outlined, size: 48, color: c.textMuted),
                        const SizedBox(height: 12),
                        Text('No items found in this section', style: TextStyle(color: c.textMuted, fontFamily: 'Inter')),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    final fileUrl = item['fileUrl'] as String?;
                    // ✅ نستخدم بطاقة العرض فقط (بدون أزرار التعديل)
                    return _PublicPortfolioCard(
                      item: item,
                      onView: fileUrl != null ? () => _openFileViewer(fileUrl) : null,
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

  void _openFileViewer(String url) async {
    try {
      final uri = Uri.parse(url);
      if (url.contains('cloudinary.com') && url.contains('/raw/')) {
        // إذا كان PDF، نضيف flag للعرض
        await launchUrl(Uri.parse('$url?fl_inline'), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open file')));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// 🎨 Filter Chip (للعرض العام)
// ─────────────────────────────────────────────────────────────
class _PublicFilterChip extends StatelessWidget {
  final String label, filter, active;
  final Function(String) onSelect;
  const _PublicFilterChip({required this.label, required this.filter, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isSelected = active == filter;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : c.textSecondary, fontWeight: FontWeight.bold, fontFamily: 'Inter')),
      selected: isSelected,
      onSelected: (_) => onSelect(filter),
      selectedColor: AppColors.primary,
      backgroundColor: c.surface,
      side: BorderSide(color: isSelected ? Colors.transparent : c.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🎨 Public Portfolio Card (Read-Only)
// ─────────────────────────────────────────────────────────────
class _PublicPortfolioCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onView;

  const _PublicPortfolioCard({required this.item, this.onView});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isProject = item['type'] == 'project';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isProject ? AppColors.primary : AppColors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isProject ? '💼 Project' : '📜 Certificate',
                  style: TextStyle(
                    color: isProject ? AppColors.primary : AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              // ✅ لا توجد أزرار تعديل هنا
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['title'] ?? '',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter', color: c.textPrimary),
          ),
          if (item['description']?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              item['description'],
              style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter', height: 1.4),
            ),
          ],
          const SizedBox(height: 12),
          if (onView != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View Document'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}