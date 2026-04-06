import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/offer_card.dart';
import '../../../providers/user_provider.dart';
import '../../../services/offers_service.dart';
import '../../../services/applied_jobs_service.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  int _currentNavIndex = 2;
  int _selectedFilter  = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = ['All', 'Full-time', 'Freelance', 'Contract', 'Remote'];

  final _offersService      = OffersService();
  final _appliedJobsService = AppliedJobsService();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  String? get _activeFilter => _selectedFilter == 0 ? null : _filters[_selectedFilter];

  Map<String, String> _routesForRole(UserRole role) {
    switch (role) {
      case UserRole.enseignant: return {'home': '/enseignant/home', 'learn': '/enseignant/courses', 'profile': '/enseignant/profile'};
      case UserRole.recruteur:  return {'home': '/recruteur/home',  'learn': '/recruteur/jobs',    'profile': '/recruteur/profile'};
      case UserRole.etudiant:
      default:                  return {'home': '/etudiant/home',   'learn': '/etudiant/learn',    'profile': '/etudiant/profile'};
    }
  }

  List<OfferModel> _applySearch(List<OfferModel> offers) {
    if (_searchQuery.isEmpty) return offers;
    final q = _searchQuery.toLowerCase();
    return offers.where((o) =>
        o.title.toLowerCase().contains(q) ||
        o.company.toLowerCase().contains(q) ||
        o.location.toLowerCase().contains(q)).toList();
  }

  Future<void> _handleApply(OfferModel offer) async {
    final uid = _uid;
    if (uid == null) return;
    final id = await _appliedJobsService.apply(
      uid: uid, offerId: offer.id, offerTitle: offer.title,
      company: offer.company, companyInitial: offer.companyInitial,
      companyBgColor: offer.companyBgColor, companyColor: offer.companyColor,
      location: offer.location, jobType: offer.jobType, salary: offer.salary,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(id != null ? 'Candidature envoyée pour ${offer.title}!' : 'Vous avez déjà postulé à cette offre.'),
      backgroundColor: id != null ? AppColors.primary : AppColors.orange,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c   = context.colors;
    final role = context.watch<UserProvider>().role;
    final nav  = _routesForRole(role);

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0: Navigator.pushNamedAndRemoveUntil(context, nav['home']!,    (r) => false); break;
            case 1: Navigator.pushNamedAndRemoveUntil(context, nav['learn']!,   (r) => false); break;
            case 3: Navigator.pushNamedAndRemoveUntil(context, nav['profile']!, (r) => false); break;
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
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Working', style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Find your next big move', style: TextStyle(color: c.textSecondary, fontSize: 16, fontFamily: 'Inter')),
                  ]),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary, borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: AppColors.primaryLight, blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4)],
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
                  shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(16)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: c.textPrimary),
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Job title, company or keyword',
                    hintStyle: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                    prefixIcon: Icon(Icons.search_rounded, color: c.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () { _searchController.clear(); setState(() => _searchQuery = ''); },
                            child: Icon(Icons.close_rounded, color: c.textMuted, size: 18))
                        : null,
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
                        border: Border.all(width: 1.24, color: isSelected ? c.textPrimary : c.border),
                      ),
                      child: Text(_filters[index],
                          style: TextStyle(color: isSelected ? c.surface : c.textSecondary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Firebase Stream ──
            Expanded(
              child: StreamBuilder<List<OfferModel>>(
                stream: _offersService.streamOffers(jobTypeFilter: _activeFilter),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Erreur de chargement', style: TextStyle(color: c.textMuted)));
                  }
                  final offers = _applySearch(snap.data ?? []);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('${offers.length} offres disponibles',
                            style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: offers.isEmpty
                            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.search_off_rounded, color: c.textMuted, size: 48),
                                const SizedBox(height: 16),
                                Text('Aucune offre trouvée', style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
                              ]))
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: offers.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final o = offers[index];
                                  return OfferCard(
                                    title: o.title, company: o.company,
                                    companyInitial: o.companyInitial,
                                    companyBg: Color(o.companyBgColor),
                                    companyColor: Color(o.companyColor),
                                    location: o.location, postedAgo: o.postedAgo,
                                    salary: o.salary, jobType: o.jobType,
                                    onApply: () => _handleApply(o),
                                    onBookmark: () {},
                                  );
                                },
                              ),
                      ),
                    ],
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
