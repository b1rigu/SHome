import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient setup(String serverAddress, String uniqueID) {
  return MqttBrowserClient.withPort('wss://$serverAddress', uniqueID, 8081)
    ..setProtocolV311()
    ..keepAlivePeriod = 20
    ..logging(on: false)
    ..websocketProtocols = MqttClientConstants.protocolsSingleDefault
    ..autoReconnect = true;
}
