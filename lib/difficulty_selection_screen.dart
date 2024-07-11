import 'package:flutter/material.dart';
import 'dart:ui';
import 'game_screen.dart';
import 'custom_back_button.dart';
import 'fade_page.dart';

class DifficultySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background_2.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: CustomBackButton(),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 100.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDifficultyButton(context, 'EASY', GameDifficulty.easy),
                          SizedBox(height: 20),
                          _buildDifficultyButton(context, 'REGULAR', GameDifficulty.normal),
                          SizedBox(height: 20),
                          _buildDifficultyButton(context, 'HARD', GameDifficulty.hard),
                          SizedBox(height: 20),
                          _buildDifficultyButton(context, 'DAILY WORD', GameDifficulty.daily, isDailyChallenge: true),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String text, GameDifficulty difficulty, {bool isDailyChallenge = false}) {
    final gradientColors = isDailyChallenge
        ? [Color(0xFFafadb1), Color(0xFFab20fd), Color(0xFFafadb1)]
        : [Color(0xFFFFD700), Color(0xFFFFA500)];

    return Container(
      width: 310,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            FadePageRoute(page: GameScreen(difficulty: difficulty)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}