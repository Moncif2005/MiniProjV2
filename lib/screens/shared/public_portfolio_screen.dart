import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../services/portfolio_cert_service.dart';
import '../../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class PublicPortfolioScreen extends StatefulWidget {
  final String userId;
  const PublicPortfolioScreen({super.key, required this.userId});

  @override
  State<PublicPortfolioScreen> createState() => _PublicPortfolioScreenState();
}

class _PublicPortfolioScreenState extends State<PublicPortfolioScreen> with SingleTickerProviderStateMixin {
  final _portfolioService = PortfolioCertService();
  String _activeFilter = 'all';
  late AnimationController _headerController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _openFileInternally(String url) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _InternalFileViewerScreen(fileUrl: url)));
  }

  Color _typeColor(String t) => t == 'project' ? AppColors.cyan : AppColors.green;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.surface.withOpacity(0.95), borderRadius: BorderRadius.circular(12), border: Border.all(color: c.border)),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 18),
          ),
        ),
        title: _UserNameHeader(userId: widget.userId, c: c),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header with User Info ──
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
              child: _PublicProfileHeader(userId: widget.userId, c: c),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          
          // ── Filter Bar (محسّن) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Row(
                  children: [
                    _ModernFilterBtn(label: 'All', filter: 'all', active: _activeFilter, color: AppColors.primary, onSelect: (v) => setState(() => _activeFilter = v)),
                    _ModernFilterBtn(label: 'Projects', filter: 'project', active: _activeFilter, color: AppColors.cyan, onSelect: (v) => setState(() => _activeFilter = v)),
                    _ModernFilterBtn(label: 'Certificates', filter: 'external_cert', active: _activeFilter, color: AppColors.green, onSelect: (v) => setState(() => _activeFilter = v)),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ── Portfolio List (Full Width) ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _portfolioService.getPortfolioStream(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5))));
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(child: _ErrorState(error: snapshot.error.toString(), c: c));
                }

                var items = snapshot.data ?? [];
                if (_activeFilter != 'all') items = items.where((i) => i['type'] == _activeFilter).toList();
                if (items.isEmpty) return SliverToBoxAdapter(child: _EmptyPortfolioState(filter: _activeFilter, c: c));

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _headerController, curve: Interval(0.3 + (index * 0.1), 1.0, curve: Curves.easeOut))),
                        child: _PublicPortfolioFullCard(
                          item: item,
                          accentColor: _typeColor(item['type'] ?? ''),
                          onView: item['fileUrl'] != null ? () => _openFileInternally(item['fileUrl']) : null,
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ── ✅ User Name Header Widget ──
class _UserNameHeader extends StatelessWidget {
  final String userId;
  final ThemeColors c;
  const _UserNameHeader({required this.userId, required this.c});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Portfolio', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 20));
        }
        if (snapshot.hasData) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final firstName = data?['firstName'] ?? '';
          final lastName = data?['lastName'] ?? '';
          final name = '${firstName.isNotEmpty ? '$firstName ' : ''}${lastName}';
          return Text('$name Portfolio', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 20), maxLines: 1, overflow: TextOverflow.ellipsis);
        }
        return Text('Portfolio', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 20));
      },
    );
  }
}

