import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minipr/services/portfolio_cert_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // ✅ تأكد من وجود هذا الاستيراد
import '../../theme/app_colors.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  final String role; // 'etudiant' | 'recruteur' | 'enseignant'

  const PublicProfileScreen({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  String _displayRole = 'etudiant';
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _loading = true;
  String? _error;

  int _jobsPosted = 0;
  int _totalApplications = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPublicProfile();
  }

  // ✅ تم حذف دالة _launchURL القديمة واستبدالها بفتح داخلي

  Future<void> _loadPublicProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(widget.userId).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        final role = data?['role']?.toString() ?? 'etudiant';

        setState(() {
          _userData = data;
          _displayRole = role;
          _loading = false;
        });

        if (role == 'recruteur') {
          _loadRecruiterStats();
        }
      } else if (mounted) {
        setState(() {
          _error = 'Profile not found';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = 'Failed to load profile';
          _loading = false;
        });
    }
  }

  Future<void> _loadRecruiterStats() async {
    try {
      final offersSnap = await _firestore
          .collection('offers')
          .where('recruiterId', isEqualTo: widget.userId)
          .get();

      _jobsPosted = offersSnap.docs.where((d) => d['isActive'] == true).length;
      for (var doc in offersSnap.docs) {
        _totalApplications +=
            int.tryParse(doc['applicationsCount']?.toString() ?? '0') ?? 0;
      }

      if (mounted) setState(() => _statsLoading = false);
    } catch (e) {
      debugPrint('❌ Stats error: $e');
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  String _getUserName() {
    if (_userData == null) return 'Unknown';
    return _userData!['displayName']?.toString() ??
        _userData!['name']?.toString() ??
        'Unknown';
  }

  String? _getUserAvatar() {
    if (_userData == null) return null;
    return _userData!['photoURL']?.toString() ??
        _userData!['avatar']?.toString();
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'Unknown') return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'recruteur':
        return AppColors.purple;
      case 'enseignant':
        return AppColors.primary;
      case 'etudiant':
        return AppColors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'recruteur':
        return 'Recruiter';
      case 'enseignant':
        return 'Teacher';
      case 'etudiant':
        return 'Student';
      default:
        return 'User';
    }
  }

  Widget _buildContactSection(ThemeColors c) {
    final data = _userData ?? {};
    final phone = data['phone']?.toString() ?? '';
    final email = data['email']?.toString() ?? '';
    final linkedin = data['linkedin']?.toString() ?? '';
    final github = data['github']?.toString() ?? '';
    final facebook = data['facebook']?.toString() ?? '';

    if (phone.isEmpty &&
        email.isEmpty &&
        linkedin.isEmpty &&
        github.isEmpty &&
        facebook.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(width: 1.24, color: c.border),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact & Social',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 16,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            if (phone.isNotEmpty)
              _ContactRow(
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: phone,
                onTap: () {
                  /* يمكن إبقاء الهاتف يفتح التطبيق الخارجي */
                },
                color: AppColors.green,
                c: c,
              ),
            if (email.isNotEmpty)
              _ContactRow(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: email,
                onTap: () {
                  /* يمكن إبقاء الإيميل يفتح التطبيق الخارجي */
                },
                color: AppColors.primary,
                c: c,
              ),
            // ... بقية روابط السوشيال ميديا تبقى كما هي أو تحذف إذا أردت
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwnProfile =
        currentUserId != null && currentUserId == widget.userId;
    final userName = _getUserName();
    final avatarUrl = _getUserAvatar();

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
          userName,
          style: TextStyle(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () =>
                      Navigator.pushNamed(context, '/edit-profile'),
                ),
              ]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: TextStyle(color: c.textMuted)),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: _getRoleColor(
                              _displayRole,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            image: avatarUrl != null && avatarUrl.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (avatarUrl == null || avatarUrl.isEmpty)
                              ? Center(
                                  child: Text(
                                    _getInitials(userName),
                                    style: TextStyle(
                                      color: _getRoleColor(_displayRole),
                                      fontSize: 32,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 22,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(
                              _displayRole,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            _getRoleLabel(_displayRole),
                            style: TextStyle(
                              color: _getRoleColor(_displayRole),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_displayRole == 'recruteur')
                  _buildRecruiterProfile(c)
                else if (_displayRole == 'etudiant')
                  _buildStudentProfile(c)
                else if (_displayRole == 'enseignant')
                  _buildTeacherProfile(c),

                // قسم التواصل الاجتماعي
                SliverToBoxAdapter(child: _buildContactSection(c)),

                // ✅ زر عرض البورتفوليو
                if (_displayRole == 'etudiant' || _displayRole == 'enseignant')
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get(),
                    builder: (ctx, snapshot) {
                      final currentUserRole = snapshot.data
                          ?.get('role')
                          ?.toString();
                      if (currentUserRole == 'recruteur') {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () {
                                  final cvUrl = _userData?['cv_url']
                                      ?.toString();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => _ReadOnlyPortfolioScreen(
                                        candidateId: widget.userId,
                                        candidateCvUrl: cvUrl,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.folder_open_rounded,
                                  size: 20,
                                ),
                                label: const Text(
                                  'View Portfolio & CV',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }

  Widget _buildRecruiterProfile(ThemeColors c) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(c, 'Company Information'),
              _InfoTile(
                icon: Icons.business_rounded,
                label: 'Company',
                value: _getUserName(),
                c: c,
              ),
              _InfoTile(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: _userData?['location']?.toString().isNotEmpty == true
                    ? _userData!['location']
                    : '—',
                c: c,
              ),
              _InfoTile(
                icon: Icons.language_rounded,
                label: 'Industry',
                value: _userData?['industry']?.toString().isNotEmpty == true
                    ? _userData!['industry']
                    : '—',
                c: c,
              ),
              const SizedBox(height: 24),
              _SectionTitle(c, 'Activity'),
              _StatsRow(c, [
                {
                  'label': 'Jobs Posted',
                  'value': _statsLoading ? '...' : _jobsPosted,
                },
                {
                  'label': 'Applications',
                  'value': _statsLoading ? '...' : _totalApplications,
                },
              ]),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildStudentProfile(ThemeColors c) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userData?['bio']?.isNotEmpty ?? false) ...[
                _SectionTitle(c, 'About'),
                Text(
                  _userData!['bio'],
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (_userData?['skills'] is List &&
                  (_userData!['skills'] as List).isNotEmpty) ...[
                _SectionTitle(c, 'Skills'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_userData!['skills'] as List)
                      .take(5)
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            s.toString(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildTeacherProfile(ThemeColors c) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userData?['bio']?.isNotEmpty ?? false) ...[
                _SectionTitle(c, 'Specialization'),
                Text(
                  _userData!['bio'],
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Helper Widgets ──
class _SectionTitle extends StatelessWidget {
  final ThemeColors c;
  final String title;
  const _SectionTitle(this.c, this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: TextStyle(
        color: c.textPrimary,
        fontSize: 18,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final ThemeColors c;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.c,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.purpleLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.purple, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  final ThemeColors c;
  final List<Map<String, dynamic>> stats;
  const _StatsRow(this.c, this.stats);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: ShapeDecoration(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(width: 1.24, color: c.border),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats
          .map(
            (s) => Column(
              children: [
                Text(
                  '${s['value']}',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  s['label'],
                  style: TextStyle(
                    color: c.textMuted,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    ),
  );
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final VoidCallback onTap;
  final Color color;
  final ThemeColors c;
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.color,
    required this.c,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: c.primary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 📁 شاشة عرض البورتفوليو للقراءة فقط (مصححة لفتح PDF داخلياً)
// ─────────────────────────────────────────────────────────────
class _ReadOnlyPortfolioScreen extends StatefulWidget {
  final String candidateId;
  final String? candidateCvUrl;

  const _ReadOnlyPortfolioScreen({
    required this.candidateId,
    this.candidateCvUrl,
  });

  @override
  State<_ReadOnlyPortfolioScreen> createState() =>
      _ReadOnlyPortfolioScreenState();
}

class _ReadOnlyPortfolioScreenState extends State<_ReadOnlyPortfolioScreen> {
  final _portfolioService = PortfolioCertService();
  String _activeFilter = 'all';

  // ✅ دالة لفتح الـ PDF داخل التطبيق
  void _openFileInternally(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _InternalFileViewerScreen(fileUrl: url), // ✅ استخدام الشاشة الذكية
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        title: const Text(
          'Candidate Portfolio',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _Chip(
                  label: 'All',
                  filter: 'all',
                  active: _activeFilter,
                  onSelect: (v) => setState(() => _activeFilter = v),
                  c: c,
                ),
                const SizedBox(width: 12),
                _Chip(
                  label: 'Projects',
                  filter: 'project',
                  active: _activeFilter,
                  onSelect: (v) => setState(() => _activeFilter = v),
                  c: c,
                ),
                const SizedBox(width: 12),
                _Chip(
                  label: 'Certificates',
                  filter: 'external_cert',
                  active: _activeFilter,
                  onSelect: (v) => setState(() => _activeFilter = v),
                  c: c,
                ),
              ],
            ),
          ),

          if (widget.candidateCvUrl != null &&
              widget.candidateCvUrl!.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    width: 1.5,
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.description_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Curriculum Vitae',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View candidate\'s resume',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _openFileInternally(widget.candidateCvUrl!),
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                    label: const Text('View CV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _portfolioService.getPortfolioStream(widget.candidateId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_off_rounded,
                          size: 48,
                          color: c.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No portfolio items found',
                          style: TextStyle(
                            color: c.textMuted,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var items = snapshot.data!;
                if (_activeFilter != 'all')
                  items = items
                      .where((i) => i['type'] == _activeFilter)
                      .toList();

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, index) => _ReadOnlyCard(
                    item: items[index],
                    c: c,
                    onOpen: _openFileInternally,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── شاشة عرض ذكية (PDF أو Image) ──
class _InternalFileViewerScreen extends StatelessWidget {
  final String fileUrl;
  const _InternalFileViewerScreen({required this.fileUrl});

  // دالة بسيطة للتأكد مما إذا كان الرابط PDF
  bool get _isPdf => fileUrl.toLowerCase().contains('.pdf') || 
                    fileUrl.contains('/raw/upload/') || // Cloudinary Raw type
                    fileUrl.contains('application/pdf');

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Viewer', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
        backgroundColor: c.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isPdf 
        ? SfPdfViewer.network(
            fileUrl,
            canShowScrollHead: false,
          )
        : InteractiveViewer( // للسماح بالتقريب والتحريك للصور
            child: Center(
              child: Image.network(
                fileUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: c.textMuted),
                      const SizedBox(height: 10),
                      Text('Failed to load image', style: TextStyle(color: c.textMuted)),
                    ],
                  );
                },
              ),
            ),
          ),
    );
  }
}
// ── Chip صغير للفلترة ──
class _Chip extends StatelessWidget {
  final String label, filter, active;
  final Function(String) onSelect;
  final ThemeColors c;
  const _Chip({
    required this.label,
    required this.filter,
    required this.active,
    required this.onSelect,
    required this.c,
  });
  @override
  Widget build(BuildContext context) {
    final isSelected = active == filter;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : c.textSecondary,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelect(filter),
      selectedColor: AppColors.primary,
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }
}

// ── بطاقة عنصر بورتفوليو ──
class _ReadOnlyCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final ThemeColors c;
  final Function(String) onOpen; // ✅ دالة لفتح الملف

  const _ReadOnlyCard({
    required this.item,
    required this.c,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isProject = item['type'] == 'project';
    final fileUrl = item['fileUrl'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(width: 1.24, color: c.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isProject ? AppColors.primary : AppColors.green)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isProject
                      ? Icons.work_outline_rounded
                      : Icons.verified_user_rounded,
                  size: 12,
                  color: isProject ? AppColors.primary : AppColors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  isProject ? 'Project' : 'Certificate',
                  style: TextStyle(
                    color: isProject ? AppColors.primary : AppColors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item['title'] ?? 'Untitled',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item['description']?.isNotEmpty ?? false) ...[
            const SizedBox(height: 6),
            Text(
              item['description'],
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 13,
                fontFamily: 'Inter',
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (fileUrl != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => onOpen(fileUrl), // ✅ استخدام الدالة الجديدة
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
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
        ],
      ),
    );
  }
}
