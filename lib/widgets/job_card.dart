import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/services/offers_service.dart';
import '../theme/app_colors.dart';

class JobCard extends StatelessWidget {
  // ✅ النمط البسيط (للصفحات الرئيسية - بيانات ثابتة)
  final String? title;
  final String? company;
  final String? type;
  final String? salary;
  final String? location;
  final VoidCallback? onBookmark;
  final VoidCallback? onTap;

  // ✅ النمط الديناميكي (لصفحة Offers - بيانات من Firestore)
  final Map<String, dynamic>? offer;
  final bool? isRecruiter;
  final VoidCallback? onApply;
  final VoidCallback? onManage;

  const JobCard({
    super.key,
    // للنمط البسيط
    this.title,
    this.company,
    this.type,
    this.salary,
    this.location,
    this.onBookmark,
    this.onTap,
    // للنمط الديناميكي
    this.offer,
    this.isRecruiter,
    this.onApply,
    this.onManage,
  });

// ── Helper: Check if user has applied to this job ──
Future<bool> _checkIfApplied(BuildContext context) async {
  if (!_isDynamicMode || isRecruiter == true) return false;
  
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || offer == null) return false;
  
  final offersService = OffersService();
  return await offersService.hasUserAppliedToJob(
    applicantId: user.uid,
    offerId: offer!['id'],
  );
}

  // ✅ دالة مساعدة لتحديد أي نمط نستخدم
  bool get _isDynamicMode => offer != null;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    // ✅ استخراج البيانات حسب النمط
    final displayTitle = _isDynamicMode ? offer!['title'] : title;
    final displayCompany = _isDynamicMode ? offer!['company'] : company;
    final displayType = _isDynamicMode ? offer!['jobType'] : type;
    final displaySalary = _isDynamicMode ? offer!['salary'] : salary;
    final displayLocation = _isDynamicMode ? offer!['location'] : location;
    
    // للألوان والرموز (فقط في النمط الديناميكي)
    final companyBg = _isDynamicMode ? Color(offer!['companyBgColor'] ?? 4293848063) : AppColors.primaryLight;
    final companyColor = _isDynamicMode ? Color(offer!['companyColor'] ?? 4283322870) : AppColors.primary;
    final companyInitial = _isDynamicMode ? (offer!['companyInitial'] ?? 'C') : (displayCompany?.isNotEmpty == true ? displayCompany![0].toUpperCase() : 'J');
    
    final isActive = _isDynamicMode ? (offer!['isActive'] ?? true) : true;
    final applicantsCount = _isDynamicMode ? offer!['applicationsCount'] : null;

    return GestureDetector(
      onTap: onTap ?? () {
        if (_isDynamicMode && isRecruiter == false && onApply != null) {
          onApply!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Company + Title ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Avatar
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: companyBg.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(companyInitial,
                      style: TextStyle(color: companyColor, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Job Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayTitle ?? 'Untitled',
                        style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(displayCompany ?? 'Company',
                        style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
                    ],
                  ),
                ),
                
                // Status Badge (فقط في النمط الديناميكي)
                if (_isDynamicMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.greenLight : AppColors.redLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Closed',
                      style: TextStyle(
                        color: isActive ? AppColors.green : AppColors.red,
                        fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ── Details Grid ──
            Wrap(
              spacing: 12, runSpacing: 8,
              children: [
                if (displayLocation != null) _DetailChip(icon: Icons.location_on_outlined, text: displayLocation, color: c.textSecondary),
                if (displaySalary != null) _DetailChip(icon: Icons.attach_money_rounded, text: displaySalary, color: AppColors.green),
                if (displayType != null) _DetailChip(icon: Icons.schedule_rounded, text: displayType, color: AppColors.purple),
                if (applicantsCount != null) _DetailChip(icon: Icons.people_outline_rounded, text: '$applicantsCount applicants', color: AppColors.primary),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // ── Description (فقط في النمط الديناميكي) ──
            if (_isDynamicMode && offer!['description'] != null && offer!['description'].toString().isNotEmpty) ...[
              Text(offer!['description'].toString().length > 100 
                  ? '${offer!['description'].toString().substring(0, 100)}...' 
                  : offer!['description'],
                style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter', height: 1.4)),
              const SizedBox(height: 16),
            ],
            
// ── Actions ──
Row(
  children: [
    // زر التقديم (للطلاب في النمط الديناميكي)
    if (_isDynamicMode && isRecruiter == false)
      Expanded(
        child: FutureBuilder<bool>(
          // ✅ نتحقق مما إذا كان المستخدم قد قدم مسبقاً
          future: _checkIfApplied(context),
          builder: (context, snapshot) {
            final hasApplied = snapshot.data ?? false;
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              // أثناء التحقق: زر صغير دائري
              return SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            
            if (hasApplied) {
              // ✅ إذا قدم: زر "تم التقديم" غير قابل للنقر
              return Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.green),
                ),
                child: const Center(
                  child: Text('✓ Applied',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                ),
              );
            }
            
            // ❌ إذا لم يقدم: زر "Apply Now" عادي
            return FilledButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Apply Now',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            );
          },
        ),
      ),
    
    // زر الإدارة (للمسؤولين) - كما هو
    if (_isDynamicMode && isRecruiter == true && onManage != null)
      Expanded(
        child: OutlinedButton.icon(
          onPressed: onManage,
          icon: const Icon(Icons.manage_accounts_rounded, size: 18),
          label: const Text('Manage',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.purple,
            side: BorderSide(color: AppColors.purple),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    
    // زر المفضلة (للنمط البسيط) - كما هو
    if (!_isDynamicMode && onBookmark != null)
      IconButton(
        onPressed: onBookmark,
        icon: const Icon(Icons.bookmark_border_rounded),
        color: c.textSecondary,
      ),
  ],
),          ],
        ),
      ),
    );
  }
}

// ── Helper: Detail Chip ──
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _DetailChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';

// class JobCard extends StatefulWidget {
//   final String title;
//   final String company;
//   final String type;
//   final String salary;
//   final String location;
//   final VoidCallback? onBookmark;

//   const JobCard({
//     super.key,
//     required this.title,
//     required this.company,
//     required this.type,
//     required this.salary,
//     this.location = '',
//     this.onBookmark,
//   });

//   @override
//   State<JobCard> createState() => _JobCardState();
// }

// class _JobCardState extends State<JobCard> {
//   bool _bookmarked = false;

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: ShapeDecoration(
//         color: c.surface,
//         shape: RoundedRectangleBorder(
//           side: BorderSide(width: 1.24, color: c.border),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         shadows: const [
//           BoxShadow(
//             color: Color(0x19000000),
//             blurRadius: 2,
//             offset: Offset(0, 1),
//             spreadRadius: -1,
//           ),
//           BoxShadow(
//             color: Color(0x19000000),
//             blurRadius: 3,
//             offset: Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [

//           // ── Title + Bookmark ──
//           Row(
//             mainAxisAlignment:
//                 MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Text(
//                   widget.title,
//                   style: TextStyle(
//                     color: c.textPrimary,
//                     fontSize: 16,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(
//                       () => _bookmarked = !_bookmarked);
//                   widget.onBookmark?.call();
//                 },
//                 child: Icon(
//                   _bookmarked
//                       ? Icons.bookmark_rounded
//                       : Icons.bookmark_border_rounded,
//                   color: _bookmarked
//                       ? AppColors.primary
//                       : c.textSecondary,
//                   size: 20,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),

//           // ── Company ──
//           Text(
//             widget.company,
//             style: TextStyle(
//               color: c.textSecondary,
//               fontSize: 13,
//               fontFamily: 'Inter',
//             ),
//           ),
//           const SizedBox(height: 12),

//           // ── Tags Row ──
//           Row(
//             children: [

//               // ── Type Badge ──
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryLight,
//                   borderRadius:
//                       BorderRadius.circular(100),
//                 ),
//                 child: Text(
//                   widget.type.toUpperCase(),
//                   style: const TextStyle(
//                     color: AppColors.primary,
//                     fontSize: 10,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),

//               // ── Salary ──
//               Row(
//                 children: [
//                   Icon(
//                     Icons.attach_money_rounded,
//                     color: c.textSecondary,
//                     size: 14,
//                   ),
//                   Text(
//                     widget.salary,
//                     style: TextStyle(
//                       color: c.textSecondary,
//                       fontSize: 12,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }