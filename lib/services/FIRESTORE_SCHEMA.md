# Firestore Database Schema — Formanova

## Overview

كل شاشة من الشاشات الست لها service منفصلة تتعامل مع Firestore بشكل مستقل.

---

## Collections Structure

```
firestore/
├── users/
│   └── {uid}/
│       ├── [fields]               ← بيانات المستخدم الأساسية
│       ├── notifications/         ← NotificationsService
│       │   └── {notifId}/
│       ├── enrollments/           ← LearningHistoryService
│       │   └── {courseId}/
│       ├── lessonProgress/        ← LessonsService
│       │   └── {courseId}/
│       └── portfolio/             ← CertificatesService
│           └── {itemId}/
│
├── courses/                       ← LearnService + LessonsService
│   └── {courseId}/
│       ├── [fields]
│       └── lessons/
│           └── {lessonId}/
│
├── offers/                        ← OffersService
│   └── {offerId}/
│
└── applications/                  ← AppliedJobsService
    └── {applicationId}/
```

---

## Document Schemas

### `/users/{uid}`
```json
{
  "uid": "string",
  "role": "etudiant | enseignant | recruteur",
  "email": "string",
  "displayName": "string",
  "photoURL": "string | null",
  "bio": "string",
  "phone": "string",
  "github": "string",
  "linkedin": "string",
  "facebook": "string",
  "createdAt": "Timestamp",
  "lastLogin": "Timestamp",
  "isActive": true,
  "settings": {
    "theme": "system | light | dark",
    "notifications": true,
    "jobNotifications": true
  },
  "privacy": {
    "profileVisible": true,
    "showEmail": false
  },
  "stats": {
    // etudiant
    "enrolledCourses": 0,
    "completedCourses": 0,
    "certificates": 0,
    "streakDays": 0,
    "totalLearningMinutes": 0,
    "jobs": {
      "reviewing": 0,
      "interviews": 0,
      "accepted": 0,
      "rejected": 0
    },
    // enseignant
    "coursesCreated": 0,
    "totalStudents": 0,
    "averageRating": 0.0,
    // recruteur
    "jobsPosted": 0,
    "totalApplicants": 0
  }
}
```

### `/users/{uid}/notifications/{notifId}`
```json
{
  "title": "string",
  "body": "string",
  "type": "course | job | achievement | system",
  "isUnread": true,
  "createdAt": "Timestamp",
  "payload": { "courseId": "...", "offerId": "..." }
}
```

### `/users/{uid}/enrollments/{courseId}`
```json
{
  "courseTitle": "string",
  "category": "string",
  "enrolledAt": "Timestamp",
  "lastAccessedAt": "Timestamp",
  "progressPercent": 0.75,
  "completedLessons": 18,
  "totalLessons": 24,
  "timeSpentMinutes": 750,
  "isCompleted": false,
  "completedAt": null,
  "userRating": null
}
```

### `/users/{uid}/lessonProgress/{courseId}`
```json
{
  "completedLessonIds": ["lessonId1", "lessonId2"],
  "lastLessonId": "lessonId2",
  "lastAccessedAt": "Timestamp",
  "progressPercent": 0.5
}
```

### `/users/{uid}/portfolio/{itemId}`
```json
{
  "type": "certificate | formation | portfolio",
  "title": "string",
  "issuer": "string",
  "date": "January 2026",
  "certId": "UC-123456789",
  "description": "string | null",
  "credentialUrl": "string | null",
  "thumbnailUrl": "string | null",
  "createdAt": "Timestamp",
  "isVerified": false
}
```

### `/courses/{courseId}`
```json
{
  "title": "string",
  "instructor": "string",
  "instructorId": "uid",
  "rating": 4.9,
  "ratingCount": 120,
  "category": "Languages | Design | Coding | Business",
  "durationMinutes": 750,
  "lessonsCount": 24,
  "price": 0.0,
  "thumbnailUrl": "string | null",
  "description": "string",
  "isPublished": true,
  "createdAt": "Timestamp",
  "enrolledCount": 0
}
```

### `/courses/{courseId}/lessons/{lessonId}`
```json
{
  "title": "string",
  "durationMinutes": 20,
  "order": 1,
  "videoUrl": "string | null",
  "description": "string",
  "isFree": false,
  "createdAt": "Timestamp"
}
```

### `/offers/{offerId}`
```json
{
  "title": "string",
  "company": "string",
  "companyInitial": "S",
  "companyBgColor": 4293848063,
  "companyColor": 4283322870,
  "location": "London, UK",
  "postedAt": "Timestamp",
  "salary": "$80k - $110k",
  "jobType": "Full-time | Freelance | Contract | Remote",
  "isActive": true,
  "description": "string",
  "recruiterId": "uid"
}
```

### `/applications/{applicationId}`
```json
{
  "applicantId": "uid",
  "offerId": "string",
  "offerTitle": "string",
  "company": "string",
  "companyInitial": "S",
  "companyBgColor": 4293848063,
  "companyColor": 4283322870,
  "location": "string",
  "jobType": "string",
  "salary": "string",
  "appliedAt": "Timestamp",
  "status": "pending | reviewing | interview | accepted | rejected",
  "statusMessage": "string | null",
  "viewCount": 0
}
```

---

## Firestore Indexes Required

```
# applications
applicantId ASC + appliedAt DESC

# offers
isActive ASC + postedAt DESC
isActive ASC + jobType ASC + postedAt DESC

# courses
isPublished ASC + rating DESC
isPublished ASC + category ASC + rating DESC

# users/{uid}/notifications
createdAt DESC
isUnread ASC

# users/{uid}/enrollments
lastAccessedAt DESC

# users/{uid}/portfolio
createdAt DESC
type ASC + createdAt DESC
```

---

## Services Summary

| Screen              | Service File                  | Collection(s)                              |
|---------------------|-------------------------------|--------------------------------------------|
| Offers              | `offers_service.dart`         | `/offers`                                  |
| Learn               | `learn_service.dart`          | `/courses`                                 |
| Lesson              | `lessons_service.dart`        | `/courses/{id}/lessons`, `/users/{uid}/lessonProgress` |
| Notifications       | `notifications_service.dart`  | `/users/{uid}/notifications`               |
| Learning History    | `learning_history_service.dart` | `/users/{uid}/enrollments`               |
| Applied Jobs        | `applied_jobs_service.dart`   | `/applications`                            |
| Certificates        | `certificates_service.dart`   | `/users/{uid}/portfolio`                   |
