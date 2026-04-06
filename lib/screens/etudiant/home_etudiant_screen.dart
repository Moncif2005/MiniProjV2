import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/continue_learning_card.dart';
import '../../widgets/course_card.dart';
import '../../widgets/job_card.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeEtudiantScreen extends StatefulWidget {
  const HomeEtudiantScreen({super.key});

  @override
  State<HomeEtudiantScreen> createState() => _HomeEtudiantScreenState();
}

class _HomeEtudiantScreenState extends State<HomeEtudiantScreen> {
  int _currentNavIndex = 0;
  final _searchController = TextEditingController();

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
      // ❌ كان: Navigator.pushNamedAndRemoveUntil(...)
      // ✅ الآن: Navigator.pushNamed فقط
      Navigator.pushNamed(context, '/etudiant/learn');
      break;
    case 2:
      Navigator.pushNamed(context, '/offers'); // ✅ بدون AndRemoveUntil
      break;
    case 3:
      Navigator.pushNamed(context, '/etudiant/profile'); // ✅ بدون AndRemoveUntil
      break;
  }
},      ),
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
                          color: c.textPrimary,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Ready to level up today?',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),

                  // ── Bell ──
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/notifications'),
                    child: Stack(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: ShapeDecoration(
                            color: c.surface,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1.24, color: c.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                                spreadRadius: -1,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: c.textSecondary,
                            size: 20,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: c.surface, width: 1.24),
                            ),
                          ),
                        ),
                      ],
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
                  shadows: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: c.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search courses, jobs, skills...',
                    hintStyle: TextStyle(
                      color: c.textMuted,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: c.textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Continue Learning ──
              const ContinueLearningCard(
                title: 'Continue Learning',
                subtitle: 'Flutter Development - Lesson 4',
                progress: 0.60,
              ),
              const SizedBox(height: 32),

              // ── Recommended ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended for You',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, '/etudiant/learn'),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: c.primary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CourseCard(
                      title: 'Arabic for Professionals',
                      instructor: 'Ahmed Hassan',
                      rating: '4.9',
                      category: 'Languages',
                      imageUrl: 'https://placehold.co/238x128',
                    ),
                    const SizedBox(width: 16),
                    CourseCard(
                      title: 'UX/UI Advanced Motion',
                      instructor: 'Sarah Jenkins',
                      rating: '4.9',
                      category: 'Design',
                      imageUrl: 'https://placehold.co/238x128',
                    ),
                    const SizedBox(width: 16),
                    CourseCard(
                      title: 'Flutter Development',
                      instructor: 'John Smith',
                      rating: '4.8',
                      category: 'Mobile',
                      imageUrl: 'https://placehold.co/238x128',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── New Opportunities ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Opportunities',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/offers'),
                    child: Text(
                      'See all',
                      style: TextStyle(
                        color: c.primary,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              JobCard(
                title: 'Senior Product Designer',
                company: 'Techflow Inc. • Remote',
                type: 'Full-Time',
                salary: '\$90K - \$120K',
                location: 'Remote',
                onBookmark: () {},
              ),
              const SizedBox(height: 12),
              JobCard(
                title: 'Marketing Specialist',
                company: 'Lumina Creative • New York, NY',
                type: 'Contract',
                salary: '\$60K - \$80K',
                location: 'New York, NY',
                onBookmark: () {},
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
