import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/raid_info.dart';
import '../theme/app_theme.dart';

class RaidDetailScreen extends StatelessWidget {
  final RaidInfo raid;

  const RaidDetailScreen({super.key, required this.raid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Text(
          raid.pokemonName,
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pokémon Boss
            _buildBossSection(),
            const SizedBox(height: 20),
            // Debilidades
            _buildWeaknessesSection(),
            const SizedBox(height: 20),
            // Top Counters
            _buildCountersSection(),
            const SizedBox(height: 20),
            // Estimador
            _buildEstimatorSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBossSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Imagen grande
          CachedNetworkImage(
            // DESPUÉS — usa la imagen real de la API (correcta también para Mega/Shadow raids)
            imageUrl: raid.imageUrl ??
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${raid.pokemonId}.png',
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BossStat(label: 'CP', value: raid.bossStats.cp.toString()),
              _BossStat(label: 'ATK', value: raid.bossStats.attack.toString()),
              _BossStat(label: 'DEF', value: raid.bossStats.defense.toString()),
              _BossStat(label: 'STA', value: raid.bossStats.stamina.toString()),
            ],
          ),
          const SizedBox(height: 12),
          // CP de captura
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.catching_pokemon, color: AppTheme.accentBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Caught CP: ${raid.bossStats.caughtCpMin} - ${raid.bossStats.caughtCpMax}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeaknessesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Debilidades',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...raid.weaknesses.map((weakness) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: weakness.multiplier >= 2.0 
                  ? Colors.red.withOpacity(0.5) 
                  : Colors.orange.withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: weakness.multiplier >= 2.0 
                      ? Colors.red.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${weakness.multiplier}x',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: weakness.multiplier >= 2.0 ? Colors.red : Colors.orange,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  weakness.type,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Icono de tipo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.getTypeColor(weakness.type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(weakness.type),
                  color: AppTheme.getTypeColor(weakness.type),
                  size: 24,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCountersSection() {
    if (raid.topCounters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Consulta las debilidades de arriba para elegir tus mejores atacantes.',
          style: TextStyle(color: AppTheme.textSecond),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top 10 Counters',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...raid.topCounters.map((counter) => _CounterCard(counter: counter)),
      ],
    );
  }

  Widget _buildEstimatorSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentBlue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Estimador de Pokebattler',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Vencer a ${raid.pokemonName} debería llevar ${raid.trainersNeeded} entrenador${raid.trainersNeeded > 1 ? 'es' : ''} con Pokémon de esta fuerza.',
            style: const TextStyle(color: AppTheme.textSecond),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            raid.difficulty < 0.5 
                ? 'Será una pelea fácil'
                : raid.difficulty < 0.8
                    ? 'Será una pelea difícil'
                    : 'Necesitarás un equipo muy fuerte',
            style: TextStyle(
              color: raid.difficulty < 0.5 
                  ? Colors.green
                  : raid.difficulty < 0.8
                      ? Colors.orange
                      : Colors.red,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'agua':
        return Icons.water_drop;
      case 'tierra':
        return Icons.terrain;
      case 'fuego':
        return Icons.local_fire_department;
      case 'planta':
        return Icons.eco;
      case 'eléctrico':
        return Icons.bolt;
      default:
        return Icons.star;
    }
  }
}

class _BossStat extends StatelessWidget {
  final String label;
  final String value;

  const _BossStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecond,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CounterCard extends StatelessWidget {
  final RaidCounter counter;

  const _CounterCard({required this.counter});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: counter.rank <= 3 
              ? AppTheme.accentBlue.withOpacity(0.5)
              : AppTheme.borderColor,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Rank
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: counter.rank <= 3 
                      ? AppTheme.accentBlue.withOpacity(0.2)
                      : AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '#${counter.rank}',
                    style: TextStyle(
                      color: counter.rank <= 3 
                          ? AppTheme.accentBlue
                          : AppTheme.textSecond,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Pokémon info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          counter.pokemonName,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (counter.isShadow)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C4DFF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Shadow',
                              style: TextStyle(
                                color: Color(0xFF7C4DFF),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        if (counter.isMega)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Mega',
                              style: TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${counter.fastMove} · ${counter.chargedMove}',
                      style: const TextStyle(
                        color: AppTheme.textSecond,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Estimator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  counter.estimator.toStringAsFixed(2),
                  style: const TextStyle(
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Stats
          Row(
            children: [
              _MiniStat(label: 'PC', value: counter.pc.toString()),
              const SizedBox(width: 8),
              _MiniStat(label: 'ATK', value: counter.atk.toString()),
              const SizedBox(width: 8),
              _MiniStat(label: 'DEF', value: counter.def.toString()),
              const SizedBox(width: 8),
              _MiniStat(label: 'DPS', value: counter.dps.toStringAsFixed(1)),
              const Spacer(),
              Text(
                'Nvl ${counter.level}',
                style: const TextStyle(
                  color: AppTheme.textSecond,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecond,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}