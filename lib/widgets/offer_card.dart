import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OfferCard extends StatefulWidget {
  final String title;
  final String company;
  final String companyInitial;
  final Color companyBg;
  final Color companyColor;
  final String location;
  final String postedAgo;
  final String salary;
  final String jobType;
  final bool isBookmarked;
  final VoidCallback? onApply;
  final VoidCallback? onBookmark;

  const OfferCard({
    super.key,
    required this.title,
    required this.company,
    required this.companyInitial,
    required this.companyBg,
    required this.companyColor,
    required this.location,
    required this.postedAgo,
    required this.salary,
    required this.jobType,
    this.isBookmarked = false,
    this.onApply,
    this.onBookmark,
  });

  @override
  State<OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<OfferCard> {
  late bool _bookmarked;

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.isBookmarked;
  }

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
          borderRadius: BorderRadius.circular(24),
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

          // ── Company + Bookmark ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.companyBg,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.companyInitial,
                        style: TextStyle(
                          color: widget.companyColor,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.company,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // ── Bookmark ──
              GestureDetector(
                onTap: () {
                  setState(() => _bookmarked = !_bookmarked);
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
          const SizedBox(height: 16),

          // ── Details Grid ──
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.location_on_outlined,
                  text: widget.location,
                  color: c.textSecondary,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.access_time_rounded,
                  text: widget.postedAgo,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.attach_money_rounded,
                  text: widget.salary,
                  color: c.textSecondary,
                ),
              ),
              Expanded(
                child: _DetailItem(
                  icon: Icons.work_outline_rounded,
                  text: widget.jobType,
                  color: AppColors.primary,
                  isBold: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Apply Button ──
          GestureDetector(
            onTap: widget.onApply,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: c.border, width: 1.24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Apply Now',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: c.textPrimary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isBold;

  const _DetailItem({
    required this.icon,
    required this.text,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight:
                  isBold ? FontWeight.w700 : FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}