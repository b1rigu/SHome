import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/common/error_text.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/core/providers/refresh_provider.dart';
import 'package:smarthomeuione/features/auth/controller/auth_controller.dart';
import 'package:smarthomeuione/firebase_options.dart';
import 'package:smarthomeuione/models/user_model.dart';
import 'package:smarthomeuione/router.dart';
import 'package:smarthomeuione/theme/palette.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  void changeData(WidgetRef ref, User data) async {
    UserModel? userModel =
        await ref.watch(authControllerProvider.notifier).getUserData(data.uid).first;
    ref.read(userProvider.notifier).update((state) => userModel);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final user = ref.watch(userProvider);
    return ref.watch(authStateChangeProvider).when(
          data: (user) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Smart Home Control',
            theme: ThemeData(fontFamily: Pallete.fontFamily),
            routerDelegate: RoutemasterDelegate(
              routesBuilder: (context) {
                if (user != null) {
                  changeData(ref, user);
                  WidgetsBinding.instance.addPostFrameCallback(
                      (_) => ref.read(refreshProvider.notifier).update((state) => !state));
                  return loggedInRoute;
                }
                return loggedOutRoute;
              },
            ),
            routeInformationParser: const RoutemasterParser(),
          ),
          error: (error, _) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
