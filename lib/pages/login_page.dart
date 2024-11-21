import 'package:flutter/material.dart';
import 'package:qit/animations/animated_homepage_route.dart';
import 'package:qit/components/login_button.dart';
import 'package:qit/components/login_field.dart';
import 'package:qit/components/swap_states_button.dart';
import 'package:qit/pages/create_room_page.dart';
import 'package:qit/services/api.dart';
import 'package:qit/services/secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool signIn = true;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();

  FocusNode _usernameFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _confirmFocusNode = FocusNode();

  void swapStates() {
    setState(() {
      signIn = !signIn;
    });
  }

  void handleSignIn(BuildContext context) async {
    String? username = _usernameController.text;
    String? password = _passwordController.text;

    // handle stuff

    bool x = await Api.postSignIn(username, password);

    if (x) {
      Navigator.push(context, HomePageRoute(child: CreateRoomPage()));
    }
  }

  void handleCreateAccount() {
    String? username = _usernameController.text;
    String? password = _passwordController.text;
    String? confirm = _confirmController.text;

    // Handle password and confirm !=

    Api.postCreateAccount(username, password);
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes when done
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(),
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: deviceHeight * 0.2,
                ),
                SizedBox(
                  height: deviceHeight * 0.01,
                ),
                const Text(
                  "Sign in or Create Account",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: deviceHeight * 0.01,
                ),
                LoginField(
                  hintText: "Username",
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  nextNode: _passwordFocusNode,
                ),
                SizedBox(
                  height: deviceHeight * 0.01,
                ),
                LoginField(
                  hintText: "Password",
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  nextNode: signIn ? null : _confirmFocusNode,
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      if (!signIn) ...[
                        SizedBox(
                          height: deviceHeight * 0.01,
                        ),
                        LoginField(
                          hintText: "Confirm Password",
                          controller: _confirmController,
                          focusNode: _confirmFocusNode,
                          nextNode: null,
                        ),
                        SizedBox(
                          height: deviceHeight * 0.01,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(right: deviceWidth * 0.1, top: 5),
                      child: const Text("Forgot password?"),
                    ),
                  ],
                ),
                SizedBox(
                  height: deviceHeight * 0.05,
                ),
                SubmitButton(
                  onTap: () =>
                      signIn ? handleSignIn(context) : handleCreateAccount(),
                  buttonText: signIn ? "Sign In" : "Create Account",
                ),
                SizedBox(
                  height: deviceHeight * 0.05,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text("OR"),
                    ),
                    Expanded(
                      child: Divider(),
                    ),
                  ],
                ),
                SizedBox(
                  height: deviceHeight * 0.05,
                ),
                SwapStatesButton(
                  buttonText: signIn ? "Create Account" : "Sign In",
                  onTap: () {
                    setState(() {
                      swapStates();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
