import '../../data/hive/models/bank_info.dart';

class BankInfoProvider {
  static final List<BankInfo> _banks = [
    BankInfo(
      name: 'HDFC Bank',
      code: 'HDFC',
      logoPath: 'assets/bank_icons/HDFC.svg',
      cardNetworks: ['Visa', 'MasterCard', 'RuPay'],
      displayColorHex: '#004DB7',
    ),
    BankInfo(
      name: 'ICICI Bank',
      code: 'ICICI',
      logoPath: 'assets/bank_icons/ICICI.svg',
      cardNetworks: ['Visa', 'MasterCard', 'Amex'],
      displayColorHex: '#F58220',
    ),
    BankInfo(
      name: 'SBI',
      code: 'SBI',
      logoPath: 'assets/bank_icons/SBI.svg',
      cardNetworks: ['Visa', 'MasterCard', 'RuPay'],
      displayColorHex: '#1B4F9C',
    ),
    BankInfo(
      name: 'Axis Bank',
      code: 'AXIS',
      logoPath: 'assets/bank_icons/AXIS.svg',
      cardNetworks: ['Visa', 'MasterCard'],
      displayColorHex: '#8B003F',
    ),
    BankInfo(
      name: 'Bank of Baroda',
      code: 'BOB',
      logoPath: 'assets/bank_icons/BOB.svg',
      cardNetworks: ['Visa', 'RuPay'],
      displayColorHex: '#FF6F00',
    ),
    BankInfo(
      name: 'Yes Bank',
      code: 'YES',
      logoPath: 'assets/bank_icons/YES.svg',
      cardNetworks: ['Visa', 'MasterCard'],
      displayColorHex: '#10449A',
    ),
    BankInfo(
      name: 'Other',
      code: 'OTHER',
      logoPath: null,
      cardNetworks: null,
      displayColorHex: '#999999',
    ),
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

  static List<BankInfo> getAllBanks() => _banks;
}
