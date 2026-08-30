// lib/screens/pokemon_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pokedex_go/models/move_detail.dart';
import 'package:pokedex_go/screens/pokedex_screen.dart';
import '../models/pokemon.dart';
import '../theme/app_theme.dart';
import '../widgets/type_badge.dart';
import '../widgets/stat_bar.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;
  final List<Pokemon> allPokemon;
  const PokemonDetailScreen({super.key, required this.pokemon,
    required this.allPokemon,});

  @override
  Widget build(BuildContext context) {
    // 👇 Verificación mejorada:
    // 1. Si isReleased es false → no disponible
    // 2. Si no tiene stats base (attack, defense, stamina) → no disponible 
    //    (esto atrapa a Pokémon futuros como Pecharunt que la API lista pero aún no tienen datos de combate)
    final hasNoStats = pokemon.baseAttack == null || 
                       pokemon.baseDefense == null || 
                       pokemon.baseStamina == null;
    
    if (!pokemon.isReleased || hasNoStats) {
      return _UnreleasedView(pokemon: pokemon);
    }
    
    return _ReleasedView(pokemon: pokemon, allPokemon: allPokemon);
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
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '#${pokemon.paddedId} ${pokemon.name}',
          style: const TextStyle(color: Color(0xFF4A4A65)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen bloqueada con candado
              Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo de fondo
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1A2E).withOpacity(0.5),
                      border: Border.all(
                        color: const Color(0xFF2D2D45),
                        width: 2,
                      ),
                    ),
                  ),
                  // Imagen desaturada
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 0.25, 0,
                    ]),
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      height: 180,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.catching_pokemon,
                        color: const Color(0xFF3A3A55).withOpacity(0.5),
                        size: 80,
                      ),
                    ),
                  ),
                  // Overlay oscuro
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.bgDark.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Candado central
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D18).withOpacity(0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2D2D45),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Color(0xFF4A4A65),
                      size: 40,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 600.ms),

              const SizedBox(height: 32),

              // Nombre del Pokémon
              Text(
                pokemon.name,
                style: const TextStyle(
                  color: Color(0xFF3A3A55),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#${pokemon.paddedId}',
                style: const TextStyle(
                  color: Color(0xFF2D2D45),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              // Caja de "no disponible"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D18),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF1E1E30),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icono de advertencia
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2D2D45),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF4A4A65),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No disponible en\nPokémon GO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF5A5A78),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Este Pokémon aún no ha sido\nintroducido en el juego.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF3A3A50),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Separador
                    Container(
                      height: 1,
                      color: const Color(0xFF1E1E30),
                    ),
                    const SizedBox(height: 20),
                    // Info de generación si existe
                    if (pokemon.generation != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category,
                            color: const Color(0xFF4A4A65),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pokemon.generation!,
                            style: const TextStyle(
                              color: Color(0xFF4A4A65),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    // Tipos (solo visuales, sin interacción)
                    if (pokemon.types.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: pokemon.types.map((t) {
                          final color = AppTheme.getTypeColor(t);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                color: color.withOpacity(0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Mensaje adicional
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.update,
                      color: const Color(0xFF4A4A65),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Vuelve pronto para comprobar si ya está disponible',
                      style: TextStyle(
                        color: Color(0xFF4A4A65),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Vista cuando el Pokémon SÍ está en el juego
// ─────────────────────────────────────────────
class _ReleasedView extends StatefulWidget {
  final Pokemon pokemon;
  final List<Pokemon> allPokemon;
  const _ReleasedView({required this.pokemon,
    required this.allPokemon,});

  @override
  State<_ReleasedView> createState() => _ReleasedViewState();
}

class _ReleasedViewState extends State<_ReleasedView> {
  bool _showShiny = false;
  bool _showMega = false;
  int _selectedMegaIndex = 0;
  int _selectedLevel = 50;

  // 👇 NUEVO: Para formas alternativas (Kyurem Blanco/Negro)
  bool _showAlternateForm = false;
  int _selectedAlternateFormIndex = 0;

  // IVs por defecto (máximos)
  int _atkIv = 15;
  int _defIv = 15;
  int _staIv = 15;

  bool get _isMegaAvailable => widget.pokemon.megaEvolutions.isNotEmpty;
  bool get _hasMultipleMegas => widget.pokemon.megaEvolutions.length > 1;

  // 👇 NUEVO: Check si tiene formas alternativas activables
  bool get _hasAlternateForms => widget.pokemon.alternateForms.isNotEmpty;

  MegaEvolution? get _currentMega =>
      _isMegaAvailable ? widget.pokemon.megaEvolutions[_selectedMegaIndex] : null;

  // 👇 NUEVO: Obtener forma alterna seleccionada
  Map<String, dynamic>? get _currentAlternateForm {
    if (_hasAlternateForms && _showAlternateForm) {
      if (_selectedAlternateFormIndex < widget.pokemon.alternateForms.length) {
        return widget.pokemon.alternateForms[_selectedAlternateFormIndex];
      }
    }
    return null;
  }

  Map<String, int> _getEffectiveStats() {
    //  PRIORIDAD: Forma alterna > Mega > Normal
    if (_currentAlternateForm != null) {
      return {
        'atk': _currentAlternateForm!['attack'] as int,
        'def': _currentAlternateForm!['defense'] as int,
        'sta': _currentAlternateForm!['stamina'] as int,
      };
    }
    if (_showMega && _currentMega != null) {
      return {
        'atk': _currentMega!.attack,
        'def': _currentMega!.defense,
        'sta': _currentMega!.stamina,
      };
    }
    return {
      'atk': widget.pokemon.baseAttack ?? 0,
      'def': widget.pokemon.baseDefense ?? 0,
      'sta': widget.pokemon.baseStamina ?? 0,
    };
  }

  List<String> _getCurrentTypes() {
    // 👇 PRIORIDAD: Forma alterna > Mega > Normal
    if (_currentAlternateForm != null) {
      final types = _currentAlternateForm!['types'] as List?;
      if (types != null && types.isNotEmpty) {
        return types.cast<String>();
      }
    }
    if (_showMega && _currentMega != null && _currentMega!.types.isNotEmpty) {
      return _currentMega!.types;
    }
    return widget.pokemon.types;
  }

  // 👇 NUEVO: Nombre de la forma actual
  String _getCurrentFormName() {
    if (_currentAlternateForm != null) {
      return _currentAlternateForm!['name'] as String;
    }
    if (_showMega && _currentMega != null) {
      return '${widget.pokemon.name} (${_currentMega!.label})';
    }
    return widget.pokemon.name;
  }

  int get _currentCp {
    final s = _getEffectiveStats();
    final atk = s['atk']! + _atkIv;
    final def = s['def']! + _defIv;
    final sta = s['sta']! + _staIv;
    final cpm = Pokemon.getCpmForLevel(_selectedLevel);
    return Pokemon.calcCp(atk, def, sta, cpm: cpm);
  }

  Widget _buildMegaToggleButton(int index) {
    final mega = widget.pokemon.megaEvolutions[index];
    final isSelected = _selectedMegaIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMegaIndex = index;
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
            color: isSelected ? const Color(0xFF00E5FF) : AppTheme.borderColor,
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
          '✨ ${mega.label}',
          style: TextStyle(
            color: isSelected ? const Color(0xFF00E5FF) : AppTheme.textSecond,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
  Widget _buildAlternateFormButton(int index) {
    final form = widget.pokemon.alternateForms[index];
    final isSelected = _selectedAlternateFormIndex == index;
    
    // 👇 Extraer solo la parte relevante del nombre (ej: "Azul", "Naranja")
    String formName = (form['name'] as String);
    // Eliminar "Floette" o nombre del Pokémon
    formName = formName.replaceAll('${widget.pokemon.name} ', '');
    formName = formName.replaceAll('flor ', '');  // Para Floette
    formName = formName.replaceAll('(', '').replaceAll(')', '');
    formName = formName.trim();
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAlternateFormIndex = index;
          _showAlternateForm = true;
          _showMega = false;
          _showShiny = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getTypeColor('Ice').withOpacity(0.25)
              : AppTheme.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.getTypeColor('Ice') : AppTheme.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.getTypeColor('Ice').withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Text(
          formName,  // 👇 Texto más corto
          style: TextStyle(
            color: isSelected ? AppTheme.getTypeColor('Ice') : AppTheme.textSecond,
            fontSize: 10,  // 👇 Fuente más pequeña
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 👇 ACTUALIZADO: Método para construir la imagen con prioridad de formas
  Widget _buildPokemonImage(Color primary) {
    // 👇 PRIORIDAD 1: Forma alterna (Kyurem Negro/Blanco)
    if (_showAlternateForm && _currentAlternateForm != null) {
      final imageUrl = _currentAlternateForm!['imageUrl'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          height: 210,
          fit: BoxFit.contain,
          errorWidget: (_, __, ___) => _buildPlaceholderImage(primary),
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
      }
    }

    // 👇 PRIORIDAD 2: Mega
    if (_showMega && _currentMega != null) {
      return CachedNetworkImage(
        imageUrl: _currentMega!.imageUrl,
        height: 210,
        fit: BoxFit.contain,
        errorWidget: (_, __, ___) => _buildPlaceholderImage(primary),
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
    }

    // 👇 PRIORIDAD 3: Shiny
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

    // 👇 Por defecto, imagen normal
    return CachedNetworkImage(
      imageUrl: widget.pokemon.imageUrl,
      height: 210,
      fit: BoxFit.contain,
      errorWidget: (_, __, ___) => _buildPlaceholderImage(primary),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
  }

  void _toggleShiny() {
    if (widget.pokemon.possibleShiny == true) {
      setState(() {
        _showShiny = !_showShiny;
        if (_showShiny) {
          _showMega = false;
          _showAlternateForm = false;
        }
      });
    }
  }

  void _toggleMega() {
    if (_isMegaAvailable) {
      setState(() {
        _showMega = !_showMega;
        if (_showMega) {
          _showShiny = false;
          _showAlternateForm = false;
        }
      });
    }
  }

  // 👇 NUEVO: Toggle para formas alternativas
  void _toggleAlternateForm() {
    if (_hasAlternateForms) {
      setState(() {
        _showAlternateForm = !_showAlternateForm;
        if (_showAlternateForm) {
          _showMega = false;
          _showShiny = false;
        }
      });
    }
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
              // 👇 NUEVO: Botón Formas Alternas (Kyurem Negro/Blanco)
              if (_hasAlternateForms)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: IconButton(
                          key: ValueKey<bool>(_showAlternateForm),
                          icon: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              _showAlternateForm
                                  ? AppTheme.getTypeColor('Ice')
                                  : AppTheme.textSecond,
                              BlendMode.srcIn,
                            ),
                            child: const Icon(
                              Icons.swap_horiz,
                              size: 24,
                            ),
                          ),
                          tooltip: _showAlternateForm ? 'Ver normal' : 'Ver formas',
                          onPressed: _toggleAlternateForm,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // 👇 Botón Mega Evolución
              if (_isMegaAvailable)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: IconButton(
                          key: ValueKey<bool>(_showMega),
                          icon: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              _showMega ? const Color(0xFF00E5FF) : AppTheme.textSecond,
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
                      size: 24,
                      shadows: _showShiny
                          ? [
                              Shadow(
                                color: const Color(0xFFFFD700).withOpacity(0.6),
                                blurRadius: 10,
                              )
                            ]
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
              const SizedBox(width: 4),
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
                          color: widget.pokemon.isMythic
                              ? const Color(0xFF2D1A3E)
                              : const Color(0xFF1A2A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.pokemon.isMythic
                                ? const Color(0xFFA855F7)
                                : const Color(0xFFFFD700),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.pokemon.isMythic ? Icons.auto_awesome : Icons.star,
                              color: widget.pokemon.isMythic
                                  ? const Color(0xFFA855F7)
                                  : const Color(0xFFFFD700),
                              size: 12,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.pokemon.isMythic ? 'Mythic' : 'Legendary',
                              style: TextStyle(
                                color: widget.pokemon.isMythic
                                    ? const Color(0xFFA855F7)
                                    : const Color(0xFFFFD700),
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
                        Expanded(
                          child: Text(
                            _getCurrentFormName(),
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '#${widget.pokemon.paddedId}',
                          style: TextStyle(
                            color: primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (widget.pokemon.generation != null)
                      Text(
                        widget.pokemon.generation!,
                        style: const TextStyle(
                          color: AppTheme.textSecond,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _getCurrentTypes().map((t) => TypeBadge(type: t)).toList(),
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
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.height,
                              label: 'Altura',
                              value: '${widget.pokemon.pokedexHeightM!.toStringAsFixed(1)} m',
                              color: primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.monitor_weight_outlined,
                              label: 'Peso',
                              value: '${widget.pokemon.pokedexWeightKg!.toStringAsFixed(1)} kg',
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    // ── Combat Power con IVs manuales ──
                    _SectionTitle(title: 'Combat Power'),
                    const SizedBox(height: 10),
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
                              Text(
                                '$_currentCp CP',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'IVs: $_atkIv / $_defIv / $_staIv (${((_atkIv + _defIv + _staIv) / 45 * 100).toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                color: AppTheme.textSecond,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 👇 NUEVO: Botones para formas alternativas (Kyurem Negro/Blanco)
                    if (_showAlternateForm && _hasAlternateForms)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(  // 👇 CAMBIAR Row POR Wrap
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            for (int i = 0; i < widget.pokemon.alternateForms.length; i++) ...[
                              _buildAlternateFormButton(i),
                            ],
                          ],
                        ),
                      ),
                    if (_showMega && _isMegaAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _hasMultipleMegas
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (int i = 0; i < widget.pokemon.megaEvolutions.length; i++) ...[
                                    if (i > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(width: 1, height: 24, color: AppTheme.borderColor),
                                      const SizedBox(width: 8),
                                    ],
                                    _buildMegaToggleButton(i),
                                  ],
                                ],
                              )
                            : Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                                  ),
                                  child: Text(
                                    '✨ ${_currentMega?.label ?? 'MEGA'}',
                                    style: const TextStyle(
                                      color: Color(0xFF00E5FF),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
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
                          _StatIvSlider(
                            label: 'ATK',
                            value: _atkIv,
                            color: const Color(0xFFFF6B35),
                            onChanged: (v) => setState(() => _atkIv = v),
                          ),
                          _StatIvSlider(
                            label: 'DEF',
                            value: _defIv,
                            color: const Color(0xFF2196F3),
                            onChanged: (v) => setState(() => _defIv = v),
                          ),
                          _StatIvSlider(
                            label: 'STA',
                            value: _staIv,
                            color: const Color(0xFF4CAF50),
                            onChanged: (v) => setState(() => _staIv = v),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nivel',
                                style: TextStyle(
                                  color: AppTheme.textSecond,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              DropdownButton<int>(
                                value: _selectedLevel,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.arrow_drop_down, size: 18, color: AppTheme.textSecond),
                                dropdownColor: AppTheme.bgCard,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                                items: [50, 45, 40, 35, 30, 25, 20, 15]
                                    .map((lvl) => DropdownMenuItem(value: lvl, child: Text('Nvl $lvl')))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _selectedLevel = v);
                                },
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
                                const Icon(Icons.bolt, color: Color(0xFFFFD700), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _currentMega?.label ?? 'Mega',
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
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.directions_walk,
                              label: 'Buddy km',
                              value: '${widget.pokemon.buddyDistanceKm} km',
                              color: const Color(0xFF00B4FF),
                            ),
                          ),
                        if (widget.pokemon.buddyDistanceKm != null && widget.pokemon.candyToEvolve != null)
                          const SizedBox(width: 12),
                        if (widget.pokemon.candyToEvolve != null)
                          Expanded(
                            child: _InfoTile(
                              icon: Icons.fiber_manual_record,
                              label: 'Candy evolución',
                              value: '${widget.pokemon.candyToEvolve}',
                              color: const Color(0xFFFF69B4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // ── Movimientos ─
                    // ─ Movimientos con detalles ──
                    if (widget.pokemon.fastMoves.isNotEmpty || widget.pokemon.chargedMoves.isNotEmpty) ...[
                      _SectionTitle(title: 'Movimientos'),
                      const SizedBox(height: 10),
                      
                      // Movimientos Rápidos
                      if (widget.pokemon.fastMoves.isNotEmpty) ...[
                        const Text(
                          'RÁPIDOS',
                          style: TextStyle(
                            color: AppTheme.textSecond,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...widget.pokemon.fastMoves.map((m) => _MoveDetailCard(move: m)),
                        if (widget.pokemon.eliteFastMoves.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'ÉLITE RÁPIDOS',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...widget.pokemon.eliteFastMoves.map((m) => _MoveDetailCard(move: m)),
                        ],
                        const SizedBox(height: 12),
                      ],
                      
                      // Movimientos Cargados
                      if (widget.pokemon.chargedMoves.isNotEmpty) ...[
                        const Text(
                          'CARGADOS',
                          style: TextStyle(
                            color: AppTheme.textSecond,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...widget.pokemon.chargedMoves.map((m) => _MoveDetailCard(move: m)),
                        if (widget.pokemon.eliteChargedMoves.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'ÉLITE CARGADOS',
                            style: TextStyle(
                              color: Color(0xFFA855F7),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...widget.pokemon.eliteChargedMoves.map((m) => _MoveDetailCard(move: m)),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ],
                    // ── Evoluciones ──
                    // ── Evoluciones con árbol interactivo ──
                    _EvolutionTree(
                      pokemon: widget.pokemon,
                      allPokemon: widget.allPokemon,
                      primaryColor: primary,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _StatIvSlider({
    required String label,
    required int value,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
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
            child: Text(
              '$value',
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(Color primary) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
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
              if (candy != null) _EvoTag('$candy candy', const Color(0xFFFF69B4)),
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
    if (pokemon.isNesting) badges.add(_Badge('🌿 Nesting', const Color(0xFF4CAF50)));
    if (pokemon.isShadow) badges.add(_Badge('🌑 Shadow', const Color(0xFF7C4DFF)));
    if (pokemon.isAlolan) badges.add(_Badge('🌺 Alolan', const Color(0xFFFF6B9D)));
    if (pokemon.isGalarian) badges.add(_Badge('⚙️ Galarian', const Color(0xFF78909C)));
    if (pokemon.isBaby) badges.add(_Badge('🍼 Baby', const Color(0xFFFF9800)));
    if (pokemon.isPvpExclusive) badges.add(_Badge('⚔️ PVP Exclusivo', const Color(0xFFE040FB)));
    if (pokemon.isRaidExclusive) badges.add(_Badge('🏅 Raid Exclusivo', const Color(0xFFFFD700)));
    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: badges
          .map(
            (b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: b.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: b.color.withOpacity(0.4), width: 1),
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

// ─────────────────────────────────
// Card de movimiento con detalles
// ─────────────────────────────────
class _MoveDetailCard extends StatelessWidget {
  final MoveDetail move;
  const _MoveDetailCard({required this.move});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.getTypeColor(move.type);
    final isFast = move.isFast;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: move.isElite 
              ? const Color(0xFFFFD700).withOpacity(0.5) 
              : typeColor.withOpacity(0.3),
          width: move.isElite ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Nombre + Tipo + Badge Élite
          Row(
            children: [
              // Indicador de tipo
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              // Nombre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      move.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      move.type,
                      style: TextStyle(
                        color: typeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge Élite
              if (move.isElite)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: const Color(0xFFFFD700), size: 10),
                      const SizedBox(width: 3),
                      Text(
                        'ÉLITE',
                        style: TextStyle(
                          color: const Color(0xFFFFD700),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              // Badge tipo de movimiento
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isFast 
                      ? const Color(0xFF00B4FF).withOpacity(0.15)
                      : const Color(0xFFFF6B35).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isFast ? 'RÁPIDO' : 'CARGADO',
                  style: TextStyle(
                    color: isFast ? const Color(0xFF00B4FF) : const Color(0xFFFF6B35),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // Stats grid
          Row(
            children: [
              // Daño
              Expanded(
                child: _MoveStat(
                  label: 'Daño',
                  value: move.power.toString(),
                  icon: Icons.flash_on,
                  color: const Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(width: 6),
              // Energía
              Expanded(
                child: _MoveStat(
                  label: 'Energía',
                  value: move.energy.toString(),
                  icon: Icons.bolt,
                  color: move.energy > 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 6),
              // Duración
              Expanded(
                child: _MoveStat(
                  label: 'Duración',
                  value: move.durationFormatted,
                  icon: Icons.timer,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Combat stats (DPS/EPS)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // DPS
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'DPS',
                        style: TextStyle(
                          color: AppTheme.textSecond,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        move.dps.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                // EPS
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'EPS',
                        style: TextStyle(
                          color: AppTheme.textSecond,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        move.eps.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                // Turns
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Turnos',
                        style: TextStyle(
                          color: AppTheme.textSecond,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        move.combatTurns.toString(),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                // Efficiency
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Rating',
                        style: TextStyle(
                          color: AppTheme.textSecond,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getEfficiencyColor(move.efficiencyRating).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${move.efficiencyRating}%',
                          style: TextStyle(
                            color: _getEfficiencyColor(move.efficiencyRating),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getEfficiencyColor(int rating) {
    if (rating >= 80) return const Color(0xFF4CAF50);
    if (rating >= 60) return const Color(0xFFFF9800);
    if (rating >= 40) return const Color(0xFFFFC107);
    return const Color(0xFF78909C);
  }
}

class _MoveStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MoveStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────
// Tile de evolución detallado
// ─────────────────────────────────
class _EvoTileDetailed extends StatelessWidget {
  final Map<String, dynamic> evo;
  final Color primaryColor;
  const _EvoTileDetailed({required this.evo, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final name = evo['pokemon_name'] ?? '';
    final candy = evo['candy_required'];
    final item = evo['item_required'];
    final lure = evo['lure_required'];
    final day = evo['only_evolves_in_daytime'] == true;
    final night = evo['only_evolves_in_nighttime'] == true;
    final buddy = evo['must_be_buddy_to_evolve'] == true;
    final buddyDistance = evo['buddy_distance_required'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Flecha + Nombre
          Row(
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
            ],
          ),
          const SizedBox(height: 8),
          // Requisitos
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (candy != null) _EvoTag('$candy candy', const Color(0xFFFF69B4)),
              if (item != null) _EvoTag(item, const Color(0xFFFFD700)),
              if (lure != null) _EvoTag(lure, const Color(0xFF4CAF50)),
              if (day) _EvoTag('☀️ Día', const Color(0xFFFFB300)),
              if (night) _EvoTag(' Noche', const Color(0xFF7C4DFF)),
              if (buddy) _EvoTag(
                ' Buddy${buddyDistance != null ? ' ($buddyDistance km)' : ''}',
                const Color(0xFF00BCD4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────
// Árbol evolutivo completo
// ─────────────────────────────────
class _EvolutionTree extends StatelessWidget {
  final Pokemon pokemon;
  final List<Pokemon> allPokemon;
  final Color primaryColor;
  
  const _EvolutionTree({
    required this.pokemon,
    required this.allPokemon,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final chain = _buildCompleteEvolutionChain();
    
    if (chain.length <= 1 && pokemon.megaEvolutions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'Árbol de Evoluciones'),
          const SizedBox(height: 12),
          
          for (int i = 0; i < chain.length; i++) ...[
            _EvolutionNode(
              pokemon: chain[i].pokemon,
              candyCost: chain[i].candyCost,
              itemRequired: chain[i].itemRequired,
              isCurrent: chain[i].pokemon.id == pokemon.id,
            ),
            
            // Flecha centrada (si no es el último)
            if (i < chain.length - 1) ...[
              const SizedBox(height: 8),
              Center(
                child: Icon(
                  Icons.arrow_downward,
                  color: primaryColor.withOpacity(0.5),
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          
          // Mega evoluciones al final
          if (pokemon.megaEvolutions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: Icon(
                Icons.arrow_downward,
                color: const Color(0xFF00E5FF).withOpacity(0.5),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            ...pokemon.megaEvolutions.map((mega) => _MegaEvolutionNode(mega: mega)),
          ],
        ],
      ),
    );
  }
  
  List<_EvolutionChainNode> _buildCompleteEvolutionChain() {
    final chain = <_EvolutionChainNode>[];
    final basePokemon = _findBaseForm(pokemon);
    _buildChainForward(basePokemon, null, chain);
    return chain;
  }
  
  Pokemon _findBaseForm(Pokemon current) {
    for (final p in allPokemon) {
      if (p.evolutions.isNotEmpty) {
        for (final evo in p.evolutions) {
          final evoName = (evo['pokemon_name'] ?? '').toString().toLowerCase();
          if (evoName == current.name.toLowerCase()) {
            return _findBaseForm(p);
          }
        }
      }
    }
    return current;
  }
  
  void _buildChainForward(
    Pokemon current,
    Map<String, dynamic>? evoData,
    List<_EvolutionChainNode> chain,
  ) {
    chain.add(_EvolutionChainNode(
      pokemon: current,
      candyCost: evoData?['candy_required'] as int?,
      itemRequired: evoData?['item_required'] as String?,
    ));
    
    if (current.evolutions.isNotEmpty) {
      final firstEvo = current.evolutions.first;
      final evoName = (firstEvo['pokemon_name'] ?? '').toString();
      
      final nextPokemon = allPokemon.firstWhere(
        (p) => p.name.toLowerCase() == evoName.toLowerCase(),
        orElse: () => current,
      );
      
      if (nextPokemon.id != current.id) {
        _buildChainForward(nextPokemon, firstEvo, chain);
      }
    }
  }
}

class _EvolutionChainNode {
  final Pokemon pokemon;
  final int? candyCost;
  final String? itemRequired;
  
  _EvolutionChainNode({
    required this.pokemon,
    this.candyCost,
    this.itemRequired,
  });
}

class _EvolutionNode extends StatelessWidget {
  final Pokemon? pokemon;
  final int? candyCost;
  final String? itemRequired;
  final bool isCurrent;
  
  const _EvolutionNode({
    required this.pokemon,
    required this.candyCost,
    this.itemRequired,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    final nodeColor = pokemon != null && pokemon!.types.isNotEmpty
        ? AppTheme.getTypeColor(pokemon!.types.first)
        : AppTheme.accentBlue;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent 
            ? nodeColor.withOpacity(0.15) 
            : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? nodeColor : nodeColor.withOpacity(0.3),
          width: isCurrent ? 2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: nodeColor.withOpacity(0.1),
              border: Border.all(
                color: nodeColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: pokemon != null
                ? CachedNetworkImage(
                    imageUrl: pokemon!.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Icon(
                      Icons.catching_pokemon,
                      color: nodeColor.withOpacity(0.3),
                      size: 32,
                    ),
                  )
                : Icon(
                    Icons.catching_pokemon,
                    color: nodeColor.withOpacity(0.3),
                    size: 32,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pokemon?.name ?? '???',
                        style: TextStyle(
                          color: isCurrent ? nodeColor : AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: nodeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ACTUAL',
                          style: TextStyle(
                            color: nodeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (pokemon != null)
                  Wrap(
                    spacing: 4,
                    children: pokemon!.types
                        .map((t) => TypeBadge(type: t, small: true))
                        .toList(),
                  ),
                const SizedBox(height: 8),
                // Requisitos de evolución
                if (candyCost != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF69B4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cake, color: const Color(0xFFFF69B4), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$candyCost candy',
                          style: const TextStyle(
                            color: Color(0xFFFF69B4),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (itemRequired != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2, color: const Color(0xFFFFD700), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          itemRequired!,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MegaEvolutionNode extends StatelessWidget {
  final MegaEvolution mega;
  
  const _MegaEvolutionNode({required this.mega});

  @override
  Widget build(BuildContext context) {
    final megaColor = const Color(0xFF00E5FF);
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: megaColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: megaColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: megaColor.withOpacity(0.15),
              border: Border.all(
                color: megaColor.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: mega.imageUrl,
              fit: BoxFit.contain,
              errorWidget: (_, __, ___) => Icon(
                Icons.auto_awesome,
                color: megaColor.withOpacity(0.5),
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mega ${mega.label}',
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: mega.types
                      .map((t) => TypeBadge(type: t, small: true))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}