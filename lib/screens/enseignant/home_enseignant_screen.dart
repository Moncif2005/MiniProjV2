import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeEnseignantScreen extends StatefulWidget {
  const HomeEnseignantScreen({super.key});

  @override
  State<HomeEnseignantScreen> createState() => _HomeEnseignantScreenState();
}

class _HomeEnseignantScreenState extends State<HomeEnseignantScreen> {
  int _currentNavIndex = 0;
  final _searchController = TextEditingController();

  // Starts empty — populated when courses are created
  final List<Map<String, dynamic>> _myCourses = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Receive a newly created course passed back from CreateCourseScreen
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final alreadyAdded = _myCourses.any((c) => c['title'] == args['title']);
      if (!alreadyAdded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _myCourses.add(args));
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();
    final displayName = user.name.isNotEmpty ? user.firstName : 'there';

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 1:
              Navigator.pushNamedAndRemoveUntil(context, '/enseignant/courses', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(context, '/offers', (route) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(context, '/enseignant/profile', (route) => false);
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $displayName!',
                        style: TextStyle(
                          color: c.textPrimary, fontSize: 24,
                          fontFamily: 'Inter', fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Ready to inspire minds today?',
                        style: TextStyle(color: c.textSecondary, fontSize: 16, fontFamily: 'Inter'),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                    child: Container(
                      width: 38, height: 38,
                      decoration: ShapeDecoration(
                        color: c.surface,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.24, color: c.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
                      ),
                      child: Icon(Icons.notifications_outlined, color: c.textSecondary, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Search Bar ──
              Container(
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.24, color: c.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: c.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search courses to manage...',
                    hintStyle: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                    prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── My Courses Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Color(0xFFB9F8CF), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('My Courses',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              _myCourses.isEmpty
                                  ? '0 active courses, let\'s create your first one!'
                                  : '${_myCourses.length} active course${_myCourses.length > 1 ? 's' : ''}',
                              style: const TextStyle(color: Color(0xFFDCFCE7), fontSize: 14, fontFamily: 'Inter'),
                            ),
                          ],
                        ),
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.20), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/enseignant/create-course'),
                      child: Container(
                        width: double.infinity, height: 44,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded, color: AppColors.green, size: 18),
                            SizedBox(width: 8),
                            Text('Create New Course',
                                style: TextStyle(color: AppColors.green, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── My Courses List ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Courses',
                      style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/enseignant/courses'),
                    child: Text('See all',
                        style: TextStyle(color: c.primary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_myCourses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(Icons.school_outlined, size: 48, color: c.textMuted),
                        const SizedBox(height: 12),
                        Text('No courses yet', style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
                        const SizedBox(height: 4),
                        Text('Create your first course above!',
                            style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter')),
                      ],
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _myCourses.map((course) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _TeacherCourseCard(
                        title: course['title'] as String,
                        category: course['category'] as String,
                        instructor: course['instructor'] as String,
                        rating: course['rating'] as String,
                      ),
                    )).toList(),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherCourseCard extends StatelessWidget {
  final String title, category, instructor, rating;
  const _TeacherCourseCard({required this.title, required this.category, required this.instructor, required this.rating});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 240,
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 128, width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 48),
              ),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.90), borderRadius: BorderRadius.circular(10)),
                  child: Text(category,
                      style: const TextStyle(color: AppColors.primary, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(instructor, style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFD08700), size: 16),
                  const SizedBox(width: 4),
                  Text(rating, style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
