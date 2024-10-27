import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  final String id;
  final String question;
  final String answer;

  Flashcard({required this.id, required this.question, required this.answer});

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  factory Flashcard.fromDocument(DocumentSnapshot doc) {
    return Flashcard(
      id: doc.id,
      question: doc['question'],
      answer: doc['answer'],
    );
  }
}
