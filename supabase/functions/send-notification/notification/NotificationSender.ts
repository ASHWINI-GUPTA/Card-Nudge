import { SupabaseService } from "../services/SupabaseService.ts";
import { FirebaseService } from "../services/FirebaseService.ts";
import { NotificationMessageBuilder } from "./NotificationBuilder.ts";
import { NotificationLog } from "../models.ts";
import { getDaysDifference } from "../utils/dateUtils.ts";

export class NotificationSender {
  constructor(
    private supabaseService: SupabaseService,
    private firebaseService: FirebaseService,
  ) {}

  async processUserNotifications(
    userId: string,
    now: Date,
    logs: NotificationLog[],
    failedTokens: string[],
  ): Promise<void> {
    const lang = await this.supabaseService.getUserLanguage(userId);
    const builder = new NotificationMessageBuilder(lang);
    const tokens = await this.supabaseService.getDeviceTokens(userId);
    if (!tokens.length) return;

    const payments = await this.supabaseService.getUserPayments(userId);
    for (const p of payments) {
      const card = p.cards;
      const remaining = p.statement_amount;
      const dueDate = new Date(p.due_date);
      const payload = `/cards/${card.id}`;
      // Calculate days until due date. Positive for future, 0 for today, negative for past.
      const diffDaysDue = getDaysDifference(now, dueDate);

      // --- ⏰  Due Reminder ---
      if (diffDaysDue >= 0) {
        let shouldSendDue = false;
        if (diffDaysDue <= 10) {
          // Always send if due in 10 days or less (including today/tomorrow).
          shouldSendDue = true;
        } else {
          const lastLog = await this.supabaseService.getLastNotificationLog(
            userId,
            card.id,
            "due",
          );
          if (!lastLog) {
            shouldSendDue = true; // Send if no previous due log
          } else {
            const daysSinceLastSend = getDaysDifference(
              new Date(lastLog.sent_at),
              now,
            );
            // More than 10 days out, send every 3 days.
            shouldSendDue = daysSinceLastSend >= 3;
          }
        }

        if (shouldSendDue) {
          const msg = builder.dueReminder(
            card.name,
            card.last_4_digits,
            diffDaysDue,
            remaining,
          );
          await this.firebaseService.sendNotification(
            userId,
            card.id,
            "due",
            msg.title,
            msg.body,
            payload,
            tokens,
            logs,
            failedTokens,
          );
        }
      } else {
        // -- ⚠️ Overdue Reminder ---
        const daysOverdue = Math.abs(diffDaysDue);
        let shouldSendOverdue = false;
        if (daysOverdue <= 7) {
          // Overdue for 7 days or less, send every day.
          shouldSendOverdue = true;
        } else {
          const lastLog = await this.supabaseService.getLastNotificationLog(
            userId,
            card.id,
            "overdue",
          );
          if (!lastLog) {
            // Always send if record not available for overdue reminder.
            shouldSendOverdue = true;
          } else {
            const daysSinceLastSend = getDaysDifference(
              new Date(lastLog.sent_at),
              now,
            );
            // Overdue for more than 7 days, send once every 3 days.
            shouldSendOverdue = daysSinceLastSend >= 3;
          }
        }

        if (shouldSendOverdue) {
          const msg = builder.overdue(card.name, card.last_4_digits, remaining);
          await this.firebaseService.sendNotification(
            userId,
            card.id,
            "overdue",
            msg.title,
            msg.body,
            payload,
            tokens,
            logs,
            failedTokens,
          );
        }
      }

      // --- 💸 Partial Payment ---
      // AG TODO: Notification for partial payments
    }

    // --- 📅 Billing Reminder ---
    const cards = await this.supabaseService.getUserCards(userId);
    for (const card of cards) {
      const billingDate = new Date(card.billing_date);
      const diffDaysBilling = getDaysDifference(now, billingDate);
      let shouldSendBilling = false;

      if (Math.abs(diffDaysBilling) <= 5) {
        shouldSendBilling = true; // Every day
      } else {
        const lastLog = await this.supabaseService.getLastNotificationLog(
          userId,
          card.id,
          "billing",
        );

        if (!lastLog) {
          shouldSendBilling = true; // Send first reminder if no log exists
        } else {
          const daysSinceLastSend = getDaysDifference(
            new Date(lastLog.sent_at),
            now,
          );

          shouldSendBilling = daysSinceLastSend >= 3; // Once in 3 days
        }
      }

      if (shouldSendBilling) {
        const msg = builder.billingReminder(
          card.name,
          card.last_4_digits,
          diffDaysBilling,
        );
        await this.firebaseService.sendNotification(
          userId,
          card.id,
          "billing",
          msg.title,
          msg.body,
          `/cards/${card.id}`,
          tokens,
          logs,
          failedTokens,
        );
      }
    }
  }
}
