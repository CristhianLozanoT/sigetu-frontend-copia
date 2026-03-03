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

## 📦 Alcance Funcional (MVP)

### Fase 1: Autenticación
- [x] Login con credenciales universitarias
- [x] Gestión de sesiones
- [x] Logout

### Fase 2: Citas (Core)
- [x] Visualizar disponibilidad de citas
- [x] Agendar cita (estudiante)
- [x] Confirmar/Rechazar cita (secretaria)
- [x] Cancelar cita (ambos)
- [x] Visualizar historial de citas

### Fase 3: Comunicación en Tiempo Real
- [x] WebSocket para actualizaciones instantáneas
- [x] Notificaciones de cambios de estado
- [x] Sincronización de datos

### Fase 4: Múltiples Sedes
- [x] Dashboard para estudiante
- [x] Panel para secretaria
- [x] Panel para administrador de sede

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

### Trimestre 1 (Q1)
- ✅ MVP con autenticación y citas básicas
- ✅ Sincronización con WebSocket
- ✅ Aplicación en Android e iOS

### Trimestre 2 (Q2)
- 🔄 Reportes y analytics
- 🔄 Notificaciones push
- 🔄 Exportar historial (PDF)

### Trimestre 3 (Q3)
- 📋 API avanzada (filtros, búsqueda)
- 📋 Integración SSO (LDAP/OAuth)
- 📋 Web version

### Trimestre 4 (Q4)
- 🎯 Optimizaciones y escalabilidad
- 🎯 Soporte multi-idioma
- 🎯 Publicación en tiendas oficiales

---

## 📊 Características Técnicas Clave

### 1. Autenticación y Sesiones
- Token-based (JWT probable)
- Gestión automática de sesiones
- Logout en caso de invalidación

### 2. API REST
- Endpoint: `http://{API_BASE_URL}/appointments`
- Métodos estándar: GET, POST, PUT, DELETE
- Tokens en header `Authorization`

### 3. WebSocket en Tiempo Real
- URL: `{API_BASE_URL}/appointments/ws`
- Sincronización instantánea de citas
- Notificaciones de cambios

### 4. Manejo de Fechas y Horas
- Formatting: **AM/PM** en toda la UI
- Parseo: Backend proporciona offset de zona horaria
- Precisión: Minutos

### 5. Multiplataforma
- **Android**: Compilación APK
- **iOS**: Compilación IPA
- **Web**: Compilación en navegador (futuro)

---

## 🔐 Consideraciones de Seguridad

- [ ] Tokens guardados en almacenamiento seguro
- [ ] HTTPS en producción
- [ ] Validación de entrada en cliente y servidor
- [ ] Logout automático en sesión inválida
- [ ] No enviar datos sensibles en logs

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

1. **Base de datos**: Manejada por backend, frontend solo consume API
2. **Autenticación**: Integrada con sistema universitario (presumiblemente)
3. **Escalabilidad**: Diseño permite múltiples sedes sin cambios mayores
4. **Mantenibilidad**: Clean Architecture facilita cambios futuros

---

**Última actualización:** Marzo 2026
