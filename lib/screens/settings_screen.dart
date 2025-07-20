import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final alturaController = TextEditingController();
  late Box configBox;

  @override
  void initState() {
    super.initState();
    configBox = Hive.box('configBox');
    _carregarAltura();
  }

  void _carregarAltura() {
    final alturaSalva = configBox.get('altura', defaultValue: 1.70);
    alturaController.text = alturaSalva.toString().replaceAll('.', ',');
  }

  void _salvarAltura() {
    final entrada = alturaController.text.trim().replaceAll(',', '.');
    final altura = double.tryParse(entrada);

    if (altura == null || altura <= 0 || altura > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Altura inválida. Use um valor entre 0 e 3 metros.")),
      );
      return;
    }

    configBox.put('altura', altura);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Altura salva com sucesso!")),
    );

    // Volta para a tela anterior após salvar
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    alturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configurações")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Altura padrão (em metros):",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: alturaController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ex: 1,75",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _salvarAltura,
              icon: const Icon(Icons.save),
              label: const Text("Salvar Altura"),
            ),
          ],
        ),
      ),
    );
  }
}
