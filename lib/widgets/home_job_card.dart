import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HomeJobCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  final VoidCallback? onTap;

  const HomeJobCard({
    super.key,
    required this.offer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    
    // استخراج البيانات بأمان
    final title = offer['title'] ?? 'Untitled Job';
    final company = offer['company'] ?? 'Unknown Company';
    final location = offer['location'] ?? 'Remote';
    final salary = offer['salary'] ?? 'Negotiable';
    final jobType = offer['jobType'] ?? 'Full-time';
    
    // ألوان الشعار (من البيانات المخزنة في العرض)
    final companyBg = Color(offer['companyBgColor'] ?? AppColors.primaryLight.value);
    final companyColor = Color(offer['companyColor'] ?? AppColors.primary.value);
    final companyInitial = (offer['companyInitial'] ?? company[0]).toString().toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            // شعار الشركة الصغير
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: companyBg.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  companyInitial,
                  style: TextStyle(
                    color: companyColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // تفاصيل الوظيفة المدمجة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$company • $location',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money_rounded, size: 12, color: AppColors.green),
                      const SizedBox(width: 4),
                      Text(
                        salary,
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.work_outline_rounded, size: 12, color: AppColors.purple),
                      const SizedBox(width: 4),
                      Text(
                        jobType,
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // سهم صغير للدلالة على الانتقال
            Icon(Icons.arrow_forward_ios_rounded, color: c.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}