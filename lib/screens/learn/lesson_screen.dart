import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum LessonItemStatus { completed, current, locked }

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  bool _isCompleted = false;

  final List<Map<String, dynamic>> _lessons = [
    {
      'title': 'Introduction to Flutter',
      'duration': '10 min',
      'status': LessonItemStatus.completed,
    },
    {
      'title': 'Widgets & Layouts',
      'duration': '15 min',
      'status': LessonItemStatus.completed,
    },
    {
      'title': 'State Management',
      'duration': '20 min',
      'status': LessonItemStatus.completed,
    },
    {
      'title': 'Navigation & Routing',
      'duration': '18 min',
      'status': LessonItemStatus.current,
    },
    {
      'title': 'Networking & APIs',
      'duration': '25 min',
      'status': LessonItemStatus.locked,
    },
    {
      'title': 'Final Project',
      'duration': '30 min',
      'status': LessonItemStatus.locked,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flutter Development',
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '6 leçons • Lesson 4 en cours',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Progress Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: AppColors.gradientBlue,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x33155DFC),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progression du cours',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: const BoxDecoration(
                                // 0x33 = 20% opacity white
                                color: Color(0x33FFFFFF),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              child: const Text(
                                '3/6 leçons',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Progress Bar ──
                        // 0x40 = 25% opacity white
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const LinearProgressIndicator(
                            value: 0.50,
                            minHeight: 8,
                            backgroundColor: Color(0x40FFFFFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '50% complété',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Lessons Title ──
                  Text(
                    'Leçons',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 18,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Lessons List ──
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _lessons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lesson = _lessons[index];
                      return _LessonItem(
                        number: index + 1,
                        title: lesson['title'] as String,
                        duration: lesson['duration'] as String,
                        status: lesson['status'] as LessonItemStatus,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Mark Complete Button ──
                  GestureDetector(
                    onTap: () {
                      setState(() => _isCompleted = !_isCompleted);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isCompleted
                                ? 'Leçon marquée comme terminée ✓'
                                : 'Leçon réouverte',
                          ),
                          backgroundColor: _isCompleted
                              ? AppColors.green
                              : c.textSecondary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isCompleted
                            ? AppColors.green
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isCompleted
                                        ? AppColors.green
                                        : AppColors.primary)
                                    .withValues(alpha: 0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isCompleted
                                ? 'Leçon terminée ✓'
                                : 'Marquer comme terminée',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lesson Item ──
class _LessonItem extends StatelessWidget {
  final int number;
  final String title;
  final String duration;
  final LessonItemStatus status;

  const _LessonItem({
    required this.number,
    required this.title,
    required this.duration,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final isCompleted = status == LessonItemStatus.completed;
    final isCurrent = status == LessonItemStatus.current;
    final isLocked = status == LessonItemStatus.locked;

    // ── Dark-safe highlight for current lesson ──
    final currentBg = context.isDark
        ? const Color(0xFF1A2A4A)
        : AppColors.primaryLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: isCurrent ? currentBg : c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.24,
            color: isCurrent ? AppColors.primary : c.border,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Status Icon ──
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.greenLight
                  : isCurrent
                  ? AppColors.primary
                  : c.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.green,
                      size: 18,
                    )
                  : isLocked
                  ? Icon(Icons.lock_rounded, color: c.textMuted, size: 16)
                  : Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Title + Duration ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isLocked ? c.textMuted : c.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: c.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        color: c.textMuted,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Right Icon ──
          if (isCompleted)
            const Icon(Icons.replay_rounded, color: AppColors.green, size: 18)
          else if (isCurrent)
            const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.primary,
              size: 20,
            )
          else
            Icon(Icons.lock_outline_rounded, color: c.textMuted, size: 18),
        ],
      ),
    );
  }
}
