import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient setup(String serverAddress, String uniqueID) {
  return MqttServerClient.withPort('wss://$serverAddress', uniqueID, 8081)
    ..useWebSocket = true
    ..setProtocolV311()
    ..keepAlivePeriod = 20
    ..logging(on: false)
    ..websocketProtocols = MqttClientConstants.protocolsSingleDefault
    ..autoReconnect = true;
}
