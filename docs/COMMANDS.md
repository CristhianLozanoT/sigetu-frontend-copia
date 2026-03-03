# Comandos Útiles - SIGETU

Referencia rápida de todos los comandos útiles para desarrollo, testing y build.

---

## 📚 Tabla de Contenidos

1. [Inicialización](#inicialización)
2. [Ejecución](#ejecución)
3. [Análisis y Calidad](#análisis-y-calidad)
4. [Build y Release](#build-y-release)
5. [Testing](#testing)
6. [Gestión de Dependencias](#gestión-de-dependencias)
7. [Debugging](#debugging)
8. [Limpieza](#limpieza)
9. [Información del Entorno](#información-del-entorno)

---

## 🚀 Inicialización

### Clonar y Configurar

```bash
# Clonar el repositorio
git clone https://github.com/tu-org/sigetu-frontend.git
cd sigetu-frontend

# Limpiar cache
flutter clean

# Obtener dependencias
flutter pub get

# Analizar posibles problemas
flutter analyze
```

---

## ▶️ Ejecución

### Ejecutar en Dispositivo por Defecto

```bash
flutter run
```

### Ejecutar en Dispositivo Específico

```bash
# Listar dispositivos
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <DEVICE_ID>
flutter run -d emulator-5554
flutter run -d "meu-iphone"
```

### Ejecutar con Variables de Entorno

```bash
# Backend local (emulador)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Backend remoto (dispositivo físico)
flutter run \
  --dart-define=API_BASE_URL=http://192.168.101.70:8000 \
  --dart-define=APPOINTMENTS_WS_URL=ws://192.168.101.70:8000/appointments/ws

# Zona horaria personalizada
flutter run \
  --dart-define=BACKEND_TIMEZONE_OFFSET_MINUTES=-300
```

### Ejecutar en Modo Release

```bash
# Modo release (optimizado, sin debug info)
flutter run --release

# Con variables de entorno en release
flutter run --release \
  --dart-define=API_BASE_URL=https://api.production.com
```

### Hot Reload / Hot Restart

Mientras `flutter run` está activo en la terminal:

```bash
r       # Hot Reload (recarga código, mantiene estado)
R       # Hot Restart (reinicia app, reset estado)
h       # Ayuda
q       # Quit
```

---

## 🔍 Análisis y Calidad

### Analizar Código

```bash
# Verificar linting y errores
flutter analyze

# Análisis detallado
flutter analyze --verbose
```

### Ver Lint Report

```bash
# Genera reporte de análisis
flutter analyze > lint_report.txt
```

---

## 🏗️ Build y Release

### Android

#### APK (Debug)

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

#### APK (Release)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### APK (Release con Backend Específico)

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.production.com \
  --dart-define=APPOINTMENTS_WS_URL=wss://api.production.com/appointments/ws
```

#### App Bundle (para Google Play)

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (Solo en macOS)

#### Build Simulator

```bash
flutter build ios --debug
```

#### Build Device (Release)

```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

### Web (Futuro)

```bash
flutter build web --release
# Output: build/web/
```

---

## 🧪 Testing

### Ejecutar Todos los Tests

```bash
flutter test
```

### Ejecutar Test Específico

```bash
flutter test test/widget_test.dart
```

### Tests con Cobertura

```bash
# Generar cobertura (requiere lcov instalado)
flutter test --coverage
```

### Ejecutar Tests en Modo Watch

```bash
# Tests se ejecutan automáticamente cuando cambias código
flutter test --watch
```

---

## 📦 Gestión de Dependencias

### Ver Todas las Dependencias

```bash
flutter pub deps
```

### Ver Árbol de Dependencias

```bash
flutter pub deps --tree
```

### Listar Dependencias Que Pueden Actualizarse

```bash
flutter pub outdated
```

### Actualizar Todas las Dependencias

```bash
flutter pub upgrade
```

### Agregar Nueva Dependencia

```bash
flutter pub add nombre_paquete
# Ejemplo:
flutter pub add intl
```

### Agregar Dev Dependency

```bash
flutter pub add --dev nombre_paquete
# Ejemplo:
flutter pub add --dev mockito
```

### Remover Dependencia

```bash
flutter pub remove nombre_paquete
```

### Obtener Dependencias Nuevamente

```bash
flutter pub get
```

---

## 🐛 Debugging

### Activar Debugger Interactivo

Mientras `flutter run` está activo, presiona:

```
d     # Debugger interactivo
```

### Ver Logs en Tiempo Real

```bash
# Logs ya aparecen en `flutter run`
# Pero puedes filtrar por error:
flutter run 2>&1 | grep -i error
```

### Monitorear Rendimiento

```bash
# Mientras app está ejecutándose
flutter run --verbose
```

### Ver Stacktrace Completo

```bash
flutter run --verbose 2>&1 | tee debug.log
```

---

## 🧹 Limpieza

### Limpiar Build

```bash
flutter clean
```

### Limpiar Build + Pub Cache (nuclear option)

```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
```

### Limpiar Caché de Pub

```bash
flutter pub cache clean
```

### Rescindir Todas las Variables Globales

```bash
flutter config --clear-features
```

---

## ℹ️ Información del Entorno

### Verificar Instalación Completa

```bash
flutter doctor
```

**Output esperado:**
```
Doctor summary (to see all details run flutter doctor -v):
✓ Flutter (Channel stable, 3.11.0, on macOS 13.2.1 22D68 darwin-arm64)
✓ Android toolchain - develop for Android devices (Android SDK 34.0.0)
✓ Xcode - develop for iOS and macOS (Xcode 15.0)
✓ Chrome - develop for the web (Chrome 120.0.0.0)
```

### Información Detallada del Entorno

```bash
flutter doctor -v
```

### Ver Versión de Flutter

```bash
flutter --version
```

### Ver Versión de Dart

```bash
dart --version
```

### Listar Canales Disponibles

```bash
flutter channel
```

### Cambiar a Canal Diferente

```bash
# stable (recomendado para producción)
flutter channel stable

# dev (desarrollo activo)
flutter channel dev

# master (desarrollo sangrante)
flutter channel master
```

---

## 📱 Gestión de Dispositivos

### Listar Dispositivos Disponibles

```bash
flutter devices
```

### Listar Emuladores Disponibles

```bash
flutter emulators
```

### Lanzar Emulador

```bash
flutter emulators --launch <emulator_id>
```

### ADB Commands (Android Debug Bridge)

```bash
# Ver dispositivos conectados
adb devices

# Reiniciar ADB
adb kill-server
adb start-server

# Push archivo al dispositivo
adb push archivo.txt /sdcard/

# Pull archivo del dispositivo
adb pull /sdcard/archivo.txt

# Abrir shell del dispositivo
adb shell

# Ver logs del dispositivo
adb logcat
```

---

## 🚨 Comandos de Emergencia

### Si Todo Falla

```bash
# El nuclear option
flutter clean
rm -rf build/ .dart_tool/ pubspec.lock
flutter pub get
flutter run
```

### Resetear Emulador Android

```bash
# Borrar datos del emulador
emulator -avd <emulator_name> -wipe-data
```

### Limpiar iOS Build

```bash
cd ios
rm -rf Pods/ Podfile.lock .symlinks/ Flutter/Flutter.xcframework
cd ..
flutter pub get
```

---

## 📊 Comandos Compostos Útiles

### Build + Validación Completa

```bash
flutter clean && \
flutter pub get && \
flutter analyze && \
flutter test && \
flutter build apk --release
```

### Desarrollo Rápido

```bash
flutter clean && \
flutter pub get && \
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### Verificación Pre-Commit

```bash
flutter analyze && \
flutter test && \
echo "✅ Listo para commit"
```

---

## 💾 Resumen Rápido

| Tarea | Comando |
|-------|---------|
| **Iniciar API** | `flutter pub get` |
| **Ejecutar app** | `flutter run` |
| **Verificar errores** | `flutter analyze` |
| **Build APK** | `flutter build apk --release` |
| **Ejecutar tests** | `flutter test` |
| **Ver dispositivos** | `flutter devices` |
| **Limpiar todo** | `flutter clean` |
| **Validar setup** | `flutter doctor` |
| **Agregar librería** | `flutter pub add nombre` |

---

**Última actualización:** Marzo 2026
