# Quick Start Guide - SIGETU

Configuración rápida y cómo ejecutar la app en tus primeros 5 minutos.

---

## ⚡ Pre-requisitos

Verifica que tengas instalado:

```bash
# Flutter SDK
flutter --version
# Output: Flutter 3.11.0 (o superior)

# Dart (viene con Flutter)
dart --version

# Git
git --version
```

Si **no** tienes Flutter, instálalo desde: https://flutter.dev/docs/get-started/install

---

## 🚀 Paso 1: Clonar el Repositorio

```bash
# Clona el proyecto
git clone https://github.com/tu-org/sigetu-frontend.git
cd sigetu-frontend

# Verifica que Flutter vea el proyecto
flutter doctor
```

---

## 📦 Paso 2: Instalar Dependencias

```bash
# Limpiar cache (recomendado)
flutter clean

# Obtener dependencias
flutter pub get

# Verificar que todo está bien
flutter analyze
```

**Expected output:**
```
Running "flutter pub get" in sigetu-frontend...
Resolving dependencies...
Got dependencies!
```

---

## 📱 Paso 3: Preparar Dispositivo/Emulador

### Opción A: Emulador Android

```bash
# Listar emuladores disponibles
flutter emulators

# Si no ves ninguno, crear uno en Android Studio
# Tools > Device Manager > Create Device

# Iniciar emulador
flutter emulators --launch <emulator_name>

# Esperar a que cargue (2-3 minutos)
```

### Opción B: Dispositivo Físico Android

```bash
# Activar Depuración USB en configuración del teléfono
# Conectar por USB

# Verificar que se detecte
flutter devices
# Output: emulator-5554  • Android SDK built for... • android-x86    • Android 12
#         BCF5M2A1234     • Android 12                 • android-arm64  • Android 12
```

### Opción C: Simulador iOS (solo macOS)

```bash
# Abrir simulador
open -a Simulator

# Verificar que se detecte
flutter devices
```

---

## ✅ Paso 4: Verificar Dispositivos

```bash
flutter devices
```

**Expected output:**
```
2 connected devices:

emulator-5554 • emulator-5554 • android-x86 • Android 12 (API 31)
Chrome        • chrome       • web-javascript • Google Chrome 120.0.0.0
```

Si no ves dispositivos:
- ✅ Emulador: Inicia uno desde Android Studio
- ✅ Físico: Activa Depuración USB y conecta por USB
- ✅ iOS: Abre el simulador en Xcode

---

## 🎯 Paso 5: Ejecutar la App

### Opción A: Emulador/Dispositivo por Defecto

```bash
flutter run
```

La app se compilará y ejecutará en el dispositivo predeterminado.

### Opción B: Dispositivo Específico

```bash
# Especificar dispositivo
flutter run -d emulator-5554

# O por nombre más legible
flutter run -d "emulator"
```

### Opción C: Con Variables de Entorno (API específica)

Si necesitas conectar a un backend diferente:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://192.168.101.70:8000 \
  --dart-define=APPOINTMENTS_WS_URL=ws://192.168.101.70:8000/appointments/ws
```

---

## 🎨 Pantalla Inicial

Deberías ver:
1. **Splash screen** (logo/branding)
2. **Pantalla de Login** (si no hay sesión previa)
3. **Dashboard** correspondiente al rol (estudiante, secretaria, etc.)

---

## 🔄 Workflow de Desarrollo

### Para Cambios Rápidos (Hot Reload)

La mayoría de cambios se aplican sin reiniciar:

```bash
# Mientras `flutter run` está activo:
# Presiona 'r' en la terminal para hot reload
r
# O presiona 'R' para hot restart (estadoReset)
R
```

### Para Cambios en Dependencias

```bash
# Si modificas pubspec.yaml:
flutter pub get
flutter run
```

### Para Compilar Nuevamente

```bash
# Fuerza recompilación
flutter clean
flutter pub get
flutter run
```

---

## 🏗️ Build para Producción

### Android APK

```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api.production.com \
  --dart-define=APPOINTMENTS_WS_URL=wss://api.production.com/appointments/ws
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA (solo en macOS)

```bash
flutter build ios \
  --dart-define=API_BASE_URL=https://api.production.com \
  --dart-define=APPOINTMENTS_WS_URL=wss://api.production.com/appointments/ws
```

**Output:** `build/ios/iphoneos/Runner.app`

### Web (futuro)

```bash
flutter build web
```

---

## 🐛 Troubleshooting

### Problema: "No devices found"

**Solución:**
```bash
# Emulador no inicia:
flutter emulators                          # Ver disponibles
flutter emulators --launch <name>          # Iniciar

# Dispositivo no detectado:
flutter devices                            # Verificar
adb devices                                # Ver por ADB directamente
adb kill-server && adb start-server        # Reiniciar ADB
```

### Problema: "Exception: No API backend reachable"

**Solución:**
```bash
# Verifica que el backend esté corriendo
curl http://192.168.101.70:8000/appointments

# Si usas emulador y backend local:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
# (10.0.2.2 es alias de localhost en emulador Android)
```

### Problema: "Gradle build failed"

**Solución:**
```bash
flutter clean
flutter pub get
flutter run
```

### Problema: "Pod install failed" (iOS)

**Solución:**
```bash
cd ios
pod install --repo-update
cd ..
flutter run
```

---

## 📊 Validar Entorno Completo

```bash
flutter doctor -v
```

Este comando verifica:
- ✅ Flutter SDK
- ✅ Android Studio / Xcode
- ✅ Emuladores/Dispositivos
- ✅ Plugins

---

## 🎯 Próximos Pasos

1. Familiarízate con la estructura: Lee [STRUCTURE.md](STRUCTURE.md)
2. Aprende la arquitectura: Lee [START_HERE.md](START_HERE.md)
3. Consulta comandos útiles: Mira [COMMANDS.md](COMMANDS.md)
4. Antes de contribuir: Lee [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 💡 Tips

- **Modo Debug:** Activa en Android Studio `Tools > Flutter > Open DevTools`
- **Logs en tiempo real:** `flutter run` muestra logs automáticamente
- **Debugger:** Presiona `d` en terminal para debugger interactivo

---

**¡Listo! Ahora ejecuta `flutter run` y comienza a desarrollar.** 🚀
