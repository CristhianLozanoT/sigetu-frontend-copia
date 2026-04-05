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

**Backend de producción (default):**
```bash
flutter run
# Usa: https://sigetu-backend.onrender.com
```

**Backend local (emulador Android):**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

**Backend local (dispositivo físico en misma red):**
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000
```

**Backend personalizado:**
```bash
flutter run \
  --dart-define=API_BASE_URL=https://mi-backend.com \
  --dart-define=BACKEND_TIMEZONE_OFFSET_MINUTES=-300
```

---

## 🔔 Configuración de Firebase (Notificaciones Push)

### Firebase Ya Configurado ✅

El proyecto ya tiene Firebase configurado para todas las plataformas:

```yaml
# En pubspec.yaml
firebase_core: ^3.0.0
firebase_messaging: ^15.0.0
flutter_local_notifications: ^17.2.4
```

**Proyecto Firebase:** `sigetu-b10c0`

| Plataforma | Estado | App ID |
|-----------|--------|--------|
| Android | ✅ | `1:882177455207:android:600e3c219b1640ee6e90c2` |
| iOS | ✅ | `1:882177455207:ios:fc2cfb26a3e112eb6e90c2` |
| Web | ✅ | `1:882177455207:web:3b807841f710f4c26e90c2` |
| Windows | ✅ | `1:882177455207:web:75655aaa38d50eaa6e90c2` |
| macOS | ✅ | `1:882177455207:ios:fc2cfb26a3e112eb6e90c2` |

### Archivos de Configuración

Ya existen en el proyecto (no necesitas crearlos):

```
android/app/google-services.json          ✅ Configurado
ios/Runner/GoogleService-Info.plist       ✅ Configurado
lib/firebase_options.dart                  ✅ Configurado
```

### Inicialización Automática

Firebase se inicializa automáticamente en `main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
);
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

### Funcionamiento

1. **Al hacer login:** Se sincroniza el FCM token con el backend automáticamente
2. **Backend envía notificación:** Llega a través de Firebase Cloud Messaging
3. **App muestra notificación:** En Android usa canal 'citas' de alta prioridad
4. **En foreground:** Se muestra notificación local

### Troubleshooting Firebase

**Si no recibes notificaciones:**

```bash
# 1. Verificar que Firebase está inicializado
flutter run
# Busca en logs: "Firebase initialized"

# 2. Verificar permisos (iOS)
# Settings > SIGETU > Notifications > Allow Notifications

# 3. Ver token FCM en logs
# Aparece al iniciar la app
```

**Si hay error de configuración:**

```bash
# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
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
curl https://sigetu-backend.onrender.com/appointments/me/current

# Si usas backend local:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
# (10.0.2.2 es alias de localhost en emulador Android)

# Si usas dispositivo físico y backend local:
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000
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

---

**Última actualización:** Abril 2026
