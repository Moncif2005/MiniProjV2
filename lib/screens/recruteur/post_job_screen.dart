import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/offers_service.dart'; // ✅ استيراد الخدمة الجديدة

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});
  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _titleCtrl    = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryCtrl   = TextEditingController();
  final _descCtrl     = TextEditingController();
  String? _type;
  bool _isPublishing = false; // ✅ حالة التحميل

  final _types = ['Full-time', 'Part-time', 'Remote', 'Hybrid', 'Contract'];
  final _offersService = OffersService(); // ✅ إنشاء نسخة من الخدمة

  @override
  void dispose() {
    _titleCtrl.dispose(); _locationCtrl.dispose();
    _salaryCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  // ✅ الدالة المحدثة: تنشر الوظيفة في Firestore فعلياً
  Future<void> _publish() async {
    // 1. التحقق من صحة البيانات
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a job title'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    // 2. الحصول على بيانات المستخدم المسجل
    final user = FirebaseAuth.instance.currentUser;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please sign in to post a job'),
        backgroundColor: AppColors.red,
      ));
      return;
    }

    setState(() => _isPublishing = true);

    try {
      // 3. استدعاء الخدمة لنشر الوظيفة في Firestore
      final offerId = await _offersService.createOffer(
        recruiterId: user.uid,
        recruiterName: userProvider.name, // نأخذ الاسم من البروفايل
        title: _titleCtrl.text.trim(),
        company: userProvider.name, // يمكن تعديلها لاحقاً لتكون اسم الشركة
        location: _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : 'Remote',
        salary: _salaryCtrl.text.trim().isNotEmpty ? _salaryCtrl.text.trim() : 'Negotiable',
        jobType: _type ?? 'Full-time',
        description: _descCtrl.text.trim(),
      );

      if (offerId != null) {
        // ✅ النجاح
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Job posted successfully! 🎉'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ));
        
        // العودة للشاشة الرئيسية لمسؤول التوظيف
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context, '/recruteur/home', (r) => false,
          );
        }
      } else {
        throw Exception('Failed to create offer');
      }

    } catch (e) {
      // ❌ التعامل مع الأخطاء
      debugPrint('❌ Error posting job: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── AppBar ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.bg,
              border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: ShapeDecoration(
                      color: c.surface,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1.24, color: c.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1))],
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Post a Job', style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                    Text('Fill in the details below', style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ],
            ),
          ),

          // ── Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Job Title *', c),
                  const SizedBox(height: 8),
                  _field(_titleCtrl, 'Ex: Senior Flutter Developer', c),
                  const SizedBox(height: 16),

                  _label('Location', c),
                  const SizedBox(height: 8),
                  _field(_locationCtrl, 'Ex: Paris, France or Remote', c),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Job Type', c),
                            const SizedBox(height: 8),
                            _dropdown(_type, 'Select type', _types, (v) => setState(() => _type = v), c),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label('Salary Range', c),
                            const SizedBox(height: 8),
                            _field(_salaryCtrl, 'Ex: \$80k–\$100k', c),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _label('Job Description', c),
                  const SizedBox(height: 8),
                  _field(_descCtrl, 'Describe the role, responsibilities, and requirements...', c, maxLines: 5),
                  const SizedBox(height: 32),

                  // ── Preview Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(context.isDark ? 0.15 : 0.06),
                      border: Border.all(color: AppColors.purple.withOpacity(0.3), width: 1.24),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
                              child: const Icon(Icons.preview_rounded, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Text('Preview', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _row('Title:', _titleCtrl.text.isNotEmpty ? _titleCtrl.text : '—', c),
                        const SizedBox(height: 6),
                        _row('Location:', _locationCtrl.text.isNotEmpty ? _locationCtrl.text : '—', c),
                        const SizedBox(height: 6),
                        _row('Type:', _type ?? '—', c),
                        const SizedBox(height: 6),
                        _row('Salary:', _salaryCtrl.text.isNotEmpty ? _salaryCtrl.text : '—', c),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Publish Button ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(top: BorderSide(color: c.border, width: 1.24)),
            ),
            child: GestureDetector(
              onTap: _isPublishing ? null : _publish, // ✅ منع النقر المتكرر أثناء التحميل
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56, width: double.infinity,
                decoration: BoxDecoration(
                  color: _isPublishing ? c.border : AppColors.purple,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _isPublishing ? [] : [const BoxShadow(color: Color(0x33AD46FF), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3)],
                ),
                child: Center(
                  child: _isPublishing 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Publish Job', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                          SizedBox(width: 8),
                          Icon(Icons.publish_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets (نفسها كما هي) ──
  Widget _label(String text, ThemeColors c) => Text(text,
    style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700));

  Widget _row(String label, String val, ThemeColors c) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter')),
      Text(val, style: TextStyle(color: c.textPrimary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
    ],
  );

  Widget _field(TextEditingController ctrl, String hint, ThemeColors c, {int maxLines = 1}) =>
    Container(
      decoration: ShapeDecoration(
        color: c.inputBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: TextField(
        controller: ctrl, maxLines: maxLines,
        style: TextStyle(color: c.textPrimary),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );

  Widget _dropdown(String? value, String hint, List<String> items, ValueChanged<String?> onChange, ThemeColors c) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color: c.inputBg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          dropdownColor: c.surface,
          hint: Text(hint, style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter')),
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontSize: 14)),
          )).toList(),
          onChanged: onChange,
        ),
      ),
    );
}

