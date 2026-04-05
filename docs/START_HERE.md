# ¡Comienza Aquí! 🚀

Bienvenido a **SIGETU**. Este documento guía a nuevos desarrolladores a través de la estructura del proyecto y cómo contribuir.

---

## 1️⃣ Primeros Pasos

### A. Configura tu Entorno
```bash
# Verifica que Flutter esté instalado
flutter doctor

# Clona e instala dependencias
git clone <repository-url>
cd sigetu-frontend
flutter clean
flutter pub get
```

### B. Ejecuta la App
```bash
# Lista dispositivos disponibles
flutter devices

# Ejecuta en tu dispositivo/emulador
flutter run -d <DEVICE_ID>
```

### C. Revisa el Código
Abre el proyecto en VS Code o Android Studio y navega a `lib/main.dart`. Este es el punto de entrada.

---

## 2️⃣ Entendiendo la Arquitectura

SIGETU usa **Clean Architecture** con tres capas por feature:

```
features/
├── auth/
│   ├── data/           ← Fuentes de datos (HTTP, local)
│   ├── domain/         ← Lógica de negocio (entidades, repositorios)
│   └── presentation/   ← UI (screens, widgets, routes)
├── student_dashboard/
│   ├── data/
│   ├── domain/
│   └── presentation/
├── secretary/
└── headquarters/
```

**¿Por qué esta estructura?**
- **Separación de responsabilidades**: cada capa tiene un trabajo específico
- **Testabilidad**: fácil de testear sin UI
- **Reusabilidad**: el domain puede usarse en web, escritorio, etc.
- **Mantenibilidad**: cambios en una capa no afectan otras

### Capas Explicadas

| Capa | Responsabilidad | Ejemplos |
|------|-----------------|----------|
| **Data** | Obtener datos (API HTTP, WebSocket, local) | `AppointmentRepository`, `AuthRemoteDataSource` |
| **Domain** | Lógica de negocio y entidades | `Appointment`, `User`, interfaces de repositorios |
| **Presentation** | UI y navegación | Screens, widgets, routes, estado local |

---

## 3️⃣ Core: Utilidades Compartidas

La carpeta `core/` contiene código reutilizable:

```
core/
├── auth/           ← Gestión de sesión y autenticación
├── constants/      ← URLs, estados, configuraciones
├── realtime/       ← WebSocket para actualizaciones en tiempo real
├── theme/          ← Colores, estilos, AppTheme
├── utils/          ← Formateadores (fechas, horas)
└── widgets/        ← Componentes reutilizables (navegación, toast)
```

**Utiliza estas utilidades**, no crees duplicadas.

---

## 4️⃣ Cómo Agregar una Nueva Feature

### Paso 1: Crea la Estructura
```bash
lib/features/mi_feature/
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   └── local/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── screens/
    ├── widgets/
    ├── providers/  (si usas state management)
    └── mi_feature_routes.dart
```

### Paso 2: Define la Entidad (Domain)
```dart
// lib/features/mi_feature/domain/entities/my_entity.dart
class MyEntity {
  final int id;
  final String name;
  
  MyEntity({required this.id, required this.name});
}
```

### Paso 3: Crea el Repositorio (Domain)
```dart
// lib/features/mi_feature/domain/repositories/my_repository.dart
abstract class MyRepository {
  Future<MyEntity> getEntity(int id);
}
```

### Paso 4: Implementa el Repositorio (Data)
```dart
// lib/features/mi_feature/data/repositories/my_repository_impl.dart
class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  
  @override
  Future<MyEntity> getEntity(int id) async {
    return remoteDataSource.getEntity(id);
  }
}
```

### Paso 5: Crea la UI (Presentation)
```dart
// lib/features/mi_feature/presentation/screens/my_screen.dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mi Feature')),
      body: Center(child: Text('Contenido aquí')),
    );
  }
}
```

### Paso 6: Registra las Rutas (Presentation)
```dart
// lib/features/mi_feature/presentation/mi_feature_routes.dart
class MyFeatureRoutes {
  static const String myScreen = '/my-feature/screen';
  
  static Map<String, WidgetBuilder> get routes => {
    myScreen: (_) => MyScreen(),
  };
}
```

