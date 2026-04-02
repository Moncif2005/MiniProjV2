import 'package:flutter/material.dart';
import '../../widgets/course_card.dart';
import '../../widgets/bottom_nav_bar.dart';

class RecommendedScreen extends StatefulWidget {
  const RecommendedScreen({super.key});

  @override
  State<RecommendedScreen> createState() => _RecommendedScreenState();
}

class _RecommendedScreenState extends State<RecommendedScreen> {
  int _currentNavIndex = 0;

  final List<Map<String, dynamic>> _courses = [
    {
      'title': 'Arabic for Professionals',
      'instructor': 'Ahmed Hassan',
      'rating': '4.9',
      'category': 'Languages',
      'imageUrl': 'https://placehold.co/238x128',
    },
    {
      'title': 'UX/UI Advanced Motion',
      'instructor': 'Sarah Jenkins',
      'rating': '4.9',
      'category': 'Design',
      'imageUrl': 'https://placehold.co/238x128',
    },
    {
      'title': 'Flutter Development',
      'instructor': 'John Smith',
      'rating': '4.8',
      'category': 'Mobile',
      'imageUrl': 'https://placehold.co/238x128',
    },
    {
      'title': 'Business Strategy 101',
      'instructor': 'Emma Brown',
      'rating': '4.6',
      'category': 'Business',
      'imageUrl': 'https://placehold.co/238x128',
    },
    {
      'title': 'Advanced Python',
      'instructor': 'Chris Lee',
      'rating': '4.7',
      'category': 'Coding',
      'imageUrl': 'https://placehold.co/238x128',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/learn', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/opportunities', (route) => false);
              break;
          }
        },
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFF5F5F5), width: 1.24),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF171717),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Recommended for You',
                    style: TextStyle(
                      color: Color(0xFF171717),
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // ── Course Grid ──
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 8),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  return CourseCard(
                    title: course['title'],
                    instructor: course['instructor'],
                    rating: course['rating'],
                    category: course['category'],
                    imageUrl: course['imageUrl'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}