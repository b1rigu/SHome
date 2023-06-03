import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/core/constants/constants.dart';
import 'package:smarthomeuione/features/room/controller/room_controller.dart';
import 'package:smarthomeuione/responsive/responsive.dart';
import 'package:smarthomeuione/theme/palette.dart';

class RoomAddScreen extends ConsumerStatefulWidget {
  const RoomAddScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RoomAddScreenState();
}

class _RoomAddScreenState extends ConsumerState<RoomAddScreen> {
  final nameController = TextEditingController();
  final dropdownItems = [0, 1, 2, 3];
  int? value;

  void createRoom() {
    ref.read(roomControllerProvider.notifier).createRoom(
          nameController.text.trim(),
          value ?? 0,
          context,
        );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void navigateBack() {
    Routemaster.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding.top;
    final isLoading = ref.watch(roomControllerProvider);
    final theme = ref.watch(themeNotifierProvider);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Responsive(
        child: isLoading
            ? const Loader()
            : Padding(
                padding: EdgeInsets.only(left: 28, right: 28, top: safePadding + 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // custom app bar
                      Row(
                        children: [
                          Ink(
                            width: 50,
                            height: 50,
                            decoration: const ShapeDecoration(
                              color: Colors.white,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () => navigateBack(),
                              splashRadius: 25,
                              icon: const FaIcon(
                                FontAwesomeIcons.chevronLeft,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            'Add a room',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      //email textfield
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp('[ ]')),
                        ],
                        decoration: const InputDecoration(
                            counterText: '',
                            hintText: 'Room name',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            icon: Icon(Icons.tag)),
                      ),
                      //icon select
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(
                            Icons.tag,
                            color: Color(0xFF808080),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: DropdownButton<int>(
                              underline: Container(color: Colors.grey, height: 1),
                              hint: const Text(
                                'Select room icon',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              value: value,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(12),
                              items: dropdownItems.map(buildMenuItem).toList(),
                              onChanged: (value) => setState(() => this.value = value),
                            ),
                          ),
                        ],
                      ),
                      // create room button
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () => createRoom(),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  DropdownMenuItem<int> buildMenuItem(int item) => DropdownMenuItem(
        value: item,
        child: Image.asset(
          'assets/icons/${Constants.roomcategoryIcons[item][0]}.png',
          width: 25,
          color: Constants.roomcategoryIcons[item][1] as Color,
        ),
      );
}
