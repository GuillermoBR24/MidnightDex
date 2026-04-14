import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/tier_entry.dart';

class TierService {
  static const String _base = 'https://pogoapi.net/api/v1';

  static Map<String, List<TierEntry>>? _byTypeCache;
  static List<TierEntry>? _megaCache;

  // ─────────────────────────────────────────────────────────────────────────
  // TOP 10 PVE POR TIPO — extraídos de la imagen @LucasOnrubia v26r Ago 2025
  // Orden: mejor (1) → peor (10), de izquierda a derecha en la imagen
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, List<String>> _hardcodedTop = {
    'Bug': [
      'Pinsir', 'Heracross', 'Beedrill', 'Pheromosa', 'Pinsir',
      'Scizor', 'Scizor', 'Volcarona', 'Scyther', 'Vikavolt',
    ],
    'Dark': [
      'Yveltal', 'Darkrai', 'Darkrai', 'Yveltal', 'Yveltal',
      'Yveltal', 'Darkrai', 'Darkrai', 'Yveltal', 'Darkrai',
    ],
    'Dragon': [
      'Rayquaza', 'Rayquaza', 'Rayquaza', 'Rayquaza', 'Rayquaza',
      'Rayquaza', 'Rayquaza', 'Rayquaza', 'Rayquaza', 'Dragonite',
    ],
    'Electric': [
      'Zekrom', 'Zekrom', 'Zekrom', 'Zekrom', 'Zekrom',
      'Electivire', 'Zekrom', 'Xurkitree', 'Raikou', 'Xurkitree',
    ],
    'Fairy': [
      'Xerneas', 'Togekiss', 'Xerneas', 'Gardevoir', 'Xerneas',
      'Zacian', 'Xerneas', 'Gardevoir', 'Togekiss', 'Xerneas',
    ],
    'Fighting': [
      'Terrakion', 'Lucario', 'Terrakion', 'Lucario', 'Lucario',
      'Lucario', 'Lucario', 'Terrakion', 'Terrakion', 'Machamp',
    ],
    'Fire': [
      'Reshiram', 'Reshiram', 'Reshiram', 'Reshiram', 'Reshiram',
      'Chandelure', 'Entei', 'Reshiram', 'Chandelure', 'Reshiram',
    ],
    'Flying': [
      'Rayquaza', 'Rayquaza', 'Moltres', 'Rayquaza', 'Rayquaza',
      'Moltres', 'Rayquaza', 'Rayquaza', 'Rayquaza', 'Staraptor',
    ],
    'Ghost': [
      'Giratina', 'Chandelure', 'Giratina', 'Chandelure', 'Giratina',
      'Giratina', 'Chandelure', 'Giratina', 'Giratina', 'Giratina',
    ],
    'Grass': [
      'Kartana', 'Leafeon', 'Kartana', 'Kartana', 'Kartana',
      'Kartana', 'Kartana', 'Leafeon', 'Kartana', 'Tangrowth',
    ],
    'Ground': [
      'Groudon', 'Groudon', 'Groudon', 'Groudon', 'Groudon',
      'Groudon', 'Garchomp', 'Groudon', 'Groudon', 'Groudon',
    ],
    'Ice': [
      'Mamoswine', 'Darmanitan', 'Mamoswine', 'Weavile', 'Mamoswine',
      'Mamoswine', 'Mamoswine', 'Glaceon', 'Darmanitan', 'Mamoswine',
    ],
    'Poison': [
      'Nihilego', 'Nihilego', 'Nihilego', 'Nihilego', 'Nihilego',
      'Nihilego', 'Nihilego', 'Nihilego', 'Beedrill', 'Nihilego',
    ],
    'Psychic': [
      'Mewtwo', 'Mewtwo', 'Mewtwo', 'Mewtwo', 'Mewtwo',
      'Mewtwo', 'Mewtwo', 'Mewtwo', 'Mewtwo', 'Mewtwo',
    ],
    'Rock': [
      'Rampardos', 'Rhyperior', 'Rampardos', 'Rhyperior', 'Rampardos',
      'Terrakion', 'Rhyperior', 'Rampardos', 'Rampardos', 'Rhyperior',
    ],
    'Steel': [
      'Metagross', 'Metagross', 'Metagross', 'Metagross', 'Metagross',
      'Metagross', 'Metagross', 'Metagross', 'Jirachi', 'Metagross',
    ],
    'Water': [
      'Kyogre', 'Kyogre', 'Kyogre', 'Kyogre', 'Kyogre',
      'Kyogre', 'Kyogre', 'Kyogre', 'Kingler', 'Kyogre',
    ],
  };