// import 'package:flutter/material.dart';
// import '../../theme/app_colors.dart';

// class PostJobScreen extends StatefulWidget {
//   const PostJobScreen({super.key});
//   @override
//   State<PostJobScreen> createState() => _PostJobScreenState();
// }

// class _PostJobScreenState extends State<PostJobScreen> {
//   final _titleCtrl    = TextEditingController();
//   final _locationCtrl = TextEditingController();
//   final _salaryCtrl   = TextEditingController();
//   final _descCtrl     = TextEditingController();
//   String? _type;

//   final _types = ['Full-time', 'Part-time', 'Remote', 'Hybrid', 'Contract'];

//   @override
//   void dispose() {
//     _titleCtrl.dispose(); _locationCtrl.dispose();
//     _salaryCtrl.dispose(); _descCtrl.dispose();
//     super.dispose();
//   }

//   void _publish() {
//     if (_titleCtrl.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Please enter a job title'),
//         backgroundColor: AppColors.red,
//         behavior: SnackBarBehavior.floating,
//       ));
//       return;
//     }

//     final newJob = {
//       'title':      _titleCtrl.text.trim(),
//       'location':   _locationCtrl.text.trim().isNotEmpty ? _locationCtrl.text.trim() : 'Remote',
//       'type':       _type ?? 'Full-time',
//       'salary':     _salaryCtrl.text.trim().isNotEmpty ? _salaryCtrl.text.trim() : 'Negotiable',
//       'applicants': 0,
//       'views':      0,
//       'status':     'Active',
//       'posted':     'Just now',
//     };

//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       content: Text('Job posted successfully!'),
//       backgroundColor: AppColors.green,
//       behavior: SnackBarBehavior.floating,
//     ));

//     Navigator.pushNamedAndRemoveUntil(
//       context, '/recruteur/home', (r) => false,
//       arguments: newJob,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.colors;

//     return Scaffold(
//       backgroundColor: c.bg,
//       body: Column(
//         children: [
//           // ── AppBar ──
//           Container(
//             padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
//             decoration: BoxDecoration(
//               color: c.bg,
//               border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
//             ),
//             child: Row(
//               children: [
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: Container(
//                     width: 38, height: 38,
//                     decoration: ShapeDecoration(
//                       color: c.surface,
//                       shape: RoundedRectangleBorder(
//                         side: BorderSide(width: 1.24, color: c.border),
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                       shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1))],
//                     ),
//                     child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Post a Job', style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
//                     Text('Fill in the details below', style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // ── Body ──
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _label('Job Title *', c),
//                   const SizedBox(height: 8),
//                   _field(_titleCtrl, 'Ex: Senior Flutter Developer', c),
//                   const SizedBox(height: 16),

