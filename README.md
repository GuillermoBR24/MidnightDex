# MidnightDex - Pokedex Go

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)
![Web](https://img.shields.io/badge/Web-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white)

Una aplicación Flutter para entusiastas de Pokémon GO que proporciona información completa sobre Pokémon, raids, noticias y más.

## ✨ Características

- **Pokedex Completa**: Explora todos los Pokémon con detalles como estadísticas, tipos y evoluciones
- **Información de Raids**: Consulta raids activos y detalles de encuentros
- **Noticias Actualizadas**: Mantente al día con las últimas noticias de Pokémon GO a través de RSS
- **Sistema de Tiers**: Información sobre rankings y clasificaciones
- **Interfaz Moderna**: Diseño intuitivo con animaciones y efectos visuales atractivos
- **Multiplataforma**: Compatible con Android, iOS, Web, Windows, Linux y macOS

## 🚀 Instalación

### Prerrequisitos

- [Flutter](https://flutter.dev/docs/get-started/install) (versión 3.7.2 o superior)
- [Dart](https://dart.dev/get-dart) (incluido con Flutter)
- Un editor como [VS Code](https://code.visualstudio.com/) con extensiones de Flutter

### Configuración del Proyecto

1. Clona el repositorio:
   ```bash
   git clone https://github.com/GuillermoBR24/midnightdex.git
   cd midnightdex/pokedex_go
   ```

2. Instala las dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

### Construcción para Plataformas Específicas

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

#### Windows
```bash
flutter build windows --release
```

#### Linux
```bash
flutter build linux --release
```

#### macOS
```bash
flutter build macos --release
```

## 📱 Uso

La aplicación cuenta con varias secciones principales:

- **Inicio**: Vista general con acceso rápido a todas las funciones
- **Pokedex**: Navega por todos los Pokémon disponibles
- **Raids**: Información sobre raids activos y próximos
- **Noticias**: Últimas actualizaciones de Pokémon GO
- **Tiers**: Rankings y clasificaciones de Pokémon

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework principal para desarrollo multiplataforma
- **Dart**: Lenguaje de programación
- **HTTP**: Para llamadas a APIs
- **Cached Network Image**: Optimización de carga de imágenes
- **Flutter Animate**: Animaciones fluidas
- **Google Fonts**: Tipografías atractivas
- **Shimmer**: Efectos de carga
- **Dart RSS**: Parseo de feeds RSS para noticias
- **URL Launcher**: Apertura de enlaces externos

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/                   # Modelos de datos
│   ├── pokemon.dart         # Modelo de Pokémon
│   ├── raid_info.dart       # Información de raids
│   ├── news.dart            # Modelo de noticias
│   ├── tier_entry.dart      # Entradas de tiers
│   └── iv_config.dart       # Configuración de IV
├── screens/                  # Pantallas de la aplicación
│   ├── home_screen.dart     # Pantalla principal
│   ├── pokedex_screen.dart  # Pantalla de Pokedex
│   ├── raids_screen.dart    # Pantalla de raids
│   ├── news_screen.dart     # Pantalla de noticias
│   ├── tier_screen.dart     # Pantalla de tiers
│   ├── pokemon_detail_screen.dart  # Detalles de Pokémon
│   └── raid_detail_screen.dart     # Detalles de raid
├── services/                 # Servicios para APIs
│   ├── pogo_api_service.dart # Servicio de API de Pokémon GO
│   ├── news_service.dart     # Servicio de noticias
│   ├── raid_service.dart     # Servicio de raids
│   └── tier_service.dart     # Servicio de tiers
├── widgets/                  # Widgets reutilizables
│   ├── pokemon_card.dart    # Tarjeta de Pokémon
│   ├── stat_bar.dart        # Barra de estadísticas
│   └── type_badge.dart      # Insignia de tipo
└── theme/                    # Tema de la aplicación
    └── app_theme.dart       # Configuración de tema
```

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Para contribuir:

1. Haz un fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 📞 Contacto

Si tienes preguntas o sugerencias, no dudes en abrir un issue en GitHub.

---

¡Disfruta explorando el mundo de Pokémon GO con MidnightDex! 🌟
