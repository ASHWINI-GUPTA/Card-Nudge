import { NotificationStrings } from "../../models.ts";

export const hi: NotificationStrings = {
  billing: (cardName, last4Digits) => ({
    title: `📅 ${cardName} के लिए बिलिंग तिथि है।`,
    body:
      `आज ${cardName} (**** ${last4Digits}) की बिलिंग तिथि है। अपने खर्चों को लॉग करना न भूलें।`,
  }),
  due: (cardName, last4Digits, dueInDays, remaining) => {
    let title = "";
    if (dueInDays === 0) {
      title = `📌 आज अंतिम तिथि है।`;
    } else if (dueInDays === 1) {
      title = `⏰ कल अंतिम तिथि है।`;
    } else {
      title = `⏰ ${dueInDays} दिन शेष।`;
    }
    return {
      title,
      body:
        `${cardName} (**** ${last4Digits}) के लिए ₹${remaining} भुगतान करना बाकी है।`,
    };
  },
  overdue: (cardName, last4Digits, remaining) => ({
    title: `⚠️ भुगतान विलंबित।`,
    body:
      `${cardName} (**** ${last4Digits}) के लिए ₹${remaining} अभी भी बाकी है। विलंब शुल्क लग सकता है।`,
  }),
  partial: (cardName, last4Digits, paid, remaining) => ({
    title: `💸 आंशिक भुगतान`,
    body:
      `आपने ₹${paid} का भुगतान किया है। ₹${remaining} अभी भी ${cardName} के लिए बाकी है।`,
  }),
};
