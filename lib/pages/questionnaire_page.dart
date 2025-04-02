import 'package:flutter/material.dart';
import '../features/questionnaire_feature.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({super.key});

  @override
  _QuestionnairePageState createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final List<Map<String, dynamic>> questions =
      QuestionnaireFeature.getQuestions();
  final Map<int, dynamic> answers = {}; // Menyimpan jawaban

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kuesioner Kesehatan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menampilkan nomor pertanyaan di depan teks pertanyaan
                  Text(
                    "${question["number"]} ${question["question"]}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Jika tipe pertanyaan adalah number (input angka)
                  if (question["type"] == "number") ...[
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          answers[index] = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Masukkan angka",
                      ),
                    ),
                  ]
                  // Jika tipe pertanyaan adalah multiple choice (radio button)
                  else if (question["type"] == "multiple_choice") ...[
                    Column(
                      children:
                          (question["options"] as List<String>).map((option) {
                            return RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: answers[index],
                              onChanged: (value) {
                                setState(() {
                                  answers[index] = value;
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ]
                  // Jika tipe pertanyaan adalah text_long (paragraf panjang)
                  else if (question["type"] == "text_long") ...[
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Tulis jawaban Anda di sini...",
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          answers[index] = value;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitAnswers,
        child: const Icon(Icons.check),
      ),
    );
  }

  void _submitAnswers() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Jawaban Anda"),
            content: SingleChildScrollView(child: Text(answers.toString())),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }
}
