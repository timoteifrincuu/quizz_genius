import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart'; // <--- AM IMPORTAT MAIN.DART PENTRU TELECOMANDĂ

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalTeste = 0;
  int _rataSucces = 0;

  @override
  void initState() {
    super.initState();
    _incarcaStatistici();
  }

  Future<void> _incarcaStatistici() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? salvari = prefs.getStringList('istoric_teste');

    if (salvari != null && salvari.isNotEmpty) {
      int sumaNotelor = 0;
      int sumaTotala = 0;

      for (var item in salvari) {
        final test = jsonDecode(item);
        sumaNotelor += (test['scor'] as int);
        sumaTotala += (test['total'] as int);
      }

      setState(() {
        _totalTeste = salvari.length;
        if (sumaTotala > 0) {
          _rataSucces = ((sumaNotelor / sumaTotala) * 100).round();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilul Meu 👤', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Utilizator QuizGenius',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Student de nota 10! 🚀',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Teste Generate', _totalTeste.toString(), Icons.library_books, context),
                _buildStatCard('Rata de Succes', '$_rataSucces%', Icons.analytics, context),
              ],
            ),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),

            // --- AICI AM CONECTAT BUTONUL ---
            ListTile(
              leading: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny, 
                            color: isDarkMode ? Colors.yellow : Colors.orange),
              title: const Text('Mod Întunecat (Dark Mode)', style: TextStyle(fontSize: 18)),
              trailing: Switch(
                value: isDarkMode,
                activeColor: Colors.deepPurple,
                onChanged: (val) {
                  // Apăsăm pe telecomandă!
                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String titlu, String valoare, IconData icon, BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: isDarkMode ? Colors.purpleAccent : Colors.deepPurple),
          const SizedBox(height: 10),
          Text(valoare, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(titlu, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}