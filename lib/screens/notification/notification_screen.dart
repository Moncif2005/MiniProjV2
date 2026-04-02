import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  // New users start with no notifications
  final List<Map<String, dynamic>> _notifications = [];

  bool get _allRead =>
      _notifications.every((n) => !(n['isUnread'] as bool));

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n['isUnread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'job':         return Icons.work_outline_rounded;
      case 'achievement': return Icons.emoji_events_rounded;
      default:            return Icons.menu_book_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'job':         return AppColors.purple;
      case 'achievement': return AppColors.orange;
      default:            return AppColors.primary;
    }
  }

  Color _bgForType(String type) {
    switch (type) {
      case 'job':         return AppColors.purpleLight;
      case 'achievement': return const Color(0xFFFFEDD4);
      default:            return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [

          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(
                24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(
                bottom: BorderSide(
                    color: c.border, width: 1.24),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c.bg,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${_notifications.where((n) => n['isUnread'] as bool).length} unread',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _allRead ? null : _markAllRead,
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      color: _allRead
                          ? c.textMuted
                          : AppColors.primary,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          color: c.textMuted,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final isUnread =
                          n['isUnread'] as bool;
                      final type = n['type'] as String;

                      return GestureDetector(
                        onTap: () {
                          setState(() =>
                              n['isUnread'] = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: isUnread
                                ? (context.isDark
                                    ? const Color(0xFF1A2A4A)
                                    : const Color(0xFFEFF6FF))
                                : c.surface,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1.24,
                                  color: isUnread
                                      ? AppColors.primaryLight
                                      : c.border),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _bgForType(type),
                                  borderRadius:
                                      BorderRadius.circular(
                                          14),
                                ),
                                child: Icon(
                                  _iconForType(type),
                                  color:
                                      _colorForType(type),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            n['title']
                                                as String,
                                            style: TextStyle(
                                              color: c
                                                  .textPrimary,
                                              fontSize: 14,
                                              fontFamily:
                                                  'Inter',
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),
                                        ),
                                        if (isUnread)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration:
                                                const BoxDecoration(
                                              color: AppColors
                                                  .primary,
                                              shape: BoxShape
                                                  .circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      n['body'] as String,
                                      style: TextStyle(
                                        color:
                                            c.textSecondary,
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      n['time'] as String,
                                      style: TextStyle(
                                        color: c.textMuted,
                                        fontSize: 11,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}