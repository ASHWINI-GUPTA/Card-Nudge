import { createClient } from "npm:@supabase/supabase-js@^2.50.1";
import admin from "npm:firebase-admin@^11.11.1";

// --- Firebase Admin SDK Initialization ---
const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
let firebaseAdminApp: admin.app.App | undefined;
if (!serviceAccountJson) {
  console.error("❌ Missing FIREBASE_SERVICE_ACCOUNT_JSON env var.");
} else {
  try {
    firebaseAdminApp = admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(serviceAccountJson)),
    });
  } catch (e) {
    console.error("❌ Firebase Admin SDK init failed:", e);
  }
}

// --- Supabase Client Initialization ---
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
let supabase: ReturnType<typeof createClient> | undefined;
if (!supabaseUrl || !supabaseKey) {
  console.error(
    "❌ Critical: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables are missing.",
  );
} else {
  try {
    supabase = supabaseUrl && supabaseKey
      ? createClient(supabaseUrl, supabaseKey)
      : undefined;
  } catch (error) {
    console.error("❌ Supabase client creation failed:", error);
  }
}

/**
 * Card entity representing a credit card.
 */
interface Card {
  id: string;
  name: string;
  last_4_digits: string;
  billing_date: string;
  is_archived: boolean;
}

/**
 * Payment entity representing a payment for a card.
 */
interface Payment {
  id: string;
  due_date: string;
  due_amount: number;
  paid_amount: number;
  is_paid: boolean;
  cards: Card | null;
}

/**
 * DeviceToken entity representing a device's FCM token.
 */
interface DeviceToken {
  device_token: string;
}

/**
 * NotificationLog entity for logging sent notifications.
 */
type NotificationLog = {
  user_id: string;
  card_id: string;
  title: string;
  body: string;
  payload: string;
  sent_at: string;
};

/**
 * Helper class to build notification messages in different languages.
 */
class NotificationMessageBuilder {
  /**
   * @param lang User's preferred language.
   */
  constructor(private lang: string) {}

  /**
   * Checks if the language is Hindi.
   * @returns {boolean}
   */
  private isHindi(): boolean {
    return this.lang?.toLowerCase() === "hindi";
  }

  /**
   * Builds a billing reminder notification message.
   * @param card Card for which the reminder is sent.
   * @returns {{title: string, body: string}}
   */
  billingReminder(card: Card): { title: string; body: string; } {
    return this.isHindi()
      ? {
        title: `📅 ${card.name} के लिए बिलिंग तिथि है।`,
        body:
          `आज ${card.name} (**** ${card.last_4_digits}) की बिलिंग तिथि है। अपने खर्चों को लॉग करना न भूलें।`,
      }
      : {
        title: `📅 Billing Day - ${card.name}`,
        body:
          `Today is the billing date for ${card.name} (**** ${card.last_4_digits}). Don't forget to log your expenses!`,
      };
  }

  /**
   * Builds a due reminder notification message.
   * @param card Card for which the reminder is sent.
   * @param dueInDays Number of days left until due date.
   * @param remaining Remaining amount to be paid.
   * @returns {{title: string, body: string}}
   */
  dueReminder(card: Card, dueInDays: number, remaining: number): { title: string; body: string; } {
    return this.isHindi()
      ? {
        title: dueInDays === 0 ? `📌 आज अंतिम तिथि है।` : `⏰ ${dueInDays} दिन शेष।`,
        body:
          `${card.name} (**** ${card.last_4_digits}) के लिए ₹${remaining} भुगतान करना बाकी है।`,
      }
      : {
        title: dueInDays === 0
          ? `📌 Payment Due Today`
          : `⏰ ${dueInDays} day${dueInDays > 1 ? "s" : ""} left`,
        body: `Pay ₹${remaining} for ${card.name} (**** ${card.last_4_digits})`,
      };
  }

