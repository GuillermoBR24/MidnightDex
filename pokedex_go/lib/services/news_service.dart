import 'dart:convert';
import 'package:dart_rss/domain/rss_feed.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsService {
  // Fuentes de noticias
  static const List<String> _sources = [
    'https://www.reddit.com/r/pokemongorss/new.json?limit=15',
  ];

  // 👇 Proxies CORS gratuitos (sin API key requerida)
  static const List<String> _proxies = [
    'https://api.codetabs.com/v1/proxy?quest=',  // ✅ Más estable
    'https://api.allorigins.win/raw?url=',        // ✅ Funciona bien
    'https://corsproxy.info/api/request?url=',    // ✅ Alternativa
  ];

  static Future<List<News>> fetchNews() async {
    for (final source in _sources) {
      for (final proxy in _proxies) {
        try {
          final url = kIsWeb ? '$proxy${Uri.encodeComponent(source)}' : source;
          
          print('🔄 Intentando: $url');
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'MidnightDex/1.0',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 25));

          if (response.statusCode == 200) {
            print('✅ Noticias cargadas exitosamente');
            return _parseRedditJson(response.body);
          }
        } catch (e) {
          print('⚠️ Falló con proxy $proxy: $e');
          continue;
        }
      }
    }
    
    throw Exception('No se pudieron cargar las noticias. Verifica tu conexión.');
  }

  // ── Parser para Reddit JSON API ──
  static List<News> _parseRedditJson(String body) {
    try {
      final jsonData = json.decode(body);
      final children = jsonData['data']['children'] as List;
      
      return children.map((post) {
        final data = post['data'];
        final thumbnail = data['thumbnail'] as String?;
        
        // Filtrar y limpiar URL de imagen
        String imageUrl = '';
        if (thumbnail != null && thumbnail.startsWith('http')) {
          // Convertir preview images a URL directa si es posible
          imageUrl = thumbnail.replaceAll('&amp;', '&');
        }
        
        // Limpiar enlace
        final permalink = data['permalink']?.toString() ?? '';
        final link = permalink.isNotEmpty 
            ? 'https://reddit.com$permalink' 
            : (data['url']?.toString() ?? '');

        return News(
          title: data['title']?.toString() ?? 'Sin título',
          description: _stripHtml(data['selftext']?.toString() ?? ''),
          imageUrl: imageUrl.isNotEmpty && !imageUrl.contains('self') && !imageUrl.contains('default') 
              ? imageUrl 
              : 'https://www.redditstatic.com/desktop2x/img/id-cards/home-banner.png',
          link: link,
          publishedAt: DateTime.fromMillisecondsSinceEpoch(
            (data['created_utc']?.toDouble() ?? 0) * 1000,
          ),
          category: 'Pokémon GO',
        );
      }).toList();
    } catch (e) {
      print('❌ Error parsing JSON: $e');
      return [];
    }
  }

  // ── Parser para RSS (respaldo) ──
  static List<News> _parseRss(String body) {
    try {
      // Usar dart_rss si está disponible, sino parsing básico
      // Aquí asumimos que tienes importado: import 'package:dart_rss/dart_rss.dart';
      final rss = RssFeed.parse(body);
      
      return (rss.items ?? []).map((item) {
        final title = (item.title as String?) ?? 'Sin título';
        final description = (item.description as String?) ?? '';
        final content = (item.content as String?) ?? '';
        final link = (item.link as String?) ?? '';
        final pubDate = (item.pubDate as DateTime?) ?? DateTime.now();
        
        final imageUrl = _extractImageUrl(content.isNotEmpty ? content : description);
        
        return News(
          title: title,
          description: _stripHtml(description),
          imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://www.redditstatic.com/desktop2x/img/id-cards/home-banner.png',
          link: link.replaceAll('.compact', ''),
          publishedAt: pubDate,
          category: 'Pokémon GO',
        );
      }).toList();
    } catch (e) {
      print('❌ Error parsing RSS: $e');
      return [];
    }
  }

  // Helpers
  static String _extractImageUrl(String html) {
    final imgRegex = RegExp(r'<img[^>]+src="([^"]+)"');
    final match = imgRegex.firstMatch(html);
    return match?.group(1)?.replaceAll('&amp;', '&') ?? '';
  }

  static String _stripHtml(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .substring(0, text.length > 200 ? 200 : text.length); // Limitar longitud
  }
}