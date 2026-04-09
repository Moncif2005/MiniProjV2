import 'package:flutter/material.dart';
import 'package:minipr/screens/recruteur/manage_offer_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/offers_service.dart';
import '../../widgets/job_card.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedType;
  final _jobTypes = [
    'All',
    'Full-time',
    'Part-time',
    'Remote',
    'Hybrid',
    'Contract',
  ];

  final _offersService = OffersService();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ✅ 1. منطق التقديم
  Future<void> _applyToJob(Map<String, dynamic> offer) async {
    final user = FirebaseAuth.instance.currentUser;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to apply'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apply for this job?'),
        content: Text(
          'Submit your application for "${offer['title']}" at ${offer['company']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apply'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _offersService.applyToJob(
        applicantId: user.uid,
        applicantName: userProvider.name,
        offerId: offer['id'],
        offerTitle: offer['title'],
        company: offer['company'],
        location: offer['location'],
        jobType: offer['jobType'],
        salary: offer['salary'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Application submitted! ✓' : 'Failed to apply',
            ),
            backgroundColor: success ? AppColors.green : AppColors.red,
          ),
        );
      }
    }
  }

  // ✅ 2. منطق سحب الطلب (الجديد)
  Future<void> _withdrawFromJob(Map<String, dynamic> offer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: const Text(
          'This will remove your application and decrease the applicant count.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Withdraw',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _offersService.withdrawApplication(
        applicantId: user.uid,
        offerId: offer['id'],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Application withdrawn ✓' : 'Failed to withdraw',
            ),
            backgroundColor: success ? AppColors.green : AppColors.red,
          ),
        );
      }
    }
  }
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

