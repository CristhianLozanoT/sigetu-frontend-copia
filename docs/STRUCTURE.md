# Estructura del Proyecto - SIGETU

Documento detallado sobre la arquitectura, estructura de carpetas y responsabilidades de cada módulo.

---

## 🏗️ Arquitectura General

**Patrón:** Clean Architecture por Features

```
PRESENTACIÓN (UI, Routes)
        ↓
    DOMAIN (Lógica pura)
        ↓
    DATA (Fuentes de datos)
        ↓
    API / BD / almacenamiento local
```

**Ventajas:**
- ✅ Cada capa tiene responsabilidad única
- ✅ Fácil testear lógica sin UI
- ✅ Cambios en API no afectan UI
- ✅ Reutilizable en otras plataformas (web, desktop)

---

## 📂 Árbol de Directorios Completo

```
sigetu-frontend/
│
├── lib/
│   ├── main.dart                          ← Punto de entrada
│   │
│   ├── core/                              ← Código compartido
│   │   ├── auth/
│   │   │   └── auth_session.dart         ← Gestión de sesiones
│   │   │
│   │   ├── constants/
│   │   │   ├── api_constants.dart        ← URLs, Base paths
│   │   │   └── appointment_statuses.dart ← Estados de citas
│   │   │
│   │   ├── realtime/
│   │   │   └── websocket_manager.dart    ← Gestión WebSocket
│   │   │
│   │   ├── theme/
│   │   │   └── app_theme.dart            ← Colores, estilos
│   │   │
│   │   ├── utils/
│   │   │   ├── app_date_formatter.dart   ← Formateo de fechas (AM/PM)
│   │   │   └── backend_datetime.dart     ← Parseo de datetimes backend
│   │   │
│   │   └── widgets/
│   │       ├── app_bottom_nav.dart       ← Navegación inferior
│   │       ├── app_toast.dart            ← Notificaciones toast
│   │       └── section_header.dart       ← Componentes reutilizables
│   │
│   └── features/                          ← Funcionalidades específicas
│       │
│       ├── auth/                          ← Feature: Autenticación
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   └── remote/            ← Llamadas a API
│       │   │   ├── models/                ← DTOs, conversiones
│       │   │   └── repositories/          ← Implementación de repositorios
│       │   │
│       │   ├── domain/
│       │   │   ├── entities/              ← User, LoginRequest, etc.
│       │   │   ├── repositories/          ← Interfaces de repositorios
│       │   │   └── usecases/              ← Casos de uso (LoginUseCase, etc.)
│       │   │
│       │   └── presentation/
│       │       ├── screens/               ← LoginScreen, RegisterScreen
│       │       ├── widgets/               ← Componentes inner feature
│       │       ├── providers/             ← Estado local (si aplica)
│       │       └── auth_routes.dart       ← Rutas de feature
│       │
│       ├── student_dashboard/
│       │   ├── data/
│       │   │   ├── datasources/remote/
│       │   │   ├── models/
│       │   │   └── repositories/
│       │   │
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   ├── repositories/
│       │   │   └── usecases/
│       │   │
│       │   └── presentation/
│       │       ├── screens/
│       │       ├── widgets/
│       │       └── student_dashboard_routes.dart
│       │
│       ├── secretary/
│       │   ├── data/
│       │   ├── domain/
│       │   └── presentation/
│       │       └── secretary_routes.dart
│       │
│       └── headquarters/
│           ├── data/
│           ├── domain/
│           └── presentation/
│
├── test/                                  ← Tests unitarios
│   └── widget_test.dart
│
├── android/                               ← Código Android (Gradle, manifests)
├── ios/                                   ← Código iOS (Xcode, Swift)
├── web/                                   ← Código Web (futuro)
├── assets/                                ← Imágenes, sounds, recursos
│
├── pubspec.yaml                           ← Dependencias del proyecto
├── analysis_options.yaml                  ← Configuración de linting
├── README.md                              ← Documentación principal
└── docs/                                  ← Documentación técnica (este directorio)
```

---

## 🔍 Explicación Detallada por Módulo

### 1. `/lib/main.dart` - Punto de Entrada

```dart
void main() {
  runApp(const MyApp());
}
```

**Responsabilidades:**
- Inicialización de la app
- Configuración de rutas
- Setup del tema
- Gestión global de sesión

**Flujo:**
1. `main()` llama `runApp(MyApp)`
2. `MyApp` es un `StatefulWidget` que:
   - Escucha cambios de sesión (`AuthSession.sessionInvalidation`)
   - Redirige a login si la sesión es inválida
   - Carga las rutas de cada feature

---

### 2. `core/` - Código Compartido

#### ✅ core/auth/auth_session.dart
**Gestiona la sesión del usuario en toda la app.**

