import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int n) => String.fromCharCodes(Iterable.generate(
    n, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
