# Guía de Contribución - SIGETU

Reglas y convenciones para contribuir al proyecto SIGETU.

---

## 📋 Tabla de Contenidos

1. [Antes de Empezar](#antes-de-empezar)
2. [Configuración Local](#configuración-local)
3. [Flujo de Trabajo (Git)](#flujo-de-trabajo-git)
4. [Convención de Commits](#convención-de-commits)
5. [Estilo de Código](#estilo-de-código)
6. [Revisión de Código](#revisión-de-código)
7. [Testing](#testing)
8. [Troubleshooting](#troubleshooting)

---

## ✅ Antes de Empezar

Lee esto primero:

- ✅ [START_HERE.md](START_HERE.md) - Entiende la arquitectura
- ✅ [STRUCTURE.md](STRUCTURE.md) - Conozca la estructura de carpetas
- ✅ [COMMANDS.md](COMMANDS.md) - Comandos útiles
- ✅ Este archivo - Convenciones

---

## 💾 Configuración Local

### 1. Fork el Repositorio

En GitHub:
1. Haz clic en **Fork** en la esquina superior derecha
2. Clona tu fork:

```bash
git clone https://github.com/tu-usuario/sigetu-frontend.git
cd sigetu-frontend
```

### 2. Agregar Remote Upstream

```bash
# Agregar remote oficial
git remote add upstream https://github.com/org-oficial/sigetu-frontend.git

# Verificar remotes
git remote -v
# origin    https://github.com/tu-usuario/sigetu-frontend.git (fetch)
# origin    https://github.com/tu-usuario/sigetu-frontend.git (push)
# upstream  https://github.com/org-oficial/sigetu-frontend.git (fetch)
```

### 3. Configurar Usuario Git

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu.email@university.edu"

# Verificar configuración
git config --global user.name
git config --global user.email
```

---

## 🌿 Flujo de Trabajo (Git)

### Paso 1: Sincronizar con Principal

Antes de empezar una nueva feature:

```bash
# Actualizar rama main
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### Paso 2: Crear Rama para Feature

Usar nombres descriptivos con prefijo:

```bash
# Prefijos recomendados:
# feature/xxx    - Nueva feature
# bugfix/xxx     - Corrección de bug
# hotfix/xxx     - Arreglo urgente de producción
# refactor/xxx   - Refactorización sin cambio de funcionalidad
# docs/xxx       - Cambios solo en documentación

# Ejemplos:
git checkout -b feature/student-dashboard-citas
git checkout -b bugfix/date-formatting-ampm
git checkout -b docs/update-readme
```

### Paso 3: Hacer Cambios

Trabaja en tu rama, commiteando regularmente:

```bash
# Ver cambios
git status

# Agregar cambios
git add archivo.dart
# O agregar todos:
git add .

# Commit (sigue Conventional Commits - ver siguiente sección)
git commit -m "feat(auth): add two-factor authentication"

# Push a tu rama
git push origin feature/student-dashboard-citas
```

### Paso 4: Pull Request

1. Ve a GitHub y abre un **Pull Request** desde tu rama a `main`
2. Rellena descripción clara
3. Menciona issues relacionados: `Closes #123`
4. Espera revisión

### Paso 5: Actualizar según Feedback

Si hay cambios solicitados:

```bash
# Hacer cambios locales
# Commit nuevamente (no squash aún)
git commit -m "refactor(auth): split loginUseCase per review"

# Push cambios
git push origin feature/student-dashboard-citas
# El PR se actualiza automáticamente
```

### Paso 6: Merge

Una vez aprobado:

```bash
# Actualizar rama main local
git fetch upstream
git checkout main
git merge upstream/main

# Opcionalmente, eliminar rama local
git branch -d feature/student-dashboard-citas
```

---

## 📝 Convención de Commits

Usamos **Conventional Commits v1.0.0**.

### Formato

```
<type>(<scope>): <subject>
<blank line>
<body (opcional)>
<blank line>
<footer (opcional)>
```

### Tipos

| Tipo | Descripción |
|------|-------------|
| **feat** | Nueva feature (aumenta minor version) |
| **fix** | Corrección de bug (aumenta patch version) |
| **refactor** | Refactorización sin cambio de funcionalidad |
| **docs** | Cambios en documentación |
| **style** | Cambios de formato, sin lógica (espacios, comillas) |
| **test** | Agregar o actualizar tests |
| **chore** | Cambios en build, dependencias, config |
| **perf** | Mejoras de rendimiento |
| **ci** | Cambios en CI/CD |

### Scope

Identifica el módulo:

```
auth      - Autenticación
student   - Dashboard estudiante
secretary - Panel secretaria
hq        - Panel administrativo
core      - Código compartido
api       - Llamadas HTTP
theme     - Sistema de temas
```

### Ejemplos

**✅ Bien:**

```
feat(auth): add two-factor authentication
- New 2FA flow in login
- Store TOTP secret in secure storage
- Add QR code generator for setup

Closes #456
```

```
fix(student): correct appointment status color display
Previously showed "pending" as green instead of yellow.
```

```
docs: update STRUCTURE.md with new architecture
```

```
refactor(core): extract date formatting logic
Split AppDateFormatter into separate functions for reusability.
```

**❌ Mal:**

```
Update code
small fixes
WIP
Done!
```

---

## 🎨 Estilo de Código

Seguimos `analysis_options.yaml` del proyecto.

### Versión de Flutter y Dart

- **Flutter:** 3.11.0 o superior
- **Dart:** 3.11.0 o superior (incluido en Flutter)

### Linting

```bash
# Verificar estilo
flutter analyze

# Debe pasar sin warnings
```

### Convenciones Dart

#### 1. Nombres

```dart
// ✅ Classes: PascalCase
class StudentDashboard { }
class AppointmentRepository { }

// ✅ Functions/methods: camelCase
void fetchAppointments() { }
String formatDate(DateTime dt) { }

// ✅ Variables: camelCase
String userName = "Juan";
int appointmentCount = 5;

// ✅ Constants: camelCase (no SCREAMING_SNAKE_CASE)
const int maxRetries = 3;
const String apiBaseUrl = "https://...";

// ✅ Private members: _leadingUnderscore
class _PrivateClass { }
String _privateVariable = "";
void _privateMethod() { }
```

#### 2. Sintaxis

```dart
// ✅ Usa var cuando el tipo es obvio
var appointment = Appointment(...);
final DateTime now = DateTime.now();

// ❌ No uses dynamic innecesariamente
dynamic data = fetchData();  // ❌ Evitar

// ✅ Usa const cuando sea posible
const Color primary = Color(0xFF2E7D32);

// ✅ Null safety (required / late)
class User {
  final String name;        // Required
  late String email;        // Initialized later
  String? phone;            // Nullable
  
  User({required this.name});
}

// ✅ Prefer final over var/let
final List<String> names = [];
final Map<String, int> scores = {};

// ❌ Avoid var for maps/lists sin tipo
var list = [];  // ❌ Mal, no sabe tipo
final List<String> list = [];  // ✅ Bien
```

#### 3. Funciones

```dart
// ✅ Firmas claras
Future<List<Appointment>> getAppointments() async {
  return await repository.fetch();
}

// ✅ Documentación (cuando es compleja)
/// Returns a formatted appointment date in AM/PM format.
/// 
/// [appointment] - The appointment to format
/// Returns: String like "2:30 PM"
String formatAppointmentTime(Appointment appointment) {
  return AppDateFormatter.toAmPm(appointment.scheduledAt);
}

// ❌ Evita funciones largas
void doEverything() {  // ❌ 200 líneas aquí
  fetchData();
  processData();
  saveData();
  updateUI();
  logMetrics();
}

// ✅ Divide en funciones pequeñas
Future<void> loadAndDisplayAppointments() async {
  final appointments = await _fetchAppointments();
  _processAppointments(appointments);
  _updateUI(appointments);
}
```

#### 4. Clases

```dart
// ✅ Organiza miembros en orden:
class Appointment {
  // 1. Campos static
  static const String tableName = 'appointments';
  
  // 2. Campos de instancia
  final int id;
  final String title;
  
  // 3. Constructor
  Appointment({
    required this.id,
    required this.title,
  });
  
  // 4. Métodos
  String getStatus() => status;
  
  // 5. Object overrides
  @override
  String toString() => 'Appointment($id)';
}
```

#### 5. Imports

```dart
// ✅ Organiza imports en orden:
// 1. Dart
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Packages externos
import 'package:http/http.dart' as http;

// 4. App (relativo)
import 'package:sigetu/core/theme/app_theme.dart';
import 'features/auth/domain/entities/user.dart';

// ❌ No mezcles órdenes
```

### Error Handling

```dart
// ✅ Manejo explícito
try {
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    return parseJson(response.body);
  } else {
    throw ApiException(response.statusCode);
  }
} on ApiException catch (e) {
  print('Error: ${e.message}');
  rethrow;
} catch (e) {
  print('Unexpected error: $e');
  rethrow;
}

// ❌ No traguéis errores silenciosamente
try {
  data = fetchData();
} catch (_) { }  // ❌ Malos
```

### Comentarios

```dart
// ✅ Comenta el POR QUÉ, no el QUÉ
// Retrasa 500ms para permitir que la animación termine
await Future.delayed(Duration(milliseconds: 500));

// ❌ No comentes el QUÉ (el código ya lo dice)
// Suma 1 a conteador
counter += 1;  // Obvio
```

---

## 👀 Revisión de Código

### Checklist Antes de Abrir PR

- [ ] El código pasa `flutter analyze`
- [ ] Escribí tests para la nueva lógica
- [ ] Los tests corren: `flutter test`
- [ ] Commit sigue [Conventional Commits](#convención-de-commits)
- [ ] Actualicé documentación si es necesario
- [ ] No agregué hardcodes (URLs, colores, etc.)
- [ ] Reutilicé componentes de `core/`
- [ ] Todas las fechas usan `AppDateFormatter`
- [ ] No duplicé código

### Durante la Revisión

Cuando un revisor solicite cambios:

```bash
# Haz los cambios
# Commit nuevamente
git commit -m "refactor(feature): address review feedback"

# No hagas force push (git push -f)
# El PR se actualiza automáticamente

# Cuando se apruebe, el maintainer hará el merge
```

### Después del Merge

```bash
# Sincroniza tu rama main local
git fetch upstream
git checkout main
git merge upstream/main

# Elimina rama local
git branch -d feature/xxx
```

---

## 🧪 Testing

### Escribir Tests

```dart
// test/features/auth/domain/usecases/login_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('LoginUseCase', () {
    late MockAuthRepository mockRepository;
    late LoginUseCase usecase;

    setUp(() {
      mockRepository = MockAuthRepository();
      usecase = LoginUseCase(mockRepository);
    });

    test('returns token on successful login', () async {
      // Arrange
      when(mockRepository.login('user@uni.edu', 'pass'))
          .thenAnswer((_) async => 'valid-token');

      // Act
      final result = await usecase('user@uni.edu', 'pass');

      // Assert
      expect(result, equals('valid-token'));
      verify(mockRepository.login('user@uni.edu', 'pass')).called(1);
    });
  });
}
```

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/path/to/test.dart

# Tests en watch mode
flutter test --watch
```

---

## 🐛 Troubleshooting

### Merge Conflicts

```bash
# Si hay conflictos al hacer merge:
git status  # Ver qué archivos tienen conflictos

# Abre cada archivo y resuelve manualmente
# Luego:
git add archivo.dart
git commit -m "chore: resolve merge conflicts"
```

### Rama Sincronizada Pero Vieja

```bash
# Rebase en vez de merge (recomendado)
git fetch upstream
git rebase upstream/main

# O merge si preferís
git merge upstream/main
```

### Accidental Commit a main

```bash
# Crear rama desde main
git branch feature/my-feature

# Reset main al commit anterior
git reset --hard origin/main

# Ir a la rama nueva
git checkout feature/my-feature
```

---

## 📞 Preguntas y Soporte

- **Dudas sobre arquitectura:** Consult [START_HERE.md](START_HERE.md)
- **Dudas sobre estructura:** Consult [STRUCTURE.md](STRUCTURE.md)
- **Dudas sobre código:** Pregunta en el PR
- **Dudas sobre comandos:** Consult [COMMANDS.md](COMMANDS.md)

---

## ✨ Resumen Rápido

1. **Fork** el repo
2. **Crea rama** con prefijo (`feature/`, `bugfix/`)
3. **Cambios** siguiendo convenciones
4. **Commit** con Conventional Commits
5. **Push** a tu fork
6. **PR** a main
7. **Espera** revisión
8. **Merge** automático una vez aprobado

---

**¡Gracias por contribuir a SIGETU!** 🙏

**Última actualización:** Marzo 2026
