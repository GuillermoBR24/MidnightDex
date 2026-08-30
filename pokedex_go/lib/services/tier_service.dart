// lib/services/tier_service.dart
import 'dart:developer' as developer;
import 'package:pokedex_go/models/pokemon.dart';
import 'package:pokedex_go/services/pogo_api_service.dart';
import '../models/tier_entry.dart';

class TierService {
  static Map<String, List<TierEntry>>? _byTypeCache;
  static List<TierEntry>? _megaCache;

  static const Map<String, List<String>> _hardcodedTop = {
    'Bug': ['Mega Pinsir', 'Mega Heracross', 'Mega Beedrill', 'Pheromosa', 'Pinsir Shadow', 'Scizor Shadow', 'Mega Scizor', 'Volcarona', 'Scyther Shadow', 'Vikavolt'],
    'Dark': ['Mega Absol', 'Mega Tyranitar', 'Tyranitar Shadow', 'Absol', 'Mega Houndoom', 'Weavile Shadow Dark', 'Salamence Shadow Dark', 'Hydreigon', 'Honchkrow', 'Mega Salamence'],
    'Dragon': ['Eternatus', 'Mega Rayquaza', 'Mega Garchomp', 'Garchomp Shadow', 'Palkia Shadow', 'Salamence Shadow', 'Dragonite Shadow', 'Palkia Origen', 'Mega Salamence Dragon', 'Dialga Shadow Dragon'],
    'Electric': ['Regieleki', 'Raikou Shadow', 'Electivire Shadow', 'Xurkitree', 'Mega Manectric', 'Thundurus Totem', 'Zapdos Shadow', 'Magnezone Shadow', 'Zekrom', 'Luxray Shadow'],
    'Fairy': ['Mega Gardevoir', 'Zacian', 'Gardevoir Shadow', 'Mega Alakazam Fairy', 'Enamorus', 'Xurkitree Fairy', 'Grandbull Shadow', 'Xerneas', 'Alakazam Shadow', 'Gardevoir'],
    'Fighting': ['Mega Lucario', 'Mega Blaziken', 'Lucario', 'Mega Heracross Fighting', 'Conkeldurr Shadow', 'Terrakion', 'Machamp Shadow', 'Mega Alakazam', 'Hariyama Shadow', 'Keldeo'],
    'Fire': ['Mega Blaziken Fire', 'Mega Charizard Y', 'Heatran Shadow', 'Blaziken Shadow', 'Chandelure Shadow', 'Darmanitan Shadow', 'Emboar Shadow', 'Moltres Shadow', 'Reshiram', 'Charizard Shadow'],
    'Flying': ['Mega Rayquaza Flying', 'Rayquaza', 'Salamence Shadow Flying', 'Staraptor Shadow', 'Moltres Shadow Flying', 'Mega Salamence Flying', 'Mega Pidgeot', 'Yveltal', 'Enamorus Flying', 'Honchkrow Shadow'],
    'Ghost': ['Mega Gengar', 'Necrozma (Lunala)', 'Chandelure Shadow Ghost', 'Gengar Shadow Ghost', 'Mega Banette', 'Mewtwo Shadow Ghost', 'Blacephalon', 'Gengar', 'Chandelure', 'Dragapult'],
    'Grass': ['Mega Sceptile', 'Kartana', 'Shaymin (cielo)', 'Mega Venusaur', 'Venusaur Shadow', 'Sceptile Shadow', 'Tangrowth Shadow', 'Torterra Shadow', 'Zarude', 'Meowscarada'],
    'Ground': ['Primal Groudon', 'Mega Garchomp', 'Groudon Shadow', 'Garchomp Shadow Ground', 'Excadrill Shadow', 'Landorus', 'Mamoswine Shadow', 'Rhyperior Shadow', 'Groudon', 'Golurk Shadow'],
    'Ice': ['Kyurem Blanco', 'Kyurem Negro', 'Mamoswine Shadow Ice', 'Weavile Shadow', 'Mewtwo Shadow Ice', 'Darmanitan', 'Baxcalibur', 'Mega Glalie', 'Mega Abomasnow', 'Mamoswine'],
    'Poison': ['Mega Beedrill Poison', 'Mega Gengar Poison', 'Eternatus Poison', 'Naganadel', 'Nihilego', 'Toxicroak Shadow', 'Roserade', 'Victreebel Shadow', 'Vileplume Shadow', 'Skuntank Shadow'],
    'Psychic': ['Mewtwo Shadow', 'Mega Alakazam Psychic', 'Mewtwo', 'Mega Gallade/Gardevoir', 'Mega Latios', 'Hoopa (Desatado)', 'Alakazam Shadow Psychic', 'Latios Shadow', 'Metagross Shadow', 'Exeggutor Shadow'],
    'Rock': ['Rampardos Shadow', 'Mega Diancie', 'Rhyperior Shadow Rock', 'Tyrantrum Shadow', 'Mega Tyranitar Rock', 'Gigalith Shadow', 'Mega Aerodactyl', 'Tyranitar Shadow', 'Rampardos', 'Rhyperior'],
    'Steel': ['Zacian Steel', 'Zamazenta', 'Necrozma (Solgaleo)', 'Metagross Shadow Steel', 'Dialga Shadow', 'Metagross', 'Excadrill Shadow', 'Dialga', 'Dialga Origen Steel', 'Mega Lucario Steel'],
    'Water': ['Primal Kyogre', 'Kyogre Shadow', 'Mega Swampert', 'Mega Blastoise', 'Swampert Shadow', 'Samurott Shadow', 'Empoleon Shadow', 'Feraligatr Shadow', 'Mega Gyarados', 'Kyogre'],
  };

