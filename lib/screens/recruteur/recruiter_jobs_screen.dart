import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/offers_service.dart';
import '../../widgets/job_card.dart';

class RecruiterJobsScreen extends StatelessWidget {
  const RecruiterJobsScreen({super.key});

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
        title: Text('My Job Posts', style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.pushNamed(context, '/recruteur/post-job'),
          ),
        ],
      ),
      body: recruiterId == null
          ? const Center(child: Text('Please sign in'))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: offersService.getOffersByRecruiter(recruiterId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: c.textMuted)));
                }
                
                final jobs = snapshot.data ?? [];
                if (jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_outline_rounded, size: 64, color: c.textMuted),
                        const SizedBox(height: 16),
                        Text('No jobs posted yet', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/recruteur/post-job'),
                          child: const Text('Post Your First Job'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: jobs.length,
                  itemBuilder: (_, index) {
                    final job = jobs[index];
                    return JobCard(
                      offer: job,
                      isRecruiter: true,
                      onManage: () => _manageJob(context, job),
                    );
                  },
                );
              },
            ),
    );
  }

  void _manageJob(BuildContext context, Map<String, dynamic> job) {
    // يمكن إعادة استخدام ManageOfferScreen أو إنشاء نسخة مخصصة
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.purple),
              title: const Text('Edit Job'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline_rounded, color: AppColors.green),
              title: Text('View Applicants (${job['applicationsCount'] ?? 0})'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/recruteur/applicants', arguments: {'offerId': job['id'], 'offerTitle': job['title']});
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded, color: AppColors.red),
              title: const Text('Deactivate'),
              titleTextStyle: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w600),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Deactivate?'),
                    content: const Text('Hide this job from seekers.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.red), onPressed: () => Navigator.pop(context, true), child: const Text('Deactivate', style: TextStyle(color: Colors.white))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await OffersService().deactivateOffer(job['id']);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job deactivated'), backgroundColor: AppColors.green));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}