  // Top megas por tipo (mejor mega de cada tipo para PVE)
  static const Map<String, String> _hardcodedMegas = {
    'Bug':      'Mega Beedrill',
    'Dark':     'Mega Tyranitar',
    'Dragon':   'Mega Rayquaza',
    'Electric': 'Mega Manectric',
    'Fairy':    'Mega Gardevoir',
    'Fighting': 'Mega Lucario',
    'Fire':     'Mega Charizard Y',
    'Flying':   'Mega Rayquaza',
    'Ghost':    'Mega Gengar',
    'Grass':    'Mega Sceptile',
    'Ground':   'Primal Groudon',
    'Ice':      'Mega Abomasnow',
    'Poison':   'Mega Beedrill',
    'Psychic':  'Mega Mewtwo Y',
    'Rock':     'Mega Diancie',
    'Steel':    'Mega Metagross',
    'Water':    'Primal Kyogre',
  };

  static Future<dynamic> _fetch(String ep) async {
    final r = await http.get(Uri.parse('$_base/$ep'),
        headers: {'Accept': 'application/json'});
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('HTTP ${r.statusCode} en $ep');
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static String _assignTier(int rank) {
    if (rank <= 2) return 'S';
    if (rank <= 5) return 'A';
    if (rank <= 8) return 'B';
    return 'C';
  }

  static Future<(Map<String, List<TierEntry>>, List<TierEntry>)>
      fetchTierData() async {
    if (_byTypeCache != null && _megaCache != null) {
      return (_byTypeCache!, _megaCache!);
    }

    // Carga de datos de la API
    final statsRaw  = await _fetch('pokemon_stats.json')          as List<dynamic>;
    final maxCpRaw  = await _fetch('pokemon_max_cp.json')         as List<dynamic>;
    final typesRaw  = await _fetch('pokemon_types.json')          as List<dynamic>;
    final movesRaw  = await _fetch('current_pokemon_moves.json')  as List<dynamic>;
    final megaRaw   = await _fetch('mega_pokemon.json')           as List<dynamic>;
    final shadowRaw = await _fetch('shadow_pokemon.json')         as Map<String, dynamic>;
    final rarityRaw = await _fetch('pokemon_rarity.json')         as Map<String, dynamic>;

    // ── Índices por nombre (insensible a mayúsculas) ──
    final statsByName  = <String, Map<String, dynamic>>{};
    final maxCpByName  = <String, int>{};
    final typesByName  = <String, List<String>>{};
    final movesByName  = <String, Map<String, dynamic>>{};
    final shadowIds    = <int>{};
    final legendaryIds = <int>{};
    final mythicIds    = <int>{};

    for (final s in statsRaw) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      if (name.isNotEmpty) statsByName[name] = Map<String, dynamic>.from(s as Map);
    }

    for (final c in maxCpRaw) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      if (name.isNotEmpty && c['max_cp'] != null) {
        maxCpByName[name] = _toInt(c['max_cp']);
      }
    }

    // types indexado por pokemon_id, luego cruzamos con stats para obtener por nombre
    final typesById = <int, List<String>>{};
    for (final t in typesRaw) {
      final pid = _toInt(t['pokemon_id']);
      if (!typesById.containsKey(pid) && t['type'] != null) {
        typesById[pid] = List<String>.from(t['type']);
      }
    }
    // Cruzar tipos con nombres via stats
    for (final s in statsRaw) {
      final name = (s['name'] ?? '').toString().toLowerCase();
      final id   = _toInt(s['id']);
      if (name.isNotEmpty && typesById.containsKey(id)) {
        typesByName[name] = typesById[id]!;
      }
    }

    for (final m in movesRaw) {
      final name = (m['pokemon_name'] ?? '').toString().toLowerCase();
      if (name.isNotEmpty) movesByName[name] = Map<String, dynamic>.from(m as Map);
    }

    shadowRaw.forEach((key, value) {
      final id = int.tryParse(key) ?? _toInt((value as Map?)?['id']);
      if (id > 0) shadowIds.add(id);
    });

    ((rarityRaw['Legendary'] as List?) ?? []).forEach((p) {
      if (p is Map && p['pokemon_id'] != null) legendaryIds.add(_toInt(p['pokemon_id']));
    });
    ((rarityRaw['Mythic'] as List?) ?? []).forEach((p) {
      if (p is Map && p['pokemon_id'] != null) mythicIds.add(_toInt(p['pokemon_id']));
    });

    // ── Construir byType desde los nombres hardcodeados ──
    // Eliminar duplicados por tipo manteniendo el primero (mejor rank)
    final byTypeFinal = <String, List<TierEntry>>{};

