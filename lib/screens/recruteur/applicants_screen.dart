import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/offers_service.dart';

class ApplicantsScreen extends StatelessWidget {
  final String offerId;
  final String offerTitle;
  const ApplicantsScreen({
    super.key,
    required this.offerId,
    required this.offerTitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final offersService = OffersService();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applicants',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              offerTitle,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: offersService.getApplicationsForOffer(offerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: c.textMuted),
              ),
            );
          }

          final applicants = snapshot.data ?? [];
          if (applicants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64,
                    color: c.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applicants yet',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Candidates will appear here when they apply',
                    style: TextStyle(color: c.textMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: applicants.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final app = applicants[index];
              final applicantId =
                  app['applicantId'] as String?; // ✅ استخراج معرف الطالب

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
                      const SnackBar(
                        content: Text('Status updated ✓'),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  }
                },
                // ✅ تمرير دالة النقر على الأفاتار
                onAvatarTap: applicantId != null
                    ? () {
                        Navigator.pushNamed(
                          context,
                          '/public/profile',
                          arguments: {
                            'userId': applicantId,
                            'role': 'etudiant',
                          },
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

// ── Applicant Card (مُحدّث مع أفاتار قابل للنقر) ──
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

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.application['status'] ?? 'pending';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.green;
      case 'rejected':
        return AppColors.red;
      case 'interview':
        return AppColors.purple;
      case 'reviewing':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final app = widget.application;
    final applicantName = app['applicantName'] ?? 'Anonymous';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ الصف العلوي: أفاتار + اسم + تاريخ
          Row(
            children: [
              // ✅ الأفاتار قابل للنقر
              GestureDetector(
                onTap: widget.onAvatarTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(applicantName),
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  applicantName,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatDate(app['appliedAt']),
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 11,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ صف الحالة + Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(_currentStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: _getStatusColor(_currentStatus)),
                ),
                child: Text(
                  _currentStatus.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(_currentStatus),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _currentStatus,
                dropdownColor: c.surface,
                underline: const SizedBox(),
                items:
                    [
                          'pending',
                          'reviewing',
                          'interview',
                          'accepted',
                          'rejected',
                        ]
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (newStatus) async {
                  if (newStatus != null && newStatus != _currentStatus) {
                    setState(() => _currentStatus = newStatus);
                    await widget.onUpdateStatus(newStatus, null);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ الوظيفة المُقدَّم عليها
          Row(
            children: [
              Icon(Icons.work_outline_rounded, size: 14, color: c.textMuted),
              const SizedBox(width: 4),
              Text(
                'Applied for: ${app['offerTitle'] ?? 'Unknown'}',
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year}';
    }
    return timestamp.toString().substring(0, 10);
  }
}
