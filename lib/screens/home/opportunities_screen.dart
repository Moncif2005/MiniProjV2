import 'package:flutter/material.dart';
import '../../widgets/job_card.dart';
import '../../widgets/bottom_nav_bar.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  int _currentNavIndex = 2;
  int _selectedFilter  = 0;

  final List<String> _filters = [
    'All', 'Full-Time', 'Contract', 'Internship', 'Remote',
  ];

  final List<Map<String, dynamic>> _jobs = [
    {
      'title': 'Senior Product Designer',
      'company': 'Techflow Inc. • Remote',
      'type': 'Full-Time',
      'salary': '\$90K - \$120K',
    },
    {
      'title': 'Marketing Specialist',
      'company': 'Lumina Creative • New York, NY',
      'type': 'Contract',
      'salary': '\$60K - \$80K',
    },
    {
      'title': 'Flutter Developer',
      'company': 'AppStudio • Remote',
      'type': 'Full-Time',
      'salary': '\$80K - \$110K',
    },
    {
      'title': 'UX Research Intern',
      'company': 'DesignLab • San Francisco, CA',
      'type': 'Internship',
      'salary': '\$25/hr',
    },
    {
      'title': 'Backend Engineer',
      'company': 'CloudBase • Remote',
      'type': 'Remote',
      'salary': '\$100K - \$140K',
    },
  ];

  List<Map<String, dynamic>> get _filteredJobs {
    if (_selectedFilter == 0) return _jobs;
    final selected = _filters[_selectedFilter];
    return _jobs.where((j) => j['type'] == selected).toList();
  }

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
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/profile', (route) => false);
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Opportunities',
                    style: TextStyle(
                      color: Color(0xFF171717),
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find your next career move',
                    style: TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Filter Chips ──
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF155DFC)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF155DFC)
                              : const Color(0xFFF5F5F5),
                          width: 1.24,
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF737373),
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── Job List ──
            Expanded(
              child: _filteredJobs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_off_outlined,
                              color: Color(0xFFA1A1A1), size: 48),
                          SizedBox(height: 16),
                          Text(
                            'No jobs found',
                            style: TextStyle(
                              color: Color(0xFFA1A1A1),
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: _filteredJobs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final job = _filteredJobs[index];
                        return JobCard(
                          title: job['title'],
                          company: job['company'],
                          type: job['type'],
                          salary: job['salary'],
                          onBookmark: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${job['title']} bookmarked!'),
                                backgroundColor:
                                    const Color(0xFF00A63E),
                                behavior: SnackBarBehavior.floating,
                              ),
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
}