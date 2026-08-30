// lib/services/pogo_api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:pokedex_go/models/move_detail.dart';
import '../models/pokemon.dart';

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

  static List<MoveDetail> _parseMoves(dynamic raw, bool isFast, {bool isElite = false}) {
    if (raw is! Map) return [];
    final result = <MoveDetail>[];
    
    raw.forEach((moveKey, moveValue) {
      if (moveValue is! Map) return;
      
      final names = moveValue['names'] as Map? ?? {};
      final typeRaw = moveValue['type'];
      final combat = moveValue['combat'] as Map? ?? {};
      
      result.add(MoveDetail(
        id: moveKey.toString(),
        name: _capitalize((names['Spanish'] ?? names['English'] ?? moveKey).toString()),
        type: _normalizeType(typeRaw),
        power: _toInt(moveValue['power']) ?? 0,
        energy: _toInt(moveValue['energy']) ?? 0,
        durationMs: _toInt(moveValue['durationMs']) ?? 0,
        combatPower: _toInt(combat['power']) ?? 0,
        combatEnergy: _toInt(combat['energy']) ?? 0,
        combatTurns: _toInt(combat['turns']) ?? 0,
        isElite: isElite,
        isFast: isFast,
      ));
    });
    
    return result;
  }

    // 👇 CORREGIDO: Parseo de Mega Evoluciones con URLs específicas y fallback inteligente para formas Z
  static List<MegaEvolution> _parseMegas(Map entry, int dexNr, String pokemonName) {
    final raw = entry['megaEvolutions'];
    if (raw is! Map || raw.isEmpty) return [];
    final result = <MegaEvolution>[];
    
    raw.forEach((key, value) {
      if (value is! Map) return;
      
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
      } else if (idUpper.contains('MEGA_X') || idUpper.contains('_X')) {
        label = 'MEGA X';
      } else if (idUpper.contains('MEGA_Y') || idUpper.contains('_Y')) {
        label = 'MEGA Y';
      } else if (idUpper.contains('_Z') || idUpper.contains('MEGA_Z')) {
        label = 'MEGA Z';
      }
      
      String image = (assets['image'] ?? '').toString();
      final shinyImage = (assets['shinyImage'] ?? '').toString();
      
      // 👇 1. URLs específicas para Mega Mewtwo y Primal (que la API no sirve bien)
      if (formId == 'MEWTWO_MEGA_X') {
        image = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10043.png';
      } else if (formId == 'MEWTWO_MEGA_Y') {
        image = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10044.png';
      } else if (formId.contains('PRIMAL') && pokemonName.contains('Kyogre')) {
        image = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10077.png';
      } else if (formId.contains('PRIMAL') && pokemonName.contains('Groudon')) {
        image = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10078.png';
      }
      
      // 👇 2. URLs específicas para MEGAS de Pokémon Legends: ZA
      final megaZaMap = {
        'MEGANIUM_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10282.png',
        'EMBOAR_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10286.png',
        'FERALIGATR_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10283.png',
        'BARBARACLE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10298.png',
        'STARMIE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10280.png',
        'FLOETTE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10296.png',
        'PYROAR_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10295.png',
        'MEOWSTIC_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10314.png',
        'CLEFABLE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10278.png',
        'SCOLIPEDE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10288.png',
        'VICTREEBEL_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10279.png',
        'EXCADRILL_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10287.png',
        'DRAGONITE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10281.png',
        'MALAMAR_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10297.png',
        'DRAGALGE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10299.png',
        'FROSLASS_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10285.png',
        'EELEKTROSS_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10290.png',
        'HAWLUCHA_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10300.png',
        'SCRAFTY_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10289.png',
        'CHANDELURE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10291.png',
        'FALINKS_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10303.png',
        'SKARMORY_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10284.png',
        'DRAMPA_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10302.png',
        'ZYGARDE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10224.png',
        'SCOVILLAIN_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10320.png',
        'GLIMMORA_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10321.png',
        'TATSUGIRI_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10323.png',
        'BAXCALIBUR_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10325.png',
        'GOLISOPOD_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10316.png',
        'GOLURK_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10313.png',
        'STARAPTOR_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10308.png',
        'CRABOMINABLE_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10315.png',
        'MAGEARNA_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10317.png',
        'ZERAORA_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10319.png',
        'RAICHU_MEGA_X': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10304.png',
        'RAICHU_MEGA_Y': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10305.png',
        'CHIMECHO_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10306.png',
        'HEATRAN_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10311.png',
        'DARKRAI_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10312.png',
        'LUCARIO_MEGA_Z': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10310.png',
        'GARCHOMP_MEGA_Z': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10309.png',
        'ABSOL_MEGA_Z': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10307.png',
        'GRENINJA_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10294.png',
        'DELPHOX_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10293.png',
        'CHESNAUGHT_MEGA': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10292.png',
        // 👇 Añadidos aquí también por si el formId coincide exactamente
        'MEWTWO_MEGA_X': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10043.png',
        'MEWTWO_MEGA_Y': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10044.png',
        'KYOGRE_PRIMAL': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10077.png',
        'GROUDON_PRIMAL': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/10078.png',
      };
      
      // 3. Búsqueda exacta por formId o idUpper
      if (megaZaMap.containsKey(formId)) {
        image = megaZaMap[formId]!;
      } else if (megaZaMap.containsKey(idUpper)) {
        image = megaZaMap[idUpper]!;
      } 
      // 4. Fallback inteligente para formas Z: busca en el mapa una clave que contenga el nombre del Pokémon y termine en _Z
      else if (label == 'MEGA Z') {
        final pokemonNameUpper = pokemonName.toUpperCase().replaceAll(' ', '_');
        for (final mapEntry in megaZaMap.entries) {
          if (mapEntry.key.contains(pokemonNameUpper) && mapEntry.key.endsWith('_Z')) {
            image = mapEntry.value;
            break;
          }
        }
      }
      
      final atk = _toInt(stats['attack']) ?? 0;
      final def = _toInt(stats['defense']) ?? 0;
      final sta = _toInt(stats['stamina']) ?? 0;
      
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

  // 👇 NUEVO: Parsear formas alternativas (Kyurem Blanco/Negro, Shaymin Cielo, etc.)
  static List<Map<String, dynamic>> _parseAlternateForms(Map entry, int dexNr) {
    final result = <Map<String, dynamic>>[];
    
    final regionForms = entry['regionForms'];
    if (regionForms is Map) {
      regionForms.forEach((formKey, formValue) {
        if (formValue is! Map) return;
        final formIdUpper = formKey.toString().toUpperCase();
        if (formIdUpper.contains('MEGA') || formIdUpper.contains('TEMP_EVOLUTION')) return;
        
        final stats = formValue['stats'] as Map? ?? {};
        final assets = formValue['assets'] as Map? ?? {};
        final names = formValue['names'] as Map? ?? {};
        
        final types = <String>[];
        final pType = _normalizeType(formValue['primaryType']);
        if (pType.isNotEmpty) types.add(pType);
        final sType = _normalizeType(formValue['secondaryType']);
        if (sType.isNotEmpty) types.add(sType);
        
        final image = (assets['image'] ?? '').toString();
        final name = names['Spanish'] ?? names['English'] ?? formKey.toString();
        
        result.add({
          'id': formKey,
          'name': _capitalize(name),
          'attack': _toInt(stats['attack']) ?? 0,
          'defense': _toInt(stats['defense']) ?? 0,
          'stamina': _toInt(stats['stamina']) ?? 0,
          'types': types,
          'imageUrl': image,
        });
      });
    }
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
          'lure_required': e['lureModule'],
          'only_evolves_in_daytime': e['onlyDaytime'] == true,
          'only_evolves_in_nighttime': e['onlyNighttime'] == true,
          'must_be_buddy_to_evolve': e['mustBeBuddy'] == true,
          'buddy_distance_required': _toInt(e['buddyDistance']),
        };
      }).toList();

      final megas = _parseMegas(entry, dexNr, name);
      final alternateForms = _parseAlternateForms(entry, dexNr);

      final genRaw = entry['generation']?.toString().replaceFirst('GENERATION_', '') ?? '';

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
        isNesting: false,
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
        fastMoves: _parseMoves(entry['quickMoves'], true),
        chargedMoves: _parseMoves(entry['cinematicMoves'], false),
        eliteFastMoves: _parseMoves(entry['eliteQuickMoves'], true, isElite: true),
        eliteChargedMoves: _parseMoves(entry['eliteCinematicMoves'], false, isElite: true),
        evolutions: evolutions,
        generation: genRaw.isNotEmpty ? 'Generación $genRaw' : null,
        raidLevel: null,
        possibleShiny: shinyImageUrl.isNotEmpty,
        assetImageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        assetShinyImageUrl: shinyImageUrl.isNotEmpty ? shinyImageUrl : null,
        megaEvolutions: megas,
        alternateForms: alternateForms,
      ));
    }

    if (result.isEmpty) {
      developer.log(
        'AVISO: fetchAllPokemon devolvió 0 elementos.',
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
      (e) => _toInt(e['dexNr'] ?? e['dex_nr']) == 149,
      orElse: () => null,
    );
    if (charizard == null) {
      print('❌ No se encontró Charizard (dexNr 6) en la respuesta.');
      return;
    }
    print(' Claves de nivel superior: ${charizard.keys.toList()}');
    final possibleKeys = ['temporaryEvolutions', 'tempEvolutions', 'megaEvolutions', 'forms'];
    for (final k in possibleKeys) {
      if (charizard[k] != null) {
        print('✅ Encontrado en "$k":');
        print(charizard[k]);
      }
    }
  }
}