import { NotificationStrings } from "../../models.ts";

export const en: NotificationStrings = {
  billing: (cardName, last4Digits) => ({
    title: `📅 Billing Day - ${cardName}`,
    body:
      `Today is the billing date for ${cardName} (**** ${last4Digits}). Don't forget to log your expenses!`,
  }),
  due: (cardName, last4Digits, dueInDays, remaining) => {
    let title = "";
    if (dueInDays === 0) {
      title = `📌 Payment Due Today`;
    } else if (dueInDays === 1) {
      title = `⏰ Payment Due Tomorrow`;
    } else {
      title = `⏰ ${dueInDays} day${dueInDays > 1 ? "s" : ""} left`;
    }
    return {
      title,
      body: `Pay ₹${remaining} for ${cardName} (**** ${last4Digits})`,
    };
  },
  overdue: (cardName, last4Digits, remaining) => ({
    title: `⚠️ Payment Overdue`,
    body:
      `₹${remaining} is still due for ${cardName} (**** ${last4Digits}). Late fee may apply.`,
  }),
  partial: (cardName, last4Digits, paid, remaining) => ({
    title: `💸 Partial Payment`,
    body:
      `You paid ₹${paid}. ₹${remaining} is still due for ${cardName} (**** ${last4Digits}).`,
  }),
};
