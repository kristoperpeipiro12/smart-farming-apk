import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:smart_farming/mqtt_sevice.dart';

void initializeBackgroundService() {
  final service = FlutterBackgroundService();

  service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final mqttService = MqttService("user_id");
  await mqttService.connect();
  mqttService.subscribe();

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Smart Farming",
          content: "Running in the background",
        );
      }
    }
  });
}

extension on ServiceInstance {
  isForegroundService() {}

  void setForegroundNotificationInfo({
    required String title,
    required String content,
  }) {}
}

mixin AndroidServiceInstance {}
