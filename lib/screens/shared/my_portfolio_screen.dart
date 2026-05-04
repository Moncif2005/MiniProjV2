import 'dart:io';
import 'package:flutter/material.dart';
import 'package:minipr/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../services/media_service.dart';
import '../../services/portfolio_cert_service.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../l10n/app_localizations.dart';

class MyPortfolioScreen extends StatefulWidget {
  const MyPortfolioScreen({super.key});
  @override
  State<MyPortfolioScreen> createState() => _MyPortfolioScreenState();
}

class _MyPortfolioScreenState extends State<MyPortfolioScreen> with SingleTickerProviderStateMixin {
  final _portfolioService = PortfolioCertService();
  bool _isUploadingCV = false;
  String _activeFilter = 'all';
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _openFileInternally(String url) => Navigator.push(context, MaterialPageRoute(builder: (_) => _InternalFileViewerScreen(fileUrl: url)));
  Color _typeColor(String t) => t == 'project' ? AppColors.cyan : AppColors.green;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: c.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.surface.withOpacity(0.9), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 18)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Portfolio', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontFamily: 'Inter', fontSize: 20)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 120)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ModernCVBanner(
                isLoading: _isUploadingCV,
                onUpload: _handleCVUpload,
                onDelete: _deleteCV,
                onView: _openFileInternally,
                hasCv: context.watch<UserProvider>().cvUrl?.isNotEmpty == true,
                cvUrl: context.watch<UserProvider>().cvUrl,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
                child: Row(
                  children: [
                    _ModernFilterBtn(label: 'All', filter: 'all', active: _activeFilter, onSelect: (v) => setState(() => _activeFilter = v)),
                    _ModernFilterBtn(label: 'Projects', filter: 'project', active: _activeFilter, onSelect: (v) => setState(() => _activeFilter = v)),
                    _ModernFilterBtn(label: 'Certificates', filter: 'external_cert', active: _activeFilter, onSelect: (v) => setState(() => _activeFilter = v)),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Portfolio List (Full Width)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _portfolioService.getPortfolioStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
                if (snapshot.hasError) return SliverToBoxAdapter(child: Center(child: Text('Error loading', style: TextStyle(color: c.textMuted))));

                var items = snapshot.data ?? [];
                if (_activeFilter != 'all') items = items.where((i) => i['type'] == _activeFilter).toList();
                if (items.isEmpty) return SliverToBoxAdapter(child: _EmptyGridState(c: c));

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _PortfolioFullCard(
                          item: item,
                          accentColor: _typeColor(item['type'] ?? ''),
                          onView: () => _openFileInternally(item['fileUrl']),
                          onEdit: () => _showEditDialog(item),
                          onDelete: () => _confirmDelete(uid, item['id']),
                        ),
                      );
                    },
                    childCount: items.length,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
        child: FloatingActionButton(
          onPressed: () => _openAddModal(uid),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ── Logic Methods ──
  Future<void> _handleCVUpload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final res = await ImagePicker().pickMedia();
    if (res == null) return;
    setState(() => _isUploadingCV = true);
    try {
      final url = await MediaService.uploadCV(uid, File(res.path));
      if (url != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({'cv_url': url, 'cv_updated_at': FieldValue.serverTimestamp()});
        if (mounted) context.read<UserProvider>().updateCvUrlOnly(url);
        _snack('✅ CV Updated', AppColors.green);
      }
    } catch (e) { _snack('❌ Failed', AppColors.red); }
    finally { if (mounted) setState(() => _isUploadingCV = false); }
  }

  Future<void> _deleteCV() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text('Remove CV?'), content: Text('This cannot be undone.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), style: FilledButton.styleFrom(backgroundColor: AppColors.red), child: Text('Remove'))]));
    if (ok == true) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'cv_url': FieldValue.delete()});
      context.read<UserProvider>().updateCvUrlOnly(null);
      _snack('🗑️ CV Removed', AppColors.green);
    }
  }

  void _snack(String msg, Color col) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: col, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  Future<void> _confirmDelete(String uid, String id) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text('Delete Item?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(c, true), style: FilledButton.styleFrom(backgroundColor: AppColors.red), child: Text('Delete'))]));
    if (ok == true) await _portfolioService.deletePortfolioItem(uid, id);
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final t = TextEditingController(text: item['title']);
    final d = TextEditingController(text: item['description'] ?? '');
    showDialog(context: context, builder: (ctx) => AlertDialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), title: Text('Edit Item', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)), content: Column(mainAxisSize: MainAxisSize.min, children: [_InputField(ctrl: t, label: 'Title', colors: context.colors), const SizedBox(height: 12), _InputField(ctrl: d, label: 'Description', lines: 3, colors: context.colors)]), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')), FilledButton(onPressed: () async { if (FirebaseAuth.instance.currentUser?.uid != null) { await PortfolioCertService().updatePortfolioItem(FirebaseAuth.instance.currentUser!.uid, item['id'], {'title': t.text.trim(), 'description': d.text.trim()}); Navigator.pop(ctx); } }, child: Text('Save'))]));
  }