```dart
class AuthSession {
  static String? accessToken;
  static String? refreshToken;
  static bool isGuest = false;
  static String? deviceId;
  static ValueNotifier<int> sessionInvalidation = ValueNotifier(0);
  
  static Future<void> restore() async { /* Restaura sesión de storage */ }
  static Future<void> setTokens(String access, String refresh) async { /* Guarda tokens */ }
  static Future<void> expireSession() async { /* Logout y limpia storage */ }
}
```

**Características:**
- Maneja **tokens JWT** (access + refresh)
- Soporta **modo invitado** (guest) con device_id
- **Almacenamiento seguro:** `flutter_secure_storage` (Android), cookies HttpOnly (Web)
- **Restauración automática** de sesión al iniciar app
- Notifica logout global mediante `sessionInvalidation`

#### ✅ core/constants/api_constants.dart
**Centraliza configuración de API.**

```dart
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sigetu-backend.onrender.com',
  );
  
  static String get appointmentsWsUrl { 
    // Construye wss:// o ws:// automáticamente desde baseUrl
  }
  
  static const int backendTimezoneOffsetMinutes = 
    int.fromEnvironment('BACKEND_TIMEZONE_OFFSET_MINUTES', defaultValue: -300);
}
```

**Uso:**
- **Producción:** Usa default `https://sigetu-backend.onrender.com`
- **Desarrollo:** Pasar `--dart-define=API_BASE_URL=http://...` al ejecutar
- **WebSocket:** Se construye automáticamente (`wss://` si HTTPS, `ws://` si HTTP)
- **Zona horaria:** Default UTC-5 (-300 minutos)

#### ✅ core/constants/appointment_statuses.dart
**Estados posibles de una cita.**

```dart
class AppointmentStatuses {
  static const pendiente = 'pendiente';
  static const llamando = 'llamando';
  static const enAtencion = 'en_atencion';
  static const atendido = 'atendido';
  static const noAsistio = 'no_asistio';
  static const finalizada = 'finalizada';
  static const cancelada = 'cancelada';
}
```

**Flujo de estados:**
```
pendiente → llamando → en_atencion → atendido/no_asistio → finalizada
                                   ↘ cancelada (en cualquier momento)
```

#### ✅ core/realtime/
**Gestión de WebSocket para actualizaciones en tiempo real.**

```dart
class AppointmentsRealtimeService {
  // URL: wss://sigetu-backend.onrender.com/appointments/ws?token=JWT
  WebSocketChannel? _channel;
  final _updatesController = StreamController<void>.broadcast();
  
  Stream<void> get updates => _updatesController.stream;
  
  void connect() {
    _channel = WebSocketChannel.connect(uriWithToken);
    _channel!.stream.listen(
      (message) => _updatesController.add(null),
      onDone: _scheduleReconnect,
      onError: (_) => _scheduleReconnect(),
    );
  }
  
  void _scheduleReconnect() {
    Timer(const Duration(seconds: 3), connect);
  }
}
```

**Características:**
- Conecta a `/appointments/ws` con token JWT en query parameter
- **Reconexión automática** cada 3 segundos si falla
- Sincroniza cambios de citas instantáneamente
- Emite stream `updates` que widgets pueden escuchar
- Se conecta/desconecta automáticamente según estado de sesión

#### ✅ core/theme/app_theme.dart
**Sistema de temas: colores, tipografía, estilos.**

```dart
class AppTheme {
  static ThemeData get light => ThemeData(
    primaryColor: Color(0xFF2E7D32),
    // ... más colores y estilos
  );
}
```

**Regla:** NO hardcodees colores en widgets. Usa siempre `Theme.of(context).primaryColor`.

#### ✅ core/utils/
**Utilidades reutilizables.**

**app_date_formatter.dart:**
```dart
class AppDateFormatter {
  static String toAmPm(DateTime dt) => DateFormat('hh:mm a').format(dt);
  static String toFullDate(DateTime dt) => DateFormat('MMMM dd, yyyy').format(dt);
}
```

**Use:** 
- Toda fecha/hora debe mostrarse en **AM/PM**
- Reutiliza este formateador, no crees otro

**backend_datetime.dart:**
```dart
class BackendDateTime {
  // Parsea ISO string con offset backend
  static DateTime parse(String iso) { ... }
  // Convierte a ISO con offset backend
  static String toIso(DateTime dt) { ... }
}
```

#### ✅ core/widgets/
**Componentes UI reutilizables por features.**

- `AppBottomNav` - Barra de navegación (3 tabs: Inicio, Mis Turnos, Perfil)
- `AppToast` - Notificaciones flotantes (usa `fluttertoast`)
- `SectionHeader` - Encabezados de secciones

