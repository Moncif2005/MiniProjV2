import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';

class JobsRecruteurScreen extends StatefulWidget {
  const JobsRecruteurScreen({super.key});

  @override
  State<JobsRecruteurScreen> createState() => _JobsRecruteurScreenState();
}

class _JobsRecruteurScreenState extends State<JobsRecruteurScreen> {
  int _currentNavIndex = 1;
  int _selectedTab = 0; // 0=Active, 1=Closed

  // Empty by default — new accounts see no jobs
  final List<Map<String, dynamic>> _jobs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      final alreadyAdded = _jobs.any((j) => j['title'] == args['title']);
      if (!alreadyAdded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _jobs.add(args));
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filtered =>
      _jobs.where((j) => _selectedTab == 0 ? j['status'] == 'Active' : j['status'] == 'Closed').toList();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final activeCount = _jobs.where((j) => j['status'] == 'Active').length;

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(context, '/recruteur/home', (route) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(context, '/offers', (route) => false);
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(context, '/recruteur/profile', (route) => false);
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/recruteur/post-job'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post Job', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Jobs', style: TextStyle(color: c.textPrimary, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.purpleLight, borderRadius: BorderRadius.circular(100)),
                    child: Text('$activeCount active',
                        style: const TextStyle(color: AppColors.purple, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _Tab(label: 'Active', isSelected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0)),
                  const SizedBox(width: 12),
                  _Tab(label: 'Closed', isSelected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_off_outlined, color: c.textMuted, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            _jobs.isEmpty ? 'No jobs posted yet' : 'No ${_selectedTab == 0 ? 'active' : 'closed'} jobs',
                            style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter'),
                          ),
                          if (_jobs.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Tap "+ Post Job" to create one!',
                                style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter')),
                          ],
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => _JobDetailCard(c: c, job: _filtered[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.purple : c.border, width: 1.24),
        ),
        child: Text(label,
            style: TextStyle(
              color: isSelected ? Colors.white : c.textSecondary,
              fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700,
            )),
      ),
    );
  }
}

class _JobDetailCard extends StatelessWidget {
  final ThemeColors c;
  final Map<String, dynamic> job;
  const _JobDetailCard({required this.c, required this.job});

  @override
  Widget build(BuildContext context) {
    final isActive = job['status'] == 'Active';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['title'] as String,
                        style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: c.textSecondary),
                        const SizedBox(width: 4),
                        Text(job['location'] as String,
                            style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded, size: 12, color: c.textMuted),
                        const SizedBox(width: 4),
                        Text(job['posted'] as String,
                            style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
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
          const SizedBox(height: 14),
          Row(
            children: [
              _Tag(label: job['type'] as String, icon: Icons.work_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              _Tag(label: job['salary'] as String, icon: Icons.attach_money_rounded, color: AppColors.green),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: c.border, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _Metric(icon: Icons.people_outline_rounded, value: '${job['applicants'] ?? 0}', label: 'Applicants', color: c.textSecondary),
              const SizedBox(width: 20),
              _Metric(icon: Icons.visibility_outlined, value: '${job['views'] ?? 0}', label: 'Views', color: c.textSecondary),
              const Spacer(),
              if (isActive)
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.purpleLight, borderRadius: BorderRadius.circular(12)),
                    child: const Text('View',
                        style: TextStyle(color: AppColors.purple, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Tag({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _Metric({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text('$value $label', style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter')),
    ]);
  }
}
