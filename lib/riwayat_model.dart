class Device {
  final String idDevice;
  final String name;

  Device({required this.idDevice, required this.name});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      idDevice: json['id_device'] ?? 'Unknown',
      name: json['name'] ?? 'No Name',
    );
  }
}

class SensorData {
  final String timestamp;
  final String idSensor;
  final String? name;
  final String? description;
  final double value;
  final String? status;
  final String? unit;

  SensorData({
    required this.timestamp,
    required this.idSensor,
    this.name,
    this.description,
    required this.value,
    this.status,
    this.unit,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) {
        try {
          return double.parse(val);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    return SensorData(
      timestamp: json['timestamp'] ?? 'N/A',
      idSensor: json['id_sensor'] ?? 'Unknown',
      name: json['sensor_name'],
      description: json['sensor_description'],
      value: parseValue(json['sensor_value']),
      status: json['status'],
      unit: json['unit'],
    );
  }
}

class SensorEntry {
  final String idSensor;
  final String? name;
  final String? description;
  final double value;
  final String? status;
  final String? unit;

  SensorEntry({
    required this.idSensor,
    this.name,
    this.description,
    required this.value,
    this.status,
    this.unit,
  });

  factory SensorEntry.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) {
        try {
          return double.parse(val);
        } catch (e) {
          return 0.0;
        }
      }
      return 0.0;
    }

    return SensorEntry(
      idSensor: json['id_sensor'] ?? 'Unknown',
      name: json['sensor_name'],
      description: json['sensor_description'],
      value: parseValue(json['sensor_value']),
      status: json['status'],
      unit: json['unit'],
    );
  }
}

class SensorHistoryResponse {
  final List<SensorData> items;
  final int currentPage;
  final int perPage;
  final int totalPages;
  final int totalItems;

  SensorHistoryResponse({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.totalPages,
    required this.totalItems,
  });

  factory SensorHistoryResponse.fromJson(Map<String, dynamic> json) {
    var list = <SensorData>[];
    if (json['items'] is List) {
      list =
          (json['items'] as List)
              .map((itemJson) => SensorData.fromJson(itemJson))
              .toList();
    }

    return SensorHistoryResponse(
      items: list,
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
    );
  }
}
