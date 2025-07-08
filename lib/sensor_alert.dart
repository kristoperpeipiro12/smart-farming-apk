class SensorAlert {
  final String time;
  final String idDevice;
  final String idSensor;
  final double sensorValue;
  final String status;

  SensorAlert({
    required this.time,
    required this.idDevice,
    required this.idSensor,
    required this.sensorValue,
    required this.status,
  });

  factory SensorAlert.fromJson(Map<String, dynamic> json) {
    return SensorAlert(
      time: json['time'],
      idDevice: json['id_device'],
      idSensor: json['id_sensor'],
      sensorValue: double.parse(json['sensor_value'].toString()),
      status: json['status'],
    );
  }
}
