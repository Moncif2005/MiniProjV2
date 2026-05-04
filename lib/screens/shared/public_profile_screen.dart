import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minipr/services/portfolio_cert_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String role;
  const PublicProfileScreen({super.key, required this.userId, required this.role});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  String _displayRole = 'etudiant';
  Map<String, dynamic>? _userData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPublicProfile();
  }

  Future<void> _loadPublicProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _userData = data;
          _displayRole = data?['role']?.toString() ?? 'etudiant';
          _loading = false;
        });
      } else if (mounted) {
        setState(() {
          _error = 'Profile not found';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load profile'; _loading = false; });
    }
  }

  String _getUserName() => _userData?['displayName']?.toString() ?? _userData?['name']?.toString() ?? 'Unknown';
  String? _getUserAvatar() => _userData?['photoURL']?.toString() ?? _userData?['avatar']?.toString();

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    return parts.length == 1 ? parts[0][0].toUpperCase() : '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'recruteur': return AppColors.purple;
      case 'enseignant': return AppColors.primary;
      case 'etudiant': return AppColors.green;
      default: return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'recruteur': return 'Recruiter';
      case 'enseignant': return 'Teacher';
      case 'etudiant': return 'Student';
      default: return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accentColor = _getRoleColor(_displayRole);
    final userName = _getUserName();
    final avatarUrl = _getUserAvatar();

    if (_loading) return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!, style: TextStyle(color: c.textMuted))));

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary), onPressed: () => Navigator.pop(context)),
        title: Text(userName, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Profile Header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
                      image: avatarUrl?.isNotEmpty == true ? DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover) : null,
                    ),
                    child: avatarUrl?.isNotEmpty != true ? Center(child: Text(_getInitials(userName), style: TextStyle(color: accentColor, fontSize: 32, fontFamily: 'Inter', fontWeight: FontWeight.w700))) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(userName, style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(100), border: Border.all(color: accentColor.withOpacity(0.3))),
                    child: Text(_getRoleLabel(_displayRole), style: TextStyle(color: accentColor, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),

          // ── Role Content ──
          if (_displayRole == 'recruteur') _buildRecruiterSection(c, accentColor),
          if (_displayRole == 'etudiant') _buildStudentSection(c, accentColor),
          if (_displayRole == 'enseignant') _buildTeacherSection(c, accentColor),

          // ── Contact Section ──
          _buildContactSection(c, accentColor),

          // ── Portfolio Button ──
          if ((_displayRole == 'etudiant' || _displayRole == 'enseignant') && FirebaseAuth.instance.currentUser?.uid != widget.userId)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ReadOnlyPortfolioScreen(candidateId: widget.userId, candidateCvUrl: _userData?['cv_url']?.toString()))),
                    icon: const Icon(Icons.folder_open_rounded, size: 18),
                    label: Text('View Portfolio & CV', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Recruiter Section ──
  Widget _buildRecruiterSection(ThemeColors c, Color accentColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Company Info', accentColor, c),
            _infoRow(Icons.business_rounded, 'Company', _getUserName(), accentColor, c),
            _infoRow(Icons.location_on_outlined, 'Location', _userData?['location']?.toString() ?? '—', accentColor, c),
          ],
        ),
      ),
    );
  }

  // ── Student Section ──
  Widget _buildStudentSection(ThemeColors c, Color accentColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userData?['bio']?.isNotEmpty == true) ...[
              _sectionTitle('About', accentColor, c),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border.withOpacity(0.5))), child: Text(_userData!['bio'], style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.5))),
              const SizedBox(height: 16),
            ],
            if (_userData?['skills'] is List && (_userData!['skills'] as List).isNotEmpty) ...[
              _sectionTitle('Skills', accentColor, c),
              Wrap(spacing: 8, runSpacing: 8, children: (_userData!['skills'] as List).take(5).map((s) => _skillChip(s.toString(), accentColor)).toList()),
            ],
          ],
        ),
      ),
    );
  }

  // ── Teacher Section ──
  Widget _buildTeacherSection(ThemeColors c, Color accentColor) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userData?['bio']?.isNotEmpty == true) ...[
              _sectionTitle('Specialization', accentColor, c),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border.withOpacity(0.5))), child: Text(_userData!['bio'], style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.5))),
            ],
          ],
        ),
      ),
    );
  }

  // ── Contact Section ──
  Widget _buildContactSection(ThemeColors c, Color accentColor) {
    final email = _userData?['email']?.toString() ?? '';
    final phone = _userData?['phone']?.toString() ?? '';
    if (email.isEmpty && phone.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Contact', accentColor, c),
              if (email.isNotEmpty) _contactRow(Icons.mail_outline_rounded, 'Email', email, AppColors.primary, c),
              if (phone.isNotEmpty) _contactRow(Icons.phone_rounded, 'Phone', phone, AppColors.green, c),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──
  Widget _sectionTitle(String title, Color color, ThemeColors c) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [Icon(Icons.info_outline_rounded, size: 16, color: color), const SizedBox(width: 6), Text(title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700))]),
  );

  Widget _infoRow(IconData icon, String label, String value, Color color, ThemeColors c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))), child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11, fontFamily: 'Inter')), Text(value, style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600))])),
    ]),
  );

  Widget _skillChip(String skill, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(100), border: Border.all(color: color.withOpacity(0.3))),
    child: Text(skill, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
  );

  Widget _contactRow(IconData icon, String label, String value, Color color, ThemeColors c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))), child: Icon(icon, color: color, size: 14)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: c.textSecondary, fontSize: 10, fontFamily: 'Inter')), Text(value, style: TextStyle(color: c.primary, fontSize: 14, fontFamily: 'Inter'), maxLines: 1, overflow: TextOverflow.ellipsis)])),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────