  static const Map<String, String> _hardcodedMegas = {
    'Bug': 'Mega Pinsir', 'Dark': 'Mega Absol', 'Dragon': 'Mega Rayquaza', 'Electric': 'Mega Manectric',
    'Fairy': 'Mega Gardevoir', 'Fighting': 'Mega Lucario', 'Fire': 'Mega Blaziken', 'Flying': 'Mega Rayquaza Flying',
    'Ghost': 'Mega Gengar', 'Grass': 'Mega Sceptile', 'Ground': 'Primal Groudon', 'Ice': 'Mega Glalie',
    'Poison': 'Mega Beedrill', 'Psychic': 'Mega Alakazam', 'Rock': 'Mega Diancie', 'Steel': 'Mega Lucario Steel', 'Water': 'Primal Kyogre',
  };

  static const Map<String, List<String>> _hardcodedMoves = {
    'Shaymin (cielo)': ['Hoja Mágica', 'Hierba Lazo'],
    'Primal Groudon': ['Disparo Lodo', 'Filo del Abismo*'],
    'Primal Kyogre': ['Cascada', 'Pulso Primigenio*'],
    'Kyurem Blanco': ['Colmillo Hielo', 'Llama gelida'],
    'Kyurem Negro': ['Cola Dragón', 'Rayo Gélido'],
    'Palkia Origen': ['Cola Dragón', 'Corte Vacío'],
    'Dialga Origen': ['Garra Metal', 'Cabeza de Hierro'],
    'Necrozma (Lunala)': ['Garra Umbría', 'Rayo Umbrío'],
    'Necrozma (Solgaleo)': ['Garra Metal', 'MeteoImpacto'],
    'Hoopa (Desatado)': ['Confusión', 'Psíquico'],
  };

  static String _slug(String s) => s.toLowerCase().replaceAll(RegExp(r'\(.*?\)'), '').trim();

  static String _assignTier(int rank) {
    if (rank <= 2) return 'S';
    if (rank <= 5) return 'A';
    if (rank <= 8) return 'B';
    return 'C';
  }

  static Pokemon? _findPokemon(List<Pokemon> all, String keyBase) {
    final key = _slug(keyBase);
    for (final p in all) {
      if (_slug(p.name) == key) return p;
    }
    for (final p in all) {
      final n = _slug(p.name);
      if (n.contains(key) || key.contains(n)) return p;
    }
    final firstWord = key.split(' ').first;
    for (final p in all) {
      if (_slug(p.name).split(' ').first == firstWord) return p;
    }
    return null;
  }

