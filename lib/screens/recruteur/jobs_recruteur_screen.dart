import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/offers_service.dart';
import '../../widgets/job_card.dart';

class JobsRecruteurScreen extends StatefulWidget {
  const JobsRecruteurScreen({super.key});
  @override
  State<JobsRecruteurScreen> createState() => _JobsRecruteurScreenState();
}

class _JobsRecruteurScreenState extends State<JobsRecruteurScreen> {
  int _selectedTab = 0;
  final _offersService = OffersService();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final recruiterId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: c.bg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/recruteur/post-job'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post Job', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Jobs', style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: recruiterId != null ? _offersService.getOffersByRecruiter(recruiterId) : Stream.value([]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      final active = snapshot.data!.where((j) => j['isActive'] == true).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.purpleLight, borderRadius: BorderRadius.circular(100)),
                        child: Text('$active active', style: const TextStyle(color: AppColors.purple, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _Tab(label: 'Active', isSelected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                  const SizedBox(width: 12),
                  _Tab(label: 'Closed', isSelected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Jobs List
            Expanded(
              child: recruiterId == null
                  ? const Center(child: Text('Please sign in'))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _offersService.getOffersByRecruiter(recruiterId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: c.textMuted)));
                        }

                        final allJobs = snapshot.data ?? [];
                        final filtered = allJobs.where((j) => _selectedTab == 0 ? (j['isActive'] == true) : (j['isActive'] == false)).toList();

                        if (filtered.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_selectedTab == 0 ? Icons.work_outline_rounded : Icons.work_off_outlined, color: c.textMuted, size: 48),
                                const SizedBox(height: 16),
                                Text(allJobs.isEmpty ? 'No jobs posted yet' : 'No ${_selectedTab == 0 ? 'active' : 'closed'} jobs', style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
                                if (allJobs.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text('Tap "+ Post Job" to create one!', style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter')),
                                ],
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final job = filtered[index];
                            return JobCard(
                              offer: job,
                              isRecruiter: true,
                              isOwner: true,
                              // ✅ نمرّر دالة تأخذ السياق الصحيح من الشاشة الرئيسية
                              onManage: () => _manageJob(job),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ دالة إدارة الوظيفة - لا تأخذ context كمعامل، تستخدم هذا السياق
void _manageJob(Map<String, dynamic> job) {
  showModalBottomSheet(
    context: context,  // ✅ هذا هو الـ context الصحيح للشاشة
    backgroundColor: context.colors.surface,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_rounded, color: AppColors.purple),
            title: const Text('Edit Job'),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.pushNamed(context, '/recruteur/edit-offer', arguments: job);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline_rounded, color: AppColors.green),
            title: Text('View Applicants (${job['applicationsCount'] ?? 0})'),
            onTap: () {
              Navigator.pop(sheetContext);
              Navigator.pushNamed(context, '/recruteur/applicants', arguments: {'offerId': job['id'], 'offerTitle': job['title']});
            },
          ),
          ListTile(
            leading: const Icon(Icons.close_rounded, color: AppColors.red),
            title: const Text('Deactivate'),
            titleTextStyle: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
            onTap: () async {
              Navigator.pop(sheetContext);
              await Future.delayed(const Duration(milliseconds: 200));
              if (!mounted) return;
              
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Deactivate?'),
                  content: const Text('Hide this job from seekers.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                    FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.red), onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Deactivate', style: TextStyle(color: Colors.white))),
                  ],
                ),
              );
              
              if (confirmed == true && mounted) {
                await _offersService.deactivateOffer(job['id']);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job deactivated'), backgroundColor: AppColors.green));
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}  // ✅ قوس واحد فقط هنا
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.purple : c.border, width: 1.24),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : c.textSecondary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      ),
    );
  }
}