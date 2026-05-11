import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/foundation.dart';
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
      'Mega Pinsir',
      'Mega Heracross',
      'Mega Beedrill',
      'Pheromosa',
      'Pinsir Shadow',
      'Scizor Shadow',
      'Mega Scizor',
      'Volcarona',
      'Scyther Shadow',
      'Vikavolt',
    ],
    'Dark': [
      'Mega Absol',
      'Mega Tyranitar',
      'Tyranitar Shadow',
      'Absol',
      'Mega Houndoom',
      'Weavile Shadow Dark',
      'Salamence Shadow Dark',
      'Hydreigon',
      'Honchkrow',
      'Mega Salamence',
    ],
    'Dragon': [
      'Eternatus',
      'Mega Rayquaza',
      'Mega Garchomp',
      'Garchomp Shadow',
      'Palkia Shadow',
      'Salamence Shadow',
      'Dragonite Shadow',
      'Palkia Origen',
      'Mega Salamence Dragon',
      'Dialga Shadow Dragon',
    ],
    'Electric': [
      'Regieleki',
      'Raikou Shadow',
      'Electivire Shadow',
      'Xurkitree',
      'Mega Manectric',
      'Thundurus Totem',
      'Zapdos Shadow',
      'Magnezone Shadow',
      'Zekrom',
      'Luxray Shadow',
    ],
    'Fairy': [
      'Mega Gardevoir',
      'Zacian',
      'Gardevoir Shadow',
      'Mega Alakazam Fairy',
      'Enamorus',
      'Xurkitree Fairy',
      'Grandbull Shadow',
      'Xerneas',
      'Alakazam Shadow',
      'Gardevoir',
    ],
    'Fighting': [
      'Mega Lucario',
      'Mega Blaziken',
      'Lucario',
      'Mega Heracross Fighting',
      'Conkeldurr Shadow',
      'Terrakion',
      'Machamp Shadow',
      'Mega Alakazam',
      'Hariyama Shadow',
      'Keldeo',
    ],
    'Fire': [
      'Mega Blaziken Fire',
      'Mega Charizard Y',
      'Heatran Shadow',
      'Blaziken Shadow',
      'Chandelure Shadow',
      'Darmanitan Shadow',
      'Emboar Shadow',
      'Moltres Shadow',
      'Reshiram',
      'Charizard Shadow',
    ],
    'Flying': [
      'Mega Rayquaza Flying',
      'Rayquaza',
      'Salamence Shadow Flying',
      'Staraptor Shadow',
      'Moltres Shadow Flying',
      'Mega Salamence Flying',
      'Mega Pidgeot',
      'Yveltal',
      'Enamorus Flying',
      'Honchkrow Shadow',
    ],
    'Ghost': [
      'Mega Gengar',
      'Necrozma (Lunala)',
      'Chandelure Shadow Ghost',
      'Gengar Shadow Ghost',
      'Mega Bannete',
      'Mewtwo Shadow Ghost',
      'Blacephalon',
      'Gengar',
      'Chandelure',
      'Dragapult',
    ],
    'Grass': [
      'Mega Sceptile',
      'Kartana',
      'Shaymin (cielo)',
      'Mega Venusaur',
      'Venusaur Shadow',
      'Sceptile Shadow',
      'Tangrowth Shadow',
      'Torterra Shadow',
      'Zarude',
      'Meowscarada',
    ],
    'Ground': [
      'Mega Primal Groudon',
      'Mega Garchomp',
      'Groudon Shadow',
      'Garchomp Shadow Ground',
      'Excadrill Shadow',
      'Landorus',
      'Mamoswine Shadow',
      'Rhyperior Shadow',
      'Groudon',
      'Golurk Shadow',
    ],
    'Ice': [
      'Kyurem Blanco',
      'Kyurem Negro',
      'Mamoswine Shadow Ice',
      'Weavile Shadow',
      'Mewtwo Shadow Ice',
      'Darmanitan',
      'Baxcalibur',
      'Mega Glalie',
      'Mega Abomasnow',
      'Mamoswine',
    ],
    'Poison': [
      'Mega Beedrill Poison',
      'Mega Gengar Poison',
      'Eternatus Poison',
      'Naganadel',
      'Nihilego',
      'Toxicroak Shadow',
      'Roserade',
      'Victreebel Shadow',
      'Vileplume Shadow',
      'Skuntank Shadow',
    ],
    'Psychic': [
      'Mewtwo Shadow',
      'Mega Alakazam Psychic',
      'Mewtwo',
      'Mega Gallade/Gardevoir',
      'Mega Latios',
      'Hoopa (Desatado)',
      'Alakazam Shadow Psychic',
      'Latios Shadow',
      'Metagross Shadow',
      'Exeggutor Shadow',
    ],
    'Rock': [
      'Rampardos Shadow',
      'Mega Diancie',
      'Rhyperior Shadow Rock',
      'Tyrantrum Shadow',
      'Mega Tyranitar Rock',
      'Gigalith Shadow',
      'Mega Aerodactyl',
      'Tyranitar Shadow',
      'Rampardos',
      'Rhyperior',
    ],
    'Steel': [
      'Zacian Steel',
      'Zamazenta',
      'Necrozma (Solgaleo)',
      'Metagross Shadow Steel',
      'Dialga Shadow',
      'Metagross',
      'Excadrill Shadow',
      'Dialga',
      'Dialga Origen Steel',
      'Mega Lucario Steel',
    ],
    'Water': [
      'Mega Primal Kyogre',
      'Kyogre Shadow',
      'Mega Swampert',
      'Mega Blastoise',
      'Swampert Shadow',
      'Samurott Shadow',
      'Empoleon Shadow',
      'Feraligatr Shadow',
      'Mega Gyarados',
      'Kyogre',
    ],
  };

  // Top megas por tipo (mejor mega de cada tipo para PVE)
  static const Map<String, String> _hardcodedMegas = {
    'Bug': 'Mega Pinsir',
    'Dark': 'Mega Absol',
    'Dragon': 'Mega Rayquaza',
    'Electric': 'Mega Manectric',
    'Fairy': 'Mega Gardevoir',
    'Fighting': 'Mega Lucario',
    'Fire': 'Mega Blaziken',
    'Flying': 'Mega Rayquaza Flying',
    'Ghost': 'Mega Gengar',
    'Grass': 'Mega Sceptile',
    'Ground': 'Primal Groudon',
    'Ice': 'Mega Glalie',
    'Poison': 'Mega Beedrill',
    'Psychic': 'Mega Alakazam',
    'Rock': 'Mega Diancie',
    'Steel': 'Mega Lucario Steel',
    'Water': 'Primal Kyogre',
  };

  // Movimientos óptimos PVE por nombre hardcodeado
  // Formato: 'Nombre' -> ['Movimiento Rápido', 'Movimiento Cargado']
  static const Map<String, List<String>> _hardcodedMoves = {
    // ── BUG ──
    'Mega Pinsir Bug': ['Picadura', 'Tijera X'],
    'Mega Heracross': ['Estoicismo', 'Megacuerno'],
    'Mega Beedrill': ['Acoso', 'Tijera X'],
    'Pheromosa': ['Picadura', 'Tijera X'],
    'Pinsir Shadow': ['Picadura', 'Tijera X'],
    'Scizor Shadow': ['Corte Furia', 'Tijera X'],
    'Mega Scizor': ['Corte Furia', 'Tijera X'],
    'Volcarona': ['Picadura', 'Zumbido'],
    'Scyther Shadow': ['Corte Furia', 'Zumbido*'],
    'Vikavolt': ['Picadura', 'Zumbido'],
    // ── DARK ──
    'Mega Absol': ['Alarido', 'Giro Vil*'],
    'Mega Tyranitar': ['Mordisco', 'Giro Vil'],
    'Tyranitar Shadow': ['Mordisco', 'Giro Vil'],
    'Absol': ['Alarido', 'Giro Vil*'],
    'Mega Houndoom': ['Alarido', 'Juego Sucio'],
    'Weavile Shadow Dark': ['Alarido', 'Juego Sucio'],
    'Salamence Shadow Dark': ['Mordisco', 'Giro Vil'],
    'Hydreigon': ['Mordisco', 'Giro Vil*'],
    'Honchkrow': ['Alarido', 'Pulso Umbrío'],
    'Mega Salamence': ['Mordisco', 'Giro Vil'],
    // ── DRAGON ──
    'Eternatus': ['Cola Dragón', 'Cañon Dinamax'],
    'Mega Rayquaza': ['Cola Dragón', 'Vasto Impacto*'],
    'Mega Garchomp': ['Cola Dragón', 'Vasto Impacto'],
    'Garchomp Shadow': ['Cola Dragón', 'Vasto Impacto'],
    'Palkia Shadow': ['Cola Dragón', 'Cometa Draco'],
    'Salamence Shadow': ['Cola Dragón', 'Cometa Draco'],
    'Dragonite Shadow': ['Cola Dragón', 'Cometa Draco*'],
    'Palkia Origen': ['Cola Dragón', 'Corte Vacio'],
    'Mega Salamence Dragon': ['Cola Dragón', 'Cometa Draco'],
    'Dialga Shadow Dragon': ['Dragoaliento', 'Cometa Draco'],
    // ── ELECTRIC ──
    'Regieleki': ['Impactrueno', 'Electrojaula*'],
    'Raikou Shadow': ['Impactrueno', 'Voltio Cruel'],
    'Electivire Shadow': ['Impactrueno', 'Voltio Cruel'],
    'Xurkitree': ['Impactrueno', 'Chispazo'],
    'Mega Manectric': ['Colmillo Rayo', 'Voltio Cruel'],
    'Thundurus Totem': ['Voltiocambio', 'Electormenta*'],
    'Zapdos Shadow': ['Impactrueno', 'Rayo'],
    'Magnezone Shadow': ['Chispa', 'Voltio Cruel'],
    'Zekrom': ['Rayo Carga', 'Rayo Fusion*'],
    'Luxray Shadow': ['Chispa', 'Voltio Cruel'],
    // ── FAIRY ──
    'Mega Gardevoir': ['Encanto', 'Brillo Mágico'],
    'Zacian': ['Garra Metal', 'Carantoña'],
    'Gardevoir Shadow': ['Encanto', 'Brillo Mágico'],
    'Mega Alakazam Fairy': ['Psicocorte', 'Brillo Mágico*'],
    'Enamorus': ['Viento Feerico', 'Brillo Mágico'],
    'Xurkitree Fairy': ['Impactrueno', 'Brillo Mágico'],
    'Grandbull Shadow': ['Encanto', 'Carantoña'],
    'Xerneas': ['Geocontrol*', 'Fuerza Lunar'],
    'Alakazam Shadow': ['Psicocorte', 'Brillo Mágico*'],
    'Gardevoir': ['Encanto', 'Brillo Mágico'],
    // ── FIGHTING ──
    'Mega Lucario': ['Palmeo*', 'Esfera Aural'],
    'Mega Blaziken': ['Contraataque', 'Onda Certera'],
    'Lucario': ['Palmeo*', 'Esfera Aural'],
    'Mega Herracross Fighting': ['Contraataque', 'A Bocajarro'],
    'Conkeldurr Shadow': ['Contraataque', 'Puño Dinámico'],
    'Terrakion': ['Doble Patada', 'Espada Santa*'],
    'Machamp Shadow': ['Contraataque', 'Puño Dinámico'],
    'Mega Alakazam': ['Contraataque*', 'Onda Certera'],
    'Hariyama Shadow': ['Palmeo', 'Puño Dinámico'],
    'Keldeo': ['Patada Baja', 'Espada Santa'],
    // ── FIRE ──
    'Mega Charizard Y': ['Giro Fuego', 'Anillo Ígneo*'],
    'Mega Blaziken Fire': ['Giro Fuego', 'Anillo Ígneo*'],
    'Heatran Shadow': ['Giro Fuego', 'Lluvia Ígneo*'],
    'Blaziken Shadow': ['Giro Fuego', 'Anillo Ígneo'],
    'Chandelure Shadow': ['Giro Fuego', 'Sofoco'],
    'Darmanitan Shadow': ['Colmillo Igneo', 'Sofoco'],
    'Emboar Shadow': ['Ascuas', 'Anillo Ígneo*'],
    'Moltres Shadow': ['Giro Fuego', 'Sofoco'],
    'Reshiram': ['Colmillo Igneo', 'Llama Fusion*'],
    'Charizard Shadow': ['Giro Fuego', 'Anillo Ígneo*'],
    // ── FLYING ──
    'Mega Rayquaza Flying': ['Tajo Aéreo', 'Ascenso Draco'],
    'Rayquaza': ['Tajo Aéreo', 'Ascenso Draco'],
    'Salamence Shadow Flying': ['Colmillo Igneo', 'Vuelo'],
    'Staraptor Shadow': ['Tornado*', 'Vuelo'],
    'Moltres Shadow Flying': ['Ataque Ala', 'Ataque Aereo*'],
    'Mega Salamence Flying': ['Colmillo Igneo', 'Vuelo'],
    'Mega Pidgeot': ['Tornado*', 'Pajaro Osado'],
    'Yveltal': ['Tornado', 'Ala Mortifera*'],
    'Enamorus Flying': ['Viento Feerico', 'Vuelo'],
    'Honchkrow Shadow': ['Picotazo', 'Ataque Aéreo'],
    // ── GHOST ──
    'Mega Gengar': ['Lengüetazo*', 'Bola Sombra'],
    'Necrozma (Lunala)': ['Garra Umbría', 'Rayo Umbrio'],
    'Chandelure Shadow Ghost': ['Infortunio', 'Bola Sombra'],
    'Gengar Shadow Ghost': ['Lengüetazo*', 'Bola Sombra'],
    'Mega Bannete': ['Garra Umbría', 'Bola Sombra'],
    'Gengar': ['Lengüetazo*', 'Bola Sombra'],
    'Mewtwo Shadow Ghost': ['Psicocorte', 'Bola Sombra*'],
    'Blacephalon': ['Impresionar', 'Bola Sombra'],
    'Chandelure': ['Infortunio', 'Bola Sombra'],
    'Dragapult': ['Impresionar', 'Bola Sombra'],
    // ── GRASS ──
    'Mega Sceptile': ['Semilladora', 'Planta Feroz*'],
    'Kartana': ['Hoja Afilada', 'Hoja Aguda'],
    'Shaymin (cielo)': ['Hoja Magica', 'Hierba Lazo'],
    'Mega Venusaur': ['Látigo Cepa', 'Planta Feroz*'],
    'Venusaur Shadow': ['Látigo Cepa', 'Planta Feroz*'],
    'Sceptile Shadow': ['Semilladora', 'Planta Feroz*'],
    'Tangrowth Shadow': ['Látigo Cepa', 'Latigazo'],
    'Torterra Shadow': ['Hoja Afilada', 'Planta Feroz*'],
    'Zarude': ['Látigo Cepa', 'Latigazo'],
    'Meowscarada': ['follaje', 'Planta Feroz*'],
    // ── GROUND ──
    'Mega Primal Groudon': ['Disparo Lodo', 'Filo del Abismo*'],
    'Groudon Shadow': ['Disparo Lodo', 'Filo del Abismo*'],
    'Grachomp Shadow Ground': ['Disparo Lodo', 'Tierra Viva*'],
    'Excadrill Shadow': ['Bofeton Lodo', 'Arenas Ardientes'],
    'Landorus': ['Disparo Lodo', 'Simun de Arena*'],
    'Mamoswine Shadow': ['Bofeton Lodo', 'Fuerza Equina'],
    'Rhyperior Shadow': ['Bofeton Lodo', 'Terremoto'],
    'Groudon': ['Disparo Lodo', 'Filo del Abismo*'],
    'Golurk Shadow': ['Bofeton Lodo', 'Tierra Viva'],
    // ── ICE ──
    'Kyurem Blanco': ['Colmillo Hielo', 'Llama gelida'],
    'Kyurem Negro': ['Cola Dragon', 'Rayo Gelido'],
    'Mamoswine Shadow Ice': ['Nieve Polvo', 'Alud'],
    'Weavile Shadow': ['Canto Helado', 'Alud'],
    'Mewtwo Shadow Ice': ['Psicocorte', 'Rayo Hielo'],
    'Darmanitan': ['Colmillo Hielo', 'Alud'],
    'Baxcalibur': ['Colmillo Hielo', 'Alud'],
    'Mega Glalie': ['Vaho Gelido', 'Alud'],
    'Mega Abomasnow': ['Nieve Polvo', 'Meteorobola'],
    'Mamoswine': ['Nieve Polvo', 'Alud'],
    // ── POISON ──
    'Mega Beedrill Poison': ['Puya Nociva', 'Bomba Lodo'],
    'Mega Gengar Poison': ['Lengüetazo*', 'Bomba Lodo'],
    'Eternatus Poison': ['Puya Nociva', 'Bomba Lodo'],
    'Nihilego': ['Puya Nociva', 'Bomba Lodo'],
    'Naganadel': ['Puya Nociva', 'Bomba Lodo'],
    'Toxicroak Shadow': ['Puya Nociva', 'Bomba Lodo'],
    'Roserade': ['Puya Nociva', 'Bomba Lodo'],
    'Victreebel Shadow': ['Ácido', 'Bomba Lodo'],
    'Vileplume Shadow': ['Ácido', 'Bomba Lodo'],
    'Skuntank Shadow': ['Puya Nociva', 'Bomba Lodo'],
    // ── PSYCHIC ──
    'Mewtwo Shadow': ['Psicocorte', 'Onda Mental*'],
    'Mega Alakazam Psychic': ['Confusión', 'Psíquico*'],
    'Mewtwo': ['Psicocorte', 'Onda Mental*'],
    'Mega Gallade/Gardevoir': ['Confusión', 'Psíquico'],
    'Mega Latios': ['Cabezazo Zen', 'Psíquico'],
    'Hoopa (Desatado)': ['Confusión', 'Psíquico'],
    'Alakazam Shadow Psychic': ['Confusión', 'Psíquico*'],
    'Latios Shadow': ['Cabezazo Zen', 'Psíquico'],
    'Metagross Shadow': ['Cabezazo Zen', 'Psíquico'],
    'Exeggutor Shadow': ['Confusión', 'Psíquico'],
    // ── ROCK ──
    'Rampardos Shadow': ['Antiaereo', 'Avalancha'],
    'Mega Diancie': ['Lanzarrocas', 'Avalancha'],
    'Rhyperior Shadow Rock': ['Antiaereo', 'Romperrocas*'],
    'Tyrantrum Shadow': ['Lanzarrocas', 'Rayo Meteorico'],
    'Mega Tyranitar Rock': ['Antiaereo*', 'Roca Afilada'],
    'Gigalith Shadow': ['Antiaereo', 'Rayo Meteórico'],
    'Mega Aerodactyl': ['Lanzarrocas', 'Avalancha'],
    'Rampardos': ['Antiaereo', 'Avalancha'],
    'Rhyperior': ['Antiaereo', 'Romperrocas*'],
    // ── STEEL ──
    'Zacian Steel': ['Garra Metal', 'Tajo Supremo'],
    'Zamazenta': ['Garra Metal', 'Embate Supremo'],
    'Necrozma (Solgaleo)': ['Garra Metal', 'MeteoImpacto'],
    'Metagross Shadow Steel': ['Puño Bala', 'Puño Meteoro'],
    'Dialga Shadow': ['Garra Metal', 'Cabeza de Hierro'],
    'Metagross': ['Puño Bala', 'Puño Meteoro'],
    'Dialga': ['Garra Metal', 'Cabeza de Hierro'],
    'Dialga Origen': ['Garra Metal', 'Cabeza de Hierro'],
    'Excadrill Shadow Steel': ['Garra Metal', 'Cabeza de Hierro'],
    'Mega Lucario Steel': ['Puño Bala', 'Foco Resplandor'],
    // ── WATER ──
    'Mega Primal Kyogre': ['Cascada', 'Pulso Primigenio*'],
    'Kyogre Shadow': ['Cascada', 'Pulso Primigenio*'],
    'Mega Swampert': ['Pistola Agua', 'Hidrocañón*'],
    'Mega Blastoise': ['Pistola Agua', 'Hidrocañón*'],
    'Swampert Shadow': ['Pistola Agua', 'Hidrocañón*'],
    'Samurott Shadow': ['Cascada', 'Hidrocañón*'],
    'Empoleon Shadow': ['Pistola Agua', 'Hidrocañón*'],
    'Feraligatr Shadow': ['Pistola Agua*', 'Hidrocañón*'],
    'Mega Gyarados': ['Cascada', 'Hidrobomba'],
    'Kyogre': ['Cascada', 'Pulso Primigenio*'],
    // ── MEGAS TAB ──
    'Primal Groudon': ['Disparo Lodo', 'Filo del Abismo*'],
    'Primal Kyogre': ['Cascada', 'Pulso Primigenio*'],
    'Mega Pinsir': ['Picadura', 'Tijera X'],
  };

  static Future<dynamic> _fetch(String ep) async {
    final r = await http.get(
      Uri.parse('$_base/$ep'),
      headers: {'Accept': 'application/json'},
    );
    if (r.statusCode == 200) return json.decode(r.body);
    throw Exception('HTTP ${r.statusCode} en $ep');
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  static int _calculateMaxCp(int attack, int defense, int stamina) {
    if (attack <= 0 || defense <= 0 || stamina <= 0) return 0;
    const cpm = 0.79030001;
    final cp = (attack * sqrt(defense) * sqrt(stamina) * cpm * cpm) / 10;
    final value = cp.floor();
    return value < 10 ? 10 : value;
  }

  static String? _resolveMegaArtworkUrl(Map<String, dynamic>? megaData) {
    if (megaData == null) return null;
    if (kIsWeb) {
      // PokemonDB artwork is not CORS-safe for Flutter Web, so fall back to
      // official artwork on web builds instead of loading a blocked image.
      return null;
    }

    final baseName = (megaData['pokemon_name'] ?? '').toString().toLowerCase();
    final megaName = (megaData['mega_name'] ?? '').toString().toLowerCase();
    if (baseName.isEmpty || megaName.isEmpty) return null;

    var slug = baseName
        .replaceAll(RegExp(r"[^a-z0-9 ]"), '')
        .replaceAll(' ', '-');
    if (megaName.contains('primal')) {
      slug = '$slug-primal';
    } else if (megaName.contains('origin')) {
      slug = '$slug-origin';
    } else if (megaName.endsWith(' x')) {
      slug = '$slug-mega-x';
    } else if (megaName.endsWith(' y')) {
      slug = '$slug-mega-y';
    } else {
      slug = '$slug-mega';
    }

    return 'https://img.pokemondb.net/artwork/large/$slug.jpg';
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
    final statsRaw = await _fetch('pokemon_stats.json') as List<dynamic>;
    final maxCpRaw = await _fetch('pokemon_max_cp.json') as List<dynamic>;
    final typesRaw = await _fetch('pokemon_types.json') as List<dynamic>;
    final movesRaw =
        await _fetch('current_pokemon_moves.json') as List<dynamic>;
    final megaRaw = await _fetch('mega_pokemon.json') as List<dynamic>;
    final shadowRaw =
        await _fetch('shadow_pokemon.json') as Map<String, dynamic>;
    final rarityRaw =
        await _fetch('pokemon_rarity.json') as Map<String, dynamic>;

    // ── Índices por nombre (insensible a mayúsculas) ──
    final statsByName = <String, Map<String, dynamic>>{};
    final maxCpByName = <String, int>{};
    final maxCpById = <int, int>{};
    final typesByName = <String, List<String>>{};
    final movesByName = <String, Map<String, dynamic>>{};
    final shadowIds = <int>{};
    final legendaryIds = <int>{};
    final mythicIds = <int>{};

    for (final s in statsRaw) {
      final name =
          (s['pokemon_name'] ?? s['name'] ?? '').toString().toLowerCase();
      if (name.isNotEmpty)
        statsByName[name] = Map<String, dynamic>.from(s as Map);
    }

    for (final c in maxCpRaw) {
      final name =
          (c['pokemon_name'] ?? c['name'] ?? '').toString().toLowerCase();
      final pid = _toInt(c['pokemon_id'] ?? c['id']);
      if (name.isNotEmpty && c['max_cp'] != null) {
        maxCpByName[name] = _toInt(c['max_cp']);
      }
      if (pid > 0 && c['max_cp'] != null) {
        maxCpById[pid] = _toInt(c['max_cp']);
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
      final name =
          (s['pokemon_name'] ?? s['name'] ?? '').toString().toLowerCase();
      final id = _toInt(s['pokemon_id'] ?? s['id']);
      if (name.isNotEmpty && id > 0 && typesById.containsKey(id)) {
        typesByName[name] = typesById[id]!;
      }
    }

    for (final m in movesRaw) {
      final name = (m['pokemon_name'] ?? '').toString().toLowerCase();
      if (name.isNotEmpty)
        movesByName[name] = Map<String, dynamic>.from(m as Map);
    }

    shadowRaw.forEach((key, value) {
      final id = int.tryParse(key) ?? _toInt((value as Map?)?['id']);
      if (id > 0) shadowIds.add(id);
    });

    ((rarityRaw['Legendary'] as List?) ?? []).forEach((p) {
      if (p is Map && p['pokemon_id'] != null)
        legendaryIds.add(_toInt(p['pokemon_id']));
    });
    ((rarityRaw['Mythic'] as List?) ?? []).forEach((p) {
      if (p is Map && p['pokemon_id'] != null)
        mythicIds.add(_toInt(p['pokemon_id']));
    });

    // ── Construir byType desde los nombres hardcodeados ──
    // Eliminar duplicados por tipo manteniendo el primero (mejor rank)
    final byTypeFinal = <String, List<TierEntry>>{};

    _hardcodedTop.forEach((type, names) {
      final nameCounts = <String, int>{};
      final entries = <TierEntry>[];

      for (int i = 0; i < names.length; i++) {
        final rawName = names[i];
        final key = rawName.toLowerCase().trim();

        // Detectar si es Shadow o Mega
        final isShadowForm = key.contains('shadow');
        final isMegaForm = key.contains('mega');
        final keyBase =
            key.replaceAll('shadow', '').replaceAll('mega', '').trim();
        final displayName =
            rawName
                .replaceAll(RegExp(r'\s*shadow\s*', caseSensitive: false), '')
                .replaceAll(RegExp(r'\s*mega\s*', caseSensitive: false), '')
                .trim();

        // Contar cuántas veces aparece este nombre (para diferenciar duplicados)
        final formIndex = nameCounts[keyBase] ?? 0;
        nameCounts[keyBase] = formIndex + 1;

        // Si es mega, buscar primero en mega_pokemon.json
        Map<String, dynamic>? megaData;
        if (isMegaForm) {
          for (final m in megaRaw) {
            final mn = (m['mega_name'] ?? '').toString().toLowerCase();
            // Buscar coincidencias más flexibles para megas
            final megaBaseName = mn
                .replaceAll('mega ', '')
                .replaceAll('primal ', '');
            if (mn == key ||
                mn.contains(keyBase) ||
                keyBase.contains(megaBaseName) ||
                megaBaseName.contains(keyBase)) {
              megaData = Map<String, dynamic>.from(m as Map);
              break;
            }
          }
        }

        // Búsqueda para normales/shadows: buscar en pokemon_stats.json
        Map<String, dynamic>? statsData;
        if (!isMegaForm) {
          // Búsqueda exacta primero
          statsData = statsByName[keyBase];

          // Si no encuentra exacto, buscar con más flexibilidad
          if (statsData == null) {
            for (final entry in statsByName.entries) {
              final apiName = entry.key;
              // Coincidencia exacta
              if (apiName == keyBase) {
                statsData = entry.value;
                break;
              }
              // Contiene la palabra clave
              if (apiName.contains(keyBase) || keyBase.contains(apiName)) {
                statsData = entry.value;
                break;
              }
              // Primera palabra coincide
              final apiWords = apiName.split(' ');
              final keyWords = keyBase.split(' ');
              if (keyWords.isNotEmpty &&
                  apiWords.isNotEmpty &&
                  apiWords.first == keyWords.first) {
                statsData = entry.value;
                break;
              }
            }
          }
        }

        // Extraer datos del Pokémon encontrado (o mega)
        int id, atk, def, sta;
        if (megaData != null) {
          id = _toInt(megaData['pokemon_id']);
          final ms = megaData['stats'] as Map?;
          atk = ms != null ? _toInt(ms['base_attack']) : 0;
          def = ms != null ? _toInt(ms['base_defense']) : 1;
          sta = ms != null ? _toInt(ms['base_stamina']) : 0;
        } else {
          id =
              statsData != null
                  ? _toInt(statsData['pokemon_id'] ?? statsData['id'])
                  : 0;
          atk = statsData != null ? _toInt(statsData['base_attack']) : 0;
          def = statsData != null ? _toInt(statsData['base_defense']) : 1;
          sta = statsData != null ? _toInt(statsData['base_stamina']) : 0;
        }

        // Max CP: calculado para megas, sino buscar CP normal
        int cp = 0;
        if (megaData != null) {
          cp = _calculateMaxCp(atk, def, sta);
          if (cp == 0 && id > 0) {
            cp = maxCpById[id] ?? 0;
          }
        } else {
          cp = maxCpByName[keyBase] ?? 0;
          if (cp == 0 && id > 0) {
            cp = maxCpById[id] ?? 0;
          }
          // Si aún no hay CP, buscar por nombre más flexible
          if (cp == 0) {
            for (final entry in maxCpByName.entries) {
              final apiName = entry.key;
              if (apiName.contains(keyBase) || keyBase.contains(apiName)) {
                cp = entry.value;
                break;
              }
            }
          }
        }

        // Tipos: usar el ID para buscar exacto (o tipos del mega), o buscar por nombre
        List<String> pokTypes;
        if (megaData != null && megaData['type'] != null) {
          pokTypes = List<String>.from(megaData['type']);
        } else if (id > 0 && typesById.containsKey(id)) {
          pokTypes = typesById[id]!;
        } else {
          // Buscar por nombre más flexible
          pokTypes = typesByName[keyBase] ?? [];
          if (pokTypes.isEmpty) {
            for (final entry in typesByName.entries) {
              if (entry.key.contains(keyBase) || keyBase.contains(entry.key)) {
                pokTypes = entry.value;
                break;
              }
            }
          }
          // Si aún no hay tipos, usar el tipo del tier como fallback
          pokTypes = pokTypes.isNotEmpty ? pokTypes : [type];
        }

        // Movimientos: usar ID para buscar exacto, o buscar por nombre más flexible
        Map<String, dynamic>? moves;
        if (id > 0) {
          // Buscar en movesRaw por pokemon_id directamente
          for (final m in movesRaw) {
            if (_toInt(m['pokemon_id']) == id) {
              moves = Map<String, dynamic>.from(m as Map);
              break;
            }
          }
        }
        // Si no se encontró por ID, buscar por nombre
        if (moves == null) {
          moves = movesByName[keyBase];
          if (moves == null) {
            for (final entry in movesByName.entries) {
              if (entry.key.contains(keyBase) || keyBase.contains(entry.key)) {
                moves = entry.value;
                break;
              }
            }
          }
        }

        final hardcodedMoves = _hardcodedMoves[rawName];
        final fasts =
            hardcodedMoves != null
                ? [hardcodedMoves[0]]
                : (moves != null
                    ? List<String>.from(moves['fast_moves'] ?? [])
                    : <String>[]);
        final charged =
            hardcodedMoves != null
                ? [hardcodedMoves[1]]
                : (moves != null
                    ? List<String>.from(moves['charged_moves'] ?? [])
                    : <String>[]);

        final isShadow = shadowIds.contains(id) || isShadowForm;

        // Aplicar boost de +20% ATK para shadows
        if (isShadow) {
          atk = (atk * 1.2).toInt();
        }

        final isLeg = legendaryIds.contains(id);
        final isMyt = mythicIds.contains(id);
        final isMega =
            isMegaForm; // Solo marcar como mega si se especifica en el nombre
        final rank = entries.length + 1;

        developer.log(
          'Type $type rank $rank: "$displayName" (shadow=$isShadow, mega=$isMega) → id=$id atk=$atk def=$def sta=$sta cp=$cp types=$pokTypes',
          name: 'TierService',
        );

        /*
        print('======= TIER DEBUG =======');
        print('type: $type');
        print('rank: $rank');
        print('rawName: $rawName');
        print('displayName: $displayName');
        print('keyBase: $keyBase');
        print('isMegaForm: $isMegaForm, isShadowForm: $isShadowForm');
        print('megaData: ${megaData != null}, statsData: ${statsData != null}, moves: ${moves != null}');
        print('id: $id  atk: $atk  def: $def  sta: $sta  cp: $cp');
        print('types: $pokTypes');
        print('fastMove: ${fasts.isNotEmpty ? fasts.first : '-'}');
        print('chargedMove: ${charged.isNotEmpty ? charged.first : '-'}');
        print('==========================');
        */

        // Si no se encontraron stats básicos, intentar buscar con nombres alternativos
        if (atk == 0 && def == 1 && sta == 0 && !isMegaForm) {
          developer.log(
            'WARNING: No stats found for "$displayName" (keyBase: "$keyBase"), trying alternative search...',
            name: 'TierService',
          );

          // Intentar buscar con variaciones del nombre
          final alternatives = [
            keyBase.replaceAll(' ', ''),
            keyBase.replaceAll(' ', '-'),
            keyBase.split(' ').first,
          ];

          for (final alt in alternatives) {
            if (statsByName.containsKey(alt)) {
              final altData = statsByName[alt]!;
              atk = _toInt(altData['base_attack']);
              def = _toInt(altData['base_defense']);
              sta = _toInt(altData['base_stamina']);
              id = _toInt(altData['id']);

              developer.log(
                'FOUND alternative stats for "$displayName" using "$alt": atk=$atk def=$def sta=$sta',
                name: 'TierService',
              );
              break;
            }
          }
        }

        entries.add(
          TierEntry(
            id: id > 0 ? id : (800 + entries.length),
            name: displayName,
            types: pokTypes,
            baseAttack: atk,
            baseDefense: def,
            baseStamina: sta,
            maxCp: cp,
            score: (10 - entries.length).toDouble(),
            isMega: isMega,
            isShadow: isShadow,
            isLegendary: isLeg,
            isMythic: isMyt,
            tier: _assignTier(rank),
            bestFastMove: fasts.isNotEmpty ? fasts.first : null,
            bestChargedMove: charged.isNotEmpty ? charged.first : null,
            formIndex: formIndex,
            imageUrlOverride: isMega ? _resolveMegaArtworkUrl(megaData) : null,
          ),
        );
      }

      if (entries.isNotEmpty) byTypeFinal[type] = entries;
    });

    developer.log(
      'Types built: ${byTypeFinal.keys.toList()}',
      name: 'TierService',
    );

    // ── Construir megas desde nombres hardcodeados ──
    final megaFinal = <TierEntry>[];

    _hardcodedMegas.forEach((type, megaName) {
      final key = megaName.toLowerCase();

      // Buscar en mega_pokemon.json por nombre
      Map<String, dynamic>? megaData;
      for (final m in megaRaw) {
        final mn = (m['mega_name'] ?? '').toString().toLowerCase();
        final keyLower = key.toLowerCase();
        // Búsqueda más flexible para megas
        final megaBaseName = mn
            .replaceAll('mega ', '')
            .replaceAll('primal ', '');
        final keyBaseName = keyLower
            .replaceAll('mega ', '')
            .replaceAll('primal ', '');
        if (mn == keyLower ||
            mn.contains(keyBaseName) ||
            keyBaseName.contains(megaBaseName) ||
            megaBaseName.contains(keyBaseName)) {
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

      final moves =
          pid > 0
              ? movesByName.entries
                  .where((e) {
                    final s = statsRaw.firstWhere(
                      (x) => _toInt(x['pokemon_id'] ?? x['id']) == pid,
                      orElse: () => <String, dynamic>{},
                    );
                    return (s['pokemon_name'] ?? s['name'] ?? '')
                            .toString()
                            .toLowerCase() ==
                        e.key;
                  })
                  .map((e) => e.value)
                  .firstOrNull
              : null;

      final hardcodedMegaMoves = _hardcodedMoves[megaName];

      final fasts = hardcodedMegaMoves != null && hardcodedMegaMoves.isNotEmpty
          ? [hardcodedMegaMoves[0]]
          : <String>[];
      final charged = hardcodedMegaMoves != null && hardcodedMegaMoves.length > 1
          ? [hardcodedMegaMoves[1]]
          : <String>[];

      if (hardcodedMegaMoves != null) {
        developer.log(
          'Mega $megaName → Moves: ${fasts.isNotEmpty ? fasts.first : '-'} / ${charged.isNotEmpty ? charged.first : '-'}',
          name: 'TierService',
        );
      }

      megaFinal.add(
        TierEntry(
          id: pid > 0 ? pid : (900 + megaFinal.length),
          name: megaName,
          types: megaTypes,
          baseAttack: atk,
          baseDefense: def,
          baseStamina: sta,
          maxCp: _calculateMaxCp(atk, def, sta),
          score: (atk * atk * sta.toDouble()) / def,
          isMega: true,
          isShadow: false,
          isLegendary: false,
          isMythic: false,
          tier: 'S',
          bestFastMove: fasts.isNotEmpty ? fasts.first : null,
          bestChargedMove: charged.isNotEmpty ? charged.first : null,
          imageUrlOverride: _resolveMegaArtworkUrl(megaData),
          tierType: type,
        ),
      );
    });

    megaFinal.sort((a, b) => b.score.compareTo(a.score));

    _byTypeCache = byTypeFinal;
    _megaCache = megaFinal;
    return (byTypeFinal, megaFinal);
  }
}
