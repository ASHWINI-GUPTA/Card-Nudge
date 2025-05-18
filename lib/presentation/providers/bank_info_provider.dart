import '../../data/hive/models/bank_info.dart';

class BankInfoProvider {
  static final List<BankInfo> _banks = [
    BankInfo(
      name: 'HDFC Bank',
      code: 'HDFC',
      logoPath: 'assets/bank_icons/HDFC.svg',
      cardNetworks: ['Visa', 'MasterCard', 'RuPay'],
    ),
    BankInfo(
      name: 'ICICI Bank',
      code: 'ICICI',
      logoPath: 'assets/bank_icons/ICICI.svg',
      cardNetworks: ['Visa', 'MasterCard', 'Amex'],
    ),
    BankInfo(
      name: 'SBI',
      code: 'SBI',
      logoPath: 'assets/bank_icons/SBI.svg',
      cardNetworks: ['Visa', 'MasterCard', 'RuPay'],
    ),
    BankInfo(
      name: 'Axis Bank',
      code: 'AXIS',
      logoPath: 'assets/bank_icons/AXIS.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'Bank of Baroda',
      code: 'BOB',
      logoPath: 'assets/bank_icons/BOB.svg',
      cardNetworks: ['Visa', 'RuPay'],
    ),
    BankInfo(
      name: 'Yes Bank',
      code: 'YES',
      logoPath: 'assets/bank_icons/YES.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'Kotak Mahindra Bank',
      code: 'KOTAK',
      logoPath: 'assets/bank_icons/KOTAK.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'IndusInd Bank',
      code: 'INDUSIND',
      logoPath: 'assets/bank_icons/INDUSIND.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'Standard Chartered',
      code: 'SCB',
      logoPath: 'assets/bank_icons/SCB.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'RBL Bank',
      code: 'RBL',
      logoPath: 'assets/bank_icons/RBL.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'Punjab National Bank',
      code: 'PNB',
      logoPath: 'assets/bank_icons/PNB.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'Union Bank of India',
      code: 'UBI',
      logoPath: 'assets/bank_icons/UBI.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'HSBC',
      code: 'HSBC',
      logoPath: 'assets/bank_icons/HSBC.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'Citi Bank',
      code: 'CITI',
      logoPath: 'assets/bank_icons/CITI.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'American Express',
      code: 'AMEX',
      logoPath: 'assets/bank_icons/AMEX.svg',
      cardNetworks: ['Amex'],
    ),
    BankInfo(
      name: 'DBS Bank',
      code: 'DBS',
      logoPath: 'assets/bank_icons/DBS.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(
      name: 'IDFC First Bank',
      code: 'IDFC',
      logoPath: 'assets/bank_icons/IDFC.svg',
      cardNetworks: ['Visa', 'MasterCard'],
    ),
    BankInfo(name: 'Other', code: 'OTHER', logoPath: null, cardNetworks: null),
  ];

  static BankInfo getBankInfo(String? name) {
    if (name == null || name.trim().isEmpty) {
      return _banks.firstWhere((b) => b.name == 'Other');
    }

    final normalized = name.trim().toLowerCase();
    return _banks.firstWhere(
      (b) =>
          b.name.toLowerCase() == normalized ||
          b.code?.toLowerCase() == normalized,
      orElse: () => _banks.firstWhere((b) => b.name == 'Other'),
    );
  }

  static List<BankInfo> getAllBanks() {
    final sortedBanks = List<BankInfo>.from(_banks)..sort((a, b) {
      if (a.name == 'Other') return 1;
      if (b.name == 'Other') return -1;
      return a.name.compareTo(b.name);
    });
    return sortedBanks;
  }
}
