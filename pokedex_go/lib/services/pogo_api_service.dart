// lib/services/pogo_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

/// Fuente única de datos de Pokédex: Pokemon GO API (comunidad, basada en
/// GameMaster de Niantic). https://github.com/pokemon-go-api/pokemon-go-api
class PogoApiService {
  static const String _pokedexUrl =
      'https://pokemon-go-api.github.io/pokemon-go-api/api/pokedex.json';

  static List<dynamic>? _rawCache;
  static List<Pokemon>? _pokemonCache;

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
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

  /// "POKEMON_TYPE_GRASS" / "grass" -> "Grass"
  static String _normalizeType(dynamic raw) {
    if (raw == null) return '';
    final s = raw is Map ? (raw['type'] ?? raw['id'] ?? '').toString() : raw.toString();
    return _capitalize(s.replaceFirst('POKEMON_TYPE_', ''));
  }

  static Future<List<dynamic>> _fetchRaw() async {
    if (_rawCache != null) return _rawCache!;
    try {
      final r = await http
          .get(Uri.parse(_pokedexUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 25));
      if (r.statusCode != 200) {
        throw Exception('HTTP ${r.statusCode} al obtener pokedex.json');
      }
      final decoded = json.decode(utf8.decode(r.bodyBytes));
      final list = decoded is List
          ? decoded
          : (decoded is Map ? (decoded['pokemon'] ?? decoded['pokedex'] ?? []) : []);
      _rawCache = List<dynamic>.from(list);
      return _rawCache!;
    } on TimeoutException {
      throw Exception('Timeout al conectar con Pokemon GO API');
    } catch (e) {
      throw Exception('Error cargando la Pokédex: $e');
    }
  }

