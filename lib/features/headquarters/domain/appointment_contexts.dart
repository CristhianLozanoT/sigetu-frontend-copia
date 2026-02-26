class AppointmentContexts {
  static const Map<String, List<String>> byCategory = {
    'Académico': [
      'Trabajos de Grado',
      'Docentes, Salones y Horarios',
      'Preparatorios y reingresos',
      'Judicaturas y Suficiencias',
      'Validación Saber Pro',
      'Homologaciones y sustentaciones',
    ],
    'Administrativo / Legal': [
      'Cancelaciones y Derechos de petición',
    ],
    'Financiero': [
      'Cursos y temas financieros',
    ],
    'Otros': [
      'Otros servicios',
    ],
  };

  static List<String> forCategory(String category) {
    return byCategory[category] ?? const [];
  }
}