#### ✅ core/notifications/
**Sistema de notificaciones Firebase Cloud Messaging.**

```dart
class NotificationService {
  // Inicializa Firebase Cloud Messaging
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    // Solicita permisos (iOS)
    await FirebaseMessaging.instance.requestPermission();
    // Crea canal de notificaciones (Android)
    const channel = AndroidNotificationChannel('citas', ...);
    await flutterLocalNotificationsPlugin.create(channel);
  }
  
  // Maneja mensajes en foreground
  FirebaseMessaging.onMessage.listen((message) { 
    // Muestra notificación local
  });
}

class FCMTokenSync {
  // Sincroniza FCM token con backend
  static Future<void> sync() async {
    final token = await FirebaseMessaging.instance.getToken();
    await http.post('/notifications/device-token', body: {
      'device_id': deviceId,
      'fcm_token': token,
      'platform': platform,
    });
  }
}
```

**Características:**
- **Firebase Cloud Messaging** para notificaciones push
- **Notificaciones locales** en Android (canal 'citas')
- **Sincronización automática** de token FCM con backend
- Maneja mensajes en **foreground** (Android + Web)
- **VAPID Key** configurado para web

---

### 3. `features/` - Funcionalidades Específicas

Cada feature sigue **Clean Architecture** con 3 capas:

#### 📦 feature/data/
**Capa de Datos**

```
data/
├── datasources/
│   └── remote/
│       └── feature_remote_datasource.dart   ← Llamadas HTTP
├── models/
│   └── feature_model.dart                   ← DTOs, conversión JSON
└── repositories/
    └── feature_repository_impl.dart         ← Implementación del repositorio
```

**Responsabilidades:**
- Llamar API REST vía `http` package
- Parsear respuestas JSON
- Convertir `Models` a `Entities`

**Ejemplo - Login:**
```dart
// RemoteDataSource
Future<String> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('${ApiConstants.baseUrl}/auth/login'),
    body: {'email': email, 'password': password},
  );
  return jsonDecode(response.body)['token'];
}
```

#### 🎯 feature/domain/
**Capa de Dominio (Lógica Pura)**

```
domain/
├── entities/
│   └── feature_entity.dart                  ← Modelos de negocio puros
├── repositories/
│   └── feature_repository.dart              ← Interfaces (contratos)
└── usecases/
    └── get_feature_usecase.dart             ← Casos de uso
```

**Responsabilidades:**
- Definir entidades (sin marcos, sin JSON)
- Definir interfaces de repositorios
- Encapsular lógica de negocio en UseCases

**Ejemplo - Entity:**
```dart
class Appointment {
  final int id;
  final String status; // pending, confirmed, cancelled
  final DateTime scheduledAt;
  
  Appointment({
    required this.id,
    required this.status,
    required this.scheduledAt,
  });
}
```

**Ejemplo - UseCase:**
```dart
class GetAppointmentsUseCase {
  final AppointmentRepository repository;
  
  GetAppointmentsUseCase(this.repository);
  
  Future<List<Appointment>> call() {
    return repository.getAppointments();
  }
}
```

#### 🎨 feature/presentation/
**Capa de Presentación (UI)**

```
presentation/
├── screens/
│   ├── feature_screen.dart                  ← Screens principales
│   └── feature_detail_screen.dart
├── widgets/
│   └── feature_card.dart                    ← Componentes internos
├── providers/
│   └── feature_provider.dart                ← Estado local (si aplica)
└── feature_routes.dart                      ← Rutas del feature
```

**Responsabilidades:**
- Construir UI (widgets)
- Manejar navegación
- Llamar UseCases
- Mostrar datos y errores

**Ejemplo - Screen:**
```dart
class AppointmentScreen extends StatefulWidget {
  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  late AppointmentRepository _repository;
  
  @override
  void initState() {
    super.initState();
    _repository = AppointmentRepositoryImpl(...);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Citas')),
      body: FutureBuilder(
        future: _repository.getAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final apt = snapshot.data![index];
                return AppointmentCard(appointment: apt);
              },
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
```

**Ejemplo - Routes:**
```dart
class StudentDashboardRoutes {
  static const String dashboard = '/student-dashboard';
  static const String appointmentDetail = '/student-dashboard/detail/:id';
  
  static Map<String, WidgetBuilder> get routes => {
    dashboard: (_) => StudentDashboardScreen(),
    appointmentDetail: (_) => AppointmentDetailScreen(),
  };
}
```

---

### 4. Features Actuales

#### 🔐 auth/
- Login con credenciales
- Registro de nuevos usuarios
- **Modo invitado (guest)** - Acceso sin credenciales usando device_id
- Gestión de sesiones con tokens JWT
- Auto-refresh de tokens
- Logout

