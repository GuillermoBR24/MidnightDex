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
  static List<dynamic>?        _stats;
  static List<dynamic>?        _maxCp;
  static List<dynamic>?        _types;
  static List<dynamic>?        _moves;
  static List<dynamic>?        _hwScale;
  static List<dynamic>?        _evolutions;
  static Map<String, dynamic>? _generations;
  static List<dynamic>?        _pvpExclusive;
  static List<dynamic>?        _raidExclusive;
  static List<dynamic>?        _baby;

  static Future<Map<String, dynamic>> _getMap(String ep) async {
    final r = await http.get(Uri.parse('$_base/$ep'));
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Error $ep');
  }

  static Future<List<dynamic>> _getList(String ep) async {
    final r = await http.get(Uri.parse('$_base/$ep'));
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('Error $ep');
  }

  static Future<List<Pokemon>> fetchAllPokemon() async {
    // Carga en paralelo todos los endpoints
    final res = await Future.wait([
      _names    ?? _getMap('pokemon_names.json'),
      _shiny    ?? _getMap('shiny_pokemon.json'),
      _released ?? _getMap('released_pokemon.json'),
      _nesting  ?? _getMap('nesting_pokemon.json'),
      _shadow   ?? _getMap('shadow_pokemon.json'),
      _alolan   ?? _getMap('alolan_pokemon.json'),
      _galarian ?? _getMap('galarian_pokemon.json'),
      _rarity   ?? _getMap('pokemon_rarity.json'),
      _buddyDist  ?? _getMap('pokemon_buddy_distances.json'),
      _candyEvolve ?? _getMap('pokemon_candy_to_evolve.json'),
      _generations ?? _getMap('pokemon_generations.json'),
    ] as Iterable<Future>);

    final listRes = await Future.wait([
      _stats      ?? _getList('pokemon_stats.json'),
      _maxCp      ?? _getList('pokemon_max_cp.json'),
      _types      ?? _getList('pokemon_types.json'),
      _moves      ?? _getList('current_pokemon_moves.json'),
      _hwScale    ?? _getList('pokemon_height_weight_scale.json'),
      _evolutions ?? _getList('pokemon_evolutions.json'),
      _pvpExclusive  ?? _getList('pvp_exclusive_pokemon.json'),
      _raidExclusive ?? _getList('raid_exclusive_pokemon.json'),
      _baby          ?? _getList('baby_pokemon.json'),
    ] as Iterable<Future>);

    _names    = res[0] as Map<String, dynamic>;
    _shiny    = res[1] as Map<String, dynamic>;
    _released = res[2] as Map<String, dynamic>;
    _nesting  = res[3] as Map<String, dynamic>;
    _shadow   = res[4] as Map<String, dynamic>;
    _alolan   = res[5] as Map<String, dynamic>;
    _galarian = res[6] as Map<String, dynamic>;
    _rarity   = res[7] as Map<String, dynamic>;
    _buddyDist   = res[8] as Map<String, dynamic>;
    _candyEvolve = res[9] as Map<String, dynamic>;
    _generations = res[10] as Map<String, dynamic>;

    _stats      = listRes[0] as List<dynamic>;
    _maxCp      = listRes[1] as List<dynamic>;
    _types      = listRes[2] as List<dynamic>;
    _moves      = listRes[3] as List<dynamic>;
    _hwScale    = listRes[4] as List<dynamic>;
    _evolutions = listRes[5] as List<dynamic>;
    _pvpExclusive  = listRes[6] as List<dynamic>;
    _raidExclusive = listRes[7] as List<dynamic>;
    _baby          = listRes[8] as List<dynamic>;

    // --- Mapas de acceso rápido ---
    final statsById  = <String, dynamic>{};
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
    for (final h in _hwScale!) hwById[h['pokemon_id'].toString()] = h;

    final evoById = <String, List<Map<String, dynamic>>>{};
    for (final e in _evolutions!) {
      final pid = e['pokemon_id'].toString();
      evoById[pid] = List<Map<String, dynamic>>.from(e['evolutions'] ?? []);
    }

    // Legendarios / Mythics
    final legendaryIds = <String>{};
    final mythicIds    = <String>{};
    (_rarity!['Legendary'] as List? ?? []).forEach((p) =>
        legendaryIds.add(p['pokemon_id'].toString()));
    (_rarity!['Mythic'] as List? ?? []).forEach((p) =>
        mythicIds.add(p['pokemon_id'].toString()));

    // Buddy distances
    final buddyById = <String, int>{};
    _buddyDist!.forEach((dist, list) {
      for (final p in (list as List)) {
        buddyById[p['pokemon_id'].toString()] = int.tryParse(dist) ?? 0;
      }
    });

    // Candy to evolve
    final candyById = <String, int>{};
    _candyEvolve!.forEach((candy, list) {
      for (final p in (list as List)) {
        candyById[p['pokemon_id'].toString()] = int.tryParse(candy) ?? 0;
      }
    });

    // Generations
    final genById = <String, String>{};
    _generations!.forEach((genName, list) {
      for (final p in (list as List)) {
        genById[p['id'].toString()] = genName;
      }
    });

    // PVP / Raid exclusive / Baby
    final pvpIds  = <String>{..._pvpExclusive!.map((p) => p['id'].toString())};
    final raidMap = <String, dynamic>{};
    for (final p in _raidExclusive!) raidMap[p['id'].toString()] = p;
    final babyIds = <String>{..._baby!.map((p) => p['id'].toString())};

    // Construir lista
    final list = <Pokemon>[];
    _names!.forEach((_, data) {
      final id  = data['id'] as int;
      final sid = id.toString();

      final stats = statsById[sid];
      final maxCp = maxCpById[sid];
      final hw    = hwById[sid];
      final moves = movesById[sid];
      final evos  = evoById[sid] ?? [];

      list.add(Pokemon(
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
        isLegendary:    legendaryIds.contains(sid),
        isMythic:       mythicIds.contains(sid),
        isPvpExclusive: pvpIds.contains(sid),
        isRaidExclusive: raidMap.containsKey(sid),
        isBaby:     babyIds.contains(sid),
        buddyDistanceKm: buddyById[sid],
        candyToEvolve:   candyById[sid],
        pokedexHeightM:  hw?['pokedex_height'] as double?,
        pokedexWeightKg: hw?['pokedex_weight'] as double?,
        fastMoves:    moves != null ? List<String>.from(moves['fast_moves'] ?? []) : [],
        chargedMoves: moves != null ? List<String>.from(moves['charged_moves'] ?? []) : [],
        eliteFastMoves:    moves != null ? List<String>.from(moves['elite_fast_moves'] ?? []) : [],
        eliteChargedMoves: moves != null ? List<String>.from(moves['elite_charged_moves'] ?? []) : [],
        evolutions: evos,
        generation: genById[sid],
        raidLevel:  raidMap[sid]?['raid_level'] as int?,
        possibleShiny: _shiny!.containsKey(sid) ? true : false,
      ));
    });

    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }
}