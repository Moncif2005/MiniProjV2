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
            // شريط سحب صغير في الأعلى للجمالية
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // خيار تعديل الوظيفة
            _buildMenuOption(
              icon: Icons.edit_outlined,
              label: 'Edit Job Details',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                // أضف هنا Navigator.push لصفحة التعديل
                Navigator.pushNamed(context, '/recruteur/edit-offer', arguments: job);
              },
            ),
            
            // خيار عرض المتقدمين
            _buildMenuOption(
              icon: Icons.people_outline_rounded,
              label: 'View Applicants',
              color: AppColors.purple,
              onTap: () {
                Navigator.pop(context);
                // أضف هنا الانتقال لصفحة المتقدمين
                                Navigator.pushNamed(context, '/recruteur/applicants', arguments: {'offerId': job['id'], 'offerTitle': job['title']});

              },
            ),
            
            // خيار حذف الوظيفة
            _buildMenuOption(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Job Post',
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context);
                // أضف هنا كود الحذف من Firestore
                                await Future.delayed(const Duration(milliseconds: 200));
                
                // التحقق من أن الشاشة لا تزال موجودة قبل المتابعة
                if (!mounted) return;
                
                final confirmed = await showDialog<bool>(
                  context: context, // ✅ نستخدم سياق الشاشة هنا أيضاً
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Deactivate?'),
                    content: const Text('Hide this job from seekers.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
                      ),
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