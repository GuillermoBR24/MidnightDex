import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/raid_info.dart';
import '../services/raid_service.dart';
import '../theme/app_theme.dart';
import 'raid_detail_screen.dart';

class RaidsScreen extends StatefulWidget {
  const RaidsScreen({super.key});

  @override
  State<RaidsScreen> createState() => _RaidsScreenState();
}

class _RaidsScreenState extends State<RaidsScreen> {
  List<RaidInfo> _raids = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadRaids();
  }

  Future<void> _loadRaids() async {
    try {
      final raids = await RaidService.fetchActiveRaids();
      setState(() {
        _raids = raids;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error.isNotEmpty) return _buildError();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: const Text(
          'Raids Activas',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.accentBlue),
            onPressed: _loadRaids,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRaids,
        color: AppTheme.accentBlue,
        child: _raids.isEmpty
            ? const Center(
                child: Text(
                  'No hay raids activas',
                  style: TextStyle(color: AppTheme.textSecond, fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _raids.length,
                itemBuilder: (_, index) => _RaidCard(
                  raid: _raids[index],
                  onTap: () => _openRaidDetail(_raids[index]),
                ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1),
              ),
      ),
    );
  }

  void _openRaidDetail(RaidInfo raid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RaidDetailScreen(raid: raid),
      ),
    );
  }

  Widget _buildLoading() => Scaffold(
    backgroundColor: AppTheme.bgDark,
    appBar: AppBar(
      backgroundColor: AppTheme.bgDark,
      title: const Text('Raids Activas'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.accentBlue),
          SizedBox(height: 16),
          Text(
            'Cargando raids...',
            style: TextStyle(color: AppTheme.textSecond),
          ),
        ],
      ),
    ),
  );

  Widget _buildError() => Scaffold(
    backgroundColor: AppTheme.bgDark,
    appBar: AppBar(
      backgroundColor: AppTheme.bgDark,
      title: const Text('Raids Activas'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.textSecond, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Error al cargar raids',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecond, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadRaids,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────
// Card de raid
// ─────────────────────────────────────────────────────────
class _RaidCard extends StatelessWidget {
  final RaidInfo raid;
  final VoidCallback onTap;

  const _RaidCard({required this.raid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getRaidColor(raid.raidLevel);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            // Header: Pokémon + Timer
            Row(
              children: [
                // Imagen del Pokémon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.1),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${raid.pokemonId}.png',
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Icon(Icons.catching_pokemon, color: AppTheme.textSecond),
                    errorWidget: (_, __, ___) => const Icon(Icons.catching_pokemon, color: AppTheme.textSecond),
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        raid.pokemonName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Raid Nivel ${raid.raidLevel}',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Timer
                Column(
                  children: [
                    Icon(Icons.access_time, color: AppTheme.textSecond, size: 16),
                    const SizedBox(height: 2),
                    Text(
                      raid.timeRemaining,
                      style: const TextStyle(
                        color: AppTheme.textSecond,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Stats rápidas
            Row(
              children: [
                _QuickStat(label: 'CP', value: raid.bossStats.cp.toString()),
                const SizedBox(width: 8),
                _QuickStat(label: 'ATK', value: raid.bossStats.attack.toString()),
                const SizedBox(width: 8),
                _QuickStat(label: 'Entrenadores', value: '${raid.trainersNeeded}'),
                const Spacer(),
                Icon(Icons.star, color: AppTheme.accentBlue, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${(raid.difficulty * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRaidColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFF00B4FF);
      case 3:
        return const Color(0xFFFF6B35);
      case 5:
        return const Color(0xFF9C27B0);
      case 6:
        return const Color(0xFFFFD700);
      default:
        return AppTheme.accentBlue;
    }
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;

  const _QuickStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecond,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}