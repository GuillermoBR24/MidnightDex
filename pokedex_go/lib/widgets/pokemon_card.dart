import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../models/pokemon.dart';
import '../theme/app_theme.dart';
import 'type_badge.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCard({super.key, required this.pokemon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final released = pokemon.isReleased;
    final primaryColor = released
        ? (pokemon.types.isNotEmpty
            ? AppTheme.getTypeColor(pokemon.types.first)
            : AppTheme.accentBlue)
        : const Color(0xFF3A3A4A);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Tarjeta base
          Container(
            decoration: BoxDecoration(
              color: released ? AppTheme.bgCard : const Color(0xFF0D0D14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: released
                    ? primaryColor.withOpacity(0.25)
                    : const Color(0xFF2A2A3A),
                width: 1,
              ),
              boxShadow: released
                  ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen (desaturada si no está introducido)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ColorFiltered(
                      colorFilter: released
                          ? const ColorFilter.mode(
                              Colors.transparent, BlendMode.saturation)
                          : const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      0.35, 0,
                            ]),
                      child: CachedNetworkImage(
                        imageUrl: pokemon.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: AppTheme.bgSurface,
                          highlightColor: AppTheme.borderColor,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.bgSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.catching_pokemon,
                          color: primaryColor.withOpacity(0.3),
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                // Datos
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  child: Column(
                    children: [
                      Text(
                        '#${pokemon.paddedId}',
                        style: TextStyle(
                          color: released
                              ? AppTheme.textSecond
                              : const Color(0xFF3A3A55),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pokemon.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: released
                              ? AppTheme.textPrimary
                              : const Color(0xFF4A4A60),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (released)
                        Wrap(
                          spacing: 4,
                          alignment: WrapAlignment.center,
                          children: pokemon.types
                              .map((t) => TypeBadge(type: t, small: true))
                              .toList(),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFF2D2D45), width: 1),
                          ),
                          child: const Text(
                            'No disponible',
                            style: TextStyle(
                              color: Color(0xFF4A4A65),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Icono de "no disponible" en esquina superior derecha
          if (!released)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF2D2D45), width: 1),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 11,
                  color: Color(0xFF4A4A65),
                ),
              ),
            ),
          // Badge de rareza (Legendary/Mythic) para los sí disponibles
          if (released && (pokemon.isLegendary || pokemon.isMythic))
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: pokemon.isMythic
                      ? const Color(0xFF2D1A3E)
                      : const Color(0xFF1A2A3E),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: pokemon.isMythic
                        ? const Color(0xFFA855F7).withOpacity(0.5)
                        : const Color(0xFFFFD700).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  pokemon.isMythic ? 'M' : 'L',
                  style: TextStyle(
                    color: pokemon.isMythic
                        ? const Color(0xFFA855F7)
                        : const Color(0xFFFFD700),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
        begin: const Offset(0.95, 0.95));
  }
}