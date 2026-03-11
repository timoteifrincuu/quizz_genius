import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../services/pdf_export_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _istoricTeste = [];

  @override
  void initState() {
    super.initState();
    _incarcaIstoric();
  }

  Future<void> _incarcaIstoric() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? salvari = prefs.getStringList('istoric_teste');

    if (salvari != null) {
      setState(() {
        _istoricTeste = salvari.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
        _istoricTeste = _istoricTeste.reversed.toList();
      });
    }
  }

  Future<void> _stergeIstoric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('istoric_teste');
    setState(() {
      _istoricTeste = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Istoric Note 📊'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Șterge Istoricul',
            onPressed: _stergeIstoric,
          )
        ],
      ),
      body: _istoricTeste.isEmpty
          ? const Center(
              child: Text(
                'Nu ai dat niciun test încă.\nGenerează unul din meniul alăturat! 🚀',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _istoricTeste.length,
              itemBuilder: (context, index) {
                final test = _istoricTeste[index];
                final nota = test['scor'];
                final total = test['total'];
                final procent = (nota / total) * 100;

                Color culoareNota = procent >= 50 ? Colors.green : Colors.red;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: culoareNota.withOpacity(0.2),
                      radius: 30,
                      child: Text(
                        '$nota/$total',
                        style: TextStyle(color: culoareNota, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    title: Text(
                      test['fisier'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text('Data: ${test['data']}'),
                    // --- NOU: Butonul de Printare alături de iconița de check ---
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.print, color: Colors.blueAccent),
                          tooltip: 'Printează acest test',
                          onPressed: () async {
                            // Dacă testul e vechi și nu a salvat întrebările, afișăm o eroare mică
                            if (test['intrebari'] == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Acest test este dintr-o versiune veche și nu conține întrebările salvate.')),
                              );
                              return;
                            }

                            // Reconstruim lista de întrebări
                            List<dynamic> intrebariJson = test['intrebari'];
                            List<Question> intrebariReconstruite = intrebariJson.map((q) => Question(
                              textIntrebare: q['textIntrebare'],
                              variante: List<String>.from(q['variante']),
                              raspunsCorect: q['raspunsCorect'],
                              explicatie: q['explicatie'] ?? '',
                            )).toList();

                            // Apelăm funcția de export PDF
                            await PdfExportService.exporteazaTest(test['fisier'], intrebariReconstruite);
                          },
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}