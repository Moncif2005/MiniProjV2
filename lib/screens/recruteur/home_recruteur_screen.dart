import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeRecruteurScreen extends StatefulWidget {
  const HomeRecruteurScreen({super.key});

  @override
  State<HomeRecruteurScreen> createState() => _HomeRecruteurScreenState();
}

class _HomeRecruteurScreenState extends State<HomeRecruteurScreen> {
  int _currentNavIndex = 0;
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _candidates = [
    {
      'name': 'Sarah Johnson',
      'role': 'UX Designer',
      'skills': ['Figma', 'Prototyping', 'Research'],
      'experience': '3 years',
      'status': 'Available',
      'initials': 'SJ',
      'color': AppColors.primaryLight,
      'textColor': AppColors.primary,
    },
    {
      'name': 'Ahmed Ben Ali',
      'role': 'Flutter Developer',
      'skills': ['Flutter', 'Dart', 'Firebase'],
      'experience': '2 years',
      'status': 'Open to work',
      'initials': 'AB',
      'color': AppColors.greenLight,
      'textColor': AppColors.green,
    },
    {
      'name': 'Marie Dupont',
      'role': 'Product Manager',
      'skills': ['Agile', 'Roadmapping', 'Analytics'],
      'experience': '5 years',
      'status': 'Available',
      'initials': 'MD',
      'color': AppColors.purpleLight,
      'textColor': AppColors.purple,
    },
  ];

  final List<Map<String, dynamic>> _postedJobs = [
    {
      'title': 'Senior UX Designer',
      'applicants': 24,
      'views': 142,
      'status': 'Active',
      'posted': '2 days ago',
    },
    {
      'title': 'React Native Developer',
      'applicants': 18,
      'views': 98,
      'status': 'Active',
      'posted': '5 days ago',
    },
    {
      'title': 'Product Manager',
      'applicants': 31,
      'views': 210,
      'status': 'Closed',
      'posted': '2 weeks ago',
    },
  ];

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
                  context, '/recruteur/jobs', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/offers', (route) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/recruteur/profile', (route) => false);
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
                        'Find your next great hire',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 16, fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                    child: Stack(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: ShapeDecoration(
                            color: c.surface,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1.24, color: c.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Icon(Icons.notifications_outlined,
                              color: c.textSecondary, size: 20),
                        ),
                        Positioned(
                          top: 6, right: 6,
                          child: Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.surface, width: 1.24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Search ──
              Container(
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.24, color: c.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: c.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search candidates...',
                    hintStyle: TextStyle(
                        color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                    prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Stats Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.gradientPurple,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33AD46FF),
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recruitment Hub',
                                style: TextStyle(
                                  color: Colors.white, fontSize: 18,
                                  fontFamily: 'Inter', fontWeight: FontWeight.w600,
                                )),
                            SizedBox(height: 4),
                            Text('3 active job posts • 73 applicants',
                                style: TextStyle(
                                  color: Color(0xFFEFD9FD), fontSize: 14,
                                  fontFamily: 'Inter',
                                )),
                          ],
                        ),
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.work_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/recruteur/post-job'),
                      child: Container(
                        width: double.infinity, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                color: AppColors.purple, size: 18),
                            SizedBox(width: 8),
                            Text('Post a New Job',
                                style: TextStyle(
                                  color: AppColors.purple, fontSize: 14,
                                  fontFamily: 'Inter', fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ── Stats Row ──
              Row(
                children: [
                  _StatCard(c: c, value: '73', label: 'Total\nApplicants',
                      icon: Icons.people_rounded, color: AppColors.primary),
                  const SizedBox(width: 12),
                  _StatCard(c: c, value: '3', label: 'Active\nJobs',
                      icon: Icons.work_rounded, color: AppColors.green),
                  const SizedBox(width: 12),
                  _StatCard(c: c, value: '8', label: 'Interviews\nScheduled',
                      icon: Icons.event_rounded, color: AppColors.purple),
                ],
              ),
              const SizedBox(height: 32),

              // ── My Posted Jobs ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Posted Jobs',
                      style: TextStyle(
                        color: c.textPrimary, fontSize: 20,
                        fontFamily: 'Inter', fontWeight: FontWeight.w700,
                      )),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/recruteur/jobs'),
                    child: Text('See all',
                        style: TextStyle(
                          color: c.primary, fontSize: 14,
                          fontFamily: 'Inter', fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._postedJobs.map((job) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PostedJobCard(c: c, job: job),
                  )),
              const SizedBox(height: 32),

              // ── Top Candidates ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Top Candidates',
                      style: TextStyle(
                        color: c.textPrimary, fontSize: 20,
                        fontFamily: 'Inter', fontWeight: FontWeight.w700,
                      )),
                  TextButton(
                    onPressed: () {},
                    child: Text('See all',
                        style: TextStyle(
                          color: c.primary, fontSize: 14,
                          fontFamily: 'Inter', fontWeight: FontWeight.w500,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._candidates.map((candidate) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CandidateCard(c: c, candidate: candidate),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final ThemeColors c;
  final String value, label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.c, required this.value, required this.label,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                  color: c.textPrimary, fontSize: 22,
                  fontFamily: 'Inter', fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  color: c.textSecondary, fontSize: 11,
                  fontFamily: 'Inter', height: 1.3,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Posted Job Card ──
class _PostedJobCard extends StatelessWidget {
  final ThemeColors c;
  final Map<String, dynamic> job;

  const _PostedJobCard({required this.c, required this.job});

  @override
  Widget build(BuildContext context) {
    final isActive = job['status'] == 'Active';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: isActive ? AppColors.greenLight : c.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.work_outline_rounded,
                color: isActive ? AppColors.green : c.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job['title'] as String,
                    style: TextStyle(
                      color: c.textPrimary, fontSize: 15,
                      fontFamily: 'Inter', fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 12, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text('${job['applicants']} applicants',
                        style: TextStyle(
                          color: c.textSecondary, fontSize: 12, fontFamily: 'Inter',
                        )),
                    const SizedBox(width: 12),
                    Icon(Icons.visibility_outlined,
                        size: 12, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text('${job['views']} views',
                        style: TextStyle(
                          color: c.textSecondary, fontSize: 12, fontFamily: 'Inter',
                        )),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.greenLight : c.iconBg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(job['status'] as String,
                style: TextStyle(
                  color: isActive ? AppColors.green : c.textSecondary,
                  fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }
}

// ── Candidate Card ──
class _CandidateCard extends StatelessWidget {
  final ThemeColors c;
  final Map<String, dynamic> candidate;

  const _CandidateCard({required this.c, required this.candidate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: candidate['color'] as Color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(candidate['initials'] as String,
                  style: TextStyle(
                    color: candidate['textColor'] as Color,
                    fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(candidate['name'] as String,
                    style: TextStyle(
                      color: c.textPrimary, fontSize: 15,
                      fontFamily: 'Inter', fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 2),
                Text('${candidate['role']} • ${candidate['experience']}',
                    style: TextStyle(
                      color: c.textSecondary, fontSize: 13, fontFamily: 'Inter',
                    )),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6, runSpacing: 4,
                  children: (candidate['skills'] as List<String>).map((skill) =>
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(skill,
                          style: const TextStyle(
                            color: AppColors.primary, fontSize: 10,
                            fontFamily: 'Inter', fontWeight: FontWeight.w700,
                          )),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_forward_rounded,
                color: AppColors.primary, size: 16),
          ),
        ],
      ),
    );
  }
}
