import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/imc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final nomeController = TextEditingController();
  double peso = 70.0;
  double altura = 1.70;
  late Box<IMC> imcBox;

  @override
  void initState() {
    super.initState();
    imcBox = Hive.box<IMC>('imcBox');
    _carregarAlturaSalva();
  }

  void _carregarAlturaSalva() async {
    final prefs = Hive.box('configBox');
    setState(() {
      altura = prefs.get('altura', defaultValue: 1.70);
    });
  }

  void _calcularSalvarIMC() {
    final nome = nomeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite seu nome")),
      );
      return;
    }

    final imc = IMC(peso: peso, altura: altura);
    imcBox.add(imc);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Resultado do IMC"),
        content: Text(
          "$nome, seu IMC é ${imc.calcular().toStringAsFixed(2)}\nClassificação: ${imc.classificacao()}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _mostrarClassificacao() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Classificação do IMC"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("• Abaixo do peso: < 18,5"),
            Text("• Peso normal: 18,5 – 24,9"),
            Text("• Sobrepeso: 25 – 29,9"),
            Text("• Obesidade grau I: 30 – 34,9"),
            Text("• Obesidade grau II: 35 – 39,9"),
            Text("• Obesidade grau III: ≥ 40"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMC Hive App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings').then((_) {
                _carregarAlturaSalva(); // Recarrega altura após voltar
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo para Nome
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Slider de Peso
            Text("Peso: ${peso.toStringAsFixed(1)} kg"),
            Slider(
              value: peso,
              min: 0,
              max: 300,
              divisions: 600,
              label: "${peso.toStringAsFixed(1)} kg",
              onChanged: (value) => setState(() => peso = value),
            ),
            const SizedBox(height: 10),

            // Altura salva
            Text("Altura (configurada): ${altura.toStringAsFixed(2)} m"),
            const SizedBox(height: 10),

            // Botões Calcular e Classificação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _calcularSalvarIMC,
                  child: const Text("Calcular IMC"),
                ),
                ElevatedButton(
                  onPressed: _mostrarClassificacao,
                  child: const Text("Classificação"),
                ),
              ],
            ),

            const Divider(height: 30),
            const Text("Histórico de IMC:"),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: imcBox.listenable(),
                builder: (context, Box<IMC> box, _) {
                  if (box.isEmpty) return const Text("Nenhum registro ainda.");
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final imc = box.getAt(index)!;
                      return ListTile(
                        title:
                            Text("IMC: ${imc.calcular().toStringAsFixed(2)}"),
                        subtitle: Text(
                          "${imc.classificacao()} — ${imc.dataHora.toLocal().toString().split('.')[0]}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => imc.delete(),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
