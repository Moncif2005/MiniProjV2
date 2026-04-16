const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");

initializeApp();

/**
 * Triggered whenever a new notification document is created under:
 *   users/{uid}/notifications/{notifId}
 *
 * If the document contains a `fcmToken`, a push notification is sent
 * to that device. The `fcmSent` field is then set to true so it won't
 * be retried.
 */
exports.sendPushOnNotification = onDocumentCreated(
  "users/{uid}/notifications/{notifId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const { title, body, fcmToken, fcmSent, type, payload } = data;

    // Skip if already sent or no token
    if (fcmSent === true || !fcmToken) {
      console.log(`⏭ Skipping push for ${event.params.notifId}: fcmSent=${fcmSent}, hasToken=${!!fcmToken}`);
      return;
    }

    const message = {
      token: fcmToken,
      notification: {
        title: title ?? "Formanova",
        body: body ?? "",
      },
      data: {
        type: type ?? "system",
        notifId: event.params.notifId,
        uid: event.params.uid,
        ...(payload ? flattenPayload(payload) : {}),
      },
      android: {
        priority: "high",
        notification: {
          channelId: "formanova_high",
          icon: "ic_launcher",
          color: "#155DFC",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    };

    try {
      const response = await getMessaging().send(message);
      console.log(`✅ Push sent [${event.params.notifId}]:`, response);

      // Mark as sent so we don't retry
      await getFirestore()
        .collection("users")
        .doc(event.params.uid)
        .collection("notifications")
        .doc(event.params.notifId)
        .update({
          fcmSent: true,
          fcmSentAt: FieldValue.serverTimestamp(),
          // Remove token from doc after use (privacy best-practice)
          fcmToken: FieldValue.delete(),
        });
    } catch (err) {
      console.error(`❌ Push failed [${event.params.notifId}]:`, err?.message ?? err);

      // If token is invalid/unregistered, remove it from the user doc
      if (
        err?.code === "messaging/invalid-registration-token" ||
        err?.code === "messaging/registration-token-not-registered"
      ) {
        console.log(`🗑 Removing stale token for uid=${event.params.uid}`);
        await getFirestore()
          .collection("users")
          .doc(event.params.uid)
          .update({ fcmToken: FieldValue.delete() });
      }
    }
  }
);

/**
 * Flatten a nested payload object into string key-value pairs
 * (FCM data fields must all be strings)
 */
function flattenPayload(payload) {
  const flat = {};
  for (const [k, v] of Object.entries(payload)) {
    flat[k] = String(v);
  }
  return flat;
}
