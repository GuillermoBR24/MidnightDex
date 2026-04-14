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
  });

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  String get label {
    if (isMega) return 'MEGA';
    if (isShadow) return 'SHADOW';
    if (isLegendary) return 'LEGENDARY';
    if (isMythic) return 'MYTHIC';
    return '';
  }
}