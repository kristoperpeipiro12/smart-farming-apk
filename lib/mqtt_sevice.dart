import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'notification_service.dart';

class MqttService {
  late MqttServerClient client;
  final String idUser;

  MqttService(this.idUser); // Konstruktor untuk menerima id_user

  Future<void> connect() async {
    client = MqttServerClient(
      '103.145.126.158',
      '$idUser',
    ); // Ganti dengan broker MQTT Anda
    client.port = 1883; // Port MQTT (default 1883)

    // Set up pengaturan koneksi
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .authenticateAs('user1', 'user1') // Isi jika ada autentikasi
        .withWillTopic('IOT/CLIENT/STATUS')
        .withWillMessage('OFFLINE')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Error connecting to MQTT: $e');
      client.disconnect();
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT connected');
    } else {
      print('MQTT connection failed - disconnecting');
      client.disconnect();
    }
  }

  void subscribe() {
    final topic = 'IOT/NOTIF/$idUser'; // Topik dinamis berdasarkan id_user
    client.subscribe(topic, MqttQos.atLeastOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final message = messages[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );
      print('Received message: $payload');
      // Kirim payload ke push notification
      NotificationService.showNotification(payload);
    });
  }

  void onConnected() {
    print('Connected to MQTT broker');
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }
}
