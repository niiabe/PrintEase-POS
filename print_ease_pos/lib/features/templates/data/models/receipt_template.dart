enum ReceiptAlignment { left, center }

class ReceiptTemplate {
  final int? id;
  final String name;
  final String storeName;
  final String storePhone;
  final String header;
  final String footer;
  final String? logoPath;
  final bool showLogo;
  final bool showQrCode;
  final bool showDivider;
  final bool showItemizedList;
  final double paperWidth;
  final double fontSize;
  final ReceiptAlignment alignment;
  final double spacing;
  final DateTime createdAt;

  const ReceiptTemplate({
    this.id,
    required this.name,
    this.storeName = '',
    this.storePhone = '',
    this.header = '',
    this.footer = 'Thank you for your patronage!',
    this.logoPath,
    this.showLogo = true,
    this.showQrCode = true,
    this.showDivider = true,
    this.showItemizedList = true,
    this.paperWidth = 80,
    this.fontSize = 1.0,
    this.alignment = ReceiptAlignment.center,
    this.spacing = 1.0,
    required this.createdAt,
  });

  factory ReceiptTemplate.fromMap(Map<String, dynamic> map) {
    return ReceiptTemplate(
      id: map['id'] as int?,
      name: map['name'] as String,
      storeName: map['storeName'] as String? ?? '',
      storePhone: map['storePhone'] as String? ?? '',
      header: map['header'] as String? ?? '',
      footer: map['footer'] as String? ?? 'Thank you for your patronage!',
      logoPath: map['logoPath'] as String?,
      showLogo: (map['showLogo'] as int? ?? 1) == 1,
      showQrCode: (map['showQrCode'] as int? ?? 1) == 1,
      showDivider: (map['showDivider'] as int? ?? 1) == 1,
      showItemizedList: (map['showItemizedList'] as int? ?? 1) == 1,
      paperWidth: (map['paperWidth'] as num?)?.toDouble() ?? 58,
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 1.0,
      alignment: ReceiptAlignment.values.firstWhere(
        (a) => a.name == map['alignment'],
        orElse: () => ReceiptAlignment.center,
      ),
      spacing: (map['spacing'] as num?)?.toDouble() ?? 1.0,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'storeName': storeName,
      'storePhone': storePhone,
      'header': header,
      'footer': footer,
      'logoPath': logoPath,
      'showLogo': showLogo ? 1 : 0,
      'showQrCode': showQrCode ? 1 : 0,
      'showDivider': showDivider ? 1 : 0,
      'showItemizedList': showItemizedList ? 1 : 0,
      'paperWidth': paperWidth,
      'fontSize': fontSize,
      'alignment': alignment.name,
      'spacing': spacing,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReceiptTemplate copyWith({
    int? id,
    String? name,
    String? storeName,
    String? storePhone,
    String? header,
    String? footer,
    String? logoPath,
    bool? showLogo,
    bool? showQrCode,
    bool? showDivider,
    bool? showItemizedList,
    double? paperWidth,
    double? fontSize,
    ReceiptAlignment? alignment,
    double? spacing,
    DateTime? createdAt,
    bool clearLogo = false,
  }) {
    return ReceiptTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      storeName: storeName ?? this.storeName,
      storePhone: storePhone ?? this.storePhone,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      showLogo: showLogo ?? this.showLogo,
      showQrCode: showQrCode ?? this.showQrCode,
      showDivider: showDivider ?? this.showDivider,
      showItemizedList: showItemizedList ?? this.showItemizedList,
      paperWidth: paperWidth ?? this.paperWidth,
      fontSize: fontSize ?? this.fontSize,
      alignment: alignment ?? this.alignment,
      spacing: spacing ?? this.spacing,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const List<String> presetNames = [
    'Shop Receipt',
    'Restaurant Receipt',
    'Invoice',
    'Delivery Slip',
  ];
}
