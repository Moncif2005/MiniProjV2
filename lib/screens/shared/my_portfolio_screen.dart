import 'dart:io';
import 'package:flutter/material.dart';
import 'package:minipr/screens/shared/pdf_viewer_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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
            padding: const EdgeInsets.all(20),
            child: _CVSection(
              isLoading: _isUploadingCV,
              onUpload: _handleCVUpload,
              onDelete: _deleteCV,
              onView: (url) => _openFileViewer(url),
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
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Projects',
                  filter: 'project',
                  active: _activeFilter,
                  onSelect: (v) => setState(() => _activeFilter = v),
                ),
                const SizedBox(width: 8),
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Failed to load portfolio.', style: TextStyle(color: AppColors.red)));
                }

                var items = snapshot.data ?? [];
                if (_activeFilter != 'all') {
                  items = items.where((i) => i['type'] == _activeFilter).toList();
                }

                if (items.isEmpty) {
                  return _buildEmptyState(c);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    final fileUrl = item['fileUrl'] as String?;
                    return _PortfolioCard(
                      item: item,
                      onDelete: () => _confirmDelete(uid, item['id']),
                      onEdit: () => _showEditDialog(context, item),
                      onView: fileUrl != null ? () => _openFileViewer(fileUrl) : null,
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
        label: const Text('Add New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
String _makeUrlInline(String url) {
  // ✅ إذا كان ملف raw من Cloudinary، أضف flag العرض المباشر
  if (url.contains('cloudinary.com') && url.contains('/raw/')) {
    return '$url?fl_inline'; 
  }
  return url;
}

// ─────────────────────────────────────────────────────────────
// 👁️ Smart File Viewer (يحمّل الملف ثم يفتحه محلياً)
// ─────────────────────────────────────────────────────────────
// void _openFileViewer(String url) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (_) => PdfViewerScreen(fileUrl: url),
//     ),
//   );
// }

void _openFileViewer(String url) async {
  try {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication, // ✅ يفتح في المتصفح الخارجي
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file. Please check your connection.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: FilledButton.styleFrom(backgroundColor: AppColors.red), 
            child: const Text('Delete')
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
        SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating)
      );
    }
  }

  Future<void> _confirmDelete(String uid, String itemId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: FilledButton.styleFrom(backgroundColor: AppColors.red), 
            child: const Text('Delete')
          ),
        ],
      ),
    );
    if (confirm == true) await _portfolioService.deletePortfolioItem(uid, itemId);
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> item) {
    final titleCtrl = TextEditingController(text: item['title']);
    final descCtrl = TextEditingController(text: item['description'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await PortfolioCertService().updatePortfolioItem(
                FirebaseAuth.instance.currentUser!.uid, 
                item['id'],
                {'title': titleCtrl.text.trim(), 'description': descCtrl.text.trim()}
              );
              if (context.mounted) Navigator.pop(ctx);
            }, 
            child: const Text('Save')
          ),
        ],
      ),
    );
  }

  void _openAddModal(String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => _AddItemForm(uid: uid),
    );
  }

  Widget _buildEmptyState(ThemeColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_rounded, size: 64, color: c.textMuted.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text('No items found', style: TextStyle(color: c.textMuted)),
        ],
      ),
    );
  }
}

// ── Helper Widgets ──

class _FilterChip extends StatelessWidget {
  final String label, filter, active;
  final Function(String) onSelect;
  const _FilterChip({required this.label, required this.filter, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isSelected = active == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(filter),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : c.textSecondary),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onView;

  const _PortfolioCard({required this.item, required this.onDelete, required this.onEdit, this.onView});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['type'] == 'project' ? '💼 Project' : '📜 Certificate',
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 18)),
                  IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 18)),
                ],
              ),
            ],
          ),
          Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (onView != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onView,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View Document'),
              ),
            ),
        ],
      ),
    );
  }
}

class _CVSection extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onUpload;
  final VoidCallback onDelete;
  final Function(String) onView;

  const _CVSection({required this.isLoading, required this.onUpload, required this.onDelete, required this.onView});

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
        border: Border.all(color: c.border)
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(hasCv ? Icons.verified_user_rounded : Icons.cloud_upload_outlined, 
                color: hasCv ? AppColors.green : AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(hasCv ? 'My Resume (CV)' : 'No CV Uploaded', 
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (isLoading)
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              else ...[
                TextButton(onPressed: onUpload, child: Text(hasCv ? 'Update' : 'Upload')),
                if (hasCv) IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20)),
              ]
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
              ),
            ),
          ]
        ],
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Add New Item', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _type,
            items: const [
              DropdownMenuItem(value: 'project', child: Text('Project')),
              DropdownMenuItem(value: 'external_cert', child: Text('Certificate')),
            ],
            onChanged: (v) => setState(() => _type = v!),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final res = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (res != null) setState(() => _file = File(res.path));
            },
            icon: Icon(_file == null ? Icons.attach_file : Icons.check),
            label: Text(_file == null ? 'Attach File' : 'File Selected'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Save'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_title.text.isEmpty || _file == null) return;
    setState(() => _isSaving = true);
    try {
      final url = await MediaService.uploadPortfolioItem('${DateTime.now().millisecondsSinceEpoch}', _file!);
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