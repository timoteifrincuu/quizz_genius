import 'package:flutter/material.dart';
import '../models/question.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pdf_export_service.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> intrebari;
  final String numeTest;

  const QuizScreen({super.key, required this.intrebari, required this.numeTest});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _indexCurent = 0;
  int _scor = 0;
  bool _intrebareRaspunsa = false;
  String _raspunsSelectat = '';

  void _verificaRaspunsul(String raspuns) {
    if (_intrebareRaspunsa) return;

    setState(() {
      _intrebareRaspunsa = true;
      _raspunsSelectat = raspuns;
      if (raspuns == widget.intrebari[_indexCurent].raspunsCorect) {
        _scor++;
      }
    });
  }

  void _urmatoareaIntrebare() {
    if (_indexCurent < widget.intrebari.length - 1) {
      setState(() {
        _indexCurent++;
        _intrebareRaspunsa = false;
        _raspunsSelectat = '';
      });
    } else {
      _salveazaRezultat();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Test Finalizat! 🎉', textAlign: TextAlign.center),
          content: Text(
            'Ai obținut $_scor din ${widget.intrebari.length} puncte.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  Navigator.of(context).pop(); 
                },
                child: const Text('Înapoi la meniu'),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _salveazaRezultat() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> istoric = prefs.getStringList('istoric_teste') ?? [];

    // NOU: Acum salvăm absolut toate datele întrebărilor!
    final testNou = {
      'fisier': widget.numeTest, 
      'scor': _scor,
      'total': widget.intrebari.length,
      'data': DateTime.now().toString().substring(0, 16), 
      'intrebari': widget.intrebari.map((q) => {
        'textIntrebare': q.textIntrebare,
        'variante': q.variante,
        'raspunsCorect': q.raspunsCorect,
        'explicatie': q.explicatie,
      }).toList(),
    };

    istoric.add(jsonEncode(testNou));
    await prefs.setStringList('istoric_teste', istoric); 
  }

  @override
  Widget build(BuildContext context) {
    final intrebare = widget.intrebari[_indexCurent];

    return Scaffold(
      appBar: AppBar(
        title: Text('Întrebarea ${_indexCurent + 1} / ${widget.intrebari.length}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Descarcă PDF',
            onPressed: () async {
              await PdfExportService.exporteazaTest(widget.numeTest, widget.intrebari);
            },
          ),
          const SizedBox(width: 8), 
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              intrebare.textIntrebare,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            ...intrebare.variante.map((varianta) {
              Color culoareButon = Colors.grey.shade200; 
              Color culoareText = Colors.black;

              if (_intrebareRaspunsa) {
                if (varianta == intrebare.raspunsCorect) {
                  culoareButon = Colors.green; 
                  culoareText = Colors.white;
                } else if (varianta == _raspunsSelectat) {
                  culoareButon = Colors.red; 
                  culoareText = Colors.white;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () => _verificaRaspunsul(varianta),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: culoareButon,
                    foregroundColor: culoareText,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(varianta, style: const TextStyle(fontSize: 16)),
                ),
              );
            }).toList(), 

            const SizedBox(height: 20),
            
            if (_intrebareRaspunsa)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Text(
                  '💡 Explicație: ${intrebare.explicatie}',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            
            const Spacer(),
            
            if (_intrebareRaspunsa)
              ElevatedButton(
                onPressed: _urmatoareaIntrebare,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _indexCurent == widget.intrebari.length - 1 ? 'Vezi Rezultatul' : 'Următoarea întrebare',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}