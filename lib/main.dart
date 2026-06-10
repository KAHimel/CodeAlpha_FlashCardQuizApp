import 'package:flutter/material.dart';

void main() {
  runApp(const FlashCardQuizApp());
}

class FlashCardQuizApp extends StatelessWidget {
  const FlashCardQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlashCard Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const FlashCardHomePage(),
    );
  }
}

class FlashCard {
  String question;
  String answer;

  FlashCard({required this.question, required this.answer});
}

class FlashCardHomePage extends StatefulWidget {
  const FlashCardHomePage({super.key});

  @override
  State<FlashCardHomePage> createState() => _FlashCardHomePageState();
}

class _FlashCardHomePageState extends State<FlashCardHomePage> {
  final List<FlashCard> _cards = [
    FlashCard(question: 'What is the capital of France?', answer: 'Paris'),
    FlashCard(
      question: 'What is the largest planet in our solar system?',
      answer: 'Jupiter',
    ),
    FlashCard(
      question: 'What is the process by which plants make food?',
      answer: 'Photosynthesis',
    ),
  ];

  int _currentIndex = 0;
  bool _showAnswer = false;

  void _showNextCard() {
    if (_cards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _cards.length;
      _showAnswer = false;
    });
  }

  void _showPreviousCard() {
    if (_cards.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
      _showAnswer = false;
    });
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  Future<void> _showCardEditor({FlashCard? card, int? index}) async {
    final questionController = TextEditingController(
      text: card?.question ?? '',
    );
    final answerController = TextEditingController(text: card?.answer ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(card == null ? 'Add Flashcard' : 'Edit Flashcard'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a question';
                    }
                    return null;
                  },
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: answerController,
                  decoration: const InputDecoration(
                    labelText: 'Answer',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter an answer';
                    }
                    return null;
                  },
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final newQuestion = questionController.text.trim();
                final newAnswer = answerController.text.trim();
                setState(() {
                  if (card == null) {
                    _cards.add(
                      FlashCard(question: newQuestion, answer: newAnswer),
                    );
                    _currentIndex = _cards.length - 1;
                    _showAnswer = false;
                  } else {
                    _cards[index!] = FlashCard(
                      question: newQuestion,
                      answer: newAnswer,
                    );
                    _showAnswer = false;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Flashcard'),
          content: const Text(
            'Are you sure you want to delete this flashcard?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _cards.removeAt(index);
        if (_cards.isEmpty) {
          _currentIndex = 0;
          _showAnswer = false;
        } else if (_currentIndex >= _cards.length) {
          _currentIndex = _cards.length - 1;
          _showAnswer = false;
        }
      });
    }
  }

  void _openCardManager() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Manage Flashcards',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showCardEditor();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              if (_cards.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No flashcards yet. Tap Add to create one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _cards.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return ListTile(
                        title: Text(card.question),
                        subtitle: Text(card.answer),
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _showCardEditor(card: card, index: index);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _confirmDelete(index);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _currentIndex = index;
                            _showAnswer = false;
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _cards.isNotEmpty ? _cards[_currentIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashCard Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Manage cards',
            onPressed: _openCardManager,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Card ${_cards.isEmpty ? 0 : _currentIndex + 1} of ${_cards.length}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: currentCard == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.outbox,
                            size: 68,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No flashcards available yet.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _openCardManager,
                            icon: const Icon(Icons.add),
                            label: const Text('Create your first card'),
                          ),
                        ],
                      ),
                    )
                  : Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentCard.question,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Text(
                                currentCard.answer,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.indigo,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              crossFadeState: _showAnswer
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _toggleAnswer,
                              icon: Icon(
                                _showAnswer
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              label: Text(
                                _showAnswer ? 'Hide Answer' : 'Show Answer',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _cards.isEmpty ? null : _showPreviousCard,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _cards.isEmpty ? null : _showNextCard,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
