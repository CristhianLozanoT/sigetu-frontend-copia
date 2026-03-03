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
  static String? _token;
  static ValueNotifier<int> sessionInvalidation = ValueNotifier(0);
  
  static void setToken(String token) => _token = token;
  static String? getToken() => _token;
  static void logout() => sessionInvalidation.value++;
}
```

**Uso:**
- Guardar/obtener token JWT
- Disparar evento de logout global
- Acceder desde cualquier parte de la app

#### ✅ core/constants/api_constants.dart
**Centraliza configuración de API.**

```dart
class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.240.178.191:8000',
  );
  
  static String get appointmentsWsUrl { ... }
}
```

**Uso:**
- Pasar `--dart-define=API_BASE_URL=...` al ejecutar
- Mismo para WebSocket
- Offset de zona horaria backend

#### ✅ core/constants/appointment_statuses.dart
**Estados posibles de una cita.**

```dart
class AppointmentStatuses {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const cancelled = 'cancelled';
}
```

#### ✅ core/realtime/
**Gestión de WebSocket para actualizaciones en tiempo real.**

Conecta a `/appointments/ws` y sincroniza cambios instantáneamente sin recargar.

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

- `AppBottomNav` - Barra de navegación
- `AppToast` - Notificaciones flotantes
- `SectionHeader` - Encabezados de secciones

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
- Autenticación (login, registro)
- Gestión de sesiones
- Logout

#### 📊 student_dashboard/
- Dashboard del estudiante
- Ver citas disponibles
- Agendar nuevas citas
- Ver historial

#### 👩‍💼 secretary/
- Panel de secretaria
- Visualizar citas pendientes
- Confirmar/rechazar citas
- Gestionar horarios

#### 🏢 headquarters/
- Panel administrativo
- Gestionar usuarios
- Configurar horarios
- Reportes

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

**Testea primero Domain (lógica pura):**
```dart
test('LoginUseCase retorna token válido', () async {
  final mockRepository = MockAppointmentRepository();
  final usecase = LoginUseCase(mockRepository);
  
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

---

**Última actualización:** Marzo 2026
