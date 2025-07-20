import 'package:hive/hive.dart';

part 'imc.g.dart';

@HiveType(typeId: 0)
class IMC extends HiveObject {
  @HiveField(0)
  final double peso;

  @HiveField(1)
  final double altura;

  @HiveField(2)
  final DateTime dataHora;

  IMC({required this.peso, required this.altura}) : dataHora = DateTime.now();

  double calcular() => peso / (altura * altura);

  String classificacao() {
    final imc = calcular();
    if (imc < 18.5) return "Abaixo do peso";
    if (imc < 24.9) return "Peso normal";
    if (imc < 29.9) return "Sobrepeso";
    if (imc < 34.9) return "Obesidade grau 1";
    if (imc < 39.9) return "Obesidade grau 2";
    return "Obesidade grau 3";
  }
}
