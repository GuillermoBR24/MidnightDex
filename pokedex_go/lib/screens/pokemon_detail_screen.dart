import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/pokemon.dart';
import '../models/iv_config.dart';
import '../theme/app_theme.dart';
import '../widgets/type_badge.dart';
import '../widgets/stat_bar.dart';
import 'dart:math';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonDetailScreen({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return pokemon.isReleased
        ? _ReleasedView(pokemon: pokemon)
        : _UnreleasedView(pokemon: pokemon);
  }
}

// ──────────────────────────────────────────────
// Vista cuando el Pokémon NO está en el juego
// ──────────────────────────────────────────────
class _UnreleasedView extends StatelessWidget {
  final Pokemon pokemon;
  const _UnreleasedView({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.accentBlue,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '#${pokemon.paddedId} ${pokemon.name}',
          style: const TextStyle(color: Color(0xFF4A4A65)),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen bloqueada
            Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0.2126,
                    0.7152,
                    0.0722,
                    0,
                    0,
                    0,
                    0,
                    0,
                    0.2,
                    0,
                  ]),
                  child: Image.network(
                    pokemon.imageUrl,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.bgDark.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0D18).withOpacity(0.85),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2D2D45),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Color(0xFF4A4A65),
                    size: 36,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 28),
            // Nombre
            Text(
              pokemon.name,
              style: const TextStyle(
                color: Color(0xFF3A3A55),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '#${pokemon.paddedId}',
              style: const TextStyle(color: Color(0xFF2D2D45), fontSize: 16),
            ),
            const SizedBox(height: 32),
            // Caja de "no disponible"
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E1E30), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.catching_pokemon,
                      color: Color(0xFF3A3A55),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no disponible en\nPokémon GO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF5A5A78),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Este Pokémon todavía no ha sido\nintroducido en el juego.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF3A3A50),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (pokemon.generation != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF2A2A40),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        pokemon.generation!,
                        style: const TextStyle(
                          color: Color(0xFF4A4A65),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Vista cuando el Pokémon SÍ está en el juego
// ──────────────────────────────────────────────
class _ReleasedView extends StatefulWidget {
  final Pokemon pokemon;
  const _ReleasedView({required this.pokemon});

  @override
  State<_ReleasedView> createState() => _ReleasedViewState();
}

class _ReleasedViewState extends State<_ReleasedView> {
  bool _showShiny = false;
  bool _showMega = false;
  String _selectedMegaForm = 'X';
  int _selectedLevel = 50;
  
  // IVs por defecto (máximos)
  int _atkIv = 15;
  int _defIv = 15;
  int _staIv = 15;

  Map<String, int> _getEffectiveStats() {
    int atk = widget.pokemon.baseAttack ?? 0;
    int def = widget.pokemon.baseDefense ?? 0;
    int sta = widget.pokemon.baseStamina ?? 0;
    
    final id = widget.pokemon.id;

    if (id == 646 && !_showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 246,  // Attack base de Kyurem Blanco/Negro
        'def': 170,  // Defense base
        'sta': 245,  // Stamina base
      };
    }
    
    // 👇 Kyurem formas: stats específicos (NO son buff +20%)
    if (id == 646 && _showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 310,  // Attack base de Kyurem Blanco/Negro
        'def': 183,  // Defense base
        'sta': 245,  // Stamina base
      };
    }

    if (id == 483 && !_showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 275,  // Attack base de Kyurem Blanco/Negro
        'def': 211,  // Defense base
        'sta': 205,  // Stamina base
      };
    }
    
    // 👇 Kyurem formas: stats específicos (NO son buff +20%)
    if (id == 483 && _showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 270,  // Attack base de Kyurem Blanco/Negro
        'def': 225,  // Defense base
        'sta': 205,  // Stamina base
      };
    }

    if (id == 484 && !_showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 280,  // Attack base de Kyurem Blanco/Negro
        'def': 215,  // Defense base
        'sta': 189,  // Stamina base
      };
    }
    
    // 👇 Kyurem formas: stats específicos (NO son buff +20%)
    if (id == 484 && _showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 286,  // Attack base de Kyurem Blanco/Negro
        'def': 223,  // Defense base
        'sta': 189,  // Stamina base
      };
    }

    if (id == 487 && !_showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 187,  // Attack base de Kyurem Blanco/Negro
        'def': 225,  // Defense base
        'sta': 284,  // Stamina base
      };
    }
    
    // 👇 Kyurem formas: stats específicos (NO son buff +20%)
    if (id == 487 && _showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 225,  // Attack base de Kyurem Blanco/Negro
        'def': 187,  // Defense base
        'sta': 284,  // Stamina base
      };
    }

    if (id == 492 && !_showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 210,  // Attack base de Kyurem Blanco/Negro
        'def': 210,  // Defense base
        'sta': 225,  // Stamina base
      };
    }
    
    // 👇 Kyurem formas: stats específicos (NO son buff +20%)
    if (id == 492 && _showMega) {
      // Kyurem Blanco/Negro tienen stats base diferentes
      // Stats oficiales de Kyurem formas fusionadas:
      return {
        'atk': 261,  // Attack base de Kyurem Blanco/Negro
        'def': 166,  // Defense base
        'sta': 225,  // Stamina base
      };
    }
    
    // 👇 Mega Evoluciones: buff oficial +20% a stats base
    if (_showMega && _isMegaAvailable) {
      atk = (atk * 1.2).round();
      def = (def * 1.2).round();
      sta = (sta * 1.2).round();
    }
    
    return {'atk': atk, 'def': def, 'sta': sta};
  }

  /// Obtiene los tipos del Pokémon considerando Mega Evoluciones
  List<String> _getCurrentTypes() {
    final id = widget.pokemon.id;
    
    // 👇 Kyurem formas: tipos específicos
    if (id == 646 && _showMega) {
      return _selectedMegaForm == 'X' 
          ? ['Dragon', 'Fire']   // Kyurem Blanco
          : ['Dragon', 'Ice'];   // Kyurem Negro
    }
    
    // Si no es forma especial, devuelve tipos normales
    if (!_showMega || !_isMegaAvailable) {
      return widget.pokemon.types;
    }
    
    // Tipos para otras Megas
    final megaTypes = <int, List<String>>{
      6: _selectedMegaForm == 'X' ? ['Fire', 'Dragon'] : ['Fire', 'Flying'],
      130: ['Water', 'Dark'],
      254: ['Grass', 'Dragon'],
      334: ['Dragon', 'Fairy'],
      150: _selectedMegaForm == 'X' ? ['Psychic', 'Fighting'] : ['Psychic'],
      383: ['Ground', 'Fire'],
    };
    
    return megaTypes[id] ?? widget.pokemon.types;
  }
  
  static const Set<int> _dualFormIds = {6, 150, 646};

  static const Set<int> _megaIds = {
    3,   // Venusaur
    6,   // Charizard
    9,   // Blastoise
    15,  // Beedrill
    18,  // Pidgeot
    65,  // Alakazam
    80,  // Slowbro
    94,  // Gengar
    115, // Kangaskhan
    127, // Pinsir
    130, // Gyarados
    142, // Aerodactyl
    149, // Dragonite
    150, // Mewtwo
    181, // Ampharos
    208, // Steelix
    212, // Scizor
    214, // Heracross
    229, // Houndoom
    248, // Tyranitar
    254, // Sceptile
    257, // Blaziken
    260, // Swampert
    282, // Gardevoir
    475, // Gallade
    302, // Sableye
    303, // Mawile
    306, // Aggron
    308, // Medicham
    310, // Manectric
    319, // Sharpedo
    323, // Camerupt
    334, // Altaria
    354, // Banette
    359, // Absol
    362, // Glalie
    373, // Salamence
    376, // Metagross
    380, // Latias
    381, // Latios
    382, // Kyogre (Primigenio)
    383, // Groudon (Primigenio)
    384, // Rayquaza
    428, // Lopunny
    445, // Garchomp
    448, // Lucario
    460, // Abomasnow
    483, // Dialga
    484, // Palkia
    487, // Giratina
    492, // Shaymin
    531, // Audino
    646, // Kyurem
    719, // Diancie
    796, // Malamar
    71,  // Victreebel
  };
  
  bool get _isMegaAvailable => _megaIds.contains(widget.pokemon.id);
  bool get _hasDualForm => _dualFormIds.contains(widget.pokemon.id);

  Widget _buildMegaToggleButton(String form) {
    final isSelected = _selectedMegaForm == form;
    final id = widget.pokemon.id;
    
    // 👇 Texto especial para Kyurem
    String buttonText;
    if (id == 646) {
      buttonText = form == 'X' ? '✨ BLANCO' : '✨ NEGRO';
    } else {
      buttonText = '✨ MEGA $form';
    }
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMegaForm = form;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF00E5FF).withOpacity(0.25)
              : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF00E5FF)
                : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Text(
          buttonText,  // 👇 Usa el texto dinámico
          style: TextStyle(
            color: isSelected 
                ? const Color(0xFF00E5FF)
                : AppTheme.textSecond,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonImage(Color primary) {
    // 👇 Si es Mega, usa asset local
    final megaAssetPath = _getMegaAssetPath();
    if (megaAssetPath != null) {
      return Image.asset(
        megaAssetPath,
        height: 180,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(primary),
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
    }
    
    // 👇 Si es Shiny, usa URL de shiny
    if (_showShiny && widget.pokemon.possibleShiny == true) {
      return CachedNetworkImage(
        imageUrl: widget.pokemon.shinyImageUrl,
        height: 210,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) {
          return CachedNetworkImage(
            imageUrl: widget.pokemon.shinyImageUrlFallback,
            height: 210,
            fit: BoxFit.contain,
            errorWidget: (_, __, ___) => _buildPlaceholderImage(primary),
          );
        },
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
    }
    
    // 👇 Por defecto, usa imagen normal
    return CachedNetworkImage(
      imageUrl: widget.pokemon.imageUrl,
      height: 210,
      fit: BoxFit.contain,
      errorWidget: (_, __, ___) => _buildPlaceholderImage(primary),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _getMegaAssetPath() {
    if (!_showMega || !_isMegaAvailable) return null;
    
    final id = widget.pokemon.id;
    
    // 👇 Kyurem formas: usa sufijo _white o _black
    if (id == 646) {
      final form = _selectedMegaForm == 'X' ? 'B' : 'N';
      return 'megas/646_$form.png';
    }
    
    // Charizard/Mewtwo: usa _x o _y
    if (_hasDualForm) {
      return 'megas/${id}_${_selectedMegaForm.toLowerCase()}.png';
    }
    
    // Mega única
    return 'megas/$id.png';
  }

  void _toggleShiny() {
    if (widget.pokemon.possibleShiny == true) {
      setState(() {
        _showShiny = !_showShiny;
        if (_showShiny) _showMega = false;
      });
    }
  }

  void _toggleMega() {
    if (_isMegaAvailable) {
      setState(() {
        _showMega = !_showMega;
        if (_showMega) _showShiny = false;
      });
    }
  }

  void _toggleMegaForm() {
    setState(() {
      _selectedMegaForm = _selectedMegaForm == 'X' ? 'Y' : 'X';
    });
  }

String get _currentImageUrl {
  final id = widget.pokemon.id;
  
  // 👇 Kyurem formas: URLs de PokeAPI
  if (id == 646 && _showMega) {
    final form = _selectedMegaForm == 'X' ? 'white' : 'black';
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/646-$form.png';
  }
  
  // Mega Evoluciones (Charizard/Mewtwo)
  if (_showMega && _isMegaAvailable) {
    if (_hasDualForm && (id == 6 || id == 150)) {
      return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/mega-${_selectedMegaForm.toLowerCase()}/$id.png';
    }
    return 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/mega/$id.png';
  }
  
  // Shiny
  if (_showShiny && widget.pokemon.possibleShiny == true) {
    return widget.pokemon.shinyImageUrl;
  }
  
  // Normal
  return widget.pokemon.imageUrl;
}

  int get _currentCp {
    final s = _getEffectiveStats();
    final atk = s['atk']! + _atkIv;
    final def = s['def']! + _defIv;
    final sta = s['sta']! + _staIv;
    
    final cpm = Pokemon.getCpmForLevel(_selectedLevel);
    
    if (atk <= 0 || def <= 0 || sta <= 0) return 0;
    
    final cp = (atk * sqrt(def.toDouble()) * sqrt(sta.toDouble()) * cpm * cpm) / 10;
    return cp.floor();
  }

  // Widget compacto para selector X/Y en la AppBar (más pequeño)
  Widget _buildCompactMegaFormButton(String form) {
    final isSelected = _selectedMegaForm == form;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMegaForm = form;
        });
      },
      child: Container(
        width: 24,  // 👈 Más pequeño
        height: 18,  // 👈 Más pequeño
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF00E5FF).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(3),  // 👈 Radio reducido
        ),
        child: Text(
          form,
          style: TextStyle(
            color: isSelected 
                ? const Color(0xFF00E5FF)
                : AppTheme.textSecond,
            fontSize: 9,  // 👈 Fuente más pequeña
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMegaFormButton(String form) {
    final isSelected = _selectedMegaForm == form;
    return GestureDetector(
      onTap: _toggleMegaForm,
      child: Container(
        width: 28,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF00E5FF).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          form,
          style: TextStyle(
            color: isSelected 
                ? const Color(0xFF00E5FF)
                : AppTheme.textSecond,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTypes = _getCurrentTypes();
    final primary = currentTypes.isNotEmpty
        ? AppTheme.getTypeColor(currentTypes.first)
        : AppTheme.accentBlue;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // ─── AppBar con imagen toggleable ───
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
            // 👇 Botón Mega Evolución
            if (_isMegaAvailable)
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón principal Mega
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: IconButton(
                        key: ValueKey<bool>(_showMega),
                        icon: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _showMega 
                              ? const Color(0xFF00E5FF)
                              : AppTheme.textSecond, 
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          'assets/mega.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                        ),
                      ),
                        tooltip: _showMega ? 'Ver normal' : 'Ver Mega',
                        onPressed: _toggleMega,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                    // 👇 Selector X/Y más compacto (solo cuando Mega está activo)
                    if (_showMega && _hasDualForm)
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            
            // 👇 Botón Shiny
            if (widget.pokemon.possibleShiny == true)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: IconButton(
                  key: ValueKey<bool>(_showShiny),
                  icon: Icon(
                    Icons.auto_awesome,
                    color: _showShiny ? const Color(0xFFFFD700) : AppTheme.textSecond,
                    size: 24,  // 👈 Reducido de 26 a 24
                    shadows: _showShiny
                        ? [Shadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 10)]
                        : [],
                  ),
                  tooltip: _showShiny ? 'Ver normal' : 'Ver shiny',
                  onPressed: _toggleShiny,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            const SizedBox(width: 4),  // 👈 Reducido de 8 a 4
          ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withOpacity(0.07),
                      border: Border.all(color: primary.withOpacity(0.15), width: 2),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.pokemon.possibleShiny == true ? _toggleShiny : null,
                    child: _buildPokemonImage(primary),
                  ),
                  if (widget.pokemon.isLegendary || widget.pokemon.isMythic)
                    Positioned(
                      bottom: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: widget.pokemon.isMythic ? const Color(0xFF2D1A3E) : const Color(0xFF1A2A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.pokemon.isMythic ? const Color(0xFFA855F7) : const Color(0xFFFFD700),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.pokemon.isMythic ? Icons.auto_awesome : Icons.star,
                              color: widget.pokemon.isMythic ? const Color(0xFFA855F7) : const Color(0xFFFFD700),
                              size: 12,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.pokemon.isMythic ? 'Mythic' : 'Legendary',
                              style: TextStyle(
                                color: widget.pokemon.isMythic ? const Color(0xFFA855F7) : const Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── CONTENIDO PRINCIPAL ───
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y número
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(widget.pokemon.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w800))),
                        Text('#${widget.pokemon.paddedId}', style: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (widget.pokemon.generation != null)
                      Text(widget.pokemon.generation!, style: const TextStyle(color: AppTheme.textSecond, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, 
                      children: _getCurrentTypes().map((t) => TypeBadge(type: t)).toList()
                    ),
                    const SizedBox(height: 16),
                    _BadgesRow(pokemon: widget.pokemon),
                    const SizedBox(height: 24),

                    // ── Dimensiones físicas ──
                    if (widget.pokemon.pokedexHeightM != null) ...[
                      _SectionTitle(title: 'Dimensiones'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _InfoTile(icon: Icons.height, label: 'Altura', value: '${widget.pokemon.pokedexHeightM!.toStringAsFixed(1)} m', color: primary)),
                          const SizedBox(width: 12),
                          Expanded(child: _InfoTile(icon: Icons.monitor_weight_outlined, label: 'Peso', value: '${widget.pokemon.pokedexWeightKg!.toStringAsFixed(1)} kg', color: primary)),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Combat Power con IVs manuales ──
                    _SectionTitle(title: 'Combat Power'),
                    const SizedBox(height: 10),
                    // CP Calculado
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primary.withOpacity(0.35), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bolt, color: primary, size: 24),
                              const SizedBox(width: 8),
                              Text('$_currentCp CP', style: TextStyle(color: primary, fontSize: 28, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'IVs: $_atkIv / $_defIv / $_staIv (${((_atkIv + _defIv + _staIv) / 45 * 100).toStringAsFixed(1)}%)',
                              style: const TextStyle(color: AppTheme.textSecond, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_showMega || (widget.pokemon.id == 646 && _showMega))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_hasDualForm || widget.pokemon.id == 646) ...[
                              _buildMegaToggleButton('X'),
                              const SizedBox(width: 8),
                              Container(width: 1, height: 24, color: AppTheme.borderColor),
                              const SizedBox(width: 8),
                              _buildMegaToggleButton('Y'),
                            ] else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                                ),
                                child: const Text(
                                  '✨ MEGA',
                                  style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sliders de IVs
                          _StatIvSlider(label: 'ATK', value: _atkIv, color: const Color(0xFFFF6B35), onChanged: (v) => setState(() => _atkIv = v)),
                          _StatIvSlider(label: 'DEF', value: _defIv, color: const Color(0xFF2196F3), onChanged: (v) => setState(() => _defIv = v)),
                          _StatIvSlider(label: 'STA', value: _staIv, color: const Color(0xFF4CAF50), onChanged: (v) => setState(() => _staIv = v)),
                          
                          const SizedBox(height: 8),
                          
                          // Selector de Nivel
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Nivel', style: TextStyle(color: AppTheme.textSecond, fontSize: 12, fontWeight: FontWeight.w600)),
                              DropdownButton<int>(
                                value: _selectedLevel,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.textSecond),
                                dropdownColor: AppTheme.bgCard,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
                                items: [50, 45, 40, 35, 30, 25, 20, 15].map((lvl) => DropdownMenuItem(value: lvl, child: Text('Nvl $lvl'))).toList(),
                                onChanged: (v) { if (v != null) setState(() => _selectedLevel = v); },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Stats base ──
                    if (widget.pokemon.baseAttack != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionTitle(title: 'Stats base'),
                          if (_showMega)
                            Row(
                              children: [
                                Icon(Icons.bolt, color: const Color(0xFFFFD700), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Mega: +20%',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      StatBar(
                        label: 'Ataque',
                        value: _getEffectiveStats()['atk']! + _atkIv,
                        maxValue: 350,
                        color: _showMega ? const Color(0xFFFF9800) : const Color(0xFFFF6B35),
                      ),
                      StatBar(
                        label: 'Defensa',
                        value: _getEffectiveStats()['def']! + _defIv,
                        maxValue: 350,
                        color: _showMega ? const Color(0xFF4FC3F7) : const Color(0xFF2196F3),
                      ),
                      StatBar(
                        label: 'Stamina',
                        value: _getEffectiveStats()['sta']! + _staIv,
                        maxValue: 500,
                        color: _showMega ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Info de juego ──
                    _SectionTitle(title: 'Información de juego'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (widget.pokemon.buddyDistanceKm != null)
                          Expanded(child: _InfoTile(icon: Icons.directions_walk, label: 'Buddy km', value: '${widget.pokemon.buddyDistanceKm} km', color: const Color(0xFF00B4FF))),
                        if (widget.pokemon.buddyDistanceKm != null && widget.pokemon.candyToEvolve != null) const SizedBox(width: 12),
                        if (widget.pokemon.candyToEvolve != null)
                          Expanded(child: _InfoTile(icon: Icons.fiber_manual_record, label: 'Candy evolución', value: '${widget.pokemon.candyToEvolve}', color: const Color(0xFFFF69B4))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (widget.pokemon.raidLevel != null)
                      _InfoTile(icon: Icons.shield, label: 'Nivel de Raid', value: 'Tier ${widget.pokemon.raidLevel}', color: const Color(0xFFFFD700), full: true),
                    const SizedBox(height: 20),

                    // ── Movimientos ──
                    if (widget.pokemon.fastMoves.isNotEmpty || widget.pokemon.chargedMoves.isNotEmpty) ...[
                      _SectionTitle(title: 'Movimientos'),
                      const SizedBox(height: 10),
                      if (widget.pokemon.fastMoves.isNotEmpty) ...[
                        const Text('RÁPIDOS', style: TextStyle(color: AppTheme.textSecond, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          ...widget.pokemon.fastMoves.map((m) => _MoveBadge(name: m, color: const Color(0xFF00B4FF))),
                          ...widget.pokemon.eliteFastMoves.map((m) => _MoveBadge(name: m, color: const Color(0xFFFFD700), elite: true)),
                        ]),
                        const SizedBox(height: 12),
                      ],
                      if (widget.pokemon.chargedMoves.isNotEmpty) ...[
                        const Text('CARGADOS', style: TextStyle(color: AppTheme.textSecond, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          ...widget.pokemon.chargedMoves.map((m) => _MoveBadge(name: m, color: const Color(0xFFFF6B35))),
                          ...widget.pokemon.eliteChargedMoves.map((m) => _MoveBadge(name: m, color: const Color(0xFFA855F7), elite: true)),
                        ]),
                        const SizedBox(height: 20),
                      ],
                    ],

                    // ── Evoluciones ──
                    if (widget.pokemon.evolutions.isNotEmpty) ...[
                      _SectionTitle(title: 'Evoluciones'),
                      const SizedBox(height: 10),
                      ...widget.pokemon.evolutions.map((evo) => _EvoTile(evo: evo, primaryColor: primary)),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para los sliders de IVs
  Widget _StatIvSlider({required String label, required int value, required Color color, required ValueChanged<int> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 15,
              divisions: 15,
              label: value.toString(),
              activeColor: color,
              inactiveColor: color.withOpacity(0.2),
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text('$value', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(Color primary) {
    return Container(
      height: 210,
      decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(Icons.catching_pokemon, color: primary.withOpacity(0.3), size: 48),
    );
  }
}

// ─────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title.toUpperCase(),
    style: const TextStyle(
      color: AppTheme.textSecond,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool full;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecond,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return full ? SizedBox(width: double.infinity, child: tile) : tile;
  }
}

class _MoveBadge extends StatelessWidget {
  final String name;
  final Color color;
  final bool elite;

  const _MoveBadge({
    required this.name,
    required this.color,
    this.elite = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: color.withOpacity(elite ? 0.7 : 0.3),
        width: elite ? 1.5 : 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (elite) ...[
          Icon(Icons.star, color: color, size: 10),
          const SizedBox(width: 4),
        ],
        Text(
          name,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _EvoTile extends StatelessWidget {
  final Map<String, dynamic> evo;
  final Color primaryColor;

  const _EvoTile({required this.evo, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final name = evo['pokemon_name'] ?? '';
    final candy = evo['candy_required'];
    final item = evo['item_required'];
    final lure = evo['lure_required'];
    final day = evo['only_evolves_in_daytime'] == true;
    final night = evo['only_evolves_in_nighttime'] == true;
    final buddy = evo['must_be_buddy_to_evolve'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.arrow_forward, color: primaryColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            children: [
              if (candy != null)
                _EvoTag('$candy candy', const Color(0xFFFF69B4)),
              if (item != null) _EvoTag(item, const Color(0xFFFFD700)),
              if (lure != null) _EvoTag(lure, const Color(0xFF4CAF50)),
              if (day) _EvoTag('Día', const Color(0xFFFFB300)),
              if (night) _EvoTag('Noche', const Color(0xFF7C4DFF)),
              if (buddy) _EvoTag('Buddy', const Color(0xFF00BCD4)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EvoTag extends StatelessWidget {
  final String text;
  final Color color;
  const _EvoTag(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

class _BadgesRow extends StatelessWidget {
  final Pokemon pokemon;
  const _BadgesRow({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final badges = <_Badge>[];
    if (pokemon.isShiny) badges.add(_Badge('✨ Shiny', const Color(0xFFFFD700)));
    if (pokemon.isNesting)
      badges.add(_Badge('🌿 Nesting', const Color(0xFF4CAF50)));
    if (pokemon.isShadow)
      badges.add(_Badge('🌑 Shadow', const Color(0xFF7C4DFF)));
    if (pokemon.isAlolan)
      badges.add(_Badge('🌺 Alolan', const Color(0xFFFF6B9D)));
    if (pokemon.isGalarian)
      badges.add(_Badge('⚙️ Galarian', const Color(0xFF78909C)));
    if (pokemon.isBaby) badges.add(_Badge('🍼 Baby', const Color(0xFFFF9800)));
    if (pokemon.isPvpExclusive)
      badges.add(_Badge('⚔️ PVP Exclusivo', const Color(0xFFE040FB)));
    if (pokemon.isRaidExclusive)
      badges.add(_Badge('🏅 Raid Exclusivo', const Color(0xFFFFD700)));

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children:
          badges
              .map(
                (b) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: b.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: b.color.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    b.label,
                    style: TextStyle(
                      color: b.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _Badge {
  final String label;
  final Color color;
  _Badge(this.label, this.color);
}
