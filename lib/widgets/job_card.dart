import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class JobCard extends StatefulWidget {
  final String title;
  final String company;
  final String type;
  final String salary;
  final String location;
  final VoidCallback? onBookmark;

  const JobCard({
    super.key,
    required this.title,
    required this.company,
    required this.type,
    required this.salary,
    this.location = '',
    this.onBookmark,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Title + Bookmark ──
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(
                      () => _bookmarked = !_bookmarked);
                  widget.onBookmark?.call();
                },
                child: Icon(
                  _bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _bookmarked
                      ? AppColors.primary
                      : c.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Company ──
          Text(
            widget.company,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),

          // ── Tags Row ──
          Row(
            children: [

              // ── Type Badge ──
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius:
                      BorderRadius.circular(100),
                ),
                child: Text(
                  widget.type.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ── Salary ──
              Row(
                children: [
                  Icon(
                    Icons.attach_money_rounded,
                    color: c.textSecondary,
                    size: 14,
                  ),
                  Text(
                    widget.salary,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}