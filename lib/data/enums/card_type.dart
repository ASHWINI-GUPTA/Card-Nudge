enum CardType { Visa, MasterCard, RuPay, AMEX, Discover, DinersClub, Other }

extension CardTypeExtension on CardType {
  String get logoPath {
    switch (this) {
      case CardType.Visa:
        return 'assets/card_networks_icons/VISA.svg';
      case CardType.MasterCard:
        return 'assets/card_networks_icons/MASTERCARD.svg';
      case CardType.RuPay:
        return 'assets/card_networks_icons/RUPAY.svg';
      case CardType.AMEX:
        return 'assets/card_networks_icons/AMEX.svg';
      case CardType.Other:
        return '';
      case CardType.Discover:
        return 'assets/card_networks_icons/DISCOVER.svg';
      case CardType.DinersClub:
        return 'assets/card_networks_icons/DINERSCLUB.svg';
    }
  }
}
