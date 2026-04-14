import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PogoApiService {
  static const String _base = 'https://pogoapi.net/api/v1';

  static Map<String, dynamic>? _names;
  static Map<String, dynamic>? _shiny;
  static Map<String, dynamic>? _released;
  static Map<String, dynamic>? _nesting;
  static Map<String, dynamic>? _shadow;
  static Map<String, dynamic>? _alolan;
  static Map<String, dynamic>? _galarian;
  static Map<String, dynamic>? _rarity;
  static Map<String, dynamic>? _buddyDist;
  static Map<String, dynamic>? _candyEvolve;
  static Map<String, dynamic>? _generations;
  static List<dynamic>? _stats;
  static List<dynamic>? _maxCp;
  static List<dynamic>? _types;
  static List<dynamic>? _moves;
  static List<dynamic>? _hwScale;
  static List<dynamic>? _evolutions;
  static List<dynamic>? _pvpExclusive;
  static Map<String, dynamic>? _raidExclusive;
  static List<dynamic>? _baby;

  static Future<Map<String, dynamic>> _getMap(String ep) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/$ep'), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      if (r.statusCode == 200) return json.decode(r.body);
      throw Exception('HTTP ${r.statusCode} en $ep');
    } on TimeoutException {
      throw Exception('Timeout al conectar con la API');
    } catch (e) {
      throw Exception('Error en $ep: $e');
    }
  }

  static Future<List<dynamic>> _getList(String ep) async {
    try {
      final r = await http
          .get(Uri.parse('$_base/$ep'), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
      if (r.statusCode == 200) return json.decode(r.body);
      throw Exception('HTTP ${r.statusCode} en $ep');
    } on TimeoutException {
      throw Exception('Timeout al conectar con la API');
    } catch (e) {
      throw Exception('Error en $ep: $e');
    }
  }

  // Carga un Map con caché
  static Future<Map<String, dynamic>> _cachedMap(
      String ep, Map<String, dynamic>? cache) async {
    if (cache != null) return cache;
    return _getMap(ep);
  }

  // Carga un List con caché
  static Future<List<dynamic>> _cachedList(
      String ep, List<dynamic>? cache) async {
    if (cache != null) return cache;
    return _getList(ep);
  }

  static Future<List<Pokemon>> fetchAllPokemon() async {
    // Carga Maps en paralelo
    final maps = await Future.wait([
      _cachedMap('pokemon_names.json', _names),
      _cachedMap('shiny_pokemon.json', _shiny),
      _cachedMap('released_pokemon.json', _released),
      _cachedMap('nesting_pokemon.json', _nesting),
      _cachedMap('shadow_pokemon.json', _shadow),
      _cachedMap('alolan_pokemon.json', _alolan),
      _cachedMap('galarian_pokemon.json', _galarian),
      _cachedMap('pokemon_rarity.json', _rarity),
      _cachedMap('pokemon_buddy_distances.json', _buddyDist),
      _cachedMap('pokemon_candy_to_evolve.json', _candyEvolve),
      _cachedMap('pokemon_generations.json', _generations),
      _cachedMap('raid_exclusive_pokemon.json', _raidExclusive),
    ]);

    // Carga Lists en paralelo
    final lists = await Future.wait([
      _cachedList('pokemon_stats.json', _stats),
      _cachedList('pokemon_max_cp.json', _maxCp),
      _cachedList('pokemon_types.json', _types),
      _cachedList('current_pokemon_moves.json', _moves),
      _cachedList('pokemon_height_weight_scale.json', _hwScale),
      _cachedList('pokemon_evolutions.json', _evolutions),
      _cachedList('pvp_exclusive_pokemon.json', _pvpExclusive),
      _cachedList('baby_pokemon.json', _baby),
    ]);

    // Guardar en caché
    _names      = maps[0];
    _shiny      = maps[1];
    _released   = maps[2];
    _nesting    = maps[3];
    _shadow     = maps[4];
    _alolan     = maps[5];
    _galarian   = maps[6];
    _rarity     = maps[7];
    _buddyDist  = maps[8];
    _candyEvolve = maps[9];
    _generations = maps[10];
    _raidExclusive = maps[11];

    _stats       = lists[0];
    _maxCp       = lists[1];
    _types       = lists[2];
    _moves       = lists[3];
    _hwScale     = lists[4];
    _evolutions  = lists[5];
    _pvpExclusive  = lists[6];
    _baby          = lists[7];

    // ── Mapas de acceso rápido por ID ──
    final statsById = <String, dynamic>{};
    for (final s in _stats!) statsById[s['id'].toString()] = s;

    final maxCpById = <String, dynamic>{};
    for (final c in _maxCp!) maxCpById[c['id'].toString()] = c;

    final typesById = <String, List<String>>{};
    for (final t in _types!) {
      final pid = t['pokemon_id'].toString();
      if (!typesById.containsKey(pid)) {
        typesById[pid] = List<String>.from(t['type'] ?? []);
      }
    }

    final movesById = <String, dynamic>{};
    for (final m in _moves!) movesById[m['pokemon_id'].toString()] = m;

    final hwById = <String, dynamic>{};
    for (final h in _hwScale!) {
      final pid = h['pokemon_id'].toString();
      if (!hwById.containsKey(pid)) hwById[pid] = h;
    }

    final evoById = <String, List<Map<String, dynamic>>>{};
    for (final e in _evolutions!) {
      final pid = e['pokemon_id'].toString();
      evoById[pid] = List<Map<String, dynamic>>.from(e['evolutions'] ?? []);
    }

    final legendaryIds = <String>{};
    final mythicIds = <String>{};
    (_rarity!['Legendary'] as List? ?? [])
        .forEach((p) => legendaryIds.add(p['pokemon_id'].toString()));
    (_rarity!['Mythic'] as List? ?? [])
        .forEach((p) => mythicIds.add(p['pokemon_id'].toString()));

    final buddyById = <String, int>{};
    _buddyDist!.forEach((dist, list) {
      for (final p in (list as List)) {
        buddyById[p['pokemon_id'].toString()] = int.tryParse(dist) ?? 0;
      }
    });

    final candyById = <String, int>{};
    _candyEvolve!.forEach((candy, list) {
      for (final p in (list as List)) {
        candyById[p['pokemon_id'].toString()] = int.tryParse(candy) ?? 0;
      }
    });

    final genById = <String, String>{};
    _generations!.forEach((genName, list) {
      for (final p in (list as List)) {
        genById[p['id'].toString()] = genName;
      }
    });

    final pvpIds = <String>{
      ..._pvpExclusive!.map((p) => p['id'].toString())
    };

    final raidMap = <String, dynamic>{};
    _raidExclusive!.forEach((key, value) {
      raidMap[key.toString()] = value;
    });

    final babyIds = <String>{..._baby!.map((p) => p['id'].toString())};

    // ── Construir lista de Pokémon ──
    final result = <Pokemon>[];

    _names!.forEach((_, data) {
      final id  = data['id'] as int;
      final sid = id.toString();

      final stats = statsById[sid];
      final maxCp = maxCpById[sid];
      final hw    = hwById[sid];
      final moves = movesById[sid];
      final evos  = evoById[sid] ?? [];

      result.add(Pokemon(
        id:   id,
        name: data['name'] as String,
        types: typesById[sid] ?? ['Normal'],
        maxCp:       maxCp?['max_cp'] as int?,
        baseAttack:  stats != null ? int.tryParse(stats['base_attack'].toString()) : null,
        baseDefense: stats != null ? int.tryParse(stats['base_defense'].toString()) : null,
        baseStamina: stats != null ? int.tryParse(stats['base_stamina'].toString()) : null,
        isShiny:    _shiny!.containsKey(sid) || _shiny!.containsKey(id),
        isReleased: _released!.containsKey(sid) || _released!.containsKey(id),
        isNesting:  _nesting!.containsKey(sid) || _nesting!.containsKey(id),
        isShadow:   _shadow!.containsKey(sid) || _shadow!.containsKey(id),
        isAlolan:   _alolan!.containsKey(sid) || _alolan!.containsKey(id),
        isGalarian: _galarian!.containsKey(sid) || _galarian!.containsKey(id),
        isLegendary:     legendaryIds.contains(sid),
        isMythic:        mythicIds.contains(sid),
        isPvpExclusive:  pvpIds.contains(sid),
        isRaidExclusive: raidMap.containsKey(sid),
        isBaby:          babyIds.contains(sid),
        buddyDistanceKm: buddyById[sid],
        candyToEvolve:   candyById[sid],
        pokedexHeightM:  (hw?['pokedex_height'] as num?)?.toDouble(),
        pokedexWeightKg: (hw?['pokedex_weight'] as num?)?.toDouble(),
        fastMoves:    moves != null ? List<String>.from(moves['fast_moves'] ?? []) : [],
        chargedMoves: moves != null ? List<String>.from(moves['charged_moves'] ?? []) : [],
        eliteFastMoves:    moves != null ? List<String>.from(moves['elite_fast_moves'] ?? []) : [],
        eliteChargedMoves: moves != null ? List<String>.from(moves['elite_charged_moves'] ?? []) : [],
        evolutions: evos,
        generation: genById[sid],
        raidLevel:  raidMap[sid]?['raid_level'] as int?,
        possibleShiny: _shiny!.containsKey(sid),
      ));
    });

    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }
}