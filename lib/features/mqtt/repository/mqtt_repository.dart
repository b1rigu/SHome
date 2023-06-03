import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smarthomeuione/core/enums/enums.dart';
import 'package:uuid/uuid.dart';
import 'server.dart' if (dart.library.html) 'browser.dart' as mqttsetup;

class MqttState extends StateNotifier<MqttAppConnectionState> {
  MqttState() : super(MqttAppConnectionState.disconnected);

  void setMqttState(MqttAppConnectionState mqttState) {
    state = mqttState;
  }
}

final mqttStateProvider = StateNotifierProvider<MqttState, MqttAppConnectionState>(
  (ref) => MqttState(),
);

final mqttProvider = Provider(
  (ref) {
    String identifier = const Uuid().v1();
    return MQTTRepository(
      identifier: identifier,
      host: 'test.mosquitto.org',
      ref: ref,
    );
  },
);

class MQTTRepository {
  MqttClient? _client;
  final String _identifier;
  final String _host;
  final Ref _ref;

  MQTTRepository({
    required String identifier,
    required String host,
    required Ref ref,
  })  : _identifier = identifier,
        _host = host,
        _ref = ref;

  void initializeMQTTClient() {
    _client = mqttsetup.setup(_host, _identifier)
      ..onDisconnected = onDisconnected
      ..onConnected = onConnected
      ..onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMess;
  }

  bool isConnected() {
    if (_client == null) {
      return false;
    }
    return _client!.connectionStatus!.state == MqttConnectionState.connected;
  }

  Future<void> connect() async {
    try {
      _ref.read(mqttStateProvider.notifier).setMqttState(MqttAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (_) {
      disconnect();
    }
  }

  void disconnect() {
    _client!.disconnect();
  }

  void publish(String message, String topic) async {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void subscribe(String topic) async {
    if (_client!.getSubscriptionsStatus(topic) == MqttSubscriptionStatus.doesNotExist) {
      _client!.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>> getSubscriptionStream() {
    return _client!.updates!;
  }

  void unsubscribe(String topic) async {
    _client!.unsubscribe(topic);
  }

  void logOut() {
    _client!.disconnect();
  }

  void onConnected() {
    print('Client connection was successful');
    _ref.read(mqttStateProvider.notifier).setMqttState(MqttAppConnectionState.connected);
  }

  void onDisconnected() {
    _ref.read(mqttStateProvider.notifier).setMqttState(MqttAppConnectionState.disconnected);
  }

  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }
}
