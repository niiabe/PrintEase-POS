class AppSettings {
  final bool isDarkMode;
  final double defaultPaperWidth;
  final String currency;
  final String storeName;
  final String storePhone;
  final double taxPercentage;
  final int? defaultTemplateId;
  final bool autoConnectPrinter;
  final bool saveReceiptsAutomatically;
  final bool autoPrint;
  final int printDensity;
  final double characterSize;
  final int lineSpacing;

  const AppSettings({
    this.isDarkMode = false,
    this.defaultPaperWidth = 80,
    this.currency = 'GHS',
    this.storeName = 'My Store',
    this.storePhone = '',
    this.taxPercentage = 0,
    this.defaultTemplateId,
    this.autoConnectPrinter = false,
    this.saveReceiptsAutomatically = true,
    this.autoPrint = true,
    this.printDensity = 1,
    this.characterSize = 1.0,
    this.lineSpacing = 1,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      isDarkMode: map['isDarkMode'] as bool? ?? false,
      defaultPaperWidth: (map['defaultPaperWidth'] as num?)?.toDouble() ?? 80,
      currency: map['currency'] as String? ?? 'GHS',
      storeName: map['storeName'] as String? ?? 'My Store',
      storePhone: map['storePhone'] as String? ?? '',
      taxPercentage: (map['taxPercentage'] as num?)?.toDouble() ?? 0,
      defaultTemplateId: map['defaultTemplateId'] as int?,
      autoConnectPrinter: map['autoConnectPrinter'] as bool? ?? false,
      saveReceiptsAutomatically:
          map['saveReceiptsAutomatically'] as bool? ?? true,
      autoPrint: map['autoPrint'] as bool? ?? true,
      printDensity: map['printDensity'] as int? ?? 1,
      characterSize: (map['characterSize'] as num?)?.toDouble() ?? 1.0,
      lineSpacing: map['lineSpacing'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'defaultPaperWidth': defaultPaperWidth,
      'currency': currency,
      'storeName': storeName,
      'storePhone': storePhone,
      'taxPercentage': taxPercentage,
      'defaultTemplateId': defaultTemplateId,
      'autoConnectPrinter': autoConnectPrinter,
      'saveReceiptsAutomatically': saveReceiptsAutomatically,
      'autoPrint': autoPrint,
      'printDensity': printDensity,
      'characterSize': characterSize,
      'lineSpacing': lineSpacing,
    };
  }

  AppSettings copyWith({
    bool? isDarkMode,
    double? defaultPaperWidth,
    String? currency,
    String? storeName,
    String? storePhone,
    double? taxPercentage,
    int? defaultTemplateId,
    bool? autoConnectPrinter,
    bool? saveReceiptsAutomatically,
    bool? autoPrint,
    int? printDensity,
    double? characterSize,
    int? lineSpacing,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      defaultPaperWidth: defaultPaperWidth ?? this.defaultPaperWidth,
      currency: currency ?? this.currency,
      storeName: storeName ?? this.storeName,
      storePhone: storePhone ?? this.storePhone,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      defaultTemplateId: defaultTemplateId ?? this.defaultTemplateId,
      autoConnectPrinter: autoConnectPrinter ?? this.autoConnectPrinter,
      saveReceiptsAutomatically:
          saveReceiptsAutomatically ?? this.saveReceiptsAutomatically,
      autoPrint: autoPrint ?? this.autoPrint,
      printDensity: printDensity ?? this.printDensity,
      characterSize: characterSize ?? this.characterSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
    );
  }
}
