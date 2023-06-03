import 'package:rive/rive.dart';

class RiveAsset {
  final String artboard, stateMachineName, title, src;
  late SMIBool? input;

  RiveAsset(
    this.src, {
    required this.artboard,
    required this.stateMachineName,
    required this.title,
    this.input,
  });

  set setInput(SMIBool status) {
    input = status;
  }
}

List<RiveAsset> bottomNavs = [
  RiveAsset(
    'assets/riveassets/icons.riv',
    artboard: 'HOME',
    stateMachineName: 'HOME_interactivity',
    title: 'Home',
  ),
  RiveAsset(
    'assets/riveassets/icons.riv',
    artboard: 'TIMER',
    stateMachineName: 'TIMER_Interactivity',
    title: 'Scene',
  ),
  RiveAsset(
    'assets/riveassets/icons.riv',
    artboard: 'BELL',
    stateMachineName: 'BELL_Interactivity',
    title: 'Info',
  ),
  RiveAsset(
    'assets/riveassets/icons.riv',
    artboard: 'USER',
    stateMachineName: 'USER_Interactivity',
    title: 'Profile',
  ),
];
