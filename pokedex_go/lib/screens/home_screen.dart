import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'pokedex_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Row(
          children: [
            // Logo estilo Pokeball
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentBlue, width: 2),
              ),
              child: const Icon(
                Icons.catching_pokemon,
                color: AppTheme.accentBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.accentBlue, AppTheme.accentCyan],
              ).createShader(bounds),
              child: const Text(
                'POKÉDEX GO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: const Text(
                'PoGoAPI',
                style: TextStyle(
                  color: AppTheme.accentCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: AppTheme.accentCyan.withOpacity(0.1),
              side: BorderSide(
                color: AppTheme.accentCyan.withOpacity(0.4)),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: const PokedexScreen(),
    );
  }
}