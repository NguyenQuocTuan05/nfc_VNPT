import 'dart:convert';

class NfcRecord {
  // Thông tin thẻ NFC cơ bản
  final String tagId;
  final String tagType;
  final DateTime timestamp;

  // Thông tin CCCD từ VNPT SDK
  final String? fullName;
  final String? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? documentNumber;
  final String? expiryDate;
  final String? personalNumber;
  final String? placeOfOrigin;
  final String? placeOfResidence;
  final String? issuingAuthority;
  final String? issueDate;

  // Raw data từ SDK
  final Map<String, dynamic>? rawData;

  NfcRecord({
    required this.tagId,
    required this.tagType,
    required this.timestamp,
    this.fullName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.documentNumber,
    this.expiryDate,
    this.personalNumber,
    this.placeOfOrigin,
    this.placeOfResidence,
    this.issuingAuthority,
    this.issueDate,
    this.rawData,
  });

  /// Parse dữ liệu trả về từ VNPT SDK (dataNFCResult)
  factory NfcRecord.fromVNPTResult(Map<dynamic, dynamic> result) {
    // Chuyển Map<dynamic, dynamic> → Map<String, dynamic>
    final data = result.map((k, v) => MapEntry(k.toString(), v));

    return NfcRecord(
      tagId: _getString(data, 'documentNumber') ?? 'N/A',
      tagType: 'CCCD - VNPT SDK',
      timestamp: DateTime.now(),
      fullName: _getString(data, 'fullName') ?? _getString(data, 'name'),
      dateOfBirth: _getString(data, 'dateOfBirth') ?? _getString(data, 'birthday'),
      gender: _getString(data, 'gender') ?? _getString(data, 'sex'),
      nationality: _getString(data, 'nationality'),
      documentNumber: _getString(data, 'documentNumber'),
      expiryDate: _getString(data, 'expiryDate') ?? _getString(data, 'doe'),
      personalNumber: _getString(data, 'personalNumber'),
      placeOfOrigin: _getString(data, 'placeOfOrigin'),
      placeOfResidence: _getString(data, 'placeOfResidence'),
      issuingAuthority: _getString(data, 'issuingAuthority'),
      issueDate: _getString(data, 'issueDate') ?? _getString(data, 'doi'),
      rawData: data,
    );
  }

  static String? _getString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  /// Kiểm tra có dữ liệu CCCD không
  bool get hasCCCDData => fullName != null || documentNumber != null;

  /// Tóm tắt thông tin
  String get summary {
    if (hasCCCDData) {
      return '${fullName ?? 'N/A'} - ${documentNumber ?? 'N/A'}';
    }
    return tagId;
  }

  Map<String, dynamic> toJson() => {
        'tagId': tagId,
        'tagType': tagType,
        'timestamp': timestamp.toIso8601String(),
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'nationality': nationality,
        'documentNumber': documentNumber,
        'expiryDate': expiryDate,
        'personalNumber': personalNumber,
        'placeOfOrigin': placeOfOrigin,
        'placeOfResidence': placeOfResidence,
        'issuingAuthority': issuingAuthority,
        'issueDate': issueDate,
      };

  factory NfcRecord.fromJson(Map<String, dynamic> json) => NfcRecord(
        tagId: json['tagId'] as String,
        tagType: json['tagType'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        fullName: json['fullName'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        gender: json['gender'] as String?,
        nationality: json['nationality'] as String?,
        documentNumber: json['documentNumber'] as String?,
        expiryDate: json['expiryDate'] as String?,
        personalNumber: json['personalNumber'] as String?,
        placeOfOrigin: json['placeOfOrigin'] as String?,
        placeOfResidence: json['placeOfResidence'] as String?,
        issuingAuthority: json['issuingAuthority'] as String?,
        issueDate: json['issueDate'] as String?,
      );

  String toJsonString() => jsonEncode(toJson());

  factory NfcRecord.fromJsonString(String jsonString) =>
      NfcRecord.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
