import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────
// NotifType
// ─────────────────────────────────────────────────────────────

enum NotifType {
  // Course-family
  courseEnrolled,
  lessonCompleted,
  courseCompleted,
  newStudentEnrolled,
  lessonAdded,
  courseRated,

  // Achievement-family
  streakAchievement,
  certificateEarned,

  // Job / Application — étudiant
  applicationSent,
  applicationReviewing,
  applicationInterview,
  applicationAccepted,
  applicationRejected,

  // Job / Application — recruteur
  newApplicant,
  offerPublished,
  offerExpiring,

  // System
  system;

  // ── Firestore key ──────────────────────────────────────────

  String get key => switch (this) {
        NotifType.courseEnrolled      => 'courseEnrolled',
        NotifType.lessonCompleted     => 'lessonCompleted',
        NotifType.courseCompleted     => 'courseCompleted',
        NotifType.newStudentEnrolled  => 'newStudentEnrolled',
        NotifType.lessonAdded         => 'lessonAdded',
        NotifType.courseRated         => 'courseRated',
        NotifType.streakAchievement   => 'streakAchievement',
        NotifType.certificateEarned   => 'certificateEarned',
        NotifType.applicationSent     => 'applicationSent',
        NotifType.applicationReviewing => 'applicationReviewing',
        NotifType.applicationInterview => 'applicationInterview',
        NotifType.applicationAccepted => 'applicationAccepted',
        NotifType.applicationRejected => 'applicationRejected',
        NotifType.newApplicant        => 'newApplicant',
        NotifType.offerPublished      => 'offerPublished',
        NotifType.offerExpiring       => 'offerExpiring',
        NotifType.system              => 'system',
      };

  // ── Category (used for icon grouping in NotificationScreen) ─

  String get category => switch (this) {
        NotifType.courseEnrolled      ||
        NotifType.lessonCompleted     ||
        NotifType.courseCompleted     ||
        NotifType.newStudentEnrolled  ||
        NotifType.lessonAdded         ||
        NotifType.courseRated         => 'course',
        NotifType.streakAchievement   ||
        NotifType.certificateEarned   => 'achievement',
        NotifType.applicationSent     ||
        NotifType.applicationReviewing ||
        NotifType.applicationInterview ||
        NotifType.applicationAccepted ||
        NotifType.applicationRejected ||
        NotifType.newApplicant        ||
        NotifType.offerPublished      ||
        NotifType.offerExpiring       => 'job',
        NotifType.system              => 'system',
      };

  // ── Factory from Firestore string ─────────────────────────

  static NotifType fromKey(String key) {
    return NotifType.values.firstWhere(
      (e) => e.key == key,
      orElse: () => NotifType.system,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NotificationModel
// ─────────────────────────────────────────────────────────────

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotifType type;
  final bool isUnread;
  final DateTime? createdAt;
  final Map<String, dynamic>? payload;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isUnread,
    this.createdAt,
    this.payload,
  });

  // ── Firestore deserialisation ──────────────────────────────

  factory NotificationModel.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return NotificationModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      type: NotifType.fromKey(data['type'] as String? ?? ''),
      isUnread: data['isUnread'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      payload: data['payload'] as Map<String, dynamic>?,
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  /// Human-readable relative time (e.g. "2h", "3j", "maintenant").
  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);

    if (diff.inSeconds < 60) return 'maintenant';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24)   return '${diff.inHours}h';
    if (diff.inDays < 7)     return '${diff.inDays}j';
    if (diff.inDays < 30)    return '${(diff.inDays / 7).floor()}sem';
    if (diff.inDays < 365)   return '${(diff.inDays / 30).floor()}mois';
    return '${(diff.inDays / 365).floor()}an';
  }
}
