import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:routemaster/routemaster.dart';
import 'package:smarthomeuione/core/common/loader.dart';
import 'package:smarthomeuione/features/auth/controller/auth_controller.dart';
import 'package:smarthomeuione/responsive/responsive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPassVisible = false;

  void signInWithEmailPass() {
    ref.read(authControllerProvider.notifier).signInWithEmailPass(
          context,
          emailController.text.trim(),
          passwordController.text.trim(),
        );
  }

  void navigateToSignUp() {
    Routemaster.of(context).push('/sign-up');
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding.top;
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      body: Responsive(
        child: Padding(
          padding: EdgeInsets.only(left: 28, right: 28, top: safePadding + 66),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //title
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'SHOME',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                //login text
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 34,
                    ),
                  ),
                ),
                //email textfield
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Email ID',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    ),
                    icon: FaIcon(
                      FontAwesomeIcons.at,
                      size: 20,
                    ),
                  ),
                ),
                //password textfield
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    icon: const FaIcon(
                      FontAwesomeIcons.lock,
                      size: 22,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => isPassVisible = !isPassVisible),
                      icon: const FaIcon(
                        FontAwesomeIcons.eyeSlash,
                        size: 20,
                      ),
                    ),
                  ),
                  obscureText: !isPassVisible,
                ),
                //forgot password button
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
                // sign in button
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => signInWithEmailPass(),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
                // //or text
                // const SizedBox(height: 20),
                // Stack(
                //   alignment: Alignment.center,
                //   children: [
                //     const Divider(),
                //     Container(
                //       width: 50,
                //       color: Pallete.scaffoldbackgroundlight,
                //       child: const Center(
                //           child: Text(
                //         'OR',
                //         style: TextStyle(color: Colors.grey),
                //       )),
                //     ),
                //   ],
                // ),
                // //login with google btn
                // const SizedBox(height: 20),
                // ElevatedButton.icon(
                //   onPressed: () => signInWithGoogle(context),
                //   icon: Image.asset(
                //     Constants.googlePath,
                //     width: 35,
                //   ),
                //   label: const Text(
                //     'Continue with Google',
                //     style: TextStyle(fontSize: 18, color: Colors.black),
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFFEEEEEE),
                //     minimumSize: const Size(double.infinity, 50),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(15),
                //     ),
                //   ),
                // ),
                //new to smart home control btn
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New to SHome?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () => navigateToSignUp(),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