    _hardcodedTop.forEach((type, names) {
      final seen    = <String>{};
      final entries = <TierEntry>[];

      for (int i = 0; i < names.length; i++) {
        final rawName = names[i];
        final key     = rawName.toLowerCase();

        // Evitar duplicados exactos
        if (seen.contains(key)) continue;
        seen.add(key);

        // Buscar en la API por nombre (búsqueda flexible)
        final statsData = statsByName[key] ??
            statsByName.entries
                .where((e) => e.key.contains(key) || key.contains(e.key))
                .map((e) => e.value)
                .firstOrNull;

        final id  = statsData != null ? _toInt(statsData['id']) : 0;
        final atk = statsData != null ? _toInt(statsData['base_attack']) : 0;
        final def = statsData != null ? _toInt(statsData['base_defense']) : 1;
        final sta = statsData != null ? _toInt(statsData['base_stamina']) : 0;
        final cp  = maxCpByName[key] ??
            maxCpByName.entries
                .where((e) => e.key.contains(key) || key.contains(e.key))
                .map((e) => e.value)
                .firstOrNull ?? 0;

        final pokTypes = typesByName[key] ??
            typesByName.entries
                .where((e) => e.key.contains(key) || key.contains(e.key))
                .map((e) => e.value)
                .firstOrNull ?? [type];

        final moves    = movesByName[key] ??
            movesByName.entries
                .where((e) => e.key.contains(key) || key.contains(e.key))
                .map((e) => e.value)
                .firstOrNull;

        final fasts   = moves != null ? List<String>.from(moves['fast_moves'] ?? []) : <String>[];
        final charged = moves != null ? List<String>.from(moves['charged_moves'] ?? []) : <String>[];

        final isShadow = shadowIds.contains(id);
        final isLeg    = legendaryIds.contains(id);
        final isMyt    = mythicIds.contains(id);
        final rank     = entries.length + 1;

        entries.add(TierEntry(
          id:          id > 0 ? id : (800 + entries.length),
          name:        rawName,
          types:       pokTypes,
          baseAttack:  atk,
          baseDefense: def,
          baseStamina: sta,
          maxCp:       cp,
          score:       (10 - entries.length).toDouble(), // score inverso al rank
          isMega:      false,
          isShadow:    isShadow,
          isLegendary: isLeg,
          isMythic:    isMyt,
          tier:        _assignTier(rank),
          bestFastMove:    fasts.isNotEmpty ? fasts.first : null,
          bestChargedMove: charged.isNotEmpty ? charged.first : null,
        ));
      }

      if (entries.isNotEmpty) byTypeFinal[type] = entries;
    });

    developer.log('Types built: ${byTypeFinal.keys.toList()}', name: 'TierService');

    // ── Construir megas desde nombres hardcodeados ──
    final megaFinal = <TierEntry>[];

    _hardcodedMegas.forEach((type, megaName) {
      final key = megaName.toLowerCase();

      // Buscar en mega_pokemon.json por nombre
      Map<String, dynamic>? megaData;
      for (final m in megaRaw) {
        final mn = (m['mega_name'] ?? '').toString().toLowerCase();
        if (mn == key || mn.contains(key.replaceAll('mega ', '').replaceAll('primal ', ''))) {
          megaData = Map<String, dynamic>.from(m as Map);
          break;
        }
      }

      int pid = 0, atk = 0, def = 1, sta = 0;
      List<String> megaTypes = [type];

      if (megaData != null) {
        pid = _toInt(megaData['pokemon_id']);
        final ms = megaData['stats'] as Map?;
        if (ms != null) {
          atk = _toInt(ms['base_attack']);
          def = _toInt(ms['base_defense']);
          sta = _toInt(ms['base_stamina']);
        }
        if (megaData['type'] != null) {
          megaTypes = List<String>.from(megaData['type']);
        }
      }

      final moves   = pid > 0 ? movesByName.entries
          .where((e) {
            final s = statsRaw.firstWhere(
              (x) => _toInt(x['id']) == pid,
              orElse: () => <String, dynamic>{},
            );
            return (s['name'] ?? '').toString().toLowerCase() == e.key;
          })
          .map((e) => e.value)
          .firstOrNull : null;

      final fasts   = moves != null ? List<String>.from(moves['fast_moves'] ?? []) : <String>[];
      final charged = moves != null ? List<String>.from(moves['charged_moves'] ?? []) : <String>[];

      megaFinal.add(TierEntry(
        id:          pid > 0 ? pid : (900 + megaFinal.length),
        name:        megaName,
        types:       megaTypes,
        baseAttack:  atk,
        baseDefense: def,
        baseStamina: sta,
        maxCp:       0,
        score:       (atk * atk * sta.toDouble()) / def,
        isMega:      true,
        isShadow:    false,
        isLegendary: false,
        isMythic:    false,
        tier:        'S',
        bestFastMove:    fasts.isNotEmpty ? fasts.first : null,
        bestChargedMove: charged.isNotEmpty ? charged.first : null,
      ));
    });

    megaFinal.sort((a, b) => b.score.compareTo(a.score));

    _byTypeCache = byTypeFinal;
    _megaCache   = megaFinal;
    return (byTypeFinal, megaFinal);
  }
}