import 'package:flutter/material.dart';
import 'package:minipr/screens/recruteur/applicants_screen.dart';
import 'package:minipr/screens/recruteur/edit_offer_screen.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/offers_service.dart';

class ManageOfferScreen extends StatelessWidget {
  final Map<String, dynamic> offer;
  const ManageOfferScreen({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final offersService = OffersService();

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Manage Job', style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Job Summary Card ──
            Container(
              padding: const EdgeInsets.all(20),
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
                  Text(offer['title'] ?? 'Untitled',
                    style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(offer['company'] ?? 'Company',
                    style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter')),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12, runSpacing: 8,
                    children: [
                      _Chip(icon: Icons.location_on_outlined, text: offer['location'] ?? 'Remote', color: c.textSecondary),
                      _Chip(icon: Icons.attach_money_rounded, text: offer['salary'] ?? 'Negotiable', color: AppColors.green),
                      _Chip(icon: Icons.schedule_rounded, text: offer['jobType'] ?? 'Full-time', color: AppColors.purple),
                      _Chip(icon: Icons.people_outline_rounded, text: '${offer['applicationsCount'] ?? 0} applicants', color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Actions ──
            Text('Actions', style: TextStyle(color: c.textPrimary, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            
// ✅ Edit Job Details
_ActionCard(
  icon: Icons.edit_rounded,
  iconColor: AppColors.purple,
  title: 'Edit Job Details',
  subtitle: 'Update title, description, salary, etc.',
  onTap: () async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditOfferScreen(offer: offer)),
    );
    if (result == true && context.mounted) {
      // Refresh the offer data if needed
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Job updated!'), backgroundColor: AppColors.green,
      ));
    }
  },
),

// ✅ View Applicants
_ActionCard(
  icon: Icons.people_outline_rounded,
  iconColor: AppColors.green,
  title: 'View Applicants',
  subtitle: '${offer['applicationsCount'] ?? 0} candidates applied',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ApplicantsScreen(
        offerId: offer['id'],
        offerTitle: offer['title'],
      )),
    );
  },
),            const SizedBox(height: 12),
            
            // ✅ Deactivate Job (مفعّل)
            _ActionCard(
              icon: Icons.close_rounded,
              iconColor: AppColors.red,
              title: 'Deactivate Job',
              subtitle: 'Hide this job from job seekers',
              isDestructive: true,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Deactivate Job?'),
                    content: const Text('This will hide the job from seekers. You can reactivate it later.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Deactivate', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  final success = await offersService.deactivateOffer(offer['id']);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? 'Job deactivated ✓' : 'Failed to deactivate'),
                      backgroundColor: success ? AppColors.green : AppColors.red,
                    ));
                    if (success) Navigator.pop(context); // Return to offers list
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper: Chip ──
class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Chip({required this.icon, required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(text, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500))],
  );
}

// ── Helper: Action Card ──
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  const _ActionCard({
    required this.icon, required this.iconColor,
    required this.title, required this.subtitle,
    required this.onTap, this.isDestructive = false,
  });
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDestructive ? AppColors.red : c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: c.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}