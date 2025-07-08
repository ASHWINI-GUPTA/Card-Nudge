/**
 * Card entity representing a credit card.
 */
export interface Card {
  id: string;
  name: string;
  last_4_digits: string;
  billing_date: string;
  is_archived: boolean;
}

/**
 * Payment entity representing a payment for a card.
 */
export interface Payment {
  id: string;
  due_date: string;
  due_amount: number;
  paid_amount: number;
  statement_amount: number;
  is_paid: boolean;
  cards: Card;
}

/**
 * DeviceToken entity representing a device's FCM token.
 */
export interface DeviceToken {
  device_token: string;
}

/**
 * Setting entity representing user-specific application settings.
 */
export interface Setting {
  language: string;
  currency: string;
  utilization_alert_threshold: number;
}

/**
 * NotificationLog entity for logging sent notifications.
 */
export type NotificationType = "billing" | "due" | "overdue" | "partial";

export type NotificationLog = {
  user_id: string;
  card_id: string;
  notification_type: NotificationType;
  title: string;
  body: string;
  payload: string;
  sent_at: string;
};

// Interface for language strings
export interface NotificationStrings {
  billing: (
    cardName: string,
    last4Digits: string,
    billingInDays: number,
  ) => { title: string; body: string };
  due: (
    cardName: string,
    last4Digits: string,
    dueInDays: number,
    remaining: number,
    currencyCode: string,
  ) => { title: string; body: string };
  overdue: (
    cardName: string,
    last4Digits: string,
    remaining: number,
    currencyCode: string,
  ) => { title: string; body: string };
  partial: (
    cardName: string,
    last4Digits: string,
    paid: number,
    remaining: number,
    currencyCode: string,
  ) => { title: string; body: string };
}
