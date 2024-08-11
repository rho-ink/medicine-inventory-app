class Gudang {
  String id;
  String name;
  String tipe;
  int totalObat;
  Map<String, ExpiryDetail> expiryDetails;

  Gudang({
    required this.id,
    required this.name,
    required this.tipe,
    required this.totalObat,
    this.expiryDetails = const {},
  });

  factory Gudang.fromJson(Map<String, dynamic> json, String id) {
    return Gudang(
      id: id,
      name: json['name'] ?? '',
      tipe: json['tipe'] ?? '',
      totalObat: json['totalObat'] ?? 0,
      expiryDetails: (json['expiryDetails'] as Map<dynamic, dynamic>? ?? {}).map(
        (k, v) => MapEntry(
          k.toString(),
          ExpiryDetail.fromJson(Map<String, dynamic>.from(v)),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tipe': tipe,
      'totalObat': totalObat,
      'expiryDetails': expiryDetails.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}



//2
//1
class ExpiryDetail {
 String id;
  String expiryDate;
  int quantity;
   String submissionDate;
   String batchId;

  ExpiryDetail({
    required this.id,
    required this.expiryDate,
    required this.quantity,
    required this.submissionDate,
    required this.batchId,
  });

  factory ExpiryDetail.fromJson(Map<String, dynamic> json) {
    return ExpiryDetail(
      id: json['id'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      quantity: json['quantity'] ?? 0,
      submissionDate: json['submissionDate'] ?? '',
      batchId:  json['batchId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expiryDate': expiryDate,
      'quantity': quantity,
      'submissionDate': submissionDate,
      'batchId' : batchId,
    };
  }
}


