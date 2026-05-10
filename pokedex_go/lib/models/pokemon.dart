// lib/models/pokemon.dart
import 'dart:math';
import 'iv_config.dart';

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
  final List<String> fastMoves;
  final List<String> chargedMoves;
  final List<String> eliteFastMoves;
  final List<String> eliteChargedMoves;
  final List<Map<String, dynamic>> evolutions;
  final String? generation;
  final int? raidLevel;
  final bool? possibleShiny;

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
  });

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get shinyImageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';

  String get shinyImageUrlFallback =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$id.png';

  String get paddedId => id.toString().padLeft(3, '0');

  String get rarity {
    if (isMythic) return 'Mythic';
    if (isLegendary) return 'Legendary';
    return 'Standard';
  }

  int calculateMaxCpWithIvs(IvConfig ivs, {int level = 50}) {
    if (baseAttack == null || baseDefense == null || baseStamina == null) {
      return maxCp ?? 0;
    }

    final cpm = getCpmForLevel(level);
    final attack = baseAttack! + ivs.attack;
    final defense = baseDefense! + ivs.defense;
    final stamina = baseStamina! + ivs.stamina;

    if (attack <= 0 || defense <= 0 || stamina <= 0) return 0;

    final cp =
        (attack *
            sqrt(defense.toDouble()) *
            sqrt(stamina.toDouble()) *
            cpm *
            cpm) /
        10;

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
