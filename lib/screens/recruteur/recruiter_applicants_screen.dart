import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../services/offers_service.dart';
import '../../l10n/app_localizations.dart';

class RecruiterApplicantsScreen extends StatelessWidget {
  const RecruiterApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final recruiterId = FirebaseAuth.instance.currentUser?.uid;
    final offersService = OffersService();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        // leading: GestureDetector(
        //   onTap: () => Navigator.pop(context),
        //   child: Container(
        //     margin: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: c.surface,
        //       borderRadius: BorderRadius.circular(14),
        //       border: Border.all(color: c.border),
        //     ),
        //     child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 18),
        //   ),
        // ),
        title: Text(
          AppLocalizations.of(context).allCandidates,
          style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: recruiterId == null
          ? _NotSignedInState(c: c)
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: offersService.getAllApplicantsForRecruiter(recruiterId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(error: snapshot.error.toString(), c: c);
                }
                
                final applicants = snapshot.data ?? [];
                if (applicants.isEmpty) {
                  return _EmptyApplicantsState(c: c);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: applicants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final app = applicants[index];
                    final applicantId = app['applicantId'];
                    
                    return _ApplicantCard(
                      application: app,
                      onUpdateStatus: (status, message) async {
                        final success = await offersService.updateApplicationStatus(
                          applicationId: app['id'],
                          status: status,
                          message: message,
                        );
                        if (context.mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context).statusUpdated),
                              ]),
                              backgroundColor: AppColors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      onAvatarTap: applicantId != null
                          ? () {
                              Navigator.pushNamed(
                                context,
                                '/public/profile',
                                arguments: {'userId': applicantId, 'role': 'etudiant'},
                              );
                            }
                          : null,
                    );
                  },
                );
              },
            ),
    );
  }
}

// ── ✅ Not Signed In State ──
class _NotSignedInState extends StatelessWidget {
  final ThemeColors c;
  const _NotSignedInState({required this.c});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(20)), child: Icon(Icons.lock_outline_rounded, size: 56, color: c.textMuted)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).pleaseSignIn, style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── ✅ Error State ──
class _ErrorState extends StatelessWidget {
  final String error;
  final ThemeColors c;
  const _ErrorState({required this.error, required this.c});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.redLight, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.error_outline_rounded, size: 48, color: AppColors.red)),
          const SizedBox(height: 16),
          Text('Error loading applicants', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Inter'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── ✅ Empty State ──
class _EmptyApplicantsState extends StatelessWidget {
  final ThemeColors c;
  const _EmptyApplicantsState({required this.c});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(20)), child: Icon(Icons.people_outline_rounded, size: 56, color: c.textMuted)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).noApplicantsYet, style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).candidatesWillAppear, style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── ✅ Applicant Card (محسّن ليتناسق مع نظام التصميم) ──
class _ApplicantCard extends StatefulWidget {
  final Map<String, dynamic> application;
  final Function(String, String?) onUpdateStatus;
  final VoidCallback? onAvatarTap;

