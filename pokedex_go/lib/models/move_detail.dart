// lib/models/move_detail.dart
class MoveDetail {
  final String id;
  final String name;
  final String type;
  final int power;
  final int energy;
  final int durationMs;
  final int combatPower;
  final int combatEnergy;
  final int combatTurns;
  final bool isElite;
  final bool isFast;

  const MoveDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.power,
    required this.energy,
    required this.durationMs,
    required this.combatPower,
    required this.combatEnergy,
    required this.combatTurns,
    this.isElite = false,
    this.isFast = false,
  });

  /// DPS estimado (Daño Por Segundo)
  double get dps => durationMs > 0 ? (combatPower / (durationMs / 1000)) : 0;

  /// EPS estimado (Energía Por Segundo)
  double get eps => durationMs > 0 ? (combatEnergy / (durationMs / 1000)) : 0;

  /// Daño por turno
  double get damagePerTurn => combatTurns > 0 ? combatPower / combatTurns : 0;

  /// Energía por turno
  double get energyPerTurn => combatTurns > 0 ? combatEnergy / combatTurns : 0;

  /// Tiempo en segundos formateado
  String get durationFormatted => '${(durationMs / 1000).toStringAsFixed(1)}s';

  /// Rating de eficiencia (0-100)
  int get efficiencyRating {
    if (isFast) {
      // Para movimientos rápidos: balance entre DPS y EPS
      final score = (dps * 10) + (eps * 15);
      return score.clamp(0, 100).round();
    } else {
      // Para movimientos cargados: priorizar daño
      final score = (power / 10) + (energy.abs() / 5);
      return score.clamp(0, 100).round();
    }
  }
}