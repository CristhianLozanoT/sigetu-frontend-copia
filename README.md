# 🎓 SIGETU - Gestión de Citas Universitarias

Aplicación móvil **Flutter** para automatizar la gestión de citas/turnos en instituciones universitarias.

> 📚 **¿Nuevo en el proyecto?** Comienza leyendo [docs/INDEX.md](docs/INDEX.md)

---

## 🚀 Quick Start

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en tu dispositivo
flutter run

# 3. Conectarse a backend específico (opcional)
flutter run --dart-define=API_BASE_URL=http://192.168.101.70:8000
```

Para instrucciones detalladas, consulta **[docs/QUICKSTART.md](docs/QUICKSTART.md)**.

---

## 📖 Documentación

Todo está documentado en `/docs`. Selecciona según tu rol:

### 👨‍💻 Desarrollador
- **[START_HERE.md](docs/START_HERE.md)** — Guía para nuevos desarrolladores
- **[STRUCTURE.md](docs/STRUCTURE.md)** — Arquitectura y estructura de carpetas
- **[COMMANDS.md](docs/COMMANDS.md)** — Comandos útiles

### 🤝 Contribuidor
- **[CONTRIBUTING.md](docs/CONTRIBUTING.md)** — Guía de contribución y convenciones

### 📊 Stakeholder / Manager
- **[PROJECT_SUMMARY.md](docs/PROJECT_SUMMARY.md)** — Objetivos y alcance del proyecto

### 📑 Índice General
- **[INDEX.md](docs/INDEX.md)** — Índice completo de documentación

---

## ✅ Requisitos

- ✅ **Flutter 3.11.0+** ([Instalar](https://flutter.dev/docs/get-started/install))
- ✅ **Dart 3.11.0+** (incluido con Flutter)
- ✅ **Android Studio / VS Code** con extensión Flutter
- ✅ **Emulador Android** o **dispositivo físico** conectado
- ✅ **Backend REST API** ejecutándose (e.g., `http://192.168.x.x:8000`)

---

## 🏗️ Stack Tecnológico

| Componente | Tecnología |
|-----------|-----------|
| **Frontend** | Flutter 3.11.0 + Dart 3.11.0 |
| **Arquitectura** | Clean Architecture (por Features) |
| **Networking** | HTTP + WebSocket |
| **UI Framework** | Material Design 3 |
| **State** | Local (con listeners) |

---

## 🎯 Características Principales

✅ **Autenticación** — Login y gestión de sesiones  
✅ **Citas en Tiempo Real** — WebSocket para sincronización instantánea  
✅ **Multi-Rol** — Estudiante, Secretaria, Administrador  
✅ **Responsive** — Adaptable a diferentes pantallas  
✅ **Multiplataforma** — Android, iOS (Web futuro)  

---

## 📁 Estructura del Proyecto

```
sigetu-frontend/
├── lib/
│   ├── main.dart                  ← Punto de entrada
│   ├── core/                      ← Código compartido
│   │   ├── auth/                  ← Autenticación
│   │   ├── constants/             ← URLs, estados
│   │   ├── theme/                 ← Sistema de temas
│   │   ├── utils/                 ← Formateos (fechas)
│   │   ├── realtime/              ← WebSocket
│   │   └── widgets/               ← Componentes globales
│   │
│   └── features/                  ← Features específicas
│       ├── auth/                  ← Autenticación
│       ├── student_dashboard/     ← Dashboard estudiante
│       ├── secretary/             ← Panel secretaria
│       └── headquarters/          ← Panel administrativo
│
├── test/                          ← Tests unitarios
├── docs/                          ← Documentación completa
│   ├── INDEX.md
│   ├── START_HERE.md
│   ├── STRUCTURE.md
│   ├── QUICKSTART.md
│   ├── COMMANDS.md
│   ├── CONTRIBUTING.md
│   └── PROJECT_SUMMARY.md
│
├── pubspec.yaml                   ← Dependencias
├── analysis_options.yaml          ← Linting
└── README.md                      ← Este archivo
```

Voir [docs/STRUCTURE.md](docs/STRUCTURE.md) pour une explication détaillée.

---

## 🔧 Comandos Esenciales

```bash
# Obtener dependencias
flutter pub get

# Ejecutar análisis
flutter analyze

# Ejecutar tests
flutter test

# Ejecutar en dispositivo
flutter run

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release

# Ver todos los comandos
flutter --help
```

📋 Referencia completa en **[docs/COMMANDS.md](docs/COMMANDS.md)**.

---

## 🔌 Configuración de API

La app se configura mediante `--dart-define`:

```bash
# Backend local (emulador)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# Backend remoto (dispositivo físico)
flutter run \
  --dart-define=API_BASE_URL=http://192.168.101.70:8000 \
  --dart-define=APPOINTMENTS_WS_URL=ws://192.168.101.70:8000/appointments/ws
```

- **API_BASE_URL** - Base de la API REST
- **APPOINTMENTS_WS_URL** - URL del WebSocket (opcional, se construye automáticamente)

Más detalles en [docs/QUICKSTART.md](docs/QUICKSTART.md).

---

## ❓ Problemas Comunes

### "No devices found"
```bash
# Listar dispositivos
flutter devices

# Si es emulador: iniciarlo desde Android Studio
# Si es físico: activar Depuración USB
```

### "No conecta al backend"
```bash
# Verificar que backend está corriendo
curl http://192.168.101.70:8000/health

# Usar IP local, no localhost
flutter run --dart-define=API_BASE_URL=http://192.168.101.70:8000
```

Más soluciones en **[docs/QUICKSTART.md](docs/QUICKSTART.md)**.

---

## 🤝 Contribuir

¿Quieres agregar una feature o arreglar un bug?

1. Lee **[docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)**
2. Sigue las convenciones de commits
3. Abre un Pull Request

---

## 📞 Soporte

- 📚 **Documentación:** [docs/INDEX.md](docs/INDEX.md)
- 🆘 **Troubleshooting:** [docs/QUICKSTART.md](docs/QUICKSTART.md)
- 👨‍💻 **Para nuevos devs:** [docs/START_HERE.md](docs/START_HERE.md)

---

## 📋 Licencia

Este proyecto es privado de la institución.

---

**Última actualización:** Marzo 2026
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
