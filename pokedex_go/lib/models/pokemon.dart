// lib/models/pokemon.dart
import 'dart:math';
import 'package:pokedex_go/models/move_detail.dart';

import 'iv_config.dart';

class MegaEvolution {
  final String formId; // p.ej. TEMP_EVOLUTION_MEGA, TEMP_EVOLUTION_MEGA_X...
  final String label; // "MEGA", "MEGA X", "MEGA Y", "PRIMIGENIO"
  final int attack;
  final int defense;
  final int stamina;
  final List<String> types;
  final String imageUrl;
  final String? shinyImageUrl;

  const MegaEvolution({
    required this.formId,
    required this.label,
    required this.attack,
    required this.defense,
    required this.stamina,
    required this.types,
    required this.imageUrl,
    this.shinyImageUrl,
  });
}

class Pokemon {
  final int id;
  final String name;
  final List<String> types;
  final int? maxCp;
  final int? baseAttack;
  final int? baseDefense;
  final int? baseStamina;
  final bool isShiny;
  final bool isReleased;
  final bool isNesting;
  final bool isShadow;
  final bool isAlolan;
  final bool isGalarian;
  final bool isLegendary;
  final bool isMythic;
  final bool isPvpExclusive;
  final bool isRaidExclusive;
  final bool isBaby;
  final int? buddyDistanceKm;
  final int? candyToEvolve;
  final double? pokedexHeightM;
  final double? pokedexWeightKg;

  final List<MoveDetail> fastMoves;
  final List<MoveDetail> chargedMoves;
  final List<MoveDetail> eliteFastMoves;
  final List<MoveDetail> eliteChargedMoves;
  
  final List<Map<String, dynamic>> evolutions;
  final String? generation;
  final int? raidLevel;
  final bool? possibleShiny;
  final List<Map<String, dynamic>> alternateForms;

  // 👇 NUEVO: datos que vienen directamente de la Pokemon GO API
  final String? assetImageUrl;
  final String? assetShinyImageUrl;
  final List<MegaEvolution> megaEvolutions;

  Pokemon({
    required this.id,
    required this.name,
    required this.types,
    this.maxCp,
    this.baseAttack,
    this.baseDefense,
    this.baseStamina,
    this.isShiny = false,
    this.isReleased = false,
    this.isNesting = false,
    this.isShadow = false,
    this.isAlolan = false,
    this.isGalarian = false,
    this.isLegendary = false,
    this.isMythic = false,
    this.isPvpExclusive = false,
    this.isRaidExclusive = false,
    this.isBaby = false,
    this.buddyDistanceKm,
    this.candyToEvolve,
    this.pokedexHeightM,
    this.pokedexWeightKg,
    this.fastMoves = const [],
    this.chargedMoves = const [],
    this.eliteFastMoves = const [],
    this.eliteChargedMoves = const [],
    this.evolutions = const [],
    this.generation,
    this.raidLevel,
    this.possibleShiny,
    this.assetImageUrl,
    this.assetShinyImageUrl,
    this.megaEvolutions = const [],
    this.alternateForms = const [],
  });

  Map<String, dynamic>? getFormByName(String formName) {
    final slug = formName.toLowerCase().trim();
    for (final form in alternateForms) {
      final formId = (form['id'] ?? '').toString().toLowerCase();
      if (formId.contains(slug) || slug.contains(formId)) {
        return form;
      }
    }
    return null;
  }

  /// Imagen oficial: prioriza la que da la Pokemon GO API, si no hay,
  /// cae en el sprite de PokéAPI (siempre existe por dex number).
  String get imageUrl =>
      (assetImageUrl != null && assetImageUrl!.isNotEmpty)
          ? assetImageUrl!
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get shinyImageUrl =>
      (assetShinyImageUrl != null && assetShinyImageUrl!.isNotEmpty)
          ? assetShinyImageUrl!
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';

  String get shinyImageUrlFallback =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$id.png';

  String get paddedId => id.toString().padLeft(3, '0');

  String get rarity {
    if (isMythic) return 'Mythic';
    if (isLegendary) return 'Legendary';
    return 'Standard';
  }

  String getImageForForm(String? formName) {
    if (formName == null) return imageUrl;
    
    final form = getFormByName(formName);
    if (form != null) {
      final imgUrl = form['imageUrl'] as String?;
      if (imgUrl != null && imgUrl.isNotEmpty) {
        return imgUrl;
      }
    }
    
    return imageUrl;
  }

  bool get hasMega => megaEvolutions.isNotEmpty;

  int calculateMaxCpWithIvs(IvConfig ivs, {int level = 50}) {
    if (baseAttack == null || baseDefense == null || baseStamina == null) {
      return maxCp ?? 0;
    }
    final cpm = getCpmForLevel(level);
    final attack = baseAttack! + ivs.attack;
    final defense = baseDefense! + ivs.defense;
    final stamina = baseStamina! + ivs.stamina;
    return calcCp(attack, defense, stamina, cpm: cpm);
  }

  /// Cálculo estándar de CP reutilizable en toda la app (Pokédex, Tier List, Raids).
  static int calcCp(int attack, int defense, int stamina, {double cpm = 0.79030001}) {
    if (attack <= 0 || defense <= 0 || stamina <= 0) return 0;
    final cp =
        (attack * sqrt(defense.toDouble()) * sqrt(stamina.toDouble()) * cpm * cpm) / 10;
    final value = cp.floor();
    return value < 10 ? 10 : value;
  }

  static double getCpmForLevel(int level) {
    const cpmTable = {
      1: 0.09400001,
      10: 0.42250000,
      15: 0.51739395,
      20: 0.59740001,
      25: 0.66793400,
      30: 0.73170000,
      35: 0.79030001,
      40: 0.79030001,
      41: 0.79530001,
      42: 0.80030000,
      43: 0.80530000,
      44: 0.81030000,
      45: 0.81530000,
      46: 0.82030000,
      47: 0.82530000,
      48: 0.83030000,
      49: 0.83530000,
      50: 0.84029999,
    };
    return cpmTable[level] ?? 0.84029999;
  }

  int get calculatedMaxCp => calculateMaxCpWithIvs(IvConfig.perfect);
}