void _manageOffer(Map<String, dynamic> job) {
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
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final userRole = context.watch<UserProvider>().role;
    final isRecruiter = userRole == UserRole.recruteur;

    return Scaffold(
      //     appBar: AppBar(
      //       leading: IconButton(
      //   icon: const Icon(Icons.arrow_back_ios), // أو أي أيقونة تفضلها
      //   onPressed: () => Navigator.pop(context), // هذه الدالة هي التي ترجعك للخلف
      // ),
      //     ),
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.24,
                              color: Color(0xFFF5F5F5),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF171717),
                        ),
                      ),
                    ),

                    Text(
                      'Job Offers',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // زر نشر وظيفة (يظهر للمسؤول فقط)
                    if (isRecruiter)
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/recruteur/post-job'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.purple,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              // Text(
                              //   'Post Job',
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 14,
                              //     fontFamily: 'Inter',
                              //     fontWeight: FontWeight.w600,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // 🔍 Search Bar
                Container(
                  decoration: ShapeDecoration(
                    color: c.inputBg,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1.24, color: c.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search jobs, companies...',
                      hintStyle: TextStyle(color: c.textMuted),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: c.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),

          // 🎛️ Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: c.bg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _jobTypes.map((type) {
                  final isSelected =
                      _selectedType == type ||
                      (type == 'All' && _selectedType == null);
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.purple : c.surface,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: isSelected ? AppColors.purple : c.border,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () => setState(
                          () => _selectedType = type == 'All' ? null : type,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : c.textPrimary,
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 📋 Jobs List (Stream from Firestore)
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _offersService.getActiveOffers(
                jobType: _selectedType,
                searchQuery: _searchCtrl.text.trim(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading offers',
                      style: TextStyle(color: c.textMuted),
                    ),
                  );
                }

                final offers = snapshot.data ?? [];

                if (offers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 64,
                          color: c.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs found',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or search terms',
                          style: TextStyle(color: c.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                // ✅ ListView.builder مع itemBuilder الصحيح
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;
                    final recruiterId = offer['recruiterId'] as String?;

                    // ✅ 1. حساب isOwner محلياً قبل استخدامه
                    final isOwner =
                        currentUserId != null && recruiterId == currentUserId;

                    return JobCard(
                      offer: offer,
                      isRecruiter: isRecruiter,
                      isOwner: isOwner, // ✅ الآن المتغير معرف بشكل صحيح
                      onManage: isOwner
                          ? () => _manageOffer(offer)
                          : null, // ✅ تمرير فقط للمالك

                      onApply: () => _applyToJob(offer),
                      onWithdraw: () => _withdrawFromJob(offer),

                      // ✅ 2. رابط البروفايل عند النقر على الشعار
                      onAvatarTap: recruiterId != null
                          ? () {
                              Navigator.pushNamed(
                                context,
                                '/public/profile',
                                arguments: {
                                  'userId': recruiterId,
                                  'role': 'recruteur',
                                },
                              );
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../theme/app_colors.dart';
// import '../../widgets/bottom_nav_bar.dart';
// import '../../widgets/offer_card.dart';
// import '../../providers/user_provider.dart';

// class OffersScreen extends StatefulWidget {
//   const OffersScreen({super.key});

//   @override
//   State<OffersScreen> createState() => _OffersScreenState();
// }

// class _OffersScreenState extends State<OffersScreen> {
//   int _currentNavIndex = 2;
//   int _selectedFilter  = 0;
//   final _searchController = TextEditingController();

//   final List<String> _filters = [
//     'All', 'Full-time', 'Freelance', 'Contract', 'Remote',
//   ];

//   final List<Map<String, dynamic>> _offers = [
//     {
//       'title': 'Senior UX Designer',
//       'company': 'Studio Nova',
//       'initial': 'S',
//       'companyBg': const Color(0xFFE0E7FF),
//       'companyColor': const Color(0xFF4F39F6),
//       'location': 'London, UK',
//       'postedAgo': '2h ago',
//       'salary': '\$80k - \$110k',
//       'jobType': 'Full-time',
//     },
//     {
//       'title': 'React Native Developer',
//       'company': 'TechPulse',
//       'initial': 'T',
//       'companyBg': const Color(0xFFCEFAFE),
//       'companyColor': const Color(0xFF0092B8),
//       'location': 'San Francisco, CA',
//       'postedAgo': '5h ago',
//       'salary': '\$120k - \$150k',
//       'jobType': 'Remote',
//     },
//     {
//       'title': 'Content Marketing Manager',
//       'company': 'GreenGrow',
//       'initial': 'G',
//       'companyBg': const Color(0xFFDCFCE7),
//       'companyColor': const Color(0xFF00A63E),
//       'location': 'Berlin, DE',
//       'postedAgo': '1d ago',
//       'salary': '\$60k - \$75k',
//       'jobType': 'Contract',
//     },
//     {
//       'title': 'Product Analyst',
//       'company': 'DataDash',
//       'initial': 'D',
//       'companyBg': const Color(0xFFFFEDD4),
//       'companyColor': const Color(0xFFF54900),
//       'location': 'Remote',
//       'postedAgo': '3d ago',
//       'salary': '\$50/hr - \$80/hr',
//       'jobType': 'Freelance',
//     },
//     {
//       'title': 'Full Stack Engineer',
//       'company': 'Finly',
//       'initial': 'F',
//       'companyBg': const Color(0xFFDBEAFE),
//       'companyColor': const Color(0xFF155DFC),
//       'location': 'New York, NY',
//       'postedAgo': '1w ago',
//       'salary': '\$140k - \$170k',
//       'jobType': 'Full-time',
//     },
//   ];

//   List<Map<String, dynamic>> get _filteredOffers {
//     if (_selectedFilter == 0) return _offers;
//     final selected = _filters[_selectedFilter];
//     return _offers.where((o) => o['jobType'] == selected).toList();
//   }

//   // ── Returns the correct routes for the current user role ──
//   Map<String, String> _routesForRole(UserRole role) {
//     switch (role) {
//       case UserRole.enseignant:
//         return {'home': '/enseignant/home', 'learn': '/enseignant/courses', 'profile': '/enseignant/profile'};
//       case UserRole.recruteur:
//         return {'home': '/recruteur/home', 'learn': '/recruteur/jobs', 'profile': '/recruteur/profile'};
//       case UserRole.etudiant:
//       default:
//         return {'home': '/etudiant/home', 'learn': '/etudiant/learn', 'profile': '/etudiant/profile'};
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c    = context.colors;
//     final role = context.watch<UserProvider>().role;
//     final nav  = _routesForRole(role);

//     return Scaffold(
//       backgroundColor: c.bg,
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentNavIndex,
//         onTap: (index) {
//           setState(() => _currentNavIndex = index);
//           switch (index) {
//             case 0:
//               Navigator.pushNamedAndRemoveUntil(context, nav['home']!, (r) => false);
//               break;
//             case 1:
//               Navigator.pushNamedAndRemoveUntil(context, nav['learn']!, (r) => false);
//               break;
//             case 3:
//               Navigator.pushNamedAndRemoveUntil(context, nav['profile']!, (r) => false);
//               break;
//           }
//         },
//       ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [

//             // ── Header ──
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Working',
//                         style: TextStyle(
//                           color: c.textPrimary,
//                           fontSize: 24,
//                           fontFamily: 'Inter',
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         'Find your next big move',
//                         style: TextStyle(
//                           color: c.textSecondary,
//                           fontSize: 16,
//                           fontFamily: 'Inter',
//                         ),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: AppColors.primary,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: AppColors.primaryLight,
//                           blurRadius: 6,
//                           offset: Offset(0, 4),
//                           spreadRadius: -4,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // ── Search ──
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Container(
//                 decoration: ShapeDecoration(
//                   color: c.surface,
//                   shape: RoundedRectangleBorder(
//                     side: BorderSide(width: 1.24, color: c.border),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 child: TextField(
//                   controller: _searchController,
//                   style: TextStyle(color: c.textPrimary),
//                   decoration: InputDecoration(
//                     hintText: 'Job title, company or keyword',
//                     hintStyle: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
//                     prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // ── Filters ──
//             SizedBox(
//               height: 40,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 itemCount: _filters.length,
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemBuilder: (context, index) {
//                   final isSelected = _selectedFilter == index;
//                   return GestureDetector(
//                     onTap: () => setState(() => _selectedFilter = index),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: isSelected ? c.textPrimary : c.surface,
//                         borderRadius: BorderRadius.circular(100),
//                         border: Border.all(
//                           width: 1.24,
//                           color: isSelected ? c.textPrimary : c.border,
//                         ),
//                       ),
//                       child: Text(
//                         _filters[index],
//                         style: TextStyle(
//                           color: isSelected ? c.surface : c.textSecondary,
//                           fontSize: 14,
//                           fontFamily: 'Inter',
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),

//             // ── Count ──
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Text(
//                 '${_filteredOffers.length} offres disponibles',
//                 style: TextStyle(
//                   color: c.textSecondary,
//                   fontSize: 13,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),

//             // ── List ──
//             Expanded(
//               child: _filteredOffers.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.search_off_rounded, color: c.textMuted, size: 48),
//                           const SizedBox(height: 16),
//                           Text('No offers found',
//                               style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
//                         ],
//                       ),
//                     )
//                   : ListView.separated(
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                       itemCount: _filteredOffers.length,
//                       separatorBuilder: (_, __) => const SizedBox(height: 16),
//                       itemBuilder: (context, index) {
//                         final offer = _filteredOffers[index];
//                         return OfferCard(
//                           title: offer['title'] as String,
//                           company: offer['company'] as String,
//                           companyInitial: offer['initial'] as String,
//                           companyBg: offer['companyBg'] as Color,
//                           companyColor: offer['companyColor'] as Color,
//                           location: offer['location'] as String,
//                           postedAgo: offer['postedAgo'] as String,
//                           salary: offer['salary'] as String,
//                           jobType: offer['jobType'] as String,
//                           onApply: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Applied to ${offer['title']}!'),
//                                 backgroundColor: AppColors.primary,
//                                 behavior: SnackBarBehavior.floating,
//                               ),
//                             );
//                           },
//                           onBookmark: () {},
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