---

## 5️⃣ Reglas de Código

### ✅ Sí
- Usa `AppDateFormatter` para formatear fechas
- Usa `BackendDateTime` para parsear/serializar datetimes
- Reutiliza componentes de `core/widgets/`
- Sigue convenciones de commits en [CONTRIBUTING.md](CONTRIBUTING.md)
- Valida errores del backend y muéstralos al usuario
- **Usa `AuthSession` para gestión de tokens y sesiones**
- **Sincroniza FCM token con backend** al iniciar sesión
- **Maneja modo guest** con device_id cuando aplique

### ❌ No
- Hardcodees URLs, usa `ApiConstants`
- Duplicues lógica entre features
- Cambies nombres de campos del backend sin requerimiento
- Agregues colores fuera del tema de `core/theme/`
- Uses `toLocal()` directamente para fechas de negocio
- **Olvides probar en Web** además de Android/iOS

---

## 6️⃣ Comandos Útiles

```bash
# Verificar errores
flutter analyze

# Ejecutar tests
flutter test

# Limpiar cache
flutter clean && flutter pub get

# Build APK (Android)
flutter build apk

# Ver dependencias
flutter pub deps
```

Más comandos en [COMMANDS.md](COMMANDS.md).

---

## 7️⃣ Estructura de Archivos Importantes

```
/
├── README.md                    ← Este archivo
├── pubspec.yaml                 ← Dependencias del proyecto
├── analysis_options.yaml        ← Configuración de linting
├── lib/
│   ├── main.dart                ← Punto de entrada
│   ├── core/
│   │   ├── auth/                ← Gestión de sesión
│   │   ├── constants/           ← URLs, estados
│   │   ├── theme/               ← Estilos y colores
│   │   └── utils/               ← Formateo de fechas
│   └── features/
│       ├── auth/                ← Autenticación
│       ├── student_dashboard/   ← Dashboard de estudiante
│       ├── secretary/           ← Pantalla de secretaria
│       └── headquarters/        ← Pantalla de sede
├── test/                        ← Tests unitarios
├── docs/                        ← Documentación (este archivo está aquí)
└── android/, ios/, web/         ← Código específico de plataformas
```

---

## 8️⃣ Preguntas Frecuentes

**P: ¿Cómo manejo autenticación?**
A: Usa `AuthSession` en `core/auth/auth_session.dart`. Guarda tokens (access + refresh), soporta modo guest, y restaura sesión automáticamente.

**P: ¿Cómo consumo la API REST?**
A: Usa `AuthHttp` de `core/auth/auth_http.dart`. Maneja auto-refresh de tokens y diferencia Web vs Android.

**P: ¿Cómo actualizo en tiempo real?**
A: Usa `AppointmentsRealtimeService` de `core/realtime/`. WebSocket se conecta automáticamente y reconecta cada 3s si falla.

**P: ¿Cómo muestro notificaciones?**
A: Para toasts usa `AppToast`. Para push usa `NotificationService` (Firebase ya configurado).

**P: ¿Cómo sincronizo el FCM token?**
A: Llama `FCMTokenSync.sync()` después del login. Registra el token en backend automáticamente.

**P: ¿Dónde agrego temas?**
A: En `core/theme/app_theme.dart`. No hardcodees colores en widgets.

**P: ¿Cómo manejo modo invitado (guest)?**
A: Usa `AuthSession.isGuest` y `AuthSession.deviceId`. El backend tiene endpoints separados para guest.

---

## 9️⃣ Siguientes Pasos

1. Lee [STRUCTURE.md](STRUCTURE.md) para comprender mejor la arquitectura
2. Consulta [COMMANDS.md](COMMANDS.md) para todos los comandos disponibles
3. Revisa [CONTRIBUTING.md](CONTRIBUTING.md) antes de hacer tu primer commit
4. Explora `lib/features/auth/` como ejemplo real de Clean Architecture

---

**¿Listo para codificar? ¡Adelante! Cualquier duda, consulta la documentación en `/docs`.** 🎉

---

**Última actualización:** Abril 2026
