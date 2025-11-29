class DeviceSpecification {
  final String name;
  final String value;

  DeviceSpecification({
    required this.name,
    required this.value,
  });

  factory DeviceSpecification.fromJson(Map<String, dynamic> json) {
    return DeviceSpecification(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

class Device {
  final String name;
  final String brand;
  final String color;
  final String type;

  final List<String> images;
  final List<String> colorOptions;
  final List<String> storageOptions;
  final List<String> detailImages;

  final double devicePrice;
  final double effectivePrice;
  final double monthlyDeduction;

  final String primaryImage;
  final List<DeviceSpecification> deviceSpecifications;

  Device({
    required this.name,
    required this.brand,
    required this.color,
    required this.type,
    required this.images,
    required this.colorOptions,
    required this.storageOptions,
    required this.detailImages,
    required this.devicePrice,
    required this.effectivePrice,
    required this.monthlyDeduction,
    required this.primaryImage,
    required this.deviceSpecifications,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      color: json['color'] ?? '',
      type: json['type'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      colorOptions: List<String>.from(json['colorOptions'] ?? []),
      storageOptions: List<String>.from(json['storageOptions'] ?? []),
      detailImages: List<String>.from(json['detailImages'] ?? []),
      devicePrice: (json['devicePrice'] ?? 0).toDouble(),
      effectivePrice: (json['effectivePrice'] ?? 0).toDouble(),
      monthlyDeduction: (json['monthlyDeduction'] ?? 0).toDouble(),
      primaryImage: json['primaryImage'] ?? '',
      deviceSpecifications: (json['deviceSpecifications'] as List<dynamic>?)
          ?.map((spec) => DeviceSpecification.fromJson(spec as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'color': color,
      'type': type,
      'images': images,
      'colorOptions': colorOptions,
      'storageOptions': storageOptions,
      'detailImages': detailImages,
      'devicePrice': devicePrice,
      'effectivePrice': effectivePrice,
      'monthlyDeduction': monthlyDeduction,
      'primaryImage': primaryImage,
      'deviceSpecifications': deviceSpecifications.map((spec) => spec.toJson()).toList(),
    };
  }
}