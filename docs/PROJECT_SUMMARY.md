# Resumen del Proyecto - SIGETU

## 📋 Visión General

**SIGETU** es una aplicación móvil **Flutter** diseñada para **gestión de citas/turnos en contexto universitario**. Facilita a estudiantes, secretarias y administradores coordinar reuniones de forma centralizada.

---

## 🎯 Objetivo Principal

Digitalizar y automatizar el proceso de gestión de citas/turnos en instituciones universitarias, eliminando conflictos de horarios, reduciendo ausencias y mejorando la experiencia de todos los actores.

---

## 🤔 Problema que Resuelve

### Antes (Manual)
- ❌ Estudiantes llamaban o esperaban en fila para agendar citas
- ❌ Secretarias manejaban agendas en papel o Excel
- ❌ Overbooking frecuente
- ❌ Falta de trazabilidad
- ❌ Comunicación ineficiente

### Después (SIGETU)
- ✅ Estudiantes agendan online desde la app
- ✅ Secretarias visualizan disponibilidad en tiempo real
- ✅ Sistema evita conflictos de horarios
- ✅ Historial y confirmaciones automáticas
- ✅ Notificaciones de cambios y recordatorios

---

## 👥 Público Objetivo

| Rol | Descripción |
|-----|-------------|
| **Estudiante** | Puede ver la disponibilidad de citas y agendar turnos |
| **Secretaria** | Gestiona disponibilidad, confirma o rechaza citas, visualiza agenda |
| **Administrador (Sede)** | Configura horarios de atención, usuarios, reportes |

---

## 📋 Alcance Funcional (MVP)

### Fase 1: Autenticación ✅
- [x] Login con credenciales universitarias
- [x] Registro de nuevos usuarios
- [x] **Modo invitado (guest)** con device_id
- [x] Gestión de sesiones con JWT
- [x] Auto-refresh de tokens
- [x] Logout

### Fase 2: Citas (Core) ✅
- [x] Visualizar disponibilidad de citas
- [x] Agendar cita (estudiante)
- [x] Reprogramar citas
- [x] **7 estados de cita:** pendiente, llamando, en_atencion, atendido, no_asistio, finalizada, cancelada
- [x] Confirmar/cambiar estado (secretaria/admin)
- [x] Cancelar cita (estudiante y secretaria)
- [x] Visualizar historial de citas
- [x] Extender tiempo de atención

### Fase 3: Comunicación en Tiempo Real ✅
- [x] WebSocket con reconexión automática (cada 3s)
- [x] Notificaciones Firebase Cloud Messaging
- [x] Sincronización de FCM token con backend
- [x] Notificaciones locales en Android
- [x] Actualización instantánea de estados

### Fase 4: Múltiples Roles y Sedes ✅
- [x] Dashboard para estudiante (5 pantallas)
- [x] Panel para secretaria (4 pantallas)
- [x] Panel para administrativo (3 pantallas)
- [x] Panel para admisiones y mercadeo (2 pantallas)
- [x] Selección y gestión de sedes (headquarters)
- [x] Componentes compartidos (shared)

---

## 🏗️ Arquitectura Técnica

### Stack Tecnológico

```
Frontend:          Backend:
├─ Flutter (Dart)  ├─ REST API
├─ HTTP/WebSocket  ├─ WebSocket
├─ Material Design  ├─ Base de Datos
└─ Clean Arch      └─ Autenticación
```

### Patrón Arquitectónico

**Clean Architecture (por Features)**

```
Cada Feature tiene:
├─ Data Layer       (Fuentes de datos, HTTP, WebSocket)
├─ Domain Layer     (Entidades, repositorios, lógica pura)
└─ Presentation     (UI, navegación, estado local)
```

**Beneficios:**
- Código testeable y desacoplado
- Fácil agregar nuevas features
- Separación clara de responsabilidades
- Reutilización de lógica

---

## 🔄 Flujos Principales

### 1. Autenticación
```
Login → Validar credenciales → Guardar token → Redirigir a Dashboard
```

### 2. Agendar Cita (Estudiante)
```
Ver disponibilidad → Seleccionar horario → Confirmar → API agrega cita
```

### 3. Confirmar Cita (Secretaria)
```
Recibir notificación WebSocket → Ver cita pendiente → Confirmar/Rechazar
↓ (en tiempo real)
Estudiante recibe actualización instantánea
```

### 4. Cancelar Cita (Ambos)
```
Usuario selecciona cita → Confirma cancelación → API cancela
↓ (en tiempo real)
Otros usuarios ven actualización inmediata
```

