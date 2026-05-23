class PrinterDevice {
  final String name;
  final String address;
  final bool isConnected;
  final int paperWidth;
  final bool isPreferred;
  final DateTime? lastConnected;

  const PrinterDevice({
    required this.name,
    required this.address,
    this.isConnected = false,
    this.paperWidth = 80,
    this.isPreferred = false,
    this.lastConnected,
  });

  factory PrinterDevice.fromMap(Map<String, dynamic> map) {
    return PrinterDevice(
      name: map['name'] as String,
      address: map['address'] as String,
      isConnected: map['isConnected'] as bool? ?? false,
      paperWidth: map['paperWidth'] as int? ?? 80,
      isPreferred: map['isPreferred'] as bool? ?? false,
      lastConnected: map['lastConnected'] != null
          ? DateTime.tryParse(map['lastConnected'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'isConnected': isConnected,
      'paperWidth': paperWidth,
      'isPreferred': isPreferred,
      'lastConnected': lastConnected?.toIso8601String(),
    };
  }

  PrinterDevice copyWith({
    String? name,
    String? address,
    bool? isConnected,
    int? paperWidth,
    bool? isPreferred,
    DateTime? lastConnected,
  }) {
    return PrinterDevice(
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      paperWidth: paperWidth ?? this.paperWidth,
      isPreferred: isPreferred ?? this.isPreferred,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }

  String get paperSizeLabel => paperWidth == 58 ? '58mm' : '80mm';
}
