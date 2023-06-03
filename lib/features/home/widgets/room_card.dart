import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/constants/constants.dart';
import 'package:smarthomeuione/features/room/controller/room_controller.dart';
import 'package:smarthomeuione/models/room_model.dart';
import 'package:smarthomeuione/theme/palette.dart';

class RoomCard extends ConsumerStatefulWidget {
  final RoomModel room;
  const RoomCard({super.key, required this.room});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RoomCardState();
}

class _RoomCardState extends ConsumerState<RoomCard> {
  final nameController = TextEditingController();

  void navigateToControlRoom(BuildContext context) {
    Routemaster.of(context).push('/room/${widget.room.roomId}');
  }

  Future changeRoomName() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change name'),
          content: TextField(
            autofocus: true,
            controller: nameController,
            maxLength: 25,
            decoration: const InputDecoration(
              hintText: 'Enter the name',
              counterText: '',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => submit(),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

  void submit() {
    ref
        .read(roomControllerProvider.notifier)
        .changeRoomName(widget.room, nameController.text.trim(), context);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    return GestureDetector(
      onTap: () => navigateToControlRoom(context),
      onLongPress: () => changeRoomName(),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: theme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //room icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (Constants.roomcategoryIcons[widget.room.icon][2] as Color)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/${Constants.roomcategoryIcons[widget.room.icon][0]}.png',
                      width: 25,
                      color: Constants.roomcategoryIcons[widget.room.icon][1] as Color,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.room.deviceMacs.length} devices',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