void _openAddModal(String uid) {
  // 1. قراءة حالة المظهر (Dark/Light) بدون مراقبة (listen: false)
  final isDarkTheme = Provider.of<ThemeProvider>(context, listen: false).isDark;
  
  // 2. إنشاء كائن الألوان يدوياً بناءً على الحالة
  final themeColors = ThemeColors(isDarkTheme);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    backgroundColor: themeColors.surface, // استخدام الألوان المستخرجة
    builder: (_) => _AddItemForm(uid: uid, colors: themeColors),
  );
}
}

// ─────────────────────────────────────────────────────────────
// 🎨 Portfolio Full-Width Card (مصحح نهائياً)
// ─────────────────────────────────────────────────────────────
class _PortfolioFullCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color accentColor;
  final VoidCallback onView, onEdit, onDelete;
  const _PortfolioFullCard({required this.item, required this.accentColor, required this.onView, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isProj = item['type'] == 'project';
    
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
          // Header: Icon + Actions
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accentColor.withOpacity(0.15), accentColor.withOpacity(0.05)],
                  ),
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
              Positioned(
                top: 12,
                right: 12,
                child: PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: c.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.more_vert_rounded, color: c.textMuted, size: 20),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: c.textSecondary), const SizedBox(width: 8), Text('Edit', style: TextStyle(fontFamily: 'Inter'))])),
                    PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: AppColors.red), const SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.red, fontFamily: 'Inter'))])),
                  ],
                  onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    isProj ? 'Project' : 'Certificate',
                    style: TextStyle(color: accentColor, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Title
                Text(
                  item['title'] ?? 'Untitled',
                  style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Description - باستخدام if تقليدي بدلاً من ...[]
                if (item['description']?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      item['description'],
                      style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.5),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                
                // ✅✅✅ View Button - نسخة متوافقة 100% ✅✅✅
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
                            Text('View Document', style: TextStyle(color: accentColor, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
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

// ─────────────────────────────────────────────────────────────
// 🎨 Modern CV Banner
// ─────────────────────────────────────────────────────────────
class _ModernCVBanner extends StatelessWidget {
  final bool isLoading, hasCv;
  final String? cvUrl;
  final VoidCallback onUpload, onDelete;
  final Function(String) onView;
  const _ModernCVBanner({required this.isLoading, required this.onUpload, required this.onDelete, required this.onView, required this.hasCv, this.cvUrl});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accentColor = hasCv ? AppColors.green : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: hasCv ? [AppColors.green.withOpacity(0.15), AppColors.green.withOpacity(0.05)] : [AppColors.primary.withOpacity(0.15), AppColors.primary.withOpacity(0.05)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: accentColor.withOpacity(0.3)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]), child: Icon(hasCv ? Icons.check_circle_rounded : Icons.upload_file_rounded, color: accentColor, size: 28)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(hasCv ? 'CV Uploaded' : 'No CV Yet', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(hasCv ? 'Tap to preview or update' : 'Upload to attract recruiters', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'))])),
        Column(children: [
          if (isLoading) SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: accentColor, strokeWidth: 2.5))
          else ...[
            IconButton(icon: Icon(hasCv ? Icons.visibility_rounded : Icons.add_rounded, color: accentColor), onPressed: hasCv ? () => onView(cvUrl!) : onUpload),
            if (hasCv) IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.red), onPressed: onDelete),
          ],
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🎨 Modern Filter Button
// ─────────────────────────────────────────────────────────────
class _ModernFilterBtn extends StatelessWidget {
  final String label, filter, active;
  final Function(String) onSelect;
  const _ModernFilterBtn({required this.label, required this.filter, required this.active, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sel = active == filter;
    return Expanded(child: GestureDetector(onTap: () => onSelect(filter), child: AnimatedContainer(duration: const Duration(milliseconds: 250), curve: Curves.easeOut, padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: sel ? Colors.white : c.textMuted, fontSize: 13, fontFamily: 'Inter', fontWeight: sel ? FontWeight.w700 : FontWeight.w500)))));
  }
}

// ─────────────────────────────────────────────────────────────
// 📝 Add Item Form (مصحح تماماً)
// ─────────────────────────────────────────────────────────────
class _AddItemForm extends StatefulWidget {
  final String uid;
  final ThemeColors colors;  // ✅ جديد
  const _AddItemForm({required this.uid, required this.colors});
  @override
  State<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<_AddItemForm> {
  final _t = TextEditingController();
  final _d = TextEditingController();
  String _type = 'project';
  File? _f;
  bool _saving = false;

  @override
  void dispose() { _t.dispose(); _d.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;  // ✅ استخدم الألوان الممررة
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Add Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Inter', color: c.textPrimary)), IconButton(onPressed: _saving ? null : () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: c.textSecondary))]),
          const SizedBox(height: 20),
          _InputField(ctrl: _t, label: 'Title', hint: 'Project or Certificate name', colors: c),  // ✅ تمرير c
          const SizedBox(height: 12),
          _InputField(ctrl: _d, label: 'Description', hint: 'Short details...', lines: 3, colors: c),  // ✅ تمرير c
          const SizedBox(height: 16),
          GestureDetector(onTap: _saving ? null : () async { final r = await ImagePicker().pickImage(source: ImageSource.gallery); if (r != null) setState(() => _f = File(r.path)); }, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: _f == null ? c.border : AppColors.primary), borderRadius: BorderRadius.circular(14), color: _f == null ? c.inputBg : AppColors.primary.withOpacity(0.05)), child: Row(children: [Icon(_f == null ? Icons.attach_file_rounded : Icons.check_circle_rounded, color: _f == null ? c.textMuted : AppColors.primary, size: 20), const SizedBox(width: 10), Text(_f == null ? 'Attach File' : 'File Ready', style: TextStyle(color: _f == null ? c.textMuted : AppColors.primary, fontWeight: FontWeight.w600, fontFamily: 'Inter'))]))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: _saving ? null : _save, style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: _saving ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text('Save to Portfolio', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Inter')))),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    if (_t.text.isEmpty || _f == null) return;
    setState(() => _saving = true);
    try {
      final url = await MediaService.uploadPortfolioItem('${DateTime.now().millisecondsSinceEpoch}', _f!);
      if (url != null) { await PortfolioCertService().addPortfolioItem(widget.uid, {'type': _type, 'title': _t.text.trim(), 'description': _d.text.trim(), 'fileUrl': url}); if (mounted) Navigator.pop(context); }
    } finally { if (mounted) setState(() => _saving = false); }
  }
}

// ─────────────────────────────────────────────────────────────
// 🧩 Input Field (مصحح)
// ─────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final int lines;
  final ThemeColors colors;  // ✅ جديد: حقل للألوان
  
  const _InputField({required this.ctrl, required this.label, this.hint = '', this.lines = 1, required this.colors});  // ✅ مطلوب
  
  @override
  Widget build(BuildContext context) {
    final c = colors;  // ✅ استخدم الحقل الممرر
    return TextField(
      controller: ctrl,
      maxLines: lines,
      style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
        hintStyle: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter'),
        filled: true,
        fillColor: c.inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🧩 Empty State
// ─────────────────────────────────────────────────────────────
class _EmptyGridState extends StatelessWidget {
  final ThemeColors c;
  const _EmptyGridState({required this.c});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(24)), child: Icon(Icons.auto_awesome_motion_rounded, size: 48, color: c.textMuted)), const SizedBox(height: 16), Text('Portfolio Empty', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text('Tap + to start building', style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Inter'))]));
}

// ─────────────────────────────────────────────────────────────
// 📄 Viewer
// ─────────────────────────────────────────────────────────────
class _InternalFileViewerScreen extends StatelessWidget {
  final String fileUrl;
  const _InternalFileViewerScreen({required this.fileUrl});
  bool get _isPdf => fileUrl.toLowerCase().endsWith('.pdf') || fileUrl.contains('/raw/');
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(backgroundColor: c.bg, appBar: AppBar(backgroundColor: c.surface, elevation: 0, title: Text(_isPdf ? 'Document' : 'Image', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, color: c.textPrimary)), leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary), onPressed: () => Navigator.pop(context))), body: _isPdf ? SfPdfViewer.network(fileUrl) : InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Center(child: Padding(padding: const EdgeInsets.all(20), child: Image.network(fileUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Center(child: Text('Failed to load', style: TextStyle(color: c.textMuted, fontFamily: 'Inter'))))))));
  }
}