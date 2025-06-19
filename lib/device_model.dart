class Device {
  final String idDevice;
  final String name;
  final String description;

  Device({
    required this.idDevice,
    required this.name,
    required this.description,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      idDevice: json['id_device'],
      name: json['name'] ?? 'No Name',
      description: json['description'] ?? 'No Description',
    );
  }
}