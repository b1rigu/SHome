import 'package:flutter/material.dart';
import 'package:smarthomeuione/models/device_usage_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyChartWidget extends StatefulWidget {
  final List<DeviceUsageModel> deviceUsageList;
  const MyChartWidget({super.key, required this.deviceUsageList});

  @override
  State<MyChartWidget> createState() => _MyChartWidgetState();
}

class _MyChartWidgetState extends State<MyChartWidget> {
  DateTime today = DateTime.now();
  DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
  late DateTime todaysstart;
  late DateTime todaysend;

  @override
  void initState() {
    super.initState();
    todaysstart = DateTime(today.year, today.month, today.day);
    todaysend = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: SfCartesianChart(
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          zoomMode: ZoomMode.x,
        ),
        primaryXAxis: DateTimeAxis(
          labelRotation: 90,
          intervalType: DateTimeIntervalType.hours,
          interval: 2,
          minimum: todaysstart,
          maximum: todaysend,
          labelStyle: const TextStyle(color: Colors.white60),
        ),
        primaryYAxis: NumericAxis(
          interval: 1,
          decimalPlaces: 1,
          labelFormat: '{value} kWh',
          labelStyle: const TextStyle(color: Colors.white60),
        ),
        title: ChartTitle(
          text: 'Daily usage graph',
          textStyle: const TextStyle(color: Colors.white),
        ),
        series: <FastLineSeries>[
          // Renders line chart
          FastLineSeries<DeviceUsageModel, DateTime>(
            dataSource: widget.deviceUsageList,
            xValueMapper: (DeviceUsageModel usageModel, _) => usageModel.dataTime,
            yValueMapper: (DeviceUsageModel usageModel, _) => usageModel.usageSum,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
