import { NotificationStrings } from "../models.ts";
import { en } from "./lang/en.ts";
import { hi } from "./lang/hi.ts";

export class NotificationMessageBuilder {
  private strings: NotificationStrings;

  constructor(lang: string) {
    switch (lang.toLowerCase()) {
      case "hindi":
        this.strings = hi;
        break;
      case "english":
      default:
        this.strings = en;
        break;
    }
  }

  billingReminder(
    cardName: string,
    last4Digits: string,
    diffDaysBilling: number,
  ): { title: string; body: string } {
    return this.strings.billing(cardName, last4Digits, diffDaysBilling);
  }

  dueReminder(
    cardName: string,
    last4Digits: string,
    dueInDays: number,
    remaining: number,
  ): { title: string; body: string } {
    return this.strings.due(cardName, last4Digits, dueInDays, remaining);
  }

  overdue(
    cardName: string,
    last4Digits: string,
    remaining: number,
  ): { title: string; body: string } {
    return this.strings.overdue(cardName, last4Digits, remaining);
  }

  partial(
    cardName: string,
    last4Digits: string,
    paid: number,
    remaining: number,
  ): { title: string; body: string } {
    return this.strings.partial(cardName, last4Digits, paid, remaining);
  }
}
