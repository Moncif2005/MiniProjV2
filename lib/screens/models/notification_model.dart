import 'package:cloud_firestore/cloud_firestore.dart';

enum NotifType {
  newApplicant,
  applicationReviewing,
  applicationInterview,
  applicationAccepted,
  applicationRejected,
}

extension NotifTypeX on NotifType {
  String get key => name;

  /// 🔥 IMPORTANT: category used in UI
  String get category {
    switch (this) {
      case NotifType.newApplicant:
        return 'job';
      case NotifType.applicationReviewing:
      case NotifType.applicationInterview:
      case NotifType.applicationAccepted:
      case NotifType.applicationRejected:
        return 'job';
    }
  }

  static NotifType fromKey(String key) {
    return NotifType.values.firstWhere(
      (e) => e.name == key,
      orElse: () => NotifType.newApplicant,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotifType type;
  final bool isUnread;
  final Timestamp createdAt;
  final Map<String, dynamic>? payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isUnread,
    required this.createdAt,
    this.payload,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      title: d['title'] ?? '',
      body: d['body'] ?? '',
      type: NotifTypeX.fromKey(d['type'] ?? ''),
      isUnread: d['isUnread'] ?? true,
      createdAt: d['createdAt'] ?? Timestamp.now(),
      payload: d['payload'] != null
          ? Map<String, dynamic>.from(d['payload'])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'type': type.key,
        'isUnread': isUnread,
        'createdAt': createdAt,
        if (payload != null) 'payload': payload,
      };

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt.toDate());

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inHours < 1) return "${diff.inMinutes} min ago";
    if (diff.inDays < 1) return "${diff.inHours} h ago";
    return "${diff.inDays} d ago";
  }
}