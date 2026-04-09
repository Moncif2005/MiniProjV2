import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
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
    // ✅ لا نستدعي الإحصائيات هنا، سننتظر حتى نعرف الدور الحقيقي من قاعدة البيانات
  }

  // ✅ دالة ذكية لفتح الروابط أو الاتصال مباشرة
  Future<void> _launchURL(String value, String type) async {
    String url = value.trim();
    if (url.isEmpty) return;

    if (type == 'phone')
      url = 'tel:$url';
    else if (type == 'email')
      url = 'mailto:$url';
    else if (!url.startsWith('http'))
      url = 'https://$url';

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPublicProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(widget.userId).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        // ✅ نأخذ الدور الحقيقي من البيانات مباشرة
        final role = data?['role']?.toString() ?? 'etudiant';

        setState(() {
          _userData = data;
          _displayRole = role; // ✅ تحديث الدور أولاً
          _loading = false;
        });

        // ✅ الآن نحمّل الإحصائيات فقط إذا كان الدور مسؤولاً
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

  // ✅ ✅ ✅ دالة التواصل الاجتماعي (موجودة داخل الكلاس) ✅ ✅ ✅
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
                onTap: () => _launchURL(phone, 'phone'),
                color: AppColors.green,
                c: c,
              ),
            if (email.isNotEmpty)
              _ContactRow(
                icon: Icons.mail_outline_rounded,
                label: 'Email',
                value: email,
                onTap: () => _launchURL(email, 'email'),
                color: AppColors.primary,
                c: c,
              ),
            if (linkedin.isNotEmpty)
              _ContactRow(
                icon: Icons.work_outline_rounded,
                label: 'LinkedIn',
                value: linkedin,
                onTap: () => _launchURL(linkedin, 'linkedin'),
                color: const Color(0xFF0077B5),
                c: c,
              ),
            if (github.isNotEmpty)
              _ContactRow(
                icon: Icons.code_rounded,
                label: 'GitHub',
                value: github,
                onTap: () => _launchURL(github, 'github'),
                color: c.textSecondary,
                c: c,
              ),
            if (facebook.isNotEmpty)
              _ContactRow(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                value: facebook,
                onTap: () => _launchURL(facebook, 'facebook'),
                color: const Color(0xFF1877F2),
                c: c,
              ),
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

                // ✅ ✅ ✅ تم حذف زر "View Company Jobs" تماماً ✅ ✅ ✅

                // قسم التواصل الاجتماعي
                SliverToBoxAdapter(child: _buildContactSection(c)),

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

              // ✅ ✅ ✅ إصلاح: عرض location و industry مباشرة بدون حقول بديلة ✅ ✅ ✅
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

// ✅ Widget صف تواصل فردي
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
            Icon(Icons.open_in_new_rounded, color: c.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
