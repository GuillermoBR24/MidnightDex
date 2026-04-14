import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'pokedex_screen.dart';
import 'tier_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    PokedexScreen(),
    TierScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentBlue, width: 2),
              ),
              child: const Icon(Icons.catching_pokemon,
                  color: AppTheme.accentBlue, size: 18),
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
              label: Text(
                _currentIndex == 0 ? 'PoGoAPI' : 'TIER LIST',
                style: TextStyle(
                  color: _currentIndex == 0
                      ? AppTheme.accentCyan
                      : const Color(0xFFFFD700),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: _currentIndex == 0
                  ? AppTheme.accentCyan.withOpacity(0.1)
                  : const Color(0xFFFFD700).withOpacity(0.1),
              side: BorderSide(
                color: _currentIndex == 0
                    ? AppTheme.accentCyan.withOpacity(0.4)
                    : const Color(0xFFFFD700).withOpacity(0.4),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          border: Border(
            top: BorderSide(color: AppTheme.borderColor, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.accentBlue,
          unselectedItemColor: AppTheme.textSecond,
          selectedLabelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.catching_pokemon),
              label: 'Pokédex',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.military_tech),
              label: 'Tier List',
            ),
          ],
        ),
      ),
    );
  }
}