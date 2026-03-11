import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class AiService {
  // PUNE AICI CHEIA TA GROQ
  static const String _apiKey = 'CHEIA_SECRETA';

  static Future<List<Question>> genereazaTest(String textDocument, int numarIntrebari, String dificultate) async {
    
    // Sistemul trebuie să fie ultra-agresiv
    final systemPrompt = '''Ești un server API invizibil.
    Singurul tău scop este să generezi EXCLUSIV cod JSON valid. 
    Nu scrie nicio introducere, niciun rezumat, nicio concluzie. Fără "Iată testul". 
    Răspunsul tău trebuie să înceapă cu { și să se termine cu }.''';

    // Am pus TEXTUL PRIMUL, și INSTRUCȚIUNILE LA FINAL
    final userPrompt = '''
      TEXT SURSĂ:
      """
      $textDocument
      """
      
      CERINȚE:
      Bazează-te STRICT pe textul de mai sus.
      1. Generează exact $numarIntrebari întrebări tip grilă.
      2. Dificultatea să fie: $dificultate.
      3. Fiecare întrebare trebuie să aibă 4 variante (A, B, C, D) și un singur răspuns corect.
      
      FORMAT OUTPUT OBLIGATORIU:
      Trebuie să returnezi DOAR acest obiect JSON, nimic altceva:
      {
        "intrebari": [
          {
            "intrebare": "textul intrebarii",
            "variante": ["Varianta A", "Varianta B", "Varianta C", "Varianta D"],
            "raspuns_corect": "Varianta B",
            "explicatie": "Explicatia pe scurt"
          }
        ]
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "response_format": {"type": "json_object"}, 
          "messages": [
            {
              "role": "system",
              "content": systemPrompt
            },
            {
              "role": "user",
              "content": userPrompt
            }
          ],
          "temperature": 0.1 
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String rawText = data['choices'][0]['message']['content'] ?? '{}';
        
        Map<String, dynamic> jsonResponse = jsonDecode(rawText);
        List<dynamic> jsonList = jsonResponse['intrebari'];
        
        return jsonList.map((q) => Question.fromJson(q)).toList();
      } else {
        throw Exception('Eroare Groq API: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      print("Eroare la generarea AI: $e");
      throw Exception('Eroare la procesarea testului: $e');
    }
  }
}