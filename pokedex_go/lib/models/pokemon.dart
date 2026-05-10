import 'dart:math';

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

  int get calculatedMaxCp {
    if (baseAttack == null || baseDefense == null || baseStamina == null) {
      return maxCp ?? 0; 
    }
    
    // Si la API ya trae un maxCp válido, úsalo como referencia
    final apiCp = maxCp;
    
    // 👇 CPM para nivel 50 (máximo en Pokémon GO)
    const cpm = 0.84029999;
    
    // 👇 Stats con IVs máximos (100% perfect)
    final attack = baseAttack! + 15;   // +15 IV Attack
    final defense = baseDefense! + 15; // +15 IV Defense  
    final stamina = baseStamina! + 15; // +15 IV Stamina
    
    if (attack <= 0 || defense <= 0 || stamina <= 0) return 0;
    
    // Fórmula oficial de Pokémon GO
    final cp = (attack * 
               sqrt(defense.toDouble()) * 
               sqrt(stamina.toDouble()) * 
               cpm * cpm) / 10;
    
    final calculatedValue = cp.floor();
    final finalValue = calculatedValue < 10 ? 10 : calculatedValue;
    
    // Retorna el mayor entre el calculado y el de API (por seguridad)
    return apiCp != null && apiCp > finalValue ? apiCp : finalValue;
  }

  int calculateCpWithIvs({
    required int attackIv,   // 0-15
    required int defenseIv,  // 0-15
    required int staminaIv,  // 0-15
    double cpm = 0.84029999, // Nivel 50 por defecto
  }) {
    if (baseAttack == null || baseDefense == null || baseStamina == null) {
      return 0;
    }
    
    final attack = baseAttack! + attackIv.clamp(0, 15);
    final defense = baseDefense! + defenseIv.clamp(0, 15);
    final stamina = baseStamina! + staminaIv.clamp(0, 15);
    
    final cp = (attack * 
              sqrt(defense.toDouble()) * 
              sqrt(stamina.toDouble()) * 
              cpm * cpm) / 10;
    
    return cp.floor().clamp(10, 9999);
  }
}