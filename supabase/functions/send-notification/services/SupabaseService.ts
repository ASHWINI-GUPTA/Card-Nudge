import {
  createClient,
  SupabaseClient,
} from "npm:@supabase/supabase-js@^2.50.1";
import { Card, NotificationLog, Payment, Setting } from "../models.ts";

export class SupabaseService {
  private client: SupabaseClient | undefined;

  /**
   * Creates an instance of SupabaseService.
   * @param supabaseUrl The URL of the Supabase project.
   * @param supabaseKey The service role key for the Supabase project.
   */
  constructor(
    supabaseUrl: string | undefined,
    supabaseKey: string | undefined,
  ) {
    if (!supabaseUrl || !supabaseKey) {
      console.error(
        "❌ Critical: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables are missing.",
      );
      return;
    }
    try {
      this.client = createClient(supabaseUrl, supabaseKey);
    } catch (error) {
      console.error("❌ Supabase client creation failed:", error);
    }
  }

  /**
   * Checks if the Supabase client has been successfully initialized.
   * @returns {boolean} True if the client is initialized, false otherwise.
   */
  isInitialized(): boolean {
    return this.client !== undefined;
  }

  /**
   * Fetches the user IDs of all users who have enabled notifications for a specific time.
   * @param {string} time The time to check for notifications, in "HH:mm" format.
   * @returns {Promise<string[]>} A promise that resolves to an array of user IDs.
   */
  async getUsersToNotify(time: string): Promise<string[]> {
    if (!this.client) return [];

    const { data, error } = await this.client
      .from("settings")
      .select("user_id")
      .eq("notifications_enabled", true)
      .eq("reminder_time", time);
    return error
      ? (console.error("Error fetching users to notify:", error), [])
      : (data ?? []).map((s) => (s as { user_id: string }).user_id);
  }

  /**
   * Retrieves the preferred language for a given user.
   * @param {string} userId The ID of the user.
   * @returns {Promise<Setting | null>} A promise that resolves to the user's setting.
   */
  async getUserSetting(userId: string): Promise<Setting | null> {
    if (!this.client) return null;

    const { data, error } = await this.client
      .from("settings")
      .select("language, currency, utilization_alert_threshold")
      .eq("user_id", userId)
      .eq("notifications_enabled", true)
      .single();

    if (error) {
      console.error(`Error fetching language for user ${userId}:`, error);
      return null;
    }
    return data as Setting;
  }

  /**
   * Fetches all non-archived cards for a given user.
   * @param {string} userId The ID of the user.
   * @returns {Promise<Card[]>} A promise that resolves to an array of cards.
   */
  async getUserCards(userId: string): Promise<Card[]> {
    if (!this.client) return [];

    const { data, error } = await this.client
      .from("cards")
      .select("id, name, last_4_digits, billing_date, is_archived")
      .eq("user_id", userId)
      .eq("is_archived", false);

    if (error) {
      console.error(`Error fetching cards for user ${userId}:`, error);
      return [];
    }
    return (data as Card[]) ?? [];
  }

  /**
   * Fetches all unpaid payments for a user, including the associated card details.
   * @param {string} userId The ID of the user.
   * @returns {Promise<Payment[]>} A promise that resolves to an array of unpaid payments.
   */
  async getUserPayments(userId: string): Promise<Payment[]> {
    if (!this.client) return [];

    const { data, error } = (await this.client
      .from("payments")
      .select(
        "id, due_date, due_amount, paid_amount, statement_amount, is_paid, cards(id, name, last_4_digits, billing_date, is_archived)",
      )
      .eq("user_id", userId)
      .eq("is_paid", false)) as {
        data: Payment[] | null;
        error: Error | null;
      };

    if (error) {
      console.error(`Error fetching payments for user ${userId}:`, error);
      return [];
    }
    return data ?? [];
  }

  /**
   * Fetches all registered FCM device tokens for a given user.
   * @param {string} userId The ID of the user.
   * @returns {Promise<string[]>} A promise that resolves to an array of device token strings.
   */
  async getDeviceTokens(userId: string): Promise<string[]> {
    if (!this.client) return [];

    const { data, error } = await this.client
      .from("device_tokens")
      .select("device_token")
      .eq("user_id", userId);

    if (error) {
      console.error(`Error fetching device tokens for user ${userId}:`, error);
      return [];
    }
    return data?.map((d) => d.device_token as string) ?? [];
  }

  /**
   * Retrieves the most recent notification log for a specific user, card, and notification type.
   * @param {string} userId The ID of the user.
   * @param {string} cardId The ID of the card.
   * @param {NotificationLog["notification_type"]} notificationType The type of notification.
   * @returns {Promise<NotificationLog | null>} A promise that resolves to the latest notification log or null if not found.
   */
  async getLastNotificationLog(
    userId: string,
    cardId: string,
    notificationType: NotificationLog["notification_type"],
  ): Promise<NotificationLog | null> {
    if (!this.client) return null;

    const { data, error } = await this.client
      .from("notification_logs")
      .select("*")
      .eq("user_id", userId)
      .eq("card_id", cardId)
      .eq("notification_type", notificationType)
      .order("sent_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error && error.code !== "PGRST116") {
      // PGRST116 is 'No rows found', which is expected
      console.error(
        `Error fetching last notification log for user ${userId}, card ${cardId}, type ${notificationType}:`,
        error,
      );
    }
    return data as NotificationLog | null;
  }

  /**
   * Deletes a list of stale or invalid FCM device tokens from the database.
   * @param {string[]} tokens The array of device tokens to delete.
   * @returns {Promise<void>} A promise that resolves when the operation is complete.
   */
  async deleteStaleTokens(tokens: string[]): Promise<void> {
    if (!this.client || !tokens.length) return;
    const { error } = await this.client
      .from("device_tokens")
      .delete()
      .in("device_token", tokens);
    if (error) {
      console.error("Error deleting stale tokens:", error);
    } else {
      console.log(`Deleted ${tokens.length} stale device tokens.`);
    }
  }

  /**
   * Inserts a batch of notification logs into the database.
   * @param {NotificationLog[]} logs An array of notification log objects to insert.
   * @returns {Promise<void>} A promise that resolves when the operation is complete.
   */
  async insertNotificationLog(logs: NotificationLog[]): Promise<void> {
    if (!this.client || !logs.length) return;
    const { error } = await this.client.from("notification_logs").insert(logs);
    if (error) {
      console.error("Error inserting notification logs:", error);
    } else {
      console.log(`Inserted ${logs.length} notification logs.`);
    }
  }
}
