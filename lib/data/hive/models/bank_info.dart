class BankInfo {
  final String name;
  final String? code;
  final String? logoPath;
  final List<String>? cardNetworks;

  const BankInfo({
    required this.name,
    this.code,
    this.logoPath,
    this.cardNetworks,
  });
}
