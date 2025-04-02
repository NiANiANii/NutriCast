class QuestionnaireFeature {
  static List<Map<String, dynamic>> getQuestions() {
    return [
      {
        "number": "1.",
        "question": "Berapa jam rata-rata Anda tidur malam dalam sehari?",
        "type": "multiple_choice",
        "options": ["2-3 jam", "4-6 jam", "7-8 jam", "Tidak tidur"],
      },
      {
        "number": "2.",
        "question":
            "Aktivitas apa yang Anda lakukan dalam sehari? (Jawab dengan jujur)",
        "type": "text_long",
      },
      {
        "number": "3.",
        "question": "Seberapa lama Anda melakukan aktivitas fisik harian?",
        "type": "multiple_choice",
        "options": [
          "30 menit/hari",
          "1 jam/hari",
          "2-4 jam/hari",
          "Tidak pernah",
        ],
      },
      {
        "number": "4.",
        "question": "Seberapa sering Anda berolahraga dalam seminggu?",
        "type": "multiple_choice",
        "options": [
          "1x per minggu",
          "2-3x per minggu",
          "Lebih dari 3x per minggu",
          "Tidak pernah",
        ],
      },
      {
        "number": "5.",
        "question": "Berapa kali Anda makan dalam sehari?",
        "type": "multiple_choice",
        "options": ["1x sehari", "2x sehari", "3x sehari"],
      },
      {
        "number": "6.",
        "question":
            "Dalam seminggu, berapa kali Anda makan makanan sumber protein hewani & nabati?",
        "type": "multiple_choice",
        "options": [
          "1x per minggu",
          "2-3x per minggu",
          "Setiap hari",
          "Tidak pernah",
        ],
      },
      {
        "number": "7.",
        "question": "Seberapa sering Anda mengonsumsi sayuran dalam sehari?",
        "type": "multiple_choice",
        "options": ["Tidak pernah", "1x sehari", "2x sehari", "Lebih dari 2x"],
      },
      {
        "number": "8.",
        "question":
            "Seberapa sering Anda mengonsumsi makanan cepat saji dalam seminggu?",
        "type": "multiple_choice",
        "options": [
          "Tidak pernah",
          "1-3 kali seminggu",
          "3-5 kali seminggu",
          "Lebih dari 5x",
        ],
      },
    ];
  }
}
