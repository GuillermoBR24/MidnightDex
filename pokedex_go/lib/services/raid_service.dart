// lib/services/raid_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/raid_info.dart';

/// Jefes de raid actuales: Pokemon GO API.
/// https://pokemon-go-api.github.io/pokemon-go-api/api/raidboss.json
class RaidService {
  static const String _raidUrl =
      'https://pokemon-go-api.github.io/pokemon-go-api/api/raidboss.json';

  static Future<List<RaidInfo>> fetchActiveRaids() async {
    try {
      final r = await http
          .get(Uri.parse(_raidUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (r.statusCode != 200) throw Exception('Error HTTP: ${r.statusCode}');

      final decoded = json.decode(utf8.decode(r.bodyBytes));
      final Map<String, dynamic> tiers = decoded is Map
          ? Map<String, dynamic>.from(decoded['current'] ?? decoded)
          : {};

      return _parseRaids(tiers);
    } on TimeoutException {
      throw Exception('Timeout al conectar con Pokemon GO API');
    } catch (e) {
      print('❌ Error fetching raids: $e');
      rethrow;
    }
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    final lower = s.toLowerCase().replaceAll('_', ' ').trim();
    return lower
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static int _levelFromKey(String key) {
    final digits = RegExp(r'\d+').firstMatch(key)?.group(0);
    if (digits != null) return int.tryParse(digits) ?? 1;
    final lower = key.toLowerCase();
    if (lower.contains('mega')) return 6;
    if (lower.contains('shadow')) return 1;
    return 1;
  }

  static List<RaidInfo> _parseRaids(Map<String, dynamic> tiers) {
    final raids = <RaidInfo>[];

    tiers.forEach((tierKey, bosses) {
      if (bosses is! List) return;
      final tier = _levelFromKey(tierKey);

      for (final boss in bosses) {
        if (boss is! Map) continue;

        final names = boss['names'] as Map? ?? {};
        final name = _capitalize((names['English'] ?? boss['id'] ?? 'Pokémon').toString());
        final dexNr = _toInt(boss['dexNr']);

        final typesRaw = (boss['types'] as List?) ??
            [boss['primaryType'], boss['secondaryType']].where((t) => t != null).toList();
        final types = typesRaw
            .map((t) => (t is Map ? t['type'] : t).toString())
            .map((t) => _capitalize(t.replaceFirst('POKEMON_TYPE_', '')))
            .where((t) => t.isNotEmpty)
            .toList();

        final combatPower = boss['combatPower'] as Map? ?? {};
        final cpMin = _toInt(combatPower['min']);
        final cpMax = _toInt(combatPower['max']);

        final assets = boss['assets'] as Map? ?? {};
        final image = (assets['image'] ?? '').toString();

        final weaknesses = _calculateWeaknesses(types);

        raids.add(RaidInfo(
          raidId: '${tierKey}_${boss['id'] ?? dexNr}',
          pokemonId: dexNr,
          pokemonName: name,
          raidLevel: tier,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          weaknesses: weaknesses,
          // La API no incluye counters calculados; se muestran solo debilidades.
          topCounters: const [],
          bossStats: RaidStats(
            cp: cpMax,
            attack: 0,
            defense: 0,
            stamina: 0,
            caughtCpMin: cpMin,
            caughtCpMax: cpMax,
          ),
          trainersNeeded: _estimateTrainers(tier),
          difficulty: _estimateDifficulty(tier),
          imageUrl: image.isNotEmpty
              ? image
              : (dexNr > 0
                  ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$dexNr.png'
                  : null),
        ));
      }
    });

    return raids;
  }

  static List<TypeWeakness> _calculateWeaknesses(List<String> types) {
    const typeEffectiveness = {
      'Fire': {'Water': 1.6, 'Ground': 1.6, 'Rock': 1.6},
      'Water': {'Electric': 1.6, 'Grass': 1.6},
      'Grass': {'Fire': 1.6, 'Ice': 1.6, 'Poison': 1.6, 'Flying': 1.6, 'Bug': 1.6},
      'Electric': {'Ground': 1.6},
      'Ice': {'Fire': 1.6, 'Fighting': 1.6, 'Rock': 1.6, 'Steel': 1.6},
      'Fighting': {'Flying': 1.6, 'Psychic': 1.6, 'Fairy': 1.6},
      'Poison': {'Ground': 1.6, 'Psychic': 1.6},
      'Ground': {'Water': 1.6, 'Grass': 1.6, 'Ice': 1.6},
      'Flying': {'Electric': 1.6, 'Ice': 1.6, 'Rock': 1.6},
      'Psychic': {'Bug': 1.6, 'Ghost': 1.6, 'Dark': 1.6},
      'Bug': {'Fire': 1.6, 'Flying': 1.6, 'Rock': 1.6},
      'Rock': {'Water': 1.6, 'Grass': 1.6, 'Fighting': 1.6, 'Ground': 1.6, 'Steel': 1.6},
      'Ghost': {'Ghost': 1.6, 'Dark': 1.6},
      'Dragon': {'Ice': 1.6, 'Dragon': 1.6, 'Fairy': 1.6},
      'Dark': {'Fighting': 1.6, 'Bug': 1.6, 'Fairy': 1.6},
      'Steel': {'Fire': 1.6, 'Fighting': 1.6, 'Ground': 1.6},
      'Fairy': {'Poison': 1.6, 'Steel': 1.6},
    };

    final weaknesses = <String, double>{};
    for (final type in types) {
      typeEffectiveness[type]?.forEach((weakType, multiplier) {
        weaknesses[weakType] = (weaknesses[weakType] ?? 1.0) * multiplier;
      });
    }

    return weaknesses.entries
        .where((e) => e.value > 1.0)
        .map((e) => TypeWeakness(type: e.key, multiplier: e.value, imageUrl: e.key.toLowerCase()))
        .toList()
      ..sort((a, b) => b.multiplier.compareTo(a.multiplier));
  }

  static int _estimateTrainers(int tier) {
    switch (tier) {
      case 1: return 1;
      case 2: return 1;
      case 3: return 2;
      case 4: return 3;
      case 5:
      case 6: return 5;
      default: return 3;
    }
  }

  static double _estimateDifficulty(int tier) {
    switch (tier) {
      case 1: return 0.2;
      case 2: return 0.4;
      case 3: return 0.6;
      case 4: return 0.8;
      case 5:
      case 6: return 0.95;
      default: return 0.5;
    }
  }
}