  static MegaEvolution? _findMega(Pokemon p, String rawName) {
    if (p.megaEvolutions.isEmpty) return null;
    if (p.megaEvolutions.length == 1) return p.megaEvolutions.first;
    final nameLower = rawName.toLowerCase();
    if (nameLower.contains(' x') || nameLower.endsWith('x')) {
      return p.megaEvolutions.firstWhere((m) => m.label.toUpperCase().contains('X'), orElse: () => p.megaEvolutions.first);
    }
    if (nameLower.contains(' y') || nameLower.endsWith('y')) {
      return p.megaEvolutions.firstWhere((m) => m.label.toUpperCase().contains('Y'), orElse: () => p.megaEvolutions.first);
    }
    if (nameLower.contains('primal') || nameLower.contains('primigenio')) {
      return p.megaEvolutions.firstWhere((m) => m.label.toUpperCase().contains('PRIMIGENIO'), orElse: () => p.megaEvolutions.first);
    }
    return p.megaEvolutions.first;
  }

  static Map<String, dynamic>? _findAlternateForm(Pokemon p, String rawName) {
    final nameLower = rawName.toLowerCase();
    for (final form in p.alternateForms) {
      final formId = (form['id'] ?? '').toString().toLowerCase();
      final formName = (form['name'] ?? '').toString().toLowerCase();
      if (formId.contains(nameLower) || 
          nameLower.contains(formId) ||
          formName.contains(nameLower) ||
          nameLower.contains(formName)) {
        return form;
      }
    }
    return null;
  }

