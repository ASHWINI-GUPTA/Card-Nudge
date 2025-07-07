import admin from "npm:firebase-admin@^11.11.1";
import { NotificationLog } from "../models.ts";

export class FirebaseService {
  private app: admin.app.App | undefined;

  constructor(serviceAccountJson: string | undefined) {
    if (!serviceAccountJson) {
      console.error("❌ Missing FIREBASE_SERVICE_ACCOUNT_JSON env var.");
      return;
    }
    try {
      this.app = admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(serviceAccountJson)),
      });
    } catch (e) {
      console.error("❌ Firebase Admin SDK init failed:", e);
    }
  }

  isInitialized(): boolean {
    return this.app !== undefined;
  }

  async sendNotification(
    userId: string,
    cardId: string,
    notificationType: NotificationLog["notification_type"],
    title: string,
    body: string,
    payload: string,
    tokens: string[],
    logs: NotificationLog[],
    failedTokens: string[],
  ): Promise<void> {
    if (!this.app || !tokens.length) return;

    const msg: admin.messaging.MulticastMessage = {
      notification: { title, body },
      data: { route: payload },
      tokens,
      android: {
        notification: {
          tag: `${notificationType}-${cardId}`,
        },
      },
      apns: {
        headers: {
          "apns-collapse-id": `${notificationType}-${cardId}`,
        },
      },
    };

    try {
      const result = await this.app.messaging().sendEachForMulticast(msg);
      result.responses.forEach((res, i) => {
        if (res.success) {
          logs.push({
            user_id: userId,
            card_id: cardId,
            notification_type: notificationType,
            title,
            body,
            payload,
            sent_at: new Date().toISOString(),
          });
        } else if (res.error) {
          const e = res.error.code;
          console.warn(
            `Failed to send FCM to token ${
              tokens[i]
            } for user ${userId}, card ${cardId}. Error: ${e}`,
          );
          if (
            [
              "messaging/invalid-registration-token",
              "messaging/registration-token-not-registered",
              "messaging/not-found",
            ].includes(e)
          ) {
            failedTokens.push(tokens[i]);
          }
        }
      });
    } catch (error) {
      console.error("Error sending FCM multicast message:", error);
    }
  }
}
