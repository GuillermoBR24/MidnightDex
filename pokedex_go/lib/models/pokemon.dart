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

  String get paddedId => id.toString().padLeft(3, '0');

  String get rarity {
    if (isMythic) return 'Mythic';
    if (isLegendary) return 'Legendary';
    return 'Standard';
  }
}