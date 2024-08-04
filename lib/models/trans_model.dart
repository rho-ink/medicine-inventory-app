class Transaksi {
  final String id;
  final String date;
  final String gudangId;
  final String name;
  final String tipe;
  final int totalTrans;

  Transaksi({
    required this.id,
    required this.date,
    required this.gudangId,
    required this.name,
    required this.tipe,
    required this.totalTrans,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      gudangId: json['gudangId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      tipe: json['tipe'] as String? ?? '',
      totalTrans: json['totalTrans'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'gudangId': gudangId,
      'name': name,
      'tipe': tipe,
      'totalTrans': totalTrans,
    };
  }
}