// 📁 ReadOnly Portfolio Screen (محسّن جذرياً + الودجتات المطلوبة)
// ─────────────────────────────────────────────────────────────
class _ReadOnlyPortfolioScreen extends StatefulWidget {
  final String candidateId;
  final String? candidateCvUrl;
  const _ReadOnlyPortfolioScreen({required this.candidateId, this.candidateCvUrl});
  @override
  State<_ReadOnlyPortfolioScreen> createState() => _ReadOnlyPortfolioScreenState();
}

class _ReadOnlyPortfolioScreenState extends State<_ReadOnlyPortfolioScreen> with SingleTickerProviderStateMixin {
  final _portfolioService = PortfolioCertService();
  String _activeFilter = 'all';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openFile(String url) => Navigator.push(context, MaterialPageRoute(builder: (_) => _FileViewerScreen(fileUrl: url)));
  Color _typeColor(String t) => t == 'project' ? AppColors.cyan : AppColors.green;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 18),
          ),
        ),
        title: Text('Candidate Portfolio', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800, color: c.textPrimary, fontSize: 18)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // 1. CV Section (إذا وجد)
          if (widget.candidateCvUrl?.isNotEmpty == true)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary.withOpacity(0.12), AppColors.primary.withOpacity(0.04)]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                          child: Icon(Icons.description_rounded, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Curriculum Vitae', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text('View candidate\'s resume', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _openFile(widget.candidateCvUrl!),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.remove_red_eye_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text('View CV', style: TextStyle(color: AppColors.primary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 2. Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
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

          // 3. Portfolio Items List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _portfolioService.getPortfolioStream(widget.candidateId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5))));
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyPortfolioState(filter: _activeFilter, c: c));
                }

                var items = snapshot.data!;
                if (_activeFilter != 'all') items = items.where((i) => i['type'] == _activeFilter).toList();
                
                if (items.isEmpty) return SliverToBoxAdapter(child: _EmptyPortfolioState(filter: _activeFilter, c: c));

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.3 + (index * 0.1), 1.0, curve: Curves.easeOut))),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _PublicPortfolioFullCard(
                            item: item,
                            accentColor: _typeColor(item['type'] ?? ''),
                            onView: item['fileUrl'] != null ? () => _openFile(item['fileUrl']) : null,
                          ),
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

// ─────────────────────────────────────────────────────────────
// 🎨 Public Portfolio Full-Width Card (مطلوب هنا)
// ─────────────────────────────────────────────────────────────
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

// ── ✅ Modern Filter Button ──
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

// ── ✅ File Viewer Screen (نفس السابق) ──
class _FileViewerScreen extends StatelessWidget {
  final String fileUrl;
  const _FileViewerScreen({required this.fileUrl});
  
  bool get _isPdf => fileUrl.toLowerCase().endsWith('.pdf') || fileUrl.contains('/raw/');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(backgroundColor: c.surface, title: Text(_isPdf ? 'PDF Viewer' : 'Image Viewer', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)), leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context))),
      body: _isPdf 
          ? SfPdfViewer.network(fileUrl)
          : InteractiveViewer(child: Center(child: Image.network(fileUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Center(child: Text('Failed to load image', style: TextStyle(color: c.textMuted)))))),
    );
  }
}