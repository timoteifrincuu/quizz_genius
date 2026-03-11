import 'dart:typed_data';
import 'dart:async'; // Am adăugat asta pentru Timer-ul animației
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/pdf_service.dart';
import '../services/ai_service.dart';
import '../models/question.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _fisierBytes;
  String? _numeFisier;
  int _numarIntrebari = 5;
  String _dificultate = 'Mediu';
  bool _seIncarca = false;

  // --- NOU: Controller pentru numele testului ---
  final TextEditingController _numeTestController = TextEditingController();

  // --- NOU: Variabile pentru animația de loading ---
  Timer? _timerLoading;
  int _indexMesajLoading = 0;
  final List<String> _mesajeLoading = [
    '🤖 AI-ul citește documentul...',
    '🧠 Analizăm informațiile esențiale...',
    '✍️ Formulăm întrebările capcană...',
    '✨ Finalizăm testul pentru tine...'
  ];

  void _pornesteAnimatieLoading() {
    _indexMesajLoading = 0;
    _timerLoading = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          // Trecem la următorul mesaj în buclă
          _indexMesajLoading = (_indexMesajLoading + 1) % _mesajeLoading.length;
        });
      }
    });
  }

  void _opresteAnimatieLoading() {
    _timerLoading?.cancel();
  }
  // ---------------------------------------------

  Future<void> _alegeFisier() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _fisierBytes = result.files.single.bytes;
        _numeFisier = result.files.single.name;
        
        // Dacă utilizatorul nu a scris un nume, punem automat numele PDF-ului în TextField
        if (_numeTestController.text.isEmpty) {
          // Eliminăm extensia ".pdf" din nume pentru a fi mai frumos
          _numeTestController.text = _numeFisier!.replaceAll('.pdf', '');
        }
      });
    }
  }

  Future<void> _genereazaTest() async {
    if (_fisierBytes == null) return;

    setState(() { 
      _seIncarca = true; 
    });
    _pornesteAnimatieLoading(); // Pornim animația!

    try {
      String text = await PdfService.extrageTextDinPdf(_fisierBytes!);
      
      if (text.isEmpty) throw Exception("Nu am putut extrage text din acest PDF.");

      List<Question> intrebari = await AiService.genereazaTest(text, _numarIntrebari, _dificultate);

      if (mounted) {
        // Stabilim numele final (dacă e gol, punem un nume generic)
        String numeFinal = _numeTestController.text.trim().isNotEmpty 
            ? _numeTestController.text.trim() 
            : 'Test fără nume';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              intrebari: intrebari, 
              numeTest: numeFinal, // Trimitem numele către QuizScreen
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _opresteAnimatieLoading(); // Oprim animația
      if (mounted) setState(() { _seIncarca = false; });
    }
  }

  @override
  void dispose() {
    _numeTestController.dispose();
    _opresteAnimatieLoading();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizGenius', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView( // Am pus scroll ca să nu dea eroare dacă ecranul e mic
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('1. Încarcă materialul (PDF)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _alegeFisier,
              icon: const Icon(Icons.upload_file),
              label: Text(_numeFisier ?? 'Selectează un fișier PDF'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            
            const SizedBox(height: 30),
            
            const Text('2. Detalii Test', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // --- NOU: Câmpul pentru numele testului ---
            TextField(
              controller: _numeTestController,
              decoration: InputDecoration(
                labelText: 'Numele Testului (ex: Istorie 1)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 20),

            Text('Număr întrebări: $_numarIntrebari', style: const TextStyle(fontSize: 16)),
            Slider(
              value: _numarIntrebari.toDouble(),
              min: 5, max: 20, divisions: 15,
              label: _numarIntrebari.toString(),
              onChanged: (val) => setState(() => _numarIntrebari = val.toInt()),
            ),
            
            const SizedBox(height: 10),
            
            const Text('Dificultate:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _dificultate,
              isExpanded: true,
              items: ['Ușor', 'Mediu', 'Greu'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
              onChanged: (val) => setState(() => _dificultate = val!),
            ),
            
            const SizedBox(height: 40),
            
            // --- NOU: Afișarea butonului SAU a animației de loading ---
            _seIncarca 
              ? Column(
                  children: [
                    const CircularProgressIndicator(color: Colors.deepPurple),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _mesajeLoading[_indexMesajLoading],
                        key: ValueKey<int>(_indexMesajLoading), // Foarte important pentru animație
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w500, 
                          color: Colors.deepPurple,
                          fontStyle: FontStyle.italic
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              : ElevatedButton(
                  onPressed: _fisierBytes == null ? null : _genereazaTest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Generează Testul AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
          ],
        ),
      ),
    );
  }
}