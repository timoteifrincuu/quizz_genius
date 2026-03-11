class Question {
  final String textIntrebare;
  final List<String> variante;
  final String raspunsCorect;
  final String explicatie;

  Question({
    required this.textIntrebare,
    required this.variante,
    required this.raspunsCorect,
    required this.explicatie,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      textIntrebare: json['intrebare'] ?? '',
      variante: List<String>.from(json['variante'] ?? []),
      raspunsCorect: json['raspuns_corect'] ?? '',
      explicatie: json['explicatie'] ?? '',
    );
  }
}