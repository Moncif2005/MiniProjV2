import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/offer_card.dart';
import '../../providers/user_provider.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  int _currentNavIndex = 2;
  int _selectedFilter  = 0;
  final _searchController = TextEditingController();

  final List<String> _filters = [
    'All', 'Full-time', 'Freelance', 'Contract', 'Remote',
  ];

  final List<Map<String, dynamic>> _offers = [
    {
      'title': 'Senior UX Designer',
      'company': 'Studio Nova',
      'initial': 'S',
      'companyBg': const Color(0xFFE0E7FF),
      'companyColor': const Color(0xFF4F39F6),
      'location': 'London, UK',
      'postedAgo': '2h ago',
      'salary': '\$80k - \$110k',
      'jobType': 'Full-time',
    },
    {
      'title': 'React Native Developer',
      'company': 'TechPulse',
      'initial': 'T',
      'companyBg': const Color(0xFFCEFAFE),
      'companyColor': const Color(0xFF0092B8),
      'location': 'San Francisco, CA',
      'postedAgo': '5h ago',
      'salary': '\$120k - \$150k',
      'jobType': 'Remote',
    },
    {
      'title': 'Content Marketing Manager',
      'company': 'GreenGrow',
      'initial': 'G',
      'companyBg': const Color(0xFFDCFCE7),
      'companyColor': const Color(0xFF00A63E),
      'location': 'Berlin, DE',
      'postedAgo': '1d ago',
      'salary': '\$60k - \$75k',
      'jobType': 'Contract',
    },
    {
      'title': 'Product Analyst',
      'company': 'DataDash',
      'initial': 'D',
      'companyBg': const Color(0xFFFFEDD4),
      'companyColor': const Color(0xFFF54900),
      'location': 'Remote',
      'postedAgo': '3d ago',
      'salary': '\$50/hr - \$80/hr',
      'jobType': 'Freelance',
    },
    {
      'title': 'Full Stack Engineer',
      'company': 'Finly',
      'initial': 'F',
      'companyBg': const Color(0xFFDBEAFE),
      'companyColor': const Color(0xFF155DFC),
      'location': 'New York, NY',
      'postedAgo': '1w ago',
      'salary': '\$140k - \$170k',
      'jobType': 'Full-time',
    },
  ];

  List<Map<String, dynamic>> get _filteredOffers {
    if (_selectedFilter == 0) return _offers;
    final selected = _filters[_selectedFilter];
    return _offers.where((o) => o['jobType'] == selected).toList();
  }

  // ── Returns the correct routes for the current user role ──
  Map<String, String> _routesForRole(UserRole role) {
    switch (role) {
      case UserRole.enseignant:
        return {'home': '/enseignant/home', 'learn': '/enseignant/courses', 'profile': '/enseignant/profile'};
      case UserRole.recruteur:
        return {'home': '/recruteur/home', 'learn': '/recruteur/jobs', 'profile': '/recruteur/profile'};
      case UserRole.etudiant:
      default:
        return {'home': '/etudiant/home', 'learn': '/etudiant/learn', 'profile': '/etudiant/profile'};
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final role = context.watch<UserProvider>().role;
    final nav  = _routesForRole(role);

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(context, nav['home']!, (r) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(context, nav['learn']!, (r) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(context, nav['profile']!, (r) => false);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Working',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Find your next big move',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryLight,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
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
                    hintText: 'Job title, company or keyword',
                    hintStyle: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                    prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Filters ──
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
                    onTap: () => setState(() => _selectedFilter = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? c.textPrimary : c.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: 1.24,
                          color: isSelected ? c.textPrimary : c.border,
                        ),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? c.surface : c.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Count ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${_filteredOffers.length} offres disponibles',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── List ──
            Expanded(
              child: _filteredOffers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, color: c.textMuted, size: 48),
                          const SizedBox(height: 16),
                          Text('No offers found',
                              style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _filteredOffers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final offer = _filteredOffers[index];
                        return OfferCard(
                          title: offer['title'] as String,
                          company: offer['company'] as String,
                          companyInitial: offer['initial'] as String,
                          companyBg: offer['companyBg'] as Color,
                          companyColor: offer['companyColor'] as Color,
                          location: offer['location'] as String,
                          postedAgo: offer['postedAgo'] as String,
                          salary: offer['salary'] as String,
                          jobType: offer['jobType'] as String,
                          onApply: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Applied to ${offer['title']}!'),
                                backgroundColor: AppColors.primary,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onBookmark: () {},
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
