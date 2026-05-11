import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/news.dart';
import '../services/news_service.dart';
import '../theme/app_theme.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<News> _news = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    try {
      final news = await NewsService.fetchNews();
      setState(() {
        _news = news;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_error.isNotEmpty) return _buildError();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: const Text(
          'Noticias Pokémon GO',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.accentBlue),
            onPressed: _loadNews,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        color: AppTheme.accentBlue,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _news.length,
          itemBuilder: (_, index) => _NewsCard(
            news: _news[index],
            onTap: () => _openLink(_news[index].link),
          ).animate().fadeIn(delay: (index * 100).ms, duration: 300.ms).slideY(begin: 0.1),
        ),
      ),
    );
  }

  Widget _buildLoading() => Scaffold(
    backgroundColor: AppTheme.bgDark,
    appBar: AppBar(
      backgroundColor: AppTheme.bgDark,
      title: const Text('Noticias Pokémon GO'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.accentBlue),
          SizedBox(height: 16),
          Text(
            'Cargando noticias...',
            style: TextStyle(color: AppTheme.textSecond),
          ),
        ],
      ),
    ),
  );

  Widget _buildError() => Scaffold(
    backgroundColor: AppTheme.bgDark,
    appBar: AppBar(
      backgroundColor: AppTheme.bgDark,
      title: const Text('Noticias Pokémon GO'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.accentBlue),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.textSecond, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Error al cargar noticias',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecond, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────
// Card de noticia
// ─────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  final News news;
  final VoidCallback onTap;

  const _NewsCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: news.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 180,
                  color: AppTheme.bgSurface,
                  child: const Center(
                    child: CircularProgressIndicator(color: AppTheme.accentBlue),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 180,
                  color: AppTheme.bgSurface,
                  child: const Icon(
                    Icons.newspaper,
                    color: AppTheme.textSecond,
                    size: 48,
                  ),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y tiempo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          news.category,
                          style: const TextStyle(
                            color: AppTheme.accentBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, color: AppTheme.textSecond, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        news.timeAgo,
                        style: const TextStyle(
                          color: AppTheme.textSecond,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Título
                  Text(
                    news.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Descripción
                  if (news.description.isNotEmpty)
                    Text(
                      news.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecond,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Botón leer más
                  Row(
                    children: [
                      const Text(
                        'Leer más',
                        style: TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: AppTheme.accentBlue, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}