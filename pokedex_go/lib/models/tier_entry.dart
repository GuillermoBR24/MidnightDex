import 'package:flutter/foundation.dart';

class TierEntry {
  final int id;
  final String name;
  final List<String> types;
  final int baseAttack;
  final int baseDefense;
  final int baseStamina;
  final int maxCp;
  final double score; // DPS×TDO estimado
  final bool isMega;
  final bool isShadow;
  final bool isLegendary;
  final bool isMythic;
  final String tier; // S, A, B, C
  final String? bestFastMove;
  final String? bestChargedMove;
  final int formIndex; // Para diferenciar duplicados (shadow, gmax, etc)
  final String? imageUrlOverride;
  final String? tierType; // Tipo para el cual es la mejor mega

  TierEntry({
    required this.id,
    required this.name,
    required this.types,
    required this.baseAttack,
    required this.baseDefense,
    required this.baseStamina,
    required this.maxCp,
    required this.score,
    required this.isMega,
    required this.isShadow,
    required this.isLegendary,
    required this.isMythic,
    required this.tier,
    this.bestFastMove,
    this.bestChargedMove,
    this.formIndex = 0,
    this.imageUrlOverride,
    this.tierType,
  });

  String get imageUrl {
    // 👇 Si el override es una ruta local (empieza con 'megas/'), usarlo primero
    if (imageUrlOverride != null && imageUrlOverride!.startsWith('megas/')) {
      return imageUrlOverride!;
    }
    
    // Para Megas normales (lógica antigua)
    if (isMega) {
      final nameLower = name.toLowerCase();
      String formSuffix = '';
      if ((id == 6 || id == 150)) {
        if (nameLower.contains(' x')) formSuffix = '_x';
        else if (nameLower.contains(' y')) formSuffix = '_y';
      }
      return 'megas/$id$formSuffix.png';
    }

    // Fallback a URL web
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
  }

  String get label {
    if (isMega) return 'MEGA';
    if (isShadow) return 'SHADOW';
    if (isLegendary) return 'LEGENDARY';
    if (isMythic) return 'MYTHIC';
    return '';
  }

  /// Retorna el tipo de forma del Pokémon: "NORMAL", "SHADOW", "MEGA", etc
  String get formType {
    if (isMega) return 'MEGA';
    if (isShadow) return 'SHADOW';
    return 'NORMAL';
  }
}
