import 'package:card_nudge/data/hive/models/bank_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BankStorage {
  static Box<BankModel>? _box;

  static Box<BankModel> getBox() {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box not initialized. Call initHive() first.');
    }
    return _box!;
  }

  static Future<void> initHive() async {
    Hive.registerAdapter(BankModelAdapter());

    _box = await Hive.openBox<BankModel>('banks');

    if (_box!.isEmpty) {
      for (var bank in _banks) {
        await _box!.put(bank.id, bank);
      }
    }
  }

  static final List<BankModel> _banks = [
    BankModel(
      name: 'HDFC Bank',
      code: 'HDFC',
      logoPath: 'assets/bank_icons/HDFC.svg',
      supportNumber: '1800 202 6161',
      website: 'https://www.hdfcbank.com',
      colorHex: 'FF0066B2',
      priority: 1,
    ),
    BankModel(
      name: 'ICICI Bank',
      code: 'ICICI',
      logoPath: 'assets/bank_icons/ICICI.svg',
      supportNumber: '1800 1080',
      website: 'https://www.icicibank.com',
      colorHex: 'FFFF7E00',
      priority: 2,
    ),
    BankModel(
      name: 'SBI Card',
      code: 'SBI',
      logoPath: 'assets/bank_icons/SBI.svg',
      supportNumber: '1800 1234',
      website: 'https://www.onlinesbi.com',
      colorHex: 'FF1F5D36',
      priority: 3,
    ),
    BankModel(
      name: 'Axis Bank',
      code: 'AXIS',
      logoPath: 'assets/bank_icons/AXIS.svg',
      supportNumber: '1800 419 5555',
      website: 'https://www.axisbank.com',
      colorHex: 'FFE91E63',
      priority: 4,
    ),
    BankModel(
      name: 'Bank of Baroda',
      code: 'BOB',
      logoPath: 'assets/bank_icons/BOB.svg',
      supportNumber: '1800 102 4455',
      website: 'https://www.bankofbaroda.in',
      colorHex: 'FFE31937',
      priority: 5,
    ),
    BankModel(
      name: 'Yes Bank',
      code: 'YES',
      logoPath: 'assets/bank_icons/YES.svg',
      supportNumber: '1800 1200',
      website: 'https://www.yesbank.in',
      colorHex: 'FF00AEEF',
      priority: 6,
    ),
    BankModel(
      name: 'Kotak Mahindra Bank',
      code: 'KOTAK',
      logoPath: 'assets/bank_icons/KOTAK.svg',
      supportNumber: '1860 266 2666',
      website: 'https://www.kotak.com',
      colorHex: 'FF5D2E8E',
      priority: 7,
    ),
    BankModel(
      name: 'IndusInd Bank',
      code: 'INDUSIND',
      logoPath: 'assets/bank_icons/INDUSIND.svg',
      supportNumber: '1860 267 7777',
      website: 'https://www.indusind.com',
      colorHex: 'FF003366',
      priority: 8,
    ),
    BankModel(
      name: 'Standard Chartered',
      code: 'SCB',
      logoPath: 'assets/bank_icons/SCB.svg',
      supportNumber: '1800 419 8300',
      website: 'https://www.sc.com/in',
      colorHex: 'FF1A3E72',
      priority: 9,
    ),
    BankModel(
      name: 'RBL Bank',
      code: 'RBL',
      logoPath: 'assets/bank_icons/RBL.svg',
      supportNumber: '1800 222 900',
      website: 'https://www.rblbank.com',
      colorHex: 'FFE31937',
      priority: 10,
    ),
    BankModel(
      name: 'Punjab National Bank',
      code: 'PNB',
      logoPath: 'assets/bank_icons/PNB.svg',
      supportNumber: '1800 180 2222',
      website: 'https://www.pnbindia.in',
      colorHex: 'FFD11D2B',
      priority: 11,
    ),
    BankModel(
      name: 'Union Bank of India',
      code: 'UBI',
      logoPath: 'assets/bank_icons/UBI.svg',
      supportNumber: '1800 222 244',
      website: 'https://www.unionbankofindia.co.in',
      colorHex: 'FF005F9E',
      priority: 12,
    ),
    BankModel(
      name: 'HSBC',
      code: 'HSBC',
      logoPath: 'assets/bank_icons/HSBC.svg',
      supportNumber: '1800 267 3456',
      website: 'https://www.hsbc.co.in',
      colorHex: 'FFDB0011',
      priority: 13,
    ),
    BankModel(
      name: 'Citi Bank',
      code: 'CITI',
      logoPath: 'assets/bank_icons/CITI.svg',
      supportNumber: '1860 210 2484',
      website: 'https://www.online.citibank.co.in',
      colorHex: 'FF003D70',
      priority: 14,
    ),
    BankModel(
      name: 'American Express',
      code: 'AMEX',
      logoPath: 'assets/bank_icons/AMEX.svg',
      supportNumber: '1800 419 2122',
      website: 'https://www.americanexpress.com',
      colorHex: 'FF016FD0',
      priority: 15,
    ),
    BankModel(
      name: 'DBS Bank',
      code: 'DBS',
      logoPath: 'assets/bank_icons/DBS.svg',
      supportNumber: '1800 209 1496',
      website: 'https://www.dbs.com/in',
      colorHex: 'FF003D70',
      priority: 16,
    ),
    BankModel(
      name: 'IDFC First Bank',
      code: 'IDFC',
      logoPath: 'assets/bank_icons/IDFC.svg',
      supportNumber: '1800 419 8332',
      website: 'https://www.idfcfirstbank.com',
      colorHex: 'FFE31937',
      priority: 17,
    ),
    BankModel(
      name: 'Bank of India',
      code: 'BOI',
      logoPath: 'assets/bank_icons/BOI.svg',
      supportNumber: '1800 220 229',
      website: 'https://www.bankofindia.co.in',
      colorHex: 'FF0066B3',
      priority: 18,
    ),
    BankModel(
      name: 'Canara Bank',
      code: 'CANARA',
      logoPath: 'assets/bank_icons/CANARA.svg',
      supportNumber: '1800 425 0018',
      website: 'https://canarabank.com',
      colorHex: 'FFF7941D',
      priority: 19,
    ),
    BankModel(
      name: 'Federal Bank',
      code: 'FEDERAL',
      logoPath: 'assets/bank_icons/FEDERAL.svg',
      supportNumber: '1800 425 1199',
      website: 'https://www.federalbank.co.in',
      colorHex: 'FF0066B3',
      priority: 21,
    ),
    BankModel(
      name: 'Bandhan Bank',
      code: 'BANDHAN',
      logoPath: 'assets/bank_icons/BANDHAN.svg',
      supportNumber: '1800 258 8181',
      website: 'https://www.bandhanbank.com',
      colorHex: 'FFE31937',
      priority: 22,
    ),
    BankModel(name: 'Other', code: 'OTHER', logoPath: null, priority: 99),
  ];
}
