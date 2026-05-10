import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pogo_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  List<Pokemon> _allPokemon = [];
  List<Pokemon> _filtered = [];
  bool _loading = true;
  String _error = '';
  final TextEditingController _search = TextEditingController();
  String _filterType = 'All';

  static const List<String> _types = [
    'All',
    'Normal',
    'Fire',
    'Water',
    'Electric',
    'Grass',
    'Ice',
    'Fighting',
    'Poison',
    'Ground',
    'Flying',
    'Psychic',
    'Bug',
    'Rock',
    'Ghost',
    'Dragon',
    'Dark',
    'Steel',
    'Fairy',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list = await PogoApiService.fetchAllPokemon();
      setState(() {
        _allPokemon = list;
        _filtered = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _search.text.toLowerCase();
    setState(() {
      _filtered =
          _allPokemon.where((p) {
            final matchName =
                p.name.toLowerCase().contains(q) || p.id.toString().contains(q);
            final matchType =
                _filterType == 'All' || p.types.contains(_filterType);
            return matchName && matchType;
          }).toList();
    });
  }

  void _setType(String type) {
    setState(() => _filterType = type);
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error.isNotEmpty) return _buildError();

    return Column(
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _search,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Buscar Pokémon...',
              hintStyle: const TextStyle(color: AppTheme.textSecond),
              prefixIcon: const Icon(Icons.search, color: AppTheme.accentBlue),
              
              // 👇 Botón X para borrar (solo visible cuando hay texto)
              suffixIcon:
                  _search.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textSecond, size: 20),
                          onPressed: () {
                            _search.clear();  // 👈 Borra el texto
                            _applyFilter();   // 👈 Aplica el filtro para mostrar todos
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      : null,
              
              filled: true,
              fillColor: AppTheme.bgSurface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.accentBlue, width: 1.5),
              ),
            ),
          ),
        ),
        // Filtro de tipos
        SizedBox(
          height: 44,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: _types.length,
            itemBuilder: (_, i) {
              final type = _types[i];
              final color =
                  type == 'All'
                      ? AppTheme.accentBlue
                      : AppTheme.getTypeColor(type);
              final selected = _filterType == type;
              return GestureDetector(
                onTap: () => _setType(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selected ? color.withOpacity(0.25) : AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? color : AppTheme.borderColor,
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: selected ? color : AppTheme.textSecond,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Contador
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${_filtered.length} Pokémon',
                style: const TextStyle(
                  color: AppTheme.textSecond,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.60,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _filtered.length,
            addAutomaticKeepAlives: true, // 👈 Mantiene el estado
            addRepaintBoundaries: true, // 👈 Optimiza renderizado
            itemBuilder: (context, index) {
              // 👇 Calcula el ancho disponible para 3 columnas
              final screenWidth = MediaQuery.of(context).size.width;
              final padding = 16.0; // 8px left + 8px right
              final spacing = 8.0; // crossAxisSpacing
              final cellWidth = (screenWidth - padding - (2 * spacing)) / 3;
              final cellHeight = cellWidth / 0.75; // childAspectRatio

              return SizedBox(
                width: cellWidth,
                height: cellHeight,
                child: PokemonCard(
                  pokemon: _filtered[index],
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => PokemonDetailScreen(
                                pokemon: _filtered[index],
                              ),
                        ),
                      ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppTheme.accentBlue),
        const SizedBox(height: 16),
        Text(
          'Cargando Pokédex...',
          style: const TextStyle(color: AppTheme.textSecond, fontSize: 14),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off, color: AppTheme.textSecond, size: 48),
        const SizedBox(height: 12),
        const Text(
          'Error al conectar con la API',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        const SizedBox(height: 8),
        // Muestra el error real para diagnosticar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecond, fontSize: 11),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _loading = true;
              _error = '';
            });
            _load();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentBlue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}