#### 📊 student_dashboard/
- Dashboard del estudiante con navegación
- Ver citas disponibles y estado
- Agendar nuevas citas (selección de sede)
- Ver historial de citas
- **Reprogramar citas**
- Perfil de usuario

#### 👩‍💼 secretary/
- Panel de secretaria con shell de navegación
- Cola de citas en tiempo real (filtrado por sede)
- Detalle completo de cada cita
- **Cambiar estado de citas:** pendiente → llamando → en_atencion → atendido/no_asistio
- **Iniciar atención y extender tiempo**
- Historial de atenciones

#### 🏢 administrative/
- Panel administrativo similar a secretaria
- Cola de citas con gestión completa
- Cambiar estados de citas
- Historial filtrado por sede
- Iniciar atención y extender tiempo

#### 🎓 admisiones_mercadeo/
- Panel específico para admisiones y mercadeo
- Shell de navegación independiente
- Historial filtrado automáticamente por sede `sede_admisiones_mercadeo`

#### 🏫 headquarters/
- Selección de sede (administrativa, asistencia estudiantil, admisiones)
- Agendar citas desde diferentes sedes
- Navegación a paneles específicos según sede

#### 🔄 shared/
- Componentes compartidos entre features
- Vistas reutilizables de historial
- Tarjetas de cita (appointment_card)

---

## 🔌 Flujo de Datos (Ejemplo: Agendar Cita)

```
1. Usuario toca botón "Agendar" en StudentDashboardScreen
   ↓
2. Screen llama --> GetAppointmentsUseCase
   ↓
3. UseCase llama --> AppointmentRepository.schedule()
   ↓
4. Repository llama --> RemoteDataSource.schedule()
   ↓
5. RemoteDataSource hace HTTP POST --> /appointments
   ↓
6. Backend responde con la cita creada (JSON)
   ↓
7. Model convierte JSON --> Entity
   ↓
8. Repository retorna Entity
   ↓
9. UseCase retorna Entity
   ↓
10. Screen recibe Entity y actualiza UI
    ↓
11. WebSocket notifica a otros clientes
```

---

## 📐 Dependencias Entre Capas

```
Presentation → (depende de) → Domain
                               ↓ (depende de)
                             Data

Regla: Data NUNCA debe importar Presentation
       Presentation NUNCA debe importar Data
       Solo a través de Domain (interfaces)
```

**Incorrecto:**
```dart
import 'package:sigetu/features/auth/data/models/user_model.dart';
// No importar modelos de Data en Presentation
```

**Correcto:**
```dart
import 'package:sigetu/features/auth/domain/entities/user.dart';
// Usar entities de Domain
```

---

## 🧪 Testing

Ubicación: `/test/`

```
test/
└── widget_test.dart    (Test placeholder, pendiente implementar tests reales)
```

⚠️ **Estado actual:** Solo existe un test placeholder del template de Flutter.

**Pendiente implementar:**
- Tests unitarios de Domain (UseCases, Entities)
- Tests de Repositories (con mocks)
- Tests de Widgets (screens, componentes)
- Tests de integración

**Ejemplo de test recomendado:**
```dart
test('LoginUseCase retorna token válido', () async {
  final mockRepository = MockAuthRepository();
  final usecase = LoginUseCase(mockRepository);
  
  when(mockRepository.login('user@uni.edu', '1234'))
      .thenAnswer((_) async => 'valid-token');
  
  final result = await usecase('user@uni.edu', '1234');
  
  expect(result, isNotEmpty);
});
```

---

## 🎨 Patrón Visual

Toda la UI debe ser **consistente con el tema**:

```dart
// ✅ Correcto
Container(
  color: Theme.of(context).primaryColor,
  child: Text(
    'Hola',
    style: Theme.of(context).textTheme.headlineSmall,
  ),
)

// ❌ Incorrecto (colores hardcodeados)
Container(
  color: Color(0xFF2E7D32),
  child: Text('Hola', style: TextStyle(fontSize: 20)),
)
```

---

## 📝 Notas Importantes

1. **No duplices código:** Reutiliza utilidades de `core/`
2. **API primero:** Diseña Domain basado en contrato backend
3. **Validación:** En Domain (lógica) y Presentation (UX)
4. **Errores:** Muestra mensajes del backend cuando existan
5. **Fechas:** Siempre con AM/PM, usa `AppDateFormatter`
6. **Modo guest:** Usa `device_id` para identificar usuarios sin cuenta
7. **Notificaciones:** Firebase FCM ya configurado, sincroniza token con backend
8. **WebSocket:** Reconexión automática cada 3 segundos
9. **Multi-plataforma:** Código preparado para Android, iOS, Web, Windows, macOS
10. **Tests:** Pendientes de implementar (solo existe placeholder)

---

**Última actualización:** Abril 2026
