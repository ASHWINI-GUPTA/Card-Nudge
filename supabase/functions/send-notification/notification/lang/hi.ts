import { NotificationStrings } from "../../../shared/models.ts";
import { formatCurrency } from "../../utils/currencyUtils.ts";

export const hi: NotificationStrings = {
  billing: (cardName, last4Digits, billingInDays) => {
    let title = "";
    let body = "";
    if (billingInDays < 0) {
      const daysAgo = Math.abs(billingInDays);
      title = `📝 स्टेटमेंट जेनरेट हो गया: ${cardName}`;
      body = `आपके ${cardName} (**** ${last4Digits}) का स्टेटमेंट ${daysAgo} दिन पहले जेनरेट हुआ था। कृपया अपना नया भुगतान लॉग करें।`;
    } else if (billingInDays === 0) {
      title = `📅 आज बिलिंग दिवस: ${cardName}`;
      body = `आपके ${cardName} (**** ${last4Digits}) का नया स्टेटमेंट जल्द ही जेनरेट होगा।`;
    } else if (billingInDays === 1) {
      title = `📅 कल बिलिंग दिवस: ${cardName}`;
      body = `${cardName} (**** ${last4Digits}) की बिलिंग तिथि कल है। अपने खर्चों को अंतिम रूप दें।`;
    } else {
      title = `📅 ${billingInDays} दिनों में बिलिंग: ${cardName}`;
      body = `${cardName} (**** ${last4Digits}) की बिलिंग तिथि ${billingInDays} दिनों में आ रही है।`;
    }
    return { title, body };
  },
  due: (
    cardName,
    last4Digits,
    dueInDays,
    remaining,
    currencyCode,
    isAutoDebit
  ) => {
    let title = "";
    if (dueInDays === 0) {
      title = `⏰ आज भुगतान की अंतिम तिथि: ${cardName}`;
    } else if (dueInDays === 1) {
      title = `⏰ कल भुगतान की अंतिम तिथि: ${cardName}`;
    } else {
      title = `⏰ भुगतान के लिए ${dueInDays} दिन शेष: ${cardName}`;
    }
    const amount = formatCurrency(remaining, currencyCode, "hi");
    let body = `कृपया लेट फीस से बचने के लिए अपने कार्ड (**** ${last4Digits}) का ${amount} का भुगतान करें।`;
    if (isAutoDebit) {
      body +=
        " इस कार्ड के लिए ऑटो-डेबिट सक्षम है — कृपया लिंक किए गए खाते में पर्याप्त शेष राशि रखें।";
    }
    return {
      title,
      body,
    };
  },
  overdue: (cardName, last4Digits, remaining, currencyCode, isAutoDebit) => {
    const amount = formatCurrency(remaining, currencyCode, "hi");
    let body = `आपके ${cardName} (**** ${last4Digits}) का ${amount} का भुगतान बकाया है। कृपया अतिरिक्त शुल्क से बचने के लिए अभी भुगतान करें।`;
    if (isAutoDebit) {
      body +=
        " इस कार्ड के लिए ऑटो-डेबिट सक्षम है — कृपया लिंक किए गए खाते में पर्याप्त शेष राशि रखें।";
    }
    return {
      title: `⚠️ भुगतान बकाया: ${cardName}`,
      body,
    };
  },
  partial: (cardName, last4Digits, paid, remaining, currencyCode) => {
    const paidAmount = formatCurrency(paid, currencyCode, "hi");
    const remainingAmount = formatCurrency(remaining, currencyCode, "hi");
    return {
      title: `💸 आंशिक भुगतान प्राप्त: ${cardName}`,
      body: `${paidAmount} के भुगतान के लिए धन्यवाद। आपके ${cardName} (**** ${last4Digits}) पर अभी भी ${remainingAmount} बकाया है।`,
    };
  },
};