  const _ApplicantCard({
    required this.application,
    required this.onUpdateStatus,
    this.onAvatarTap,
  });

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  late String _currentStatus;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  String status = widget.application['status'] ?? 'pending';
  _currentStatus = status == 'approved' ? 'accepted' : status;
  }

  // ✅ لون الحالة (متناسق مع النظام)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted': return AppColors.green;
      case 'rejected': return AppColors.red;
      case 'interview': return AppColors.purple;
      case 'reviewing': return AppColors.primary;
      default: return Colors.orange;
    }
  }

  // ✅ أيقونة لكل حالة
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted': return Icons.check_circle_rounded;
      case 'rejected': return Icons.cancel_rounded;
      case 'interview': return Icons.meeting_room_rounded;
      case 'reviewing': return Icons.search_rounded;
      default: return Icons.pending_rounded;
    }
  }

  // ✅ توليد الأحرف الأولى من الاسم
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ✅ تنسيق التاريخ بشكل نسبي أنيق
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        if (diff.inHours == 0) return '${diff.inMinutes}m ago';
        return '${diff.inHours}h ago';
      }
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    }
    return timestamp.toString().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDark;
    final app = widget.application;
    final applicantName = app['applicantName'] ?? 'Anonymous';
    final applicantEmail = app['applicantEmail'] ?? '';
    final offerTitle = app['offerTitle'] ?? 'Unknown Position';
    final appliedDate = _formatDate(app['appliedAt']);
    final statusColor = _getStatusColor(_currentStatus);

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _isExpanded ? statusColor.withOpacity(0.4) : c.border, width: 1.24),
          boxShadow: _isExpanded 
              ? [BoxShadow(color: statusColor.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: [
            // ✅ شريط علوي ملون حسب حالة المتقدم
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [statusColor, statusColor.withOpacity(0.4)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header: Avatar + Name + Date ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Avatar قابل للنقر (مع معالجة null-safe)
                      GestureDetector(
                        onTap: widget.onAvatarTap != null ? () => widget.onAvatarTap!() : null,
                        child: Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(isDark ? 0.2 : 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(applicantName),
                              style: TextStyle(color: statusColor, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              applicantName,
                              style: TextStyle(color: c.textPrimary, fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (applicantEmail.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                applicantEmail,
                                style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // ✅ شارة التاريخ
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded, size: 10, color: c.textMuted),
                            const SizedBox(width: 3),
                            Text(appliedDate, style: TextStyle(color: c.textMuted, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Status Badge + Dropdown ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ شارة الحالة (مصممة مثل _DetailPill)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getStatusIcon(_currentStatus), size: 10, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              _currentStatus.toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      
                      // ✅ Dropdown محسّن مع أيقونات
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: c.inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currentStatus,
                            icon: Icon(Icons.arrow_drop_down_rounded, size: 18, color: c.textSecondary),
                            items: [
                              _buildStatusItem('pending', Icons.pending_rounded, Colors.orange),
                              _buildStatusItem('reviewing', Icons.search_rounded, AppColors.primary),
                              _buildStatusItem('interview', Icons.meeting_room_rounded, AppColors.purple),
                              _buildStatusItem('accepted', Icons.check_circle_rounded, AppColors.green),
                              _buildStatusItem('rejected', Icons.cancel_rounded, AppColors.red),
                            ],
                            onChanged: (newStatus) {
                              if (newStatus != null && newStatus != _currentStatus) {
                                setState(() => _currentStatus = newStatus);
                                widget.onUpdateStatus(newStatus, null);
                              }
                            },
                            style: TextStyle(color: c.textPrimary, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                            dropdownColor: c.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ✅ قسم موسع يظهر عند النقر على البطاقة
                  if (_isExpanded) ...[
                    const SizedBox(height: 14),
                    Divider(color: c.border.withOpacity(0.5), height: 1, indent: 4, endIndent: 4),
                    const SizedBox(height: 14),
                    
                    // معلومات الوظيفة المُقدَّم عليها
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                          child: Icon(Icons.work_outline_rounded, size: 14, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Applied for', style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Inter')),
                              Text(offerTitle, style: TextStyle(color: c.textPrimary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // ✅ زر عرض البروفايل (عريض وواضح)
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: widget.onAvatarTap != null ? () => widget.onAvatarTap!() : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.visibility_rounded, size: 16, color: AppColors.green),
                              const SizedBox(width: 6),
                              Text('View Full Profile', style: TextStyle(color: AppColors.green, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ✅ سهم التوسيع في الأسفل
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: Icon(
                        _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        size: 18,
                        color: c.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ عنصر Dropdown منسّق
  DropdownMenuItem<String> _buildStatusItem(String value, IconData icon, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(value.toUpperCase(), style: TextStyle(fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}