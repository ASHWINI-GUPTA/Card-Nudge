import '../data/enums/card_type.dart';

String obfuscateCardNumber(String cardNumber, CardType cardType) {
  String maskedCardNumber;
  if (cardType == CardType.AMEX) {
    // Amex: 15 digits, format: **** ****** *1234
    maskedCardNumber =
        '**** ****** *${cardNumber.substring(cardNumber.length - 4)}';
  } else if (cardType == CardType.DinersClub) {
    // Diners Club: 14 digits, format: **** ****** 1234
    maskedCardNumber =
        '**** ****** ${cardNumber.substring(cardNumber.length - 4)}';
  } else {
    // Default (Visa, Mastercard, Discover, etc.): 16 digits, format: **** **** **** 1234
    maskedCardNumber =
        '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }
  return maskedCardNumber;
}
