import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils.dart';
import 'custom_back_button.dart';

enum GameDifficulty { easy, normal, hard, daily }

class GameScreen extends StatefulWidget {
  final GameDifficulty difficulty;

  GameScreen({required this.difficulty});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Future<List<String>> wordsFuture;
  String? targetWord;
  String? scrambledWord;
  List<String>? guesses;
  String currentGuess = '';
  int currentRow = 0;
  late int maxAttempts;
  bool isDaily = false;
  bool dailyCompleted = false;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.difficulty == GameDifficulty.daily) {
      _clearStoredDailyWord();
    }
    _setDifficultyParameters();
    wordsFuture = _loadWords();
    _checkDailyCompletion();
  }

  Future<void> _clearStoredDailyWord() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('daily_word');
    await prefs.remove('daily_word_date');
  }

  void _setDifficultyParameters() {
    isDaily = widget.difficulty == GameDifficulty.daily;
    switch (widget.difficulty) {
      case GameDifficulty.easy:
        maxAttempts = 6;
        break;
      case GameDifficulty.normal:
        maxAttempts = 4;
        break;
      case GameDifficulty.hard:
        maxAttempts = 3;
        break;
      case GameDifficulty.daily:
        maxAttempts = 4;
        break;
    }
    print("Difficulty set: ${widget.difficulty}, isDaily: $isDaily");
  }

  Future<void> _checkDailyCompletion() async {
    if (isDaily) {
      final prefs = await SharedPreferences.getInstance();
      final String today = DateFormat('yyyyMMdd').format(DateTime.now());
      dailyCompleted = prefs.getBool('daily_completed_$today') ?? false;
    }
  }

  Future<List<String>> _loadWords() async {
    print("Loading words. isDaily: $isDaily");
    if (isDaily) {
      print("Attempting to load daily word");
      final dailyWord = await getDailyWord();
      print("Daily word loaded: $dailyWord");
      return [dailyWord];
    }
    print("Loading words from 5_words.txt");
    String content = await rootBundle.loadString('assets/5_words.txt');
    List<String> words = content.split('\n').map((word) => word.trim().toUpperCase()).toList();
    print("Loaded ${words.length} words from 5_words.txt");
    return words;
  }


  Future<String?> getMostRecentWord() async {
    final String csvContent = await rootBundle.loadString('assets/daily_word.csv');
    final List<String> lines = csvContent.split('\n').reversed.toList();

    for (String line in lines) {
      final List<String> parts = line.split(',');
      if (parts.length == 2) {
        return parts[1].trim().toUpperCase();
      }
    }

    return null;
  }

  Future<String> getDailyWord() async {
    try {
      final String csvContent = await rootBundle.loadString('assets/daily_word.csv');
      final List<String> lines = csvContent.split('\n');

      final DateTime now = DateTime.now();
      final String today = DateFormat('ddMMyy').format(now);
      print('Today\'s date: $today');

      for (String line in lines) {
        final List<String> parts = line.split(',');
        if (parts.length == 2) {
          String date = parts[0].trim();
          String word = parts[1].trim().toUpperCase();
          print('Checking date: $date, word: $word');
          if (date == today) {
            print('Match found! Word for today: $word');
            return word;
          }
        }
      }

      print('No word found for today');
      throw Exception('No word found for today');
    } catch (e) {
      print("Error in getDailyWord: $e");
      rethrow;
    }
  }

  void _initializeGameState(List<String> words) {
    if (isDaily) {
      targetWord = words[0];
    } else {
      targetWord = words[Random().nextInt(words.length)];
    }
    print('Selected word: $targetWord');
    scrambledWord = _scrambleWord(targetWord!);
    print('Scrambled word: $scrambledWord');
    guesses = List.filled(maxAttempts, '');
    currentGuess = '';
    currentRow = 0;
  }

  void _focusTextField() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  String _scrambleWord(String word) {
    List<String> characters = word.split('');
    String original = word;
    String scrambled;
    int attempts = 0;
    do {
      characters.shuffle(Random());
      scrambled = characters.join('');
      attempts++;
      if (attempts > 100) {
        // If we can't scramble after 100 attempts, just reverse the word
        scrambled = word.split('').reversed.join('');
        break;
      }
    } while (scrambled == original);
    print('Original: $original, Scrambled: $scrambled, Attempts: $attempts');
    return scrambled;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void onSubmit() {
    if (currentGuess.length == 5 && targetWord != null && guesses != null) {
      setState(() {
        guesses![currentRow] = currentGuess;
      });
      if (currentGuess == targetWord) {
        showGameOverDialog(true);
      } else if (currentRow == maxAttempts - 1) {
        showGameOverDialog(false);
      } else {
        setState(() {
          currentRow++;
          currentGuess = '';
          _controller.clear();
        });
        if (currentRow > 1) {
          _scrollToCurrentRow();
        }
      }
    }
    _controller.clear();
    setState(() {
      currentGuess = '';
    });
  }

  void _scrollToCurrentRow() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        ((currentRow - 1) * (MediaQuery.of(context).size.width / 5 + 8)).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void showGameOverDialog(bool won) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple[100],
          title: Text(
            won ? 'Congratulations!' : 'Game Over',
            style: TextStyle(color: Colors.deepPurple[800], fontWeight: FontWeight.bold),
          ),
          content: Text(
            won ? 'You unscrambled the word!' : 'The word was $targetWord',
            style: TextStyle(color: Colors.deepPurple[700]),
          ),
          actions: <Widget>[
            if (!isDaily)
              TextButton(
                child: Text('Play Again', style: TextStyle(color: Colors.deepPurple)),
                onPressed: () {
                  Navigator.of(context).pop();
                  startNewGame();
                },
              ),
            TextButton(
              child: Text('Home', style: TextStyle(color: Colors.deepPurple)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    if (isDaily && won) {
      _markDailyAsCompleted();
    }
  }

  Future<void> _markDailyAsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyyMMdd').format(DateTime.now());
    await prefs.setBool('daily_completed_$today', true);
    await prefs.setStringList('daily_guesses_$today', guesses!);
    setState(() {
      dailyCompleted = true;
    });
  }

  void startNewGame() {
    setState(() {
      wordsFuture = _loadWords();
      targetWord = null;
      scrambledWord = null;
      guesses = null;
      currentGuess = '';
      currentRow = 0;
    });
    _controller.clear();
    FocusScope.of(context).requestFocus(_focusNode);
    _scrollToTop();
  }

  Color getLetterColor(int row, int col) {
    if (targetWord == null || guesses == null || row >= currentRow) return Colors.white;
    if (guesses![row][col] == targetWord![col]) {
      return Colors.green[300]!;
    } else if (targetWord!.contains(guesses![row][col])) {
      return Colors.orange[200]!;
    }
    return Colors.grey[300]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!isDaily)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: startNewGame,
              tooltip: 'New Game',
            ),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => Utils.showHowToPlayDialog(context),
            tooltip: 'How to Play',
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No words available'));
          } else {
            if (targetWord == null) {
              _initializeGameState(snapshot.data!);
            }
            return isDaily && dailyCompleted
                ? _buildCompletedDailyView()
                : _buildGameView();
          }
        },
      ),
    );
  }

  Widget _buildCompletedDailyView() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background_2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Daily Challenge Completed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Come back tomorrow for a new word!',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  child: Text('View Your Attempt'),
                  onPressed: () {
                    _showPreviousAttempt();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showPreviousAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyyMMdd').format(DateTime.now());
    final List<String>? previousGuesses = prefs.getStringList('daily_guesses_$today');

    if (previousGuesses != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Your Daily Challenge Attempt'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: previousGuesses
                  .where((guess) => guess.isNotEmpty)
                  .map((guess) => Text(guess))
                  .toList(),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildGameView() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background_2.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  scrambledWord ?? '',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 2.0, color: Colors.black, offset: Offset(1, 1))],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: maxAttempts * 5,
                  itemBuilder: (context, index) {
                    int row = index ~/ 5;
                    int col = index % 5;
                    return GestureDetector(
                      onTap: _focusTextField,
                      child: Container(
                        decoration: BoxDecoration(
                          color: getLetterColor(row, col),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            guesses != null && row < guesses!.length && col < guesses![row].length
                                ? guesses![row][col]
                                : '',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.deepPurple[800]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 5,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  autocorrect: false,
                  onChanged: (text) {
                    setState(() {
                      currentGuess = text.toUpperCase();
                      if (currentGuess.length <= 5 && guesses != null) {
                        guesses![currentRow] = currentGuess.padRight(5);
                      }
                    });
                  },
                  onSubmitted: (_) => onSubmit(),
                  decoration: InputDecoration(
                    hintText: 'Enter your guess',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.deepPurple[400],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: onSubmit,
                    ),
                    counterStyle: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
