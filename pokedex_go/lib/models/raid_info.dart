class RaidInfo {
  final String raidId;
  final int pokemonId;
  final String pokemonName;
  final String? form;
  final int raidLevel;
  final DateTime startTime;
  final DateTime endTime;
  final List<TypeWeakness> weaknesses;
  final List<RaidCounter> topCounters;
  final RaidStats bossStats;
  final int trainersNeeded;
  final double difficulty;

  RaidInfo({
    required this.raidId,
    required this.pokemonId,
    required this.pokemonName,
    this.form,
    required this.raidLevel,
    required this.startTime,
    required this.endTime,
    required this.weaknesses,
    required this.topCounters,
    required this.bossStats,
    required this.trainersNeeded,
    required this.difficulty,
  });

  String get timeRemaining => _getTimeRemaining();
  
  String _getTimeRemaining() {
    final diff = endTime.difference(DateTime.now());
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'Finalizando';
  }
}

class TypeWeakness {
  final String type;
  final double multiplier;
  final String imageUrl;

  TypeWeakness({
    required this.type,
    required this.multiplier,
    required this.imageUrl,
  });
}

class RaidCounter {
  final int rank;
  final int pokemonId;
  final String pokemonName;
  final String? form;
  final bool isShadow;
  final bool isMega;
  final int level;
  final double ivPercentage;
  final String fastMove;
  final String chargedMove;
  final double dps;
  final double tdo;
  final double estimator;
  final int pc;
  final int atk;
  final int def;
  final int sta;

  RaidCounter({
    required this.rank,
    required this.pokemonId,
    required this.pokemonName,
    this.form,
    this.isShadow = false,
    this.isMega = false,
    required this.level,
    required this.ivPercentage,
    required this.fastMove,
    required this.chargedMove,
    required this.dps,
    required this.tdo,
    required this.estimator,
    required this.pc,
    required this.atk,
    required this.def,
    required this.sta,
  });
}

class RaidStats {
  final int cp;
  final int attack;
  final int defense;
  final int stamina;
  final int caughtCpMin;
  final int caughtCpMax;

  RaidStats({
    required this.cp,
    required this.attack,
    required this.defense,
    required this.stamina,
    required this.caughtCpMin,
    required this.caughtCpMax,
  });
}