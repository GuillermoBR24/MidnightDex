import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/pokemon.dart';
import '../theme/app_theme.dart';
import '../widgets/type_badge.dart';
import '../widgets/stat_bar.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return pokemon.isReleased ? _ReleasedView(pokemon: pokemon) : _UnreleasedView(pokemon: pokemon);
  }
}

// ──────────────────────────────────────────────
// Vista cuando el Pokémon NO está en el juego
// ──────────────────────────────────────────────
class _UnreleasedView extends StatelessWidget {
  final Pokemon pokemon;
  const _UnreleasedView({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('#${pokemon.paddedId} ${pokemon.name}',
            style: const TextStyle(color: Color(0xFF4A4A65))),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen bloqueada
            Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      0.2, 0,
                  ]),
                  child: Image.network(pokemon.imageUrl, height: 160, fit: BoxFit.contain),
                ),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.bgDark.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D18).withOpacity(0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF2D2D45), width: 2),
                  ),
                  child: const Icon(Icons.lock, color: Color(0xFF4A4A65), size: 36),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 28),
            // Nombre
            Text(
              pokemon.name,
              style: const TextStyle(
                color: Color(0xFF3A3A55),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '#${pokemon.paddedId}',
              style: const TextStyle(color: Color(0xFF2D2D45), fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Caja de "no disponible"
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E1E30), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.catching_pokemon,
                        color: Color(0xFF3A3A55), size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no disponible en\nPokémon GO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5A5A78),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este Pokémon todavía no ha sido\nintroducido en el juego.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF3A3A50),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (pokemon.generation != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFF2A2A40), width: 1),
                      ),
                      child: Text(
                        pokemon.generation!,
                        style: const TextStyle(
                          color: Color(0xFF4A4A65),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Vista cuando el Pokémon SÍ está en el juego
// ──────────────────────────────────────────────
class _ReleasedView extends StatelessWidget {
  final Pokemon pokemon;
  const _ReleasedView({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final primary = pokemon.types.isNotEmpty
        ? AppTheme.getTypeColor(pokemon.types.first)
        : AppTheme.accentBlue;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // ─── AppBar ───
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: Alignment.center,
                children: [
                  // Anillo decorativo
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withOpacity(0.07),
                      border: Border.all(
                          color: primary.withOpacity(0.15), width: 2),
                    ),
                  ),
                  CachedNetworkImage(
                    imageUrl: pokemon.imageUrl,
                    height: 210,
                    fit: BoxFit.contain,
                  ).animate().fadeIn(duration: 500.ms).scale(
                      begin: const Offset(0.8, 0.8)),
                  // Badges de rareza sobre la imagen
                  if (pokemon.isLegendary || pokemon.isMythic)
                    Positioned(
                      bottom: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: pokemon.isMythic
                              ? const Color(0xFF2D1A3E)
                              : const Color(0xFF1A2A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: pokemon.isMythic
                                ? const Color(0xFFA855F7)
                                : const Color(0xFFFFD700),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pokemon.isMythic
                                  ? Icons.auto_awesome
                                  : Icons.star,
                              color: pokemon.isMythic
                                  ? const Color(0xFFA855F7)
                                  : const Color(0xFFFFD700),
                              size: 12,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              pokemon.isMythic ? 'Mythic' : 'Legendary',
                              style: TextStyle(
                                color: pokemon.isMythic
                                    ? const Color(0xFFA855F7)
                                    : const Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Contenido ───
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Nombre y número
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pokemon.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '#${pokemon.paddedId}',
                          style: TextStyle(
                            color: primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Generación
                    if (pokemon.generation != null)
                      Text(
                        pokemon.generation!,
                        style: const TextStyle(
                          color: AppTheme.textSecond,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    const SizedBox(height: 12),

                    // Tipos
                    Wrap(
                      spacing: 8,
                      children: pokemon.types
                          .map((t) => TypeBadge(type: t))
                          .toList(),
                    ),
                    const SizedBox(height: 16),

                    // Badges de características
                    _BadgesRow(pokemon: pokemon),
                    const SizedBox(height: 24),

                    // ── Sección: Dimensiones físicas ──
                    if (pokemon.pokedexHeightM != null) ...[
                      _SectionTitle(title: 'Dimensiones'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.height,
                              label: 'Altura',
                              value:
                                  '${pokemon.pokedexHeightM!.toStringAsFixed(1)} m',
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.monitor_weight_outlined,
                              label: 'Peso',
                              value:
                                  '${pokemon.pokedexWeightKg!.toStringAsFixed(1)} kg',
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Sección: Combat Power ──
                    if (pokemon.maxCp != null) ...[
                      _SectionTitle(title: 'Combat Power'),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: primary.withOpacity(0.35), width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt, color: primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Max CP ${pokemon.maxCp}',
                              style: TextStyle(
                                color: primary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Sección: Stats base ──
                    if (pokemon.baseAttack != null) ...[
                      _SectionTitle(title: 'Stats base'),
                      const SizedBox(height: 10),
                      StatBar(
                        label: 'Ataque',
                        value: pokemon.baseAttack!,
                        maxValue: 350,
                        color: const Color(0xFFFF6B35),
                      ),
                      StatBar(
                        label: 'Defensa',
                        value: pokemon.baseDefense!,
                        maxValue: 350,
                        color: const Color(0xFF2196F3),
                      ),
                      StatBar(
                        label: 'Stamina',
                        value: pokemon.baseStamina!,
                        maxValue: 500,
                        color: const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Sección: Info de juego ──
                    _SectionTitle(title: 'Información de juego'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (pokemon.buddyDistanceKm != null)
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.directions_walk,
                              label: 'Buddy km',
                              value: '${pokemon.buddyDistanceKm} km',
                              color: const Color(0xFF00B4FF),
                            ),
                          ),
                        if (pokemon.buddyDistanceKm != null &&
                            pokemon.candyToEvolve != null)
                          const SizedBox(width: 12),
                        if (pokemon.candyToEvolve != null)
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.fiber_manual_record,
                              label: 'Candy evolución',
                              value: '${pokemon.candyToEvolve}',
                              color: const Color(0xFFFF69B4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (pokemon.raidLevel != null)
                      _InfoTile(
                        icon: Icons.shield,
                        label: 'Nivel de Raid',
                        value: 'Tier ${pokemon.raidLevel}',
                        color: const Color(0xFFFFD700),
                        full: true,
                      ),
                    const SizedBox(height: 20),

                    // ── Sección: Movimientos ──
                    if (pokemon.fastMoves.isNotEmpty ||
                        pokemon.chargedMoves.isNotEmpty) ...[
                      _SectionTitle(title: 'Movimientos'),
                      const SizedBox(height: 10),

                      if (pokemon.fastMoves.isNotEmpty) ...[
                        const Text(
                          'RÁPIDOS',
                          style: TextStyle(
                            color: AppTheme.textSecond,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...pokemon.fastMoves
                                .map((m) => _MoveBadge(
                                    name: m, color: const Color(0xFF00B4FF))),
                            ...pokemon.eliteFastMoves
                                .map((m) => _MoveBadge(
                                    name: m,
                                    color: const Color(0xFFFFD700),
                                    elite: true)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (pokemon.chargedMoves.isNotEmpty) ...[
                        const Text(
                          'CARGADOS',
                          style: TextStyle(
                            color: AppTheme.textSecond,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ...pokemon.chargedMoves
                                .map((m) => _MoveBadge(
                                    name: m,
                                    color: const Color(0xFFFF6B35))),
                            ...pokemon.eliteChargedMoves
                                .map((m) => _MoveBadge(
                                    name: m,
                                    color: const Color(0xFFA855F7),
                                    elite: true)),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],

                    // ── Sección: Evoluciones ──
                    if (pokemon.evolutions.isNotEmpty) ...[
                      _SectionTitle(title: 'Evoluciones'),
                      const SizedBox(height: 10),
                      ...pokemon.evolutions.map(
                        (evo) => _EvoTile(
                          evo: evo,
                          primaryColor: primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title.toUpperCase(),
    style: const TextStyle(
      color: AppTheme.textSecond,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool full;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecond,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return full ? SizedBox(width: double.infinity, child: tile) : tile;
  }
}

class _MoveBadge extends StatelessWidget {
  final String name;
  final Color color;
  final bool elite;

  const _MoveBadge({required this.name, required this.color, this.elite = false});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color.withOpacity(elite ? 0.7 : 0.3),
        width: elite ? 1.5 : 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (elite) ...[
          Icon(Icons.star, color: color, size: 10),
          const SizedBox(width: 4),
        ],
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _EvoTile extends StatelessWidget {
  final Map<String, dynamic> evo;
  final Color primaryColor;

  const _EvoTile({required this.evo, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final name   = evo['pokemon_name'] ?? '';
    final candy  = evo['candy_required'];
    final item   = evo['item_required'];
    final lure   = evo['lure_required'];
    final day    = evo['only_evolves_in_daytime'] == true;
    final night  = evo['only_evolves_in_nighttime'] == true;
    final buddy  = evo['must_be_buddy_to_evolve'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.arrow_forward, color: primaryColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            children: [
              if (candy != null)
                _EvoTag('$candy candy', const Color(0xFFFF69B4)),
              if (item != null)
                _EvoTag(item, const Color(0xFFFFD700)),
              if (lure != null)
                _EvoTag(lure, const Color(0xFF4CAF50)),
              if (day)
                _EvoTag('Día', const Color(0xFFFFB300)),
              if (night)
                _EvoTag('Noche', const Color(0xFF7C4DFF)),
              if (buddy)
                _EvoTag('Buddy', const Color(0xFF00BCD4)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvoTag extends StatelessWidget {
  final String text;
  final Color color;
  const _EvoTag(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _BadgesRow extends StatelessWidget {
  final Pokemon pokemon;
  const _BadgesRow({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final badges = <_Badge>[];
    if (pokemon.isShiny)    badges.add(_Badge('✨ Shiny', const Color(0xFFFFD700)));
    if (pokemon.isNesting)  badges.add(_Badge('🌿 Nesting', const Color(0xFF4CAF50)));
    if (pokemon.isShadow)   badges.add(_Badge('🌑 Shadow', const Color(0xFF7C4DFF)));
    if (pokemon.isAlolan)   badges.add(_Badge('🌺 Alolan', const Color(0xFFFF6B9D)));
    if (pokemon.isGalarian) badges.add(_Badge('⚙️ Galarian', const Color(0xFF78909C)));
    if (pokemon.isBaby)     badges.add(_Badge('🍼 Baby', const Color(0xFFFF9800)));
    if (pokemon.isPvpExclusive)  badges.add(_Badge('⚔️ PVP Exclusivo', const Color(0xFFE040FB)));
    if (pokemon.isRaidExclusive) badges.add(_Badge('🏅 Raid Exclusivo', const Color(0xFFFFD700)));

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: badges
          .map((b) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: b.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: b.color.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  b.label,
                  style: TextStyle(
                    color: b.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _Badge {
  final String label;
  final Color color;
  _Badge(this.label, this.color);
}