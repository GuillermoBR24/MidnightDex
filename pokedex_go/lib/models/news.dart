class News {
  final String title;
  final String description;
  final String imageUrl;
  final String link;
  final DateTime publishedAt;
  final String category;

  News({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.publishedAt,
    required this.category,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inDays > 0) return 'Hace ${diff.inDays} días';
    if (diff.inHours > 0) return 'Hace ${diff.inHours} horas';
    if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} minutos';
    return 'Ahora';
  }
}