  static Future<(Map<String, List<TierEntry>>, List<TierEntry>)> fetchTierData() async {
    if (_byTypeCache != null && _megaCache != null) {
      return (_byTypeCache!, _megaCache!);
    }

    final allPokemon = await PogoApiService.fetchAllPokemon();
    final byTypeFinal = <String, List<TierEntry>>{};

    _hardcodedTop.forEach((type, names) {
      final entries = <TierEntry>[];
      for (int i = 0; i < names.length; i++) {
        final rawName = names[i];
        final key = rawName.toLowerCase();

        final isMegaForm = key.contains('mega') || key.contains('primal') || key.contains('primigenio');
        final isShadowForm = key.contains('shadow');
        final isAlternateForm = 
            key.contains('cielo') || 
            key.contains('blanco') || 
            key.contains('negro') || 
            key.contains('origen') ||
            key.contains('desatado') ||
            key.contains('lunala') ||
            key.contains('solgaleo');

        final displayName = rawName
            .replaceAll(RegExp(r'\s*shadow\s*', caseSensitive: false), '')
            .replaceAll(RegExp(r'\s*mega\s*', caseSensitive: false), '')
            .replaceAll(RegExp(r'\s*primal\s*', caseSensitive: false), '')
            .trim();

        final pokemon = _findPokemon(allPokemon, displayName);

        Map<String, dynamic>? alternateForm;
        if (isAlternateForm && pokemon != null) {
          alternateForm = _findAlternateForm(pokemon, rawName);
        }

        final mega = (isMegaForm && pokemon != null && alternateForm == null)
            ? _findMega(pokemon, rawName)
            : null;

        int id, atk, def, sta, cp;
        List<String> pokTypes;
        String? imageOverride;

        if (alternateForm != null) {
          id = pokemon!.id;
          atk = (alternateForm['attack'] as int? ?? 0);
          def = (alternateForm['defense'] as int? ?? 1);
          sta = (alternateForm['stamina'] as int? ?? 0);
          pokTypes = (alternateForm['types'] as List?)?.cast<String>() ?? pokemon.types;
          imageOverride = (alternateForm['imageUrl'] as String? ?? '');
          cp = Pokemon.calcCp(atk, def, sta);
        } else if (mega != null) {
          id = pokemon!.id;
          atk = mega.attack;
          def = mega.defense == 0 ? 1 : mega.defense;
          sta = mega.stamina;
          pokTypes = mega.types;
          imageOverride = mega.imageUrl;
          cp = Pokemon.calcCp(atk, def, sta);
        } else if (pokemon != null) {
          id = pokemon.id;
          atk = pokemon.baseAttack ?? 0;
          def = pokemon.baseDefense ?? 1;
          sta = pokemon.baseStamina ?? 0;
          if (isShadowForm) atk = (atk * 1.2).toInt();
          pokTypes = pokemon.types.isNotEmpty ? pokemon.types : [type];
          imageOverride = pokemon.imageUrl;
          cp = pokemon.maxCp ?? Pokemon.calcCp(atk, def, sta);
        } else {
          developer.log('No se encontró "$rawName" en la Pokemon GO API', name: 'TierService');
          id = 800 + entries.length;
          atk = 0;
          def = 1;
          sta = 0;
          pokTypes = [type];
          cp = 0;
        }

        final hardcodedMoves = _hardcodedMoves[rawName];
        
        // 👇 CORRECCIÓN: Manejar correctamente List<MoveDetail> vs List<String>
        List<String> fasts;
        if (hardcodedMoves != null) {
          fasts = [hardcodedMoves[0]];
        } else if (pokemon != null) {
          fasts = pokemon.fastMoves.map((m) => m.name).toList();
        } else {
          fasts = [];
        }

        List<String> charged;
        if (hardcodedMoves != null && hardcodedMoves.length > 1) {
          charged = [hardcodedMoves[1]];
        } else if (pokemon != null) {
          charged = pokemon.chargedMoves.map((m) => m.name).toList();
        } else {
          charged = [];
        }

        final rank = entries.length + 1;
        entries.add(TierEntry(
          id: id,
          name: displayName,
          types: pokTypes,
          baseAttack: atk,
          baseDefense: def,
          baseStamina: sta,
          maxCp: cp,
          score: (10 - entries.length).toDouble(),
          isMega: mega != null,
          isShadow: isShadowForm,
          isLegendary: pokemon?.isLegendary ?? false,
          isMythic: pokemon?.isMythic ?? false,
          tier: _assignTier(rank),
          bestFastMove: fasts.isNotEmpty ? fasts.first : null,
          bestChargedMove: charged.isNotEmpty ? charged.first : null,
          imageUrlOverride: imageOverride,
        ));
      }
      if (entries.isNotEmpty) byTypeFinal[type] = entries;
    });

    final megaFinal = <TierEntry>[];
    _hardcodedMegas.forEach((type, megaName) {
      final keyBase = megaName.replaceAll(RegExp(r'mega|primal', caseSensitive: false), '').trim();
      final pokemon = _findPokemon(allPokemon, keyBase);
      final mega = pokemon != null ? _findMega(pokemon, megaName) : null;

      final atk = mega?.attack ?? 0;
      final def = mega?.defense ?? 1;
      final sta = mega?.stamina ?? 0;

      final hardcodedMegaMoves = _hardcodedMoves[megaName];
      
      List<String> fasts = [];
      if (hardcodedMegaMoves != null && hardcodedMegaMoves.isNotEmpty) {
        fasts = [hardcodedMegaMoves[0]];
      }
      
      List<String> charged = [];
      if (hardcodedMegaMoves != null && hardcodedMegaMoves.length > 1) {
        charged = [hardcodedMegaMoves[1]];
      }

      megaFinal.add(TierEntry(
        id: pokemon?.id ?? (900 + megaFinal.length),
        name: megaName,
        types: mega?.types ?? [type],
        baseAttack: atk,
        baseDefense: def,
        baseStamina: sta,
        maxCp: Pokemon.calcCp(atk, def, sta),
        score: def > 0 ? (atk * atk * sta.toDouble()) / def : 0,
        isMega: true,
        isShadow: false,
        isLegendary: false,
        isMythic: false,
        tier: 'S',
        bestFastMove: fasts.isNotEmpty ? fasts.first : null,
        bestChargedMove: charged.isNotEmpty ? charged.first : null,
        imageUrlOverride: mega?.imageUrl,
        tierType: type,
      ));
    });

    megaFinal.sort((a, b) => b.score.compareTo(a.score));

    _byTypeCache = byTypeFinal;
    _megaCache = megaFinal;
    return (byTypeFinal, megaFinal);
  }
}