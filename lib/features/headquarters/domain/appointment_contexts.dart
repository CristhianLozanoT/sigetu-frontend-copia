class AppointmentContexts {
  // Sedes canónicas.
  static const String sedeAsistenciaEstudiantil = 'asistencia_estudiantil';
  static const String sedeAdministrativa = 'sede_administrativa';
  static const String sedeAdmisionesMercadeo = 'sede_admisiones_mercadeo';

  // Categorías canónicas enviadas al backend en el campo `category`.
  static const String academico = 'academico';
  static const String administrativo = 'administrativo';
  static const String financiero = 'financiero';
  static const String otro = 'otro';
  static const String pagosFacturacion = 'pagos_facturacion';
  static const String recibosCertificados = 'recibos_certificados';
  static const String creditosFinanciacion = 'creditos_financiacion';
  static const String problemasSoporteFinanciero =
      'problemas_soporte_financiero';
  static const String plataformasServicios = 'plataformas_servicios';
  static const String informacionAcademica = 'informacion_academica';
  static const String inscripcionMatricula = 'inscripcion_matricula';

  // Etiquetas mostradas en UI -> categoría canónica para API.
  static const Map<String, String> _labelToApiCategory = {
    'Académico': academico,
    'Administrativo / Legal': administrativo,
    'Financiero': financiero,
    'Otros': otro,
    'Pagos y facturación': pagosFacturacion,
    'Recibos y certificados': recibosCertificados,
    'Créditos y financiación': creditosFinanciacion,
    'Problemas y soporte financiero': problemasSoporteFinanciero,
    'Plataformas y servicios': plataformasServicios,
    'Información académica': informacionAcademica,
    'Inscripción y matrícula': inscripcionMatricula,
  };

  // Contextos disponibles por categoría canónica.
  // El valor seleccionado se normaliza y se envía en el campo `context`.
  static const Map<String, List<String>> byCategory = {
    academico: [
      'Trabajos de Grado',
      'Docentes, Salones y Horarios',
      'Preparatorios y reingresos',
      'Judicaturas y Suficiencias',
      'Validación Saber Pro',
      'Homologaciones y sustentaciones',
    ],
    administrativo: [
      'Cancelaciones y Derechos de petición',
    ],
    financiero: [
      'Cursos y temas financieros',
    ],
    otro: [
      'Otros servicios',
    ],
    pagosFacturacion: [
      'Pagos con tarjeta (Todo tipo de pagos, no se acepta efectivo)',
      'Validación de pagos',
      'Facturación electrónica',
      'Cruces de saldos a favor',
      'Aplicaciones de descuentos',
    ],
    recibosCertificados: [
      'Generación de recibos (Todo tipo de recibos)',
      'Solicitud de certificados de valores pagados',
      'Constancias y certificados',
    ],
    creditosFinanciacion: [
      'Trámites de crédito (Financiación, requisitos, documentos, renovación de créditos)',
      'Financiación interna y externa',
      'Trámites relacionados con ICETEX',
    ],
    problemasSoporteFinanciero: [
      'Problemas con matrículas financieras',
    ],
    plataformasServicios: [
      'Habilitación de plataformas',
    ],
    informacionAcademica: [
      'Información primer semestre',
      'Información pregrados y posgrados',
    ],
    inscripcionMatricula: [
      'Información matrícula nuevos primer semestre',
    ],
  };

  static List<String> forCategory(String category) {
    final apiCategory = toApiCategory(category);
    return byCategory[apiCategory] ?? const [];
  }

  // Permite recibir tanto etiquetas de UI como valores canónicos.
  static String toApiCategory(String value) {
    final trimmed = value.trim();
    return _labelToApiCategory[trimmed] ?? trimmed.toLowerCase();
  }

  // Contextos visibles en UI -> contexto canónico para API.
  // En sede administrativa se envía en snake_case según contrato backend.
  static const Map<String, String> _labelToApiContext = {
    'Pagos con tarjeta (Todo tipo de pagos, no se acepta efectivo)':
        'pagos_con_tarjeta',
    'Validación de pagos': 'validacion_pagos',
    'Facturación electrónica': 'facturacion_electronica',
    'Cruces de saldos a favor': 'cruces_saldos_favor',
    'Aplicaciones de descuentos': 'aplicacion_descuentos',
    'Generación de recibos (Todo tipo de recibos)': 'generacion_recibos',
    'Solicitud de certificados de valores pagados':
      'certificado_valores_pagados',
    'Constancias y certificados': 'constancias_certificados',
    'Trámites de crédito (Financiación, requisitos, documentos, renovación de créditos)':
      'tramites_credito',
    'Financiación interna y externa': 'financiacion_interna_externa',
    'Trámites relacionados con ICETEX': 'tramites_icetex',
    'Problemas con matrículas financieras': 'problemas_matriculas_financieras',
    'Habilitación de plataformas': 'habilitacion_plataformas',
    'Información primer semestre': 'informacion_primer_semestre',
    'Información pregrados y posgrados': 'informacion_pregrados_posgrados',
    'Información matrícula nuevos primer semestre':
      'informacion_matricula_nuevos_primer_semestre',
  };

  // Mantiene compatibilidad con el comportamiento previo para contextos no mapeados.
  static String toApiContext(String value) {
    final trimmed = value.trim();
    return _labelToApiContext[trimmed] ?? _normalizeLegacy(trimmed);
  }

  static String _normalizeLegacy(String value) {
    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'Á': 'A',
      'É': 'E',
      'Í': 'I',
      'Ó': 'O',
      'Ú': 'U',
      'ñ': 'n',
      'Ñ': 'N',
    };

    var normalized = value;
    replacements.forEach((key, replacement) {
      normalized = normalized.replaceAll(key, replacement);
    });

    return normalized.toLowerCase();
  }

  static const Set<String> _administrativeCategories = {
    pagosFacturacion,
    recibosCertificados,
    creditosFinanciacion,
    problemasSoporteFinanciero,
    plataformasServicios,
  };

  static const Set<String> _admissionsMarketingCategories = {
    informacionAcademica,
    inscripcionMatricula,
  };

  // Resuelve la sede canónica a partir de la categoría seleccionada.
  static String headquarterForCategory(String category) {
    final apiCategory = toApiCategory(category);
    if (_administrativeCategories.contains(apiCategory)) {
      return sedeAdministrativa;
    }
    if (_admissionsMarketingCategories.contains(apiCategory)) {
      return sedeAdmisionesMercadeo;
    }
    return sedeAsistenciaEstudiantil;
  }
}
