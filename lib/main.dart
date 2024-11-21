import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qit/pages/home_page.dart';
import 'package:qit/services/secure_storage.dart';

Future main() async {
  await dotenv.load(fileName: "assets/.env", mergeWith: {
    "TEST_VAR": "5",
  });
  SecureStorage.initialize();
  SecureStorage.saveNewItem("is_authorized", "false");

  var x = await SecureStorage.getItem("state");
  print(x);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Raleway',
      ),
      home: const HomePage(),
    );
  }
}