//                   _label('Location', c),
//                   const SizedBox(height: 8),
//                   _field(_locationCtrl, 'Ex: Paris, France or Remote', c),
//                   const SizedBox(height: 16),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _label('Job Type', c),
//                             const SizedBox(height: 8),
//                             _dropdown(_type, 'Select type', _types, (v) => setState(() => _type = v), c),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             _label('Salary Range', c),
//                             const SizedBox(height: 8),
//                             _field(_salaryCtrl, 'Ex: \$80k–\$100k', c),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),

//                   _label('Job Description', c),
//                   const SizedBox(height: 8),
//                   _field(_descCtrl, 'Describe the role, responsibilities, and requirements...', c, maxLines: 5),
//                   const SizedBox(height: 32),

//                   // ── Preview Card ──
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: AppColors.purple.withOpacity(context.isDark ? 0.15 : 0.06),
//                       border: Border.all(color: AppColors.purple.withOpacity(0.3), width: 1.24),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               width: 36, height: 36,
//                               decoration: const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle),
//                               child: const Icon(Icons.preview_rounded, color: Colors.white, size: 18),
//                             ),
//                             const SizedBox(width: 12),
//                             Text('Preview', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         _row('Title:', _titleCtrl.text.isNotEmpty ? _titleCtrl.text : '—', c),
//                         const SizedBox(height: 6),
//                         _row('Location:', _locationCtrl.text.isNotEmpty ? _locationCtrl.text : '—', c),
//                         const SizedBox(height: 6),
//                         _row('Type:', _type ?? '—', c),
//                         const SizedBox(height: 6),
//                         _row('Salary:', _salaryCtrl.text.isNotEmpty ? _salaryCtrl.text : '—', c),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ── Publish Button ──
//           Container(
//             padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
//             decoration: BoxDecoration(
//               color: c.surface,
//               border: Border(top: BorderSide(color: c.border, width: 1.24)),
//             ),
//             child: GestureDetector(
//               onTap: _publish,
//               child: Container(
//                 height: 56, width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: AppColors.purple,
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: const [BoxShadow(color: Color(0x33AD46FF), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3)],
//                 ),
//                 child: const Center(
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Publish Job', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
//                       SizedBox(width: 8),
//                       Icon(Icons.publish_rounded, color: Colors.white, size: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _label(String text, ThemeColors c) => Text(text,
//     style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700));

//   Widget _row(String label, String val, ThemeColors c) => Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(label, style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter')),
//       Text(val, style: TextStyle(color: c.textPrimary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
//     ],
//   );

//   Widget _field(TextEditingController ctrl, String hint, ThemeColors c, {int maxLines = 1}) =>
//     Container(
//       decoration: ShapeDecoration(
//         color: c.inputBg,
//         shape: RoundedRectangleBorder(
//           side: BorderSide(width: 1.24, color: c.border),
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//       child: TextField(
//         controller: ctrl, maxLines: maxLines,
//         style: TextStyle(color: c.textPrimary),
//         onChanged: (_) => setState(() {}),
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter'),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           border: InputBorder.none,
//         ),
//       ),
//     );

//   Widget _dropdown(String? value, String hint, List<String> items, ValueChanged<String?> onChange, ThemeColors c) =>
//     Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: ShapeDecoration(
//         color: c.inputBg,
//         shape: RoundedRectangleBorder(
//           side: BorderSide(width: 1.24, color: c.border),
//           borderRadius: BorderRadius.circular(14),
//         ),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value, isExpanded: true,
//           dropdownColor: c.surface,
//           hint: Text(hint, style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter')),
//           items: items.map((e) => DropdownMenuItem(
//             value: e,
//             child: Text(e, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontSize: 14)),
//           )).toList(),
//           onChanged: onChange,
//         ),
//       ),
//     );
// }
