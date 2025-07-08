import { NotificationStrings } from "../../models.ts";
import { formatCurrency } from "../../utils/currencyUtils.ts";

export const en: NotificationStrings = {
  billing: (cardName, last4Digits, billingInDays) => {
    let title = "";
    let body = "";
    if (billingInDays < 0) {
      const daysAgo = Math.abs(billingInDays);
      title = `📝 Statement Generated: ${cardName}`;
      body =
        `Your statement for ${cardName} (**** ${last4Digits}) was generated ${daysAgo} day${
          daysAgo > 1 ? "s" : ""
        } ago. Please log your new payment details.`;
    } else if (billingInDays === 0) {
      title = `📅 Billing Day Today: ${cardName}`;
      body =
        `Your new statement for ${cardName} (**** ${last4Digits}) will be generated soon.`;
    } else if (billingInDays === 1) {
      title = `📅 Billing Day Tomorrow: ${cardName}`;
      body =
        `Your billing date for ${cardName} (**** ${last4Digits}) is tomorrow. Finalize your expenses.`;
    } else {
      title = `📅 Billing in ${billingInDays} Days: ${cardName}`;
      body =
        `The billing date for ${cardName} (**** ${last4Digits}) is approaching in ${billingInDays} days.`;
    }
    return { title, body };
  },
  due: (cardName, last4Digits, dueInDays, remaining, currencyCode) => {
    let title = "";
    if (dueInDays === 0) {
      title = `⏰ Payment Due Today: ${cardName}`;
    } else if (dueInDays === 1) {
      title = `⏰ Payment Due Tomorrow: ${cardName}`;
    } else {
      title = `⏰ ${dueInDays} Days Left to Pay: ${cardName}`;
    }
    const amount = formatCurrency(remaining, currencyCode, "en");
    return {
      title,
      body:
        `Please pay ${amount} for your card ending in ${last4Digits} to avoid late fees.`,
    };
  },
  overdue: (cardName, last4Digits, remaining, currencyCode) => {
    const amount = formatCurrency(remaining, currencyCode, "en");
    return {
      title: `⚠️ Overdue Payment: ${cardName}`,
      body:
        `Your payment of ${amount} for ${cardName} (**** ${last4Digits}) is overdue. Please pay now to avoid further charges.`,
    };
  },
  partial: (cardName, last4Digits, paid, remaining, currencyCode) => {
    const paidAmount = formatCurrency(paid, currencyCode, "en");
    const remainingAmount = formatCurrency(remaining, currencyCode, "en");
    return {
      title: `💸 Partial Payment Received: ${cardName}`,
      body:
        `Thank you for paying ${paidAmount}. A balance of ${remainingAmount} is still due for ${cardName} (**** ${last4Digits}).`,
    };
  },
};