  /**
   * Builds an overdue notification message.
   * @param card Card for which the payment is overdue.
   * @param remaining Remaining overdue amount.
   * @returns {{title: string, body: string}}
   */
  overdue(card: Card, remaining: number): { title: string; body: string; } {
    return this.isHindi()
      ? {
        title: `⚠️ भुगतान विलंबित।`,
        body:
          `${card.name} (**** ${card.last_4_digits}) के लिए ₹${remaining} अभी भी बाकी है। विलंब शुल्क लग सकता है।`,
      }
      : {
        title: `⚠️ Payment Overdue`,
        body:
          `₹${remaining} is still due for ${card.name} (**** ${card.last_4_digits}). Late fee may apply.`,
      };
  }

  /**
   * Builds a partial payment notification message.
   * @param card Card for which partial payment was made.
   * @param paid Amount paid.
   * @param remaining Remaining amount to be paid.
   * @returns {{title: string, body: string}}
   */
  partial(card: Card, paid: number, remaining: number): { title: string; body: string; } {
    return this.isHindi()
      ? {
        title: `💸 आंशिक भुगतान`,
        body:
          `आपने ₹${paid} का भुगतान किया है। ₹${remaining} अभी भी ${card.name} के लिए बाकी है।`,
      }
      : {
        title: `💸 Partial Payment`,
        body:
          `You paid ₹${paid}. ₹${remaining} is still due for ${card.name} (**** ${card.last_4_digits}).`,
      };
  }
}

/**
 * Gets the list of user IDs to notify at a specific time.
 * @param time Reminder time in HH:MM format.
 * @returns {Promise<string[]>}
 */
async function getUsersToNotify(time: string): Promise<string[]> {
  if (!supabase) return [];

  const { data, error } = await supabase
    .from("settings")
    .select("user_id")
    .eq("notifications_enabled", true)
    .eq("reminder_time", time);
  return error
    ? []
    : (data ?? []).map((s) => (s as { user_id: string }).user_id);
}

/**
 * Gets the preferred language of a user.
 * @param userId User's ID.
 * @returns {Promise<string>}
 */
async function getUserLanguage(userId: string): Promise<string> {
  if (!supabase) return "English";

  const { data } = await supabase
    .from("settings")
    .select("language")
    .eq("user_id", userId)
    .maybeSingle();
  return data!.language as string ?? "English";
}

/**
 * Gets all active cards for a user.
 * @param userId User's ID.
 * @returns {Promise<Card[]>}
 */
async function getUserCards(userId: string): Promise<Card[]> {
  if (!supabase) return [];

  const { data } = await supabase
    ?.from("cards")
    .select("id, name, last_4_digits, billing_date, is_archived")
    .eq("user_id", userId)
    .eq("is_archived", false);
  return data as Card[] ?? [];
}

/**
 * Gets all payments for a user.
 * @param userId User's ID.
 * @returns {Promise<Payment[]>}
 */
async function getUserPayments(userId: string): Promise<Payment[]> {
  if (!supabase) return [];

  const { data } = await supabase
    ?.from("payments")
    .select(
      "id, due_date, due_amount, paid_amount, is_paid, cards(id, name, last_4_digits, billing_date, is_archived)",
    )
    .eq("user_id", userId)
    .or("is_paid.eq.false")
    .or("paid_amount.lt.due_amount") as {
      data: Payment[] | null;
      error: Error | null;
    };

  return data ?? [];
}

/**
 * Gets all device tokens for a user.
 * @param userId User's ID.
 * @returns {Promise<string[]>}
 */
async function getDeviceTokens(userId: string): Promise<string[]> {
  if (!supabase) return [];

  const { data } = await supabase
    ?.from("device_tokens")
    .select("device_token")
    .eq("user_id", userId);
  return data?.map((d) => d.device_token as string) ?? [];
}

/**
 * Sends a notification to a list of device tokens and logs the result.
 * @param userId User's ID.
 * @param cardId Card's ID.
 * @param title Notification title.
 * @param body Notification body.
 * @param payload Notification payload (route).
 * @param tokens Device tokens to send to.
 * @param logs Array to collect successful notification logs.
 * @param failed Array to collect failed device tokens.
 */
