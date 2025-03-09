import 'package:flutter/material.dart';

void main() => runApp(const FlashcardApp());

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FlashcardScreen(),
    );
  }
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({Key? key}) : super(key: key);

  static List<List<Flashcard>> decks = [
    [
      Flashcard(question: "What is the capital of France?", answer: "Paris"),
      Flashcard(question: "What is 2 + 2?", answer: "4"),
      Flashcard(question: "What is the largest planet?", answer: "Jupiter"),
      Flashcard(question: "Who wrote 'Romeo and Juliet'?", answer: "Shakespeare"),
    ],
    [
      Flashcard(question: "What is Flutter?", answer: "A UI toolkit for building apps."),
      Flashcard(question: "What is Dart?", answer: "A client-optimized language."),
    ],
  ];

  static List<Flashcard> userCreatedFlashcards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(title: const Text('Flashcards')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: decks.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeckScreen(deck: decks[index], title: 'Deck ${index + 1}')),
              );
            },
            child: Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Deck ${index + 1}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateFlashcardScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class DeckScreen extends StatefulWidget {
  final List<Flashcard> deck;
  final String title;

  const DeckScreen({Key? key, required this.deck, required this.title}) : super(key: key);

  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  int score = 0;

  void updateScore(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        score++;
      }
    });
  }

  void showScoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Score'),
          content: Text('Your score: $score'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.score),
            onPressed: showScoreDialog,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: widget.deck.length,
        itemBuilder: (context, index) {
          return FlashcardWidget(flashcard: widget.deck[index], onAnswered: updateScore);
        },
      ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final Function(bool) onAnswered;

  const FlashcardWidget({Key? key, required this.flashcard, required this.onAnswered}) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => showAnswer = !showAnswer),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  showAnswer ? widget.flashcard.answer : widget.flashcard.question,
                  key: ValueKey(showAnswer),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          if (showAnswer) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onAnswered(true);
                    setState(() => showAnswer = false);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('Correct'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onAnswered(false);
                    setState(() => showAnswer = false);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('Incorrect'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class CreateFlashcardScreen extends StatelessWidget {
  const CreateFlashcardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController questionController = TextEditingController();
    final TextEditingController answerController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(title: const Text('Create Flashcard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Answer', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                  FlashcardScreen.userCreatedFlashcards.add(
                    Flashcard(
                      question: questionController.text,
                      answer: answerController.text,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('Create Flashcard'),
            ),
          ],
        ),
      ),
    );
  }
}