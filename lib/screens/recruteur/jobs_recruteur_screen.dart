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
  int _selectedTab = 0; // 0 للأعمال النشطة، 1 للأعمال المغلقة
  final _offersService = OffersService();

  // ✅ التحسين 1: نقل الدالة خارج الـ build لضمان استقرار الـ Context
void _manageJob(Map<String, dynamic> job) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط سحب صغير
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Manage: ${job['title']}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Inter'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // ✅ خيار 1: تعديل الوظيفة
          _buildMenuOption(
            icon: Icons.edit_outlined,
            label: 'Edit Job Details',
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/recruteur/edit-offer', arguments: job);
            },
          ),
          
          // ✅ خيار 2: عرض المتقدمين
                    _buildMenuOption(
            icon: Icons.people_outline_rounded,
            label: 'View Applicants (${job['applicationsCount'] ?? 0})',
            color: AppColors.purple,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context, 
                '/recruteur/applicants', 
                arguments: {'offerId': job['id'], 'offerTitle': job['title']},
              );
            },
          ),

// ✅ خيار ذكي: غلق/فتح الوظيفة حسب حالتها
_buildMenuOption(
  icon: (job['isActive'] == true) ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
  label: (job['isActive'] == true) ? 'Close Job' : 'Open Job',  // ✅ يتغير النص ديناميكياً
  color: (job['isActive'] == true) ? Colors.orange : Colors.green, // ✅ يتغير اللون أيضاً
  onTap: () async {
    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    
    final isActive = job['isActive'] == true;
    
    // نصوص ورسائل ديناميكية حسب الحالة
    final title = isActive ? 'Close Job?' : 'Open Job?';
    final content = isActive 
        ? 'This will hide the job from seekers. You can reopen it later.'
        : 'This will make the job visible to seekers again.';
    final actionText = isActive ? 'Close' : 'Open';
    final actionColor = isActive ? Colors.orange : Colors.green;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: actionColor),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(actionText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      bool success = false;
      
      if (isActive) {
        // ✅ غلق الوظيفة
        success = await _offersService.deactivateOffer(job['id']);
      } else {
        // ✅ فتح الوظيفة
        success = await _offersService.activateOffer(job['id']);
      }
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isActive ? 'Job closed ✓' : 'Job opened ✓'),
          backgroundColor: AppColors.green,
        ));
      }
    }
  },
),
          
          // ✅ خيار 4: حذف الوظيفة نهائياً (جديد - يحذف من القاعدة)
          _buildMenuOption(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Permanently',  // ✅ زر جديد للحذف النهائي
            color: Colors.red,
            onTap: () async {
              Navigator.pop(context);
              await Future.delayed(const Duration(milliseconds: 200));
              if (!mounted) return;
              
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Permanently?'),
                  content: const Text('This will permanently delete the job and all its applications. This action cannot be undone!'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true && mounted) {
                // ✅ نستخدم deleteOffer للحذف النهائي من Firestore
                await _offersService.deleteOffer(job['id']);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Job deleted permanently ✓'), backgroundColor: AppColors.green));
                }
              }
            },
          ),
          
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

  // ودجت مساعد لخيارات القائمة
  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

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
        label: const Text('Post Job', 
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
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
                  Text('My Jobs', 
                    style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  
                  // عداد الوظائف النشطة
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: recruiterId != null ? _offersService.getOffersByRecruiter(recruiterId) : Stream.value([]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final active = snapshot.data!.where((j) => j['isActive'] == true).length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.purpleLight, borderRadius: BorderRadius.circular(100)),
                        child: Text('$active active', 
                          style: const TextStyle(color: AppColors.purple, fontSize: 13, fontWeight: FontWeight.w700)),
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
                        
                        final allJobs = snapshot.data ?? [];
                        // تصفية الوظائف بناءً على التبويب المختار
                        final filtered = allJobs.where((j) => 
                          _selectedTab == 0 ? (j['isActive'] == true) : (j['isActive'] == false)
                        ).toList();

                        if (filtered.isEmpty) {
                          return _buildEmptyState(c);
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final job = filtered[index];
                            // ✅ التحسين 2: التأكد من تمرير onManage بشكل صحيح
                            return JobCard(
                              offer: job,
                              isRecruiter: true,
                              isOwner: true, 
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

  Widget _buildEmptyState(ThemeColors c) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_selectedTab == 0 ? Icons.work_outline_rounded : Icons.work_off_outlined, color: c.textMuted, size: 48),
          const SizedBox(height: 16),
          Text('No ${_selectedTab == 0 ? 'active' : 'closed'} jobs found', 
            style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

// الـ Tab Widget (لم يتغير تصميمه ولكن تأكد من وجوده)
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
        child: Text(label, 
          style: TextStyle(
            color: isSelected ? Colors.white : c.textSecondary, 
            fontSize: 14, 
            fontWeight: FontWeight.w700
          )),
      ),
    );
  }
}