import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/course_card.dart';
import '../../widgets/continue_learning_card.dart';
import '../../widgets/job_card.dart';

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
    final displayName = user.name.isNotEmpty ? user.firstName : 'Alex';

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/etudiant/learn', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/offers', (route) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/etudiant/profile', (route) => false);
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
                          color: c.textPrimary,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Ready to learn something new?',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
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
                              side: BorderSide(width: 1.24, color: c.border),
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
                          child: Icon(Icons.notifications_outlined,
                              color: c.textSecondary, size: 20),
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
                              border:
                                  Border.all(color: c.surface, width: 1.24),
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
                    hintText: 'Search courses...',
                    hintStyle: TextStyle(
                        color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: c.textSecondary),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Continue Learning Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: ShapeDecoration(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0xFFDBEAFE),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: Color(0xFFDBEAFE),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Continue Learning',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '0 courses in progress ',
                              style: TextStyle(
                                color: Color(0xFFDBEAFE),
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.play_circle_outline,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, '/etudiant/learn'),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'Browse All Courses',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Recommended Courses ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/etudiant/learn'),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── In Progress — only shown when the user has started courses ──
              if (user.hasEnrolledCourses) ...[
                Text(
                  'In Progress',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...user.enrolledCourses.map((course) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ContinueLearningCard(
                    title: course.title,
                    subtitle: course.subtitle,
                    progress: course.progress,
                  ),
                )),
                const SizedBox(height: 32),
              ],

              // ── Job Opportunities ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Job Opportunities',
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
                title: 'Senior UX Designer',
                company: 'Studio Nova',
                location: 'London, UK',
                salary: '\$80k - \$110k',
                type: 'Full-time',
                postedAgo: '2h ago',
                companyInitial: 'S',
                companyColor: const Color(0xFFE0E7FF),
                initialColor: const Color(0xFF4F39F6),
              ),
              const SizedBox(height: 12),
              JobCard(
                title: 'React Native Developer',
                company: 'TechPulse',
                location: 'San Francisco, CA',
                salary: '\$120k - \$150k',
                type: 'Remote',
                postedAgo: '5h ago',
                companyInitial: 'T',
                companyColor: const Color(0xFFCEFAFE),
                initialColor: const Color(0xFF0092B8),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
