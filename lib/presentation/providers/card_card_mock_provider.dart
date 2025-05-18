import '../../data/enums/card_type.dart';
import '../../data/hive/models/credit_card_model.dart';
import '../../data/hive/storage/bank_storage.dart';

class CardMockDataProvider {
  static List<CreditCardModel> getMockCreditCards() {
    final banks = BankStorage.getBox().values.toList();

    // Helper function to find bank ID by code
    String findBankIdByCode(String code) {
      return banks.firstWhere((bank) => bank.code == code).id;
    }

    return [
      CreditCardModel(
        name: 'Amazon Pay ICICI',
        bankId: findBankIdByCode('ICICI'),
        last4Digits: '9012',
        billingDate: DateTime(2025, 5, 20),
        dueDate: DateTime(2025, 6, 10),
        cardType: CardType.Visa,
        creditLimit: 70000.0,
        currentUtilization: 0.0,
      ),
      CreditCardModel(
        name: 'SBI SimplyCLICK',
        bankId: findBankIdByCode('SBI'),
        last4Digits: '2345',
        billingDate: DateTime(2025, 5, 14),
        dueDate: DateTime(2025, 6, 4),
        cardType: CardType.MasterCard,
        creditLimit: 100000.0,
        currentUtilization: 30000.0,
      ),
      CreditCardModel(
        name: 'Axis Flipkart',
        bankId: findBankIdByCode('AXIS'),
        last4Digits: '8765',
        billingDate: DateTime(2025, 5, 10),
        dueDate: DateTime(2025, 5, 30),
        cardType: CardType.Visa,
        creditLimit: 80000.0,
        currentUtilization: 12000.0,
      ),
      CreditCardModel(
        name: 'HDFC Millennia',
        bankId: findBankIdByCode('HDFC'),
        last4Digits: '1122',
        billingDate: DateTime(2025, 5, 5),
        dueDate: DateTime(2025, 5, 25),
        cardType: CardType.MasterCard,
        creditLimit: 150000.0,
        currentUtilization: 50000.0,
      ),
      CreditCardModel(
        name: 'IndusInd Iconia',
        bankId: findBankIdByCode('INDUSIND'),
        last4Digits: '3344',
        billingDate: DateTime(2025, 5, 12),
        dueDate: DateTime(2025, 6, 1),
        cardType: CardType.Visa,
        creditLimit: 125000.0,
        currentUtilization: 20000.0,
      ),
      CreditCardModel(
        name: 'Standard Chartered Manhattan',
        bankId: findBankIdByCode('SCB'),
        last4Digits: '5566',
        billingDate: DateTime(2025, 5, 7),
        dueDate: DateTime(2025, 5, 27),
        cardType: CardType.MasterCard,
        creditLimit: 95000.0,
        currentUtilization: 35000.0,
      ),
      CreditCardModel(
        name: 'Kotak 811 #DreamDifferent',
        bankId: findBankIdByCode('KOTAK'),
        last4Digits: '7788',
        billingDate: DateTime(2025, 5, 17),
        dueDate: DateTime(2025, 6, 6),
        cardType: CardType.Visa,
        creditLimit: 60000.0,
        currentUtilization: 0.0,
      ),
      CreditCardModel(
        name: 'ICICI Coral',
        bankId: findBankIdByCode('ICICI'),
        last4Digits: '9900',
        billingDate: DateTime(2025, 5, 3),
        dueDate: DateTime(2025, 5, 23),
        cardType: CardType.RuPay,
        creditLimit: 85000.0,
        currentUtilization: 25000.0,
      ),
      CreditCardModel(
        name: 'YES Prosperity Edge',
        bankId: findBankIdByCode('YES'),
        last4Digits: '2233',
        billingDate: DateTime(2025, 5, 6),
        dueDate: DateTime(2025, 5, 26),
        cardType: CardType.MasterCard,
        creditLimit: 70000.0,
        currentUtilization: 50000.0,
      ),
      CreditCardModel(
        name: 'HSBC Platinum',
        bankId: findBankIdByCode('HSBC'),
        last4Digits: '4455',
        billingDate: DateTime(2025, 5, 2),
        dueDate: DateTime(2025, 5, 22),
        cardType: CardType.Visa,
        creditLimit: 110000.0,
        currentUtilization: 100000.0,
      ),
    ];
  }
}
