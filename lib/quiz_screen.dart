import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'flashcard_model.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Flashcard> flashcards = [];
  int currentIndex = 0;
  int correctAnswers = 0;
  bool isQuizFinished = false;

  @override
  void initState() {
    super.initState();
    loadFlashcards();
  }

  void loadFlashcards() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('flashcards').get();
    setState(() {
      flashcards =
          snapshot.docs.map((doc) => Flashcard.fromDocument(doc)).toList();
    });
  }

  void submitAnswer(bool isCorrect) {
    setState(() {
      if (isCorrect) correctAnswers++;
      if (currentIndex < flashcards.length - 1) {
        currentIndex++;
      } else {
        isQuizFinished = true;
        saveScore();
      }
    });
  }

  void saveScore() async {
    await FirebaseFirestore.instance.collection('scores').add({
      'totalQuestions': flashcards.length,
      'correctAnswers': correctAnswers,
      'date': Timestamp.now(),
    });
  }

  void restartQuiz() {
    setState(() {
      currentIndex = 0;
      correctAnswers = 0;
      isQuizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcard Quiz'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isQuizFinished
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You scored $correctAnswers out of ${flashcards.length}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: restartQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlipCard(
                      front: FlashcardView(
                        text: flashcards[currentIndex].question,
                        color: Colors.blueAccent,
                      ),
                      back: FlashcardView(
                        text: flashcards[currentIndex].answer,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Score: $correctAnswers / ${flashcards.length}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AnswerButton(
                          label: "Incorrect",
                          color: Colors.redAccent,
                          onPressed: () => submitAnswer(false),
                        ),
                        AnswerButton(
                          label: "Correct",
                          color: Colors.greenAccent,
                          onPressed: () => submitAnswer(true),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class FlashcardView extends StatelessWidget {
  final String text;
  final Color color;

  FlashcardView({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: color,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  AnswerButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