  static List<String> _movesFromList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((m) => (m is Map ? (m['name'] ?? m['id'] ?? '') : m).toString())
        .where((s) => s.isNotEmpty)
        .map((s) => _capitalize(s.replaceAll('_FAST', '').replaceAll('_', ' ')))
        .toList();
  }

  static List<MegaEvolution> _parseMegas(Map entry, int dexNr, String pokemonName) {
    final raw = entry['megaEvolutions'];
    if (raw is! Map || raw.isEmpty) return [];

    final result = <MegaEvolution>[];

    raw.forEach((key, value) {
      if (value is! Map) return;

      // El id real puede venir en la propia clave del mapa o en value['id']
      final formId = (value['id'] ?? key).toString();
      final idUpper = formId.toUpperCase();

      final stats = value['stats'] as Map? ?? {};
      final assets = value['assets'] as Map? ?? {};

      final typePrimary = _normalizeType(value['primaryType']);
      final typeSecondary =
          value['secondaryType'] != null ? _normalizeType(value['secondaryType']) : null;

      String label = 'MEGA';
      if (idUpper.contains('PRIMAL')) {
        label = 'PRIMIGENIO';
      } else if (idUpper.contains('MEGA_X')) {
        label = 'MEGA X';
      } else if (idUpper.contains('MEGA_Y')) {
        label = 'MEGA Y';
      }

      final image = (assets['image'] ?? '').toString();
      final shinyImage = (assets['shinyImage'] ?? '').toString();

      final atk = _toInt(stats['attack']) ?? 0;
      final def = _toInt(stats['defense']) ?? 0;
      final sta = _toInt(stats['stamina']) ?? 0;

      if (image.isEmpty) {
        developer.log(
          '⚠️ Mega "$formId" de "$pokemonName" sin imagen utilizable. Claves: ${value.keys.toList()}',
          name: 'PogoApiService',
        );
      }

      result.add(MegaEvolution(
        formId: formId,
        label: label,
        attack: atk,
        defense: def,
        stamina: sta,
        types: [
          typePrimary,
          if (typeSecondary != null && typeSecondary.isNotEmpty) typeSecondary,
        ],
        imageUrl: image.isNotEmpty
            ? image
            : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$dexNr.png',
        shinyImageUrl: shinyImage.isNotEmpty ? shinyImage : null,
      ));
    });

    return result;
  }

  static Future<List<Pokemon>> fetchAllPokemon() async {
    if (_pokemonCache != null) return _pokemonCache!;

    final raw = await _fetchRaw();
    final result = <Pokemon>[];

    for (final entry in raw) {
      if (entry is! Map) continue;

      final dexNr = _toInt(entry['dexNr'] ?? entry['dex_nr']) ?? 0;
      if (dexNr <= 0) continue;

      final names = entry['names'] as Map? ?? {};
      final name = (names['English'] ?? entry['id'] ?? 'Pokémon #$dexNr').toString();

      final stats = entry['stats'] as Map? ?? {};
      final typePrimary = _normalizeType(entry['primaryType']);
      final typeSecondary =
          entry['secondaryType'] != null ? _normalizeType(entry['secondaryType']) : null;

      final assets = entry['assets'] as Map? ?? {};
      final imageUrl = (assets['image'] ?? '').toString();
      final shinyImageUrl = (assets['shinyImage'] ?? '').toString();

      final classRaw = (entry['pokemonClass'] ?? '').toString().toUpperCase();
      final isLegendary = classRaw.contains('LEGENDARY');
      final isMythic = classRaw.contains('MYTHIC');
      final isBaby = classRaw.contains('BABY');
      final isShadowAvailable = entry['isShadow'] == true;

      final evolutionsRaw = entry['evolutions'] as List? ?? [];
      final evolutions = evolutionsRaw.whereType<Map>().map<Map<String, dynamic>>((e) {
        final evoNames = e['names'] as Map? ?? {};
        return {
          'pokemon_name': _capitalize((evoNames['English'] ?? e['id'] ?? '').toString()),
          'candy_required': _toInt(e['candyCost']),
          'item_required': e['formChangeItem'],
        };
      }).toList();

      final megas = _parseMegas(entry, dexNr, name);

      result.add(Pokemon(
        id: dexNr,
        name: _capitalize(name),
        types: [
          typePrimary,
          if (typeSecondary != null && typeSecondary.isNotEmpty) typeSecondary,
        ],
        baseAttack: _toInt(stats['attack']),
        baseDefense: _toInt(stats['defense']),
        baseStamina: _toInt(stats['stamina']),
        isShiny: shinyImageUrl.isNotEmpty,
        isReleased: entry['released'] != false,
        isNesting: false, // no disponible en esta API
        isShadow: isShadowAvailable,
        isAlolan: name.toLowerCase().contains('alolan'),
        isGalarian: name.toLowerCase().contains('galarian'),
        isLegendary: isLegendary,
        isMythic: isMythic,
        isPvpExclusive: false,
        isRaidExclusive: false,
        isBaby: isBaby,
        buddyDistanceKm: _toInt(entry['buddyDistanceKm']),
        candyToEvolve: _toInt(entry['candyToEvolve']),
        pokedexHeightM: (entry['height'] as num?)?.toDouble(),
        pokedexWeightKg: (entry['weight'] as num?)?.toDouble(),
        fastMoves: _movesFromList(entry['quickMoves']),
        chargedMoves: _movesFromList(entry['cinematicMoves']),
        eliteFastMoves: _movesFromList(entry['eliteQuickMoves']),
        eliteChargedMoves: _movesFromList(entry['eliteCinematicMoves']),
        evolutions: evolutions,
        generation: entry['generation']?.toString().replaceFirst('GENERATION_', ''),
        raidLevel: null,
        possibleShiny: shinyImageUrl.isNotEmpty,
        assetImageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        assetShinyImageUrl: shinyImageUrl.isNotEmpty ? shinyImageUrl : null,
        megaEvolutions: megas,
      ));
    }

    if (result.isEmpty) {
      developer.log(
        'AVISO: fetchAllPokemon devolvió 0 elementos. Revisa los nombres de '
        'campo del JSON real de pokedex.json (puede que hayan cambiado).',
        name: 'PogoApiService',
      );
    }

    result.sort((a, b) => a.id.compareTo(b.id));
    _pokemonCache = result;
    return result;
  }

  static Future<void> debugPrintMegaStructure() async {
    final raw = await _fetchRaw();
    final charizard = raw.firstWhere(
      (e) => _toInt(e['dexNr'] ?? e['dex_nr']) == 6,
      orElse: () => null,
    );
    if (charizard == null) {
      print('❌ No se encontró Charizard (dexNr 6) en la respuesta.');
      return;
    }
    print('🔑 Claves de nivel superior: ${charizard.keys.toList()}');
    final possibleKeys = ['temporaryEvolutions', 'tempEvolutions', 'megaEvolutions', 'forms'];
    for (final k in possibleKeys) {
      if (charizard[k] != null) {
        print('✅ Encontrado en "$k":');
        print(charizard[k]);
      }
    }
  }
}