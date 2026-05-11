// lib/services/raid_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/raid_info.dart';

class RaidService {
  static const String _baseUrl = 'https://pogoapi.net/api/v1';

  static Future<List<RaidInfo>> fetchActiveRaids() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/raid_bosses.json'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseRaids(data['current'] ?? {});
      }
      throw Exception('Error HTTP: ${response.statusCode}');
    } catch (e) {
      print('❌ Error fetching raids: $e');
      rethrow;
    }
  }

  static List<RaidInfo> _parseRaids(Map<String, dynamic> tiers) {
    final raids = <RaidInfo>[];
    
    tiers.forEach((tierKey, bosses) {
      final tier = int.tryParse(tierKey) ?? (tierKey == 'mega' ? 6 : 1);
      
      for (final boss in bosses) {
        final id = boss['id'] as int;
        final name = boss['name'] as String;
        final types = List<String>.from(boss['type'] ?? []);
        
        // Calcular debilidades
        final weaknesses = _calculateWeaknesses(types);
        
        // Calcular top counters (simplificado)
        final counters = _calculateTopCounters(id, types, weaknesses);
        
        raids.add(RaidInfo(
          raidId: '${tierKey}_$id',
          pokemonId: id,
          pokemonName: name,
          raidLevel: tier,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          weaknesses: weaknesses,
          topCounters: counters,
          bossStats: RaidStats(
            cp: boss['max_unboosted_cp'] ?? 0,
            attack: 0, // Se puede obtener de pokemon_stats.json
            defense: 0,
            stamina: 0,
            caughtCpMin: boss['min_unboosted_cp'] ?? 0,
            caughtCpMax: boss['max_unboosted_cp'] ?? 0,
          ),
          trainersNeeded: _estimateTrainers(tier),
          difficulty: _estimateDifficulty(tier),
        ));
      }
    });
    
    return raids;
  }

  // Calcular debilidades basadas en tipos
  static List<TypeWeakness> _calculateWeaknesses(List<String> types) {
    // Mapa de efectividad de tipos (simplificado)
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
      final effectiveAgainst = typeEffectiveness[type];
      if (effectiveAgainst != null) {
        effectiveAgainst.forEach((weakType, multiplier) {
          weaknesses[weakType] = (weaknesses[weakType] ?? 1.0) * multiplier;
        });
      }
    }
    
    // Convertir a lista ordenada por multiplicador
    return weaknesses.entries
        .where((e) => e.value > 1.0)
        .map((e) => TypeWeakness(
              type: e.key,
              multiplier: e.value,
              imageUrl: e.key.toLowerCase(),
            ))
        .toList()
      ..sort((a, b) => b.multiplier.compareTo(a.multiplier));
  }

  // Calcular top counters (simplificado con stats base)
  static List<RaidCounter> _calculateTopCounters(
    int bossId,
    List<String> bossTypes,
    List<TypeWeakness> weaknesses,
  ) {
    // Lista de Pokémon con alto ataque y tipos efectivos
    // En producción, esto vendría de una base de datos o cálculo real
    final topCounters = <RaidCounter>[];
    
    // Ejemplo: si el boss es débil a Agua, sugerir Kyogre, Gyarados, etc.
    if (weaknesses.any((w) => w.type == 'Water')) {
      topCounters.addAll([
        RaidCounter(
          rank: 1,
          pokemonId: 382,
          pokemonName: 'Primal Kyogre',
          level: 50,
          ivPercentage: 100,
          fastMove: 'Cascada',
          chargedMove: 'Pulso Primigenio',
          dps: 26.0,
          tdo: 5902,
          estimator: 0.58,
          pc: 5902,
          atk: 353,
          def: 238,
          sta: 205,
        ),
        RaidCounter(
          rank: 2,
          pokemonId: 130,
          pokemonName: 'Gyarados',
          isShadow: true,
          level: 50,
          ivPercentage: 100,
          fastMove: 'Bofetón Lodo',
          chargedMove: 'Hidrobomba',
          dps: 22.5,
          tdo: 3200,
          estimator: 0.72,
          pc: 3200,
          atk: 237,
          def: 186,
          sta: 216,
        ),
      ]);
    }
    
    // Agregar más counters según debilidades...
    return topCounters.take(10).toList();
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
  
  static Future<Map<int, Map<String, int>>> _loadPokemonStats() async {
  final response = await http.get(Uri.parse('$_baseUrl/pokemon_stats.json'));
  if (response.statusCode == 200) {
    final List<dynamic> stats = json.decode(response.body);
    return {
      for (final s in stats)
        s['id'] as int: {
          'atk': int.tryParse(s['base_attack'].toString()) ?? 0,
          'def': int.tryParse(s['base_defense'].toString()) ?? 0,
          'sta': int.tryParse(s['base_stamina'].toString()) ?? 0,
        }
    };
  }
  return {};
}
}