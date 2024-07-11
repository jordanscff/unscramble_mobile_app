import 'package:flutter/material.dart';

class Utils {
  static void showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('How to Play', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Start the game:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('   Press the PLAY button to begin a new game.'),
                SizedBox(height: 10),
                Text('2. Unscramble the word:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('   A scrambled 5-letter word will appear at the top of the game screen.'),
                SizedBox(height: 10),
                Text('3. Make your guess:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('   Type your 5-letter guess in the text field at the bottom of the game screen.'),
                SizedBox(height: 10),
                Text('4. Submit your guess:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('   Press the send button or hit enter to submit your guess.'),
                SizedBox(height: 10),
                Text('5. Understand the colors:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: Colors.green[300],
                      margin: EdgeInsets.only(right: 5),
                    ),
                    Expanded(child: Text('Correct letter in the right position')),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: Colors.orange[200],
                      margin: EdgeInsets.only(right: 5),
                    ),
                    Expanded(child: Text('Correct letter in the wrong position')),
                  ],
                ),
                SizedBox(height: 10),
                Text('6. Keep guessing:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('   You have multiple attempts to guess the word.'),
                SizedBox(height: 10),
                Text('7. Win or lose:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('   Guess the word within the allowed attempts to win!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Got it!', style: TextStyle(color: Colors.deepPurple)),
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