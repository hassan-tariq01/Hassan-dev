import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  home: FlashcardScreen(),
));

class Flashcard {
  final String question;
  final String answer;

  const Flashcard({required this.question, required this.answer});
}

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  static const List<Flashcard> flashcards = [
    Flashcard(question: "What is the capital of France?", answer: "Paris"),
    Flashcard(question: "What is 2 + 2?", answer: "4"),
    Flashcard(question: "What is the largest planet?", answer: "Jupiter"),
    Flashcard(question: "Who wrote 'Romeo and Juliet'?", answer: "Shakespeare"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            return FlashcardWidget(flashcard: flashcards[index]);
          },
        ),
      ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  const FlashcardWidget({super.key, required this.flashcard});

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => showAnswer = !showAnswer),
      child: Card(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                child: child,
              );
            },
            child: Text(
              showAnswer ? widget.flashcard.answer : widget.flashcard.question,
              key: ValueKey(showAnswer),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
