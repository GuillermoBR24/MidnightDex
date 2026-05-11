import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/tier_entry.dart';
import '../services/tier_service.dart';
import '../theme/app_theme.dart';
import '../widgets/type_badge.dart';

class TierScreen extends StatefulWidget {
  const TierScreen({super.key});

  @override
  State<TierScreen> createState() => _TierScreenState();
}

class _TierScreenState extends State<TierScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Map<String, List<TierEntry>> _byType = {};
  List<TierEntry> _megas = [];
  bool _loading = true;
  String _error = '';
  String _selectedType = 'Fire';

  static const List<String> _types = [
    'Fire',
    'Water',
    'Grass',
    'Electric',
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
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final (byType, megas) = await TierService.fetchTierData();
      setState(() {
        _byType = byType;
        _megas = megas;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error.isNotEmpty) return _buildError();

    return Column(
      children: [
        // Tabs
        Container(
          color: AppTheme.bgDark,
          child: TabBar(
            controller: _tabs,
            labelColor: AppTheme.accentBlue,
            unselectedLabelColor: AppTheme.textSecond,
            indicatorColor: AppTheme.accentBlue,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'TOP 10 POR TIPO'),
              Tab(text: 'MEJORES MEGAS'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _TypeTab(
                byType: _byType,
                types: _types,
                selectedType: _selectedType,
                onTypeSelected: (t) => setState(() => _selectedType = t),
              ),
              _MegaTab(megas: _megas),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppTheme.accentBlue),
        SizedBox(height: 16),
        Text(
          'Calculando tier list...',
          style: TextStyle(color: AppTheme.textSecond),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: AppTheme.textSecond, size: 48),
        const SizedBox(height: 12),
        Text(
          _error,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecond, fontSize: 12),
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

// ─────────────────────────────────────────────────────────
// Tab: Top 10 por tipo
// ─────────────────────────────────────────────────────────
class _TypeTab extends StatelessWidget {
  final Map<String, List<TierEntry>> byType;
  final List<String> types;
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  const _TypeTab({
    required this.byType,
    required this.types,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final list = byType[selectedType] ?? [];

    return Column(
      children: [
        // Selector de tipo horizontal
        SizedBox(
          height: 46,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            scrollDirection: Axis.horizontal,
            itemCount: types.length,
            itemBuilder: (_, i) {
              final type = types[i];
              final color = AppTheme.getTypeColor(type);
              final sel = selectedType == type;
              return GestureDetector(
                onTap: () => onTypeSelected(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? color.withOpacity(0.25) : AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? color : AppTheme.borderColor,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: sel ? color : AppTheme.textSecond,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Cabecera
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.getTypeColor(selectedType),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Top 10 atacantes $selectedType — PVE Raids',
                style: const TextStyle(
                  color: AppTheme.textSecond,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // Lista
        Expanded(
          child:
              list.isEmpty
                  ? const Center(
                    child: Text(
                      'Sin datos para este tipo',
                      style: TextStyle(color: AppTheme.textSecond),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    itemCount: list.length,
                    itemBuilder:
                        (_, i) => _TierCard(entry: list[i], rank: i + 1)
                            .animate()
                            .fadeIn(delay: (i * 40).ms, duration: 300.ms)
                            .slideX(begin: 0.05),
                  ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tab: Mejores Megas por tipo
// ─────────────────────────────────────────────────────────
class _MegaTab extends StatelessWidget {
  final List<TierEntry> megas;
  const _MegaTab({required this.megas});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppTheme.accentCyan,
                size: 14,
              ),
              const SizedBox(width: 8),
              const Text(
                'Mejor mega evolución por tipo — PVE',
                style: TextStyle(
                  color: AppTheme.textSecond,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            itemCount: megas.length,
            itemBuilder:
                (_, i) =>
                    _TierCard(entry: megas[i], rank: i + 1, showType: true)
                        .animate()
                        .fadeIn(delay: (i * 40).ms, duration: 300.ms)
                        .slideX(begin: 0.05),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// Card de entrada de tier
// ─────────────────────────────────────────────────────────
class _TierCard extends StatelessWidget {
  final TierEntry entry;
  final int rank;
  final bool showType;

  const _TierCard({
    required this.entry,
    required this.rank,
    this.showType = false,
  });

  static const Map<String, Color> _tierColors = {
    'S': Color(0xFFFF4444),
    'A': Color(0xFFFF9900),
    'B': Color(0xFF00B4FF),
    'C': Color(0xFF78909C),
  };

  @override
  Widget build(BuildContext context) {
    final tierColor = _tierColors[entry.tier] ?? AppTheme.textSecond;
    final primary =
        entry.types.isNotEmpty
            ? AppTheme.getTypeColor(entry.types.first)
            : AppTheme.accentBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rank <= 3 ? primary : AppTheme.textSecond,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Imagen
          SizedBox(
            width: 52,
            height: 52,
            child: entry.isMega
                ? Image.asset(  // 👇 Para Megas: usa asset local
                    entry.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.auto_awesome,  // ✨ Icono de Mega si falla
                      color: primary.withOpacity(0.3),
                      size: 32,
                    ),
                  )
                : CachedNetworkImage(  // 👇 Para normales: usa URL
                    imageUrl: entry.imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Icon(
                      Icons.catching_pokemon,
                      color: primary.withOpacity(0.3),
                      size: 32,
                    ),
                  ),
          ),
          const SizedBox(width: 10),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre + labels
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Label: MEGA, LEGENDARY, MYTHIC
                    if (entry.label.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: _labelColor(entry).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _labelColor(entry).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          entry.label,
                          style: TextStyle(
                            color: _labelColor(entry),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    // Badge: NORMAL, SHADOW (si no tiene otro label)
                    if (entry.label.isEmpty && entry.formType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: _formColor(entry).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: _formColor(entry).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          entry.formType,
                          style: TextStyle(
                            color: _formColor(entry),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    // Badge: tipo del tier para megas
                    if (entry.tierType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          entry.tierType!,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Tipos + stats
                Row(
                  children: [
                    if (showType)
                      ...entry.types.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: TypeBadge(type: t, small: true),
                        ),
                      ),
                    if (!showType) ...[
                      _StatChip(
                        'ATK',
                        entry.baseAttack,
                        const Color(0xFFFF6B35),
                      ),
                      const SizedBox(width: 4),
                      _StatChip(
                        'DEF',
                        entry.baseDefense,
                        const Color(0xFF2196F3),
                      ),
                      const SizedBox(width: 4),
                      _StatChip(
                        'STA',
                        entry.baseStamina,
                        const Color(0xFF4CAF50),
                      ),
                    ],
                  ],
                ),

                // Mejor movimiento
                if (entry.bestFastMove != null || entry.bestChargedMove != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${entry.bestFastMove ?? ''} · ${entry.bestChargedMove ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecond,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Score DPS + Tier badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: tierColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.tier,
                  style: TextStyle(
                    color: tierColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.maxCp > 0 ? '${entry.maxCp} CP' : 'MEGA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _labelColor(TierEntry e) {
    if (e.isMega) return const Color(0xFF00E5FF);
    if (e.isShadow) return const Color(0xFF7C4DFF);
    if (e.isMythic) return const Color(0xFFA855F7);
    if (e.isLegendary) return const Color(0xFFFFD700);
    return AppTheme.accentBlue;
  }

  Color _formColor(TierEntry e) {
    if (e.isShadow) return const Color(0xFF7C4DFF); // Púrpura para shadow
    return AppTheme.textSecond; // Gris neutro para normal
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      '$label $value',
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700),
    ),
  );
}
