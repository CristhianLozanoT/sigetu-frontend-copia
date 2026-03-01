# SIGETU (Flutter)

Aplicación móvil Flutter para gestión de citas/turnos.

## Requisitos

- Flutter SDK instalado (`flutter --version`)
- Dart (incluido con Flutter)
- Android Studio o VS Code con extensión Flutter
- Un emulador Android o dispositivo físico conectado
- API backend ejecutándose (ejemplo: `http://192.168.x.x:8000`)

## 1) Clonar e instalar dependencias

```bash
flutter clean
flutter pub get
```

## 2) Validar entorno

```bash
flutter doctor
flutter devices
```

Si no ves tu dispositivo, revisa USB Debugging o inicia el emulador.

## 3) Variables de entorno usadas por la app

La app usa `--dart-define`:

- `API_BASE_URL`
- `APPOINTMENTS_WS_URL` (opcional)

Implementación actual:

- Si **no** envías `APPOINTMENTS_WS_URL`, se construye automáticamente desde `API_BASE_URL`:
	- `http` -> `ws`
	- `https` -> `wss`
	- path: `/appointments/ws`

> Nota: No se usa Firebase ni notificaciones push en esta versión.

## 4) Ejecutar el proyecto

### Opción A: Dispositivo físico en red local

```bash
flutter run -d <DEVICE_ID> \
	--dart-define=API_BASE_URL=http://192.168.101.70:8000 \
	--dart-define=APPOINTMENTS_WS_URL=ws://192.168.101.70:8000/appointments/ws
```

### Opción B: Emulador Android

Puedes usar el valor por defecto de la app:

```bash
flutter run -d <DEVICE_ID>
```

Por defecto, `API_BASE_URL` apunta a:

```text
http://10.0.2.2:8000
```

## 5) Analizar el código

```bash
flutter analyze
```

## 6) Build APK (opcional)

```bash
flutter build apk \
	--dart-define=API_BASE_URL=http://192.168.101.70:8000 \
	--dart-define=APPOINTMENTS_WS_URL=ws://192.168.101.70:8000/appointments/ws
```

## Estructura rápida

- `lib/main.dart`: punto de entrada
- `lib/core/constants/api_constants.dart`: URLs de API y WebSocket
- `lib/features/**`: módulos de funcionalidades

## Problemas comunes

### 1) `No devices found`

- Ejecuta `flutter devices`
- Si es físico: activa depuración USB
- Si es emulador: inicia uno desde Android Studio

### 2) No conecta al backend en celular físico

- Usa IP local del servidor (`192.168.x.x`), no `localhost`
- Verifica que backend y celular estén en la misma red
- Revisa firewall/puerto `8000`

### 3) WebSocket no conecta

- Verifica `APPOINTMENTS_WS_URL`
- Si backend es HTTPS, usa `wss://`

### 4) Dependencias corruptas o caché rara

```bash
flutter clean
flutter pub get
```

---

Si necesitas, puedo agregar una sección con comandos específicos para Windows PowerShell (copiar/pegar directo) y para macOS/Linux.
