void basicType() {
  int x = 42;
  x = x + 2;
  print("O valor de x é $x");
}

void varType() {
  var x = 42;
  x = x + 2;
  print("O valor de x é $x");
}

void finalType() {
  final x = 42;
  // x = x + 2; // Não compila, pois 'x' é final
  print("O valor de x é $x");
}

void stringType() {
  String x = "42";
  x = x + "2";
  print("O valor de x é $x");
}

void dynamicType() {
  dynamic x = "42";
  x = x + "2";
  print("O valor de x é $x");

  x = 42;
  x = x + 2;
  print("O valor de x é $x");
}
