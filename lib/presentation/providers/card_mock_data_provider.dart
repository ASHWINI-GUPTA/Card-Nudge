import '../../data/hive/models/credit_card_model.dart';

class CardMockDataProvider {
  static final List<CreditCardModel> mockCreditCards = [
    CreditCardModel(
      cardName: 'Amazon Pay',
      bankName: 'ICICI Bank',
      last4Digits: '9012',
      billingDate: DateTime(2025, 5, 20),
      dueDate: DateTime(2025, 6, 10),
      limit: 7000.0,
      currentDueAmount: 0.0,
    ),
    CreditCardModel(
      cardName: 'SBI SimplyCLICK',
      bankName: 'SBI',
      last4Digits: '2345',
      billingDate: DateTime(2025, 5, 14),
      dueDate: DateTime(2025, 6, 4),
      limit: 100000.0,
      currentDueAmount: 3000.0,
    ),
    CreditCardModel(
      cardName: 'Axis Flipkart',
      bankName: 'Axis Bank',
      last4Digits: '8765',
      billingDate: DateTime(2025, 5, 10),
      dueDate: DateTime(2025, 5, 30),
      limit: 80000.0,
      currentDueAmount: 12000.0,
    ),
    CreditCardModel(
      cardName: 'HDFC Millennia',
      bankName: 'HDFC Bank',
      last4Digits: '1122',
      billingDate: DateTime(2025, 5, 5),
      dueDate: DateTime(2025, 5, 25),
      limit: 150000.0,
      currentDueAmount: 50000.0,
    ),
    CreditCardModel(
      cardName: 'IndusInd Iconia',
      bankName: 'IndusInd Bank',
      last4Digits: '3344',
      billingDate: DateTime(2025, 5, 12),
      dueDate: DateTime(2025, 6, 1),
      limit: 125000.0,
      currentDueAmount: 2000.0,
    ),
    CreditCardModel(
      cardName: 'Standard Chartered Manhattan',
      bankName: 'Standard Chartered',
      last4Digits: '5566',
      billingDate: DateTime(2025, 5, 7),
      dueDate: DateTime(2025, 5, 27),
      limit: 95000.0,
      currentDueAmount: 35000.0,
    ),
    CreditCardModel(
      cardName: 'Kotak 811 #DreamDifferent',
      bankName: 'Kotak Mahindra Bank',
      last4Digits: '7788',
      billingDate: DateTime(2025, 5, 17),
      dueDate: DateTime(2025, 6, 6),
      limit: 60000.0,
      currentDueAmount: 0.0,
    ),
    CreditCardModel(
      cardName: 'ICICI Coral',
      bankName: 'ICICI Bank',
      last4Digits: '9900',
      billingDate: DateTime(2025, 5, 3),
      dueDate: DateTime(2025, 5, 23),
      limit: 85000.0,
      currentDueAmount: 2500.0,
    ),
    CreditCardModel(
      cardName: 'YES Prosperity Edge',
      bankName: 'YES Bank',
      last4Digits: '2233',
      billingDate: DateTime(2025, 5, 6),
      dueDate: DateTime(2025, 5, 26),
      limit: 70000.0,
      currentDueAmount: 5000.0,
    ),
    CreditCardModel(
      cardName: 'HSBC Platinum',
      bankName: 'HSBC',
      last4Digits: '4455',
      billingDate: DateTime(2025, 5, 2),
      dueDate: DateTime(2025, 5, 22),
      limit: 110000.0,
      currentDueAmount: 10000.0,
    ),
  ];

  static List<CreditCardModel> getMockCreditCards() {
    return List.from(mockCreditCards);
  }
}
