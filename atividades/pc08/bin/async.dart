import 'dart:async';

String addHello(String name) {
  return 'Hello $name';
}

Future<String> greetUser() async {
  try {
    String username = await fetchUsername();
    return addHello(username);
  } catch (e) {
    return 'Erro ao buscar o nome do usuário';
  }
}

Future<String> sayGoodbye() async {
  try {
    String username = await logoutUser();
    return '$username Thanks, see you next time';
  } catch (e) {
    return 'Erro ao fazer logout';
  }
}

Future<String> fetchUsername() async {
  return Future.delayed(Duration(seconds: 2), () => 'Jenny');
}

Future<String> logoutUser() async {
  return Future.delayed(Duration(seconds: 2), () => 'Jenny');
}

void main() async {
  print(await greetUser());
  print(await sayGoodbye());
}
