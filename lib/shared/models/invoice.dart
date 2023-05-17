class Invoice {
  String? invoice;
  String hash;
  String? memo;
  int amount;
  String mintUrl;

  Invoice(
      {required this.hash,
      required this.amount,
      required this.mintUrl,
      this.memo,
      this.invoice});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'invoice': invoice,
      'hash': hash,
      'amount': amount,
      'mint_url': mintUrl,
    };
    if (memo != null) {
      json['memo'] = memo;
    }
    return json;
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoice: json['invoice'],
      hash: json['hash'],
      amount: json['amount'],
      mintUrl: json['mint_url'],
      memo: json.containsKey('memo') ? json['memo'] : null,
    );
  }
}
