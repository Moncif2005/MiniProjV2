import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // ✅ استيراد مكتبة PDF للعرض الداخلي

import '../../services/media_service.dart';
import '../../services/portfolio_cert_service.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';

class MyPortfolioScreen extends StatefulWidget {
  const MyPortfolioScreen({super.key});

  @override
  State<MyPortfolioScreen> createState() => _MyPortfolioScreenState();
}

class _MyPortfolioScreenState extends State<MyPortfolioScreen> {
  final _portfolioService = PortfolioCertService();
  bool _isUploadingCV = false;
  String _activeFilter = 'all';

  // ✅ دالة لفتح الملف داخلياً (PDF أو Image) بدلاً من المتصفح
  void _openFileInternally(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _InternalFileViewerScreen(fileUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Portfolio',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── 1. CV Section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: _CVSection(
              isLoading: _isUploadingCV,
              onUpload: _handleCVUpload,
              onDelete: _deleteCV,
              onView: (url) => _openFileInternally(url), // ✅ تعديل هنا
            ),
          ),

          // ── 2. Filter Chips ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  filter: 'all',
                  active: _activeFilter,
                  onSelect: (v) => setState(() => _activeFilter = v),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Projects',
                  filter: 'project',
                  active: _activeFilter,
                  onSelect: (v) => setState(() => _activeFilter = v),
                ),
                const SizedBox(width: 12),
                _FilterChip(
                  label: 'Certificates',
                  filter: 'external_cert',
                  active: _activeFilter,
                  onSelect: (v) => setState(() => _activeFilter = v),
                ),
              ],
            ),
          ),

          // ── 3. Portfolio Items Stream ──
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _portfolioService.getPortfolioStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            color: c.textMuted,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load portfolio',
                      style: TextStyle(
                        color: AppColors.red,
                        fontFamily: 'Inter',
                      ),
                    ),
                  );
                }

                var items = snapshot.data ?? [];

                if (_activeFilter != 'all') {
                  items = items
                      .where((i) => i['type'] == _activeFilter)
                      .toList();
                }

                if (items.isEmpty) return _buildEmptyState(c);

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    final fileUrl = item['fileUrl'] as String?;
                    return _PortfolioCard(
                      item: item,
                      onDelete: () => _confirmDelete(uid, item['id']),
                      onEdit: () => _showEditDialog(item),
                      onView: fileUrl != null
                          ? () =>
                                _openFileInternally(fileUrl) // ✅ تعديل هنا
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddModal(uid),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add New',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _handleCVUpload() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final result = await ImagePicker().pickMedia();
    if (result == null) return;

    setState(() => _isUploadingCV = true);
    try {
      final file = File(result.path);
      final url = await MediaService.uploadCV(uid, file);
      if (url != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'cv_url': url,
          'cv_updated_at': FieldValue.serverTimestamp(),
        });
        if (mounted) context.read<UserProvider>().updateCvUrlOnly(url);
        _showSnackBar('✅ CV updated successfully', AppColors.green);
      }
    } catch (e) {
      _showSnackBar('❌ Upload failed', AppColors.red);
    } finally {
      if (mounted) setState(() => _isUploadingCV = false);
    }
  }

  Future<void> _deleteCV() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete CV?'),
        content: const Text('Are you sure you want to remove your CV?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'cv_url': FieldValue.delete(),
      });
      context.read<UserProvider>().updateCvUrlOnly(null);
      _showSnackBar('🗑️ CV removed', AppColors.green);
    }
  }

  void _showSnackBar(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(String uid, String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true)
      await _portfolioService.deletePortfolioItem(uid, itemId);
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final themeData = Theme.of(context);
    final titleCtrl = TextEditingController(text: item['title']);
    final descCtrl = TextEditingController(text: item['description'] ?? '');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final itemId = item['id'];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Item',
            style: TextStyle(
              color: themeData.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                style: TextStyle(
                  color: themeData.colorScheme.onSurface,
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(
                    color: themeData.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: themeData.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: themeData.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                style: TextStyle(
                  color: themeData.colorScheme.onSurface,
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    color: themeData.colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: themeData.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: themeData.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeData.colorScheme.onSurfaceVariant,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                if (uid == null) return;

                await PortfolioCertService().updatePortfolioItem(uid, itemId, {
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                });

                if (mounted) {
                  Navigator.pop(dialogCtx);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Save', style: TextStyle(fontFamily: 'Inter')),
            ),
          ],
        );
      },
    );
  }

  void _openAddModal(String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => _AddItemForm(uid: uid),
    );
  }

  Widget _buildEmptyState(ThemeColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_motion_rounded,
            size: 64,
            color: c.textMuted.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No items found',
            style: TextStyle(color: c.textMuted, fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🎨 Filter Chip
// ─────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label, filter, active;
  final Function(String) onSelect;
  const _FilterChip({
    required this.label,
    required this.filter,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isSelected = active == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(filter),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : c.textSecondary,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
      backgroundColor: c.surface,
      side: BorderSide(color: isSelected ? Colors.transparent : c.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 🎨 Portfolio Card
// ─────────────────────────────────────────────────────────────
class _PortfolioCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onView;

  const _PortfolioCard({
    required this.item,
    required this.onDelete,
    required this.onEdit,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (item['type'] == 'project'
                              ? AppColors.primary
                              : AppColors.green)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item['type'] == 'project' ? '💼 Project' : '📜 Certificate',
                  style: TextStyle(
                    color: item['type'] == 'project'
                        ? AppColors.primary
                        : AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: c.textSecondary,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    splashRadius: 20,
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.red,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['title'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'Inter',
              color: c.textPrimary,
            ),
          ),
          if (item['description']?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Text(
              item['description'],
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 13,
                fontFamily: 'Inter',
                height: 1.4,
              ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 📎 CV Section
// ─────────────────────────────────────────────────────────────
class _CVSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onUpload;
  final VoidCallback onDelete;
  final Function(String) onView;

  const _CVSection({
    required this.isLoading,
    required this.onUpload,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();
    final hasCv = user.cvUrl?.isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                hasCv
                    ? Icons.verified_user_rounded
                    : Icons.cloud_upload_outlined,
                color: hasCv ? AppColors.green : AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasCv ? 'My Resume (CV)' : 'No CV Uploaded',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: c.textPrimary,
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                TextButton(
                  onPressed: onUpload,
                  child: Text(
                    hasCv ? 'Update' : 'Upload',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                if (hasCv)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.red,
                      size: 20,
                    ),
                  ),
              ],
            ],
          ),
          if (hasCv) ...[
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => onView(user.cvUrl!),
                icon: const Icon(Icons.remove_red_eye_outlined),
                label: const Text('Preview CV'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 📝 Add Item Form
// ─────────────────────────────────────────────────────────────
class _AddItemForm extends StatefulWidget {
  final String uid;
  const _AddItemForm({required this.uid});
  @override
  State<_AddItemForm> createState() => _AddItemFormState();
}

class _AddItemFormState extends State<_AddItemForm> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _type = 'project';
  File? _file;
  bool _isSaving = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      color: c.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: c.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'project', child: Text('💼 Project')),
                  DropdownMenuItem(
                    value: 'external_cert',
                    child: Text('📜 Certificate'),
                  ),
                ],
                onChanged: _isSaving ? null : (v) => setState(() => _type = v!),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: c.textSecondary),
                  filled: true,
                  fillColor: c.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                style: TextStyle(color: c.textPrimary, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _title,
                style: TextStyle(color: c.textPrimary, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: c.textSecondary),
                  filled: true,
                  fillColor: c.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _desc,
                maxLines: 3,
                style: TextStyle(color: c.textPrimary, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: c.textSecondary),
                  filled: true,
                  fillColor: c.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _isSaving
                    ? null
                    : () async {
                        final res = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                        );
                        if (res != null) setState(() => _file = File(res.path));
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _file == null ? c.border : AppColors.green,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _file == null
                        ? c.bg
                        : AppColors.green.withOpacity(0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _file == null
                            ? Icons.attach_file_rounded
                            : Icons.check_circle_rounded,
                        color: _file == null ? c.textMuted : AppColors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _file == null ? 'Attach Image/File' : 'File Selected ✓',
                        style: TextStyle(
                          color: _file == null ? c.textMuted : AppColors.green,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save to Portfolio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_title.text.isEmpty || _file == null) return;
    setState(() => _isSaving = true);
    try {
      final url = await MediaService.uploadPortfolioItem(
        '${DateTime.now().millisecondsSinceEpoch}',
        _file!,
      );
      if (url != null) {
        await PortfolioCertService().addPortfolioItem(widget.uid, {
          'type': _type,
          'title': _title.text.trim(),
          'description': _desc.text.trim(),
          'fileUrl': url,
        });
        if (mounted) Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ─────────────────────────────────────────────────────────────
// 📄 شاشة عرض ذكية ومصححة (PDF أو Image) - مع توسيط مثالي للصورة
// ─────────────────────────────────────────────────────────────
class _InternalFileViewerScreen extends StatefulWidget {
  final String fileUrl;
  const _InternalFileViewerScreen({required this.fileUrl});

  @override
  State<_InternalFileViewerScreen> createState() => _InternalFileViewerScreenState();
}

class _InternalFileViewerScreenState extends State<_InternalFileViewerScreen> {
  bool _isPdf = false;

  @override
  void initState() {
    super.initState();
    final url = widget.fileUrl.toLowerCase();
    if (url.contains('/raw/') || url.endsWith('.pdf')) {
      _isPdf = true;
    } else {
      _isPdf = false;
    }
    debugPrint('🔍 Opening URL: ${widget.fileUrl} | Type: ${_isPdf ? "PDF" : "Image"}');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isPdf ? 'PDF Viewer' : 'Image Viewer'),
        backgroundColor: c.surface,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: _isPdf
          ? SfPdfViewer.network(widget.fileUrl)
          : InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              // ✅ الحل هنا: استخدام Center و ConstrainedBox لضمان التوسيط
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width,
                    maxHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Image.network(
                    widget.fileUrl,
                    fit: BoxFit.contain, // ✅ هذا يضمن ظهور الصورة كاملة داخل الحدود
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('❌ Image Error: $error');
                      return Center(child: Text('Failed to load image'));
                    },
                  ),
                ),
              ),
            ),
    );
  }
}