---

## 🚀 Roadmap Inicial

### Fase 1 - MVP ✅ (Completado)
- ✅ Autenticación (login, registro, modo guest)
- ✅ Gestión de citas básicas
- ✅ Sincronización con WebSocket
- ✅ Multi-rol (estudiante, secretaria, admin, admisiones)
- ✅ Notificaciones Firebase
- ✅ Android, iOS, Web

### Fase 2 - En Progreso 🔄
- ⚠️ Tests unitarios y de integración (pendiente)
- 📋 Reportes y analytics
- 📋 Exportar historial (PDF)

### Fase 3 - Futuro 🎯
- 📋 Integración SSO (LDAP/OAuth)
- 📋 Soporte multi-idioma
- 📋 Optimizaciones de rendimiento
- 📋 Publicación en tiendas oficiales

---

## 📊 Características Técnicas Clave

### 1. Autenticación y Sesiones
- Token-based con JWT (access + refresh tokens)
- **Modo invitado** con identificación por device_id
- Gestión automática de sesiones y auto-refresh
- Almacenamiento seguro: `flutter_secure_storage` (Android), cookies HttpOnly (Web)
- Logout automático en caso de invalidación

### 2. API REST
- **Producción:** `https://sigetu-backend.onrender.com`
- **Desarrollo:** Configurable con `--dart-define=API_BASE_URL`
- Métodos estándar: GET, POST, PATCH
- Tokens en header `Authorization: Bearer {token}`
- **30+ endpoints** para gestión completa

### 3. WebSocket en Tiempo Real
- URL: `wss://sigetu-backend.onrender.com/appointments/ws?token=JWT`
- **Reconexión automática** cada 3 segundos si falla
- Sincronización instantánea de cambios de citas
- Notificaciones de cambios de estado en tiempo real

### 4. Notificaciones Push
- **Firebase Cloud Messaging** integrado
- Sincronización de FCM token con backend (`POST /notifications/device-token`)
- Notificaciones locales en Android (canal 'citas')
- Soporte para Web con VAPID key
- Manejo de mensajes en foreground

### 5. Manejo de Fechas y Horas
- Formatting: **AM/PM** en toda la UI (usando `intl`)
- Parseo: Backend proporciona offset de zona horaria (default UTC-5)
- Utilidades: `AppDateFormatter` y `BackendDateTime`
- Precisión: Minutos

### 6. Multiplataforma
- **Android**: APK/AAB compilable
- **iOS**: IPA compilable (Bundle ID: `com.example.sigetu`)
- **Web**: Compilación lista, soporte completo
- **Windows**: Configuración de launcher icons
- **macOS**: Configuración lista

---

## 🔐 Consideraciones de Seguridad

- [x] Tokens guardados en almacenamiento seguro (`flutter_secure_storage` en Android)
- [x] Cookies HttpOnly para Web
- [x] HTTPS en producción (`https://sigetu-backend.onrender.com`)
- [x] WSS (WebSocket Secure) en producción
- [x] Validación de entrada en cliente
- [x] Logout automático en sesión inválida
- [ ] No enviar datos sensibles en logs (revisar)
- [x] Device_id para trazabilidad en modo guest

---

## 📈 Métricas de Éxito

| Métrica | Meta |
|---------|------|
| **Disponibilidad** | 99% uptime |
| **Latencia API** | < 200ms |
| **Sincronización WebSocket** | < 100ms |
| **Tasa de adoption** | 70% de estudiantes activos |
| **Satisfacción** | NPS > 40 |

---

## 🤝 Stakeholders Principales

- Estudiantes (usuarios finales)
- Secretarias y administrativos (power users)
- Departamento de TI (soporte)
- Dirección/Rectorado (steward del proyecto)

---

## 📝 Notas Importantes

1. **Base de datos**: Manejada por backend, frontend solo consume API REST
2. **Autenticación**: Sistema propio con JWT + modo invitado opcional
3. **Escalabilidad**: Diseño permite múltiples sedes sin cambios mayores
4. **Mantenibilidad**: Clean Architecture facilita cambios futuros
5. **Firebase**: Ya configurado y en uso para notificaciones push
6. **Tests**: Pendientes de implementar (actualmente solo placeholder)
7. **Bundle ID iOS**: Usar placeholder `com.example.sigetu`, cambiar a `com.uniautonoma.sigetu` en producción

---

**Última actualización:** Abril 2026
