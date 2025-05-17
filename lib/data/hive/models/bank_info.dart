class BankInfo {
  final String name;
  final String? code;
  final String? logoPath;
  final List<String>? cardNetworks;
  final String? displayColorHex;

  const BankInfo({
    required this.name,
    this.code,
    this.logoPath,
    this.cardNetworks,
    this.displayColorHex,
  });
}
