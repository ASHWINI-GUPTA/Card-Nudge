/**
 * Card entity representing a credit card.
 */
export interface Card {
  id: string;
  name: string;
  last_4_digits: string;
  billing_date: string;
  is_archived: boolean;
  card_type: string;
  bank_id: string;
  credit_card_summaries: CreditCardSummary[] | null;
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
    billingInDays: number
  ) => { title: string; body: string };
  due: (
    cardName: string,
    last4Digits: string,
    dueInDays: number,
    remaining: number,
    currencyCode: string
  ) => { title: string; body: string };
  overdue: (
    cardName: string,
    last4Digits: string,
    remaining: number,
    currencyCode: string
  ) => { title: string; body: string };
  partial: (
    cardName: string,
    last4Digits: string,
    paid: number,
    remaining: number,
    currencyCode: string
  ) => { title: string; body: string };
}

/**
 * ProcessingStatus type representing the status of a processing task.
 */
export enum ProcessingStatus {
  Pending = 1,
  Completed = 2,
  Failed = 3,
}

/**
 * CreditCardSummary entity representing a summary of credit card benefits.
 */
export interface CreditCardSummary {
  id: string;
  card_id: string;
  markdown_summary: string;
  status: ProcessingStatus;
  error_message: string | null;
  user_liked: boolean | null;
  updated_at: Date;
}

/**
 * Bank entity representing a financial institution.
 *
 * A Bank is identified by a unique `id` and has a `name` and `code`.
 * This entity provides foundational information about the bank.
 */
export interface Bank {
  id: string;
  name: string;
  code: string;
}
