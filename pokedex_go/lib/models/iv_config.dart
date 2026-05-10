// lib/models/iv_config.dart
// ⚠️ ESTE ARCHIVO SOLO CONTIENE LA CLASE IvConfig - NADA MÁS

class IvConfig {
  final String label;
  final int attack;
  final int defense;
  final int stamina;
  final String description;

  const IvConfig({
    required this.label,
    required this.attack,
    required this.defense,
    required this.stamina,
    this.description = '',
  });

  // Configuraciones predefinidas
  static const IvConfig perfect = IvConfig(
    label: '100% Perfecto',
    attack: 15,
    defense: 15,
    stamina: 15,
    description: '15/15/15 - Máximos IVs',
  );

  static const IvConfig raid35 = IvConfig(
    label: '82% Raid Level 35',
    attack: 12,
    defense: 12,
    stamina: 12,
    description: '12/12/12 - Raid con boost climático',
  );

  static const IvConfig raid25 = IvConfig(
    label: '67% Raid Level 25',
    attack: 10,
    defense: 10,
    stamina: 10,
    description: '10/10/10 - Raid normal',
  );

  static const IvConfig wild15 = IvConfig(
    label: '40% Wild Level 15',
    attack: 6,
    defense: 6,
    stamina: 6,
    description: '6/6/6 - Pokémon salvaje',
  );

  static const IvConfig hundo = IvConfig(
    label: '0% Hundo',
    attack: 0,
    defense: 0,
    stamina: 0,
    description: '0/0/0 - Mínimos IVs',
  );

  static const IvConfig custom = IvConfig(
    label: 'Personalizado',
    attack: 15,
    defense: 15,
    stamina: 15,
    description: 'IVs personalizados',
  );

  static const List<IvConfig> presets = [
    perfect,
    raid35,
    raid25,
    wild15,
    hundo,
    custom,
  ];

  int get ivSum => attack + defense + stamina;
  double get ivPercentage => (ivSum / 45) * 100;
}

// 👈 FIN DE iv_config.dart - NO AGREGUES NADA MÁS AQUÍ
