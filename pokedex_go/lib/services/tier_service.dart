import 'dart:developer' as developer;
import 'package:pokedex_go/models/pokemon.dart';
import 'package:pokedex_go/services/pogo_api_service.dart';
import '../models/tier_entry.dart';

class TierService {
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
      'Mega Banette',
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

  static String _slug(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\(.*?\)'), '').trim();

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
      return p.megaEvolutions.firstWhere(
        (m) => m.label.toUpperCase().contains('X'),
        orElse: () => p.megaEvolutions.first,
      );
    }
    if (nameLower.contains(' y') || nameLower.endsWith('y')) {
      return p.megaEvolutions.firstWhere(
        (m) => m.label.toUpperCase().contains('Y'),
        orElse: () => p.megaEvolutions.first,
      );
    }
    return p.megaEvolutions.first;
  }

  static Future<(Map<String, List<TierEntry>>, List<TierEntry>)> fetchTierData() async {
    if (_byTypeCache != null && _megaCache != null) {
      return (_byTypeCache!, _megaCache!);
    }

    // 👇 única fuente de datos ahora: Pokemon GO API, vía PogoApiService
    final allPokemon = await PogoApiService.fetchAllPokemon();

    final byTypeFinal = <String, List<TierEntry>>{};

    _hardcodedTop.forEach((type, names) {
      final entries = <TierEntry>[];

      for (int i = 0; i < names.length; i++) {
        final rawName = names[i];
        final key = rawName.toLowerCase();
        final isMegaForm =
            key.contains('mega') || key.contains('primal') || key.contains('primigenio');
        final isShadowForm = key.contains('shadow');
        final displayName = rawName
            .replaceAll(RegExp(r'\s*shadow\s*', caseSensitive: false), '')
            .replaceAll(RegExp(r'\s*mega\s*', caseSensitive: false), '')
            .trim();

        final pokemon = _findPokemon(allPokemon, displayName);
        final mega = (isMegaForm && pokemon != null) ? _findMega(pokemon, rawName) : null;

        int id, atk, def, sta, cp;
        List<String> pokTypes;
        String? imageOverride;

        if (mega != null) {
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
        final fasts = hardcodedMoves != null ? [hardcodedMoves[0]] : (pokemon?.fastMoves ?? []);
        final charged = hardcodedMoves != null && hardcodedMoves.length > 1
            ? [hardcodedMoves[1]]
            : (pokemon?.chargedMoves ?? []);

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

    // ── Megas por tipo ──
    final megaFinal = <TierEntry>[];
    _hardcodedMegas.forEach((type, megaName) {
      final keyBase = megaName
          .replaceAll(RegExp(r'mega|primal', caseSensitive: false), '')
          .trim();
      final pokemon = _findPokemon(allPokemon, keyBase);
      final mega = pokemon != null ? _findMega(pokemon, megaName) : null;

      final atk = mega?.attack ?? 0;
      final def = mega?.defense ?? 1;
      final sta = mega?.stamina ?? 0;

      final hardcodedMegaMoves = _hardcodedMoves[megaName];
      final fasts = (hardcodedMegaMoves?.isNotEmpty ?? false) ? [hardcodedMegaMoves![0]] : <String>[];
      final charged = ((hardcodedMegaMoves?.length ?? 0) > 1) ? [hardcodedMegaMoves![1]] : <String>[];

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