async function sendNotification(
  userId: string,
  cardId: string,
  title: string,
  body: string,
  payload: string,
  tokens: string[],
  logs: NotificationLog[],
  failed: string[],
) {
  if (!firebaseAdminApp) return;
  const msg: admin.messaging.MulticastMessage = {
    notification: { title, body },
    data: { route: payload },
    tokens,
  };
  const result = await firebaseAdminApp.messaging().sendEachForMulticast(msg);
  result.responses.forEach((res, i) => {
    if (res.success) {
      logs.push({
        user_id: userId,
        card_id: cardId,
        title,
        body,
        payload,
        sent_at: new Date().toISOString(),
      });
    } else if (res.error) {
      const e = res.error.code;
      if (
        [
          "messaging/invalid-registration-token",
          "messaging/registration-token-not-registered",
          "messaging/not-found",
        ].includes(e)
      ) {
        failed.push(tokens[i]);
      }
    }
  });
}

/**
 * Deletes stale device tokens from the database.
 * @param tokens Array of device tokens to delete.
 */
async function deleteStaleTokens(tokens: string[]) {
  if (!tokens.length || !supabase) return;
  await supabase.from("device_tokens").delete().in("device_token", tokens);
}

/**
 * Inserts notification logs into the database.
 * @param logs Array of notification logs to insert.
 */
async function insertNotificationLog(logs: NotificationLog[]) {
  if (!logs.length || !supabase) return;
  await supabase.from("notification_logs").insert(logs);
}

/**
 * Main handler for the notification routine.
 */
Deno.serve(async () => {
  if (!firebaseAdminApp || !supabase) {
    return new Response("Firebase/Supabase not initialized", { status: 500 });
  }
  const now = new Date();
  const today = now.toISOString().split("T")[0];
  const reminderTime = now.toISOString().slice(11, 16);

  const users = await getUsersToNotify(reminderTime);
  const logs: NotificationLog[] = [];
  const failed: string[] = [];

  if (!users.length) {
    console.debug("📭 No users to notify at this time");
    return new Response("No users to notify at this time", { status: 200 });
  }

  for (const userId of users) {
    const lang = await getUserLanguage(userId);
    const builder = new NotificationMessageBuilder(lang);
    const tokens = await getDeviceTokens(userId);
    if (!tokens.length) continue;

    const cards = await getUserCards(userId);
    for (const card of cards) {
      if (card.billing_date === today) {
        const msg = builder.billingReminder(card);
        await sendNotification(
          userId,
          card.id,
          msg.title,
          msg.body,
          `/cards/${card.id}`,
          tokens,
          logs,
          failed,
        );
      }
    }

    const payments = await getUserPayments(userId);
    for (const p of payments) {
      const card = p.cards;
      if (!card) continue;
      const remaining = p.due_amount - p.paid_amount;
      const dueDate = new Date(p.due_date);
      const diff = Math.ceil(
        (dueDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24),
      );
      const payload = `/cards/${card.id}`;

      if (diff >= 0) {
        const msg = builder.dueReminder(card, diff, remaining);
        await sendNotification(
          userId,
          card.id,
          msg.title,
          msg.body,
          payload,
          tokens,
          logs,
          failed,
        );
      }
      if (now > dueDate && remaining > 0) {
        const msg = builder.overdue(card, remaining);
        await sendNotification(
          userId,
          card.id,
          msg.title,
          msg.body,
          payload,
          tokens,
          logs,
          failed,
        );
      }
      if (p.paid_amount > 0 && remaining > 0) {
        const msg = builder.partial(card, p.paid_amount, remaining);
        await sendNotification(
          userId,
          card.id,
          msg.title,
          msg.body,
          payload,
          tokens,
          logs,
          failed,
        );
      }
    }
  }

  if (logs.length) await insertNotificationLog(logs);
  if (failed.length) await deleteStaleTokens(failed);

  return new Response("✅ Notification routine complete", { status: 200 });
});