// ── ✅ Public Profile Header Widget ──
class _PublicProfileHeader extends StatelessWidget {
  final String userId;
  final ThemeColors c;
  const _PublicProfileHeader({required this.userId, required this.c});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Container(height: 140, color: c.surface);
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final firstName = data?['firstName'] ?? '';
        final lastName = data?['lastName'] ?? '';
        final bio = data?['bio'] ?? '';
        final avatar = data?['photoURL']?.toString() ?? data?['avatar']?.toString();
        final name = '${firstName.isNotEmpty ? '$firstName ' : ''}${lastName}'.trim();
        final initials = name.isEmpty ? '?' : name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withOpacity(0.12), AppColors.primary.withOpacity(0.04)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                  image: avatar?.isNotEmpty == true ? DecorationImage(image: NetworkImage(avatar!), fit: BoxFit.cover) : null,
                ),
                child: avatar?.isNotEmpty != true ? Center(child: Text(initials, style: TextStyle(color: AppColors.primary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700))) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? 'User' : name, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w800)),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(bio, style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter', height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── ✅ Modern Filter Button (مع ألوان ديناميكية) ──
class _ModernFilterBtn extends StatelessWidget {
  final String label, filter, active;
  final Color color;
  final Function(String) onSelect;
  const _ModernFilterBtn({required this.label, required this.filter, required this.active, required this.color, required this.onSelect});
  
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sel = active == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: sel ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 3))] : [],
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: sel ? Colors.white : c.textMuted, fontSize: 13, fontFamily: 'Inter', fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
        ),
      ),
    );
  }
}

// ── ✅ Public Portfolio Full-Width Card (محسّن) ──
class _PublicPortfolioFullCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color accentColor;
  final VoidCallback? onView;
  const _PublicPortfolioFullCard({required this.item, required this.accentColor, this.onView});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isProj = item['type'] == 'project';
    final title = item['title'] ?? 'Untitled';
    final description = item['description'] ?? '';
    
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border, width: 1.2),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon Area with accent gradient
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accentColor.withOpacity(0.15), accentColor.withOpacity(0.05)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Center(
              child: Icon(
                isProj ? Icons.work_outline_rounded : Icons.verified_user_rounded,
                color: accentColor,
                size: 40,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(100), border: Border.all(color: accentColor.withOpacity(0.3))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isProj ? Icons.work_outline_rounded : Icons.verified_user_rounded, size: 10, color: accentColor),
                      const SizedBox(width: 4),
                      Text(isProj ? 'Project' : 'Certificate', style: TextStyle(color: accentColor, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Title
                Text(title, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                
                // Description
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(description, style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.5), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ),
                
                // View Button
                if (onView != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onView,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accentColor.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility_rounded, size: 18, color: accentColor),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context).viewDocument, style: TextStyle(color: accentColor, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── ✅ Error State Widget ──
class _ErrorState extends StatelessWidget {
  final String error;
  final ThemeColors c;
  const _ErrorState({required this.error, required this.c});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.error_outline_rounded, size: 48, color: AppColors.red)),
          const SizedBox(height: 16),
          Text('Failed to load portfolio', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Inter'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── ✅ Empty State Widget ──
class _EmptyPortfolioState extends StatelessWidget {
  final String filter;
  final ThemeColors c;
  const _EmptyPortfolioState({required this.filter, required this.c});
  
  @override
  Widget build(BuildContext context) {
    final message = filter == 'project' ? 'No projects shared yet' : (filter == 'external_cert' ? 'No certificates added yet' : 'Portfolio is empty');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(24)), child: Icon(Icons.auto_awesome_motion_rounded, size: 56, color: c.textMuted)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Check back later for new content', style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Inter'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── ✅ Internal File Viewer (محسّن) ──
class _InternalFileViewerScreen extends StatelessWidget {
  final String fileUrl;
  const _InternalFileViewerScreen({required this.fileUrl});
  bool get _isPdf => fileUrl.toLowerCase().endsWith('.pdf') || fileUrl.contains('/raw/');
  
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: Text(_isPdf ? 'Document Viewer' : 'Image Viewer', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, color: c.textPrimary)),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 18),
          ),
        ),
      ),
      body: _isPdf 
          ? SfPdfViewer.network(fileUrl, canShowScrollHead: false, )
          : InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.network(
                    fileUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(color: AppColors.primary, value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                    },
                    errorBuilder: (context, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(20)), child: Icon(Icons.broken_image_rounded, size: 48, color: c.textMuted)),
                        const SizedBox(height: 16),
                        Text('Failed to load image', style: TextStyle(color: c.textMuted, fontFamily: 'Inter', fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}