module QuestionnaireHelper

  # 1. CUESTIONARIO NARRATIVO (Diagnóstico Profundo - 30 Preguntas)
  # Se utiliza en: public_questionnaires/new y admin/prospect_questionnaires/show
  def get_categorized_questions
    {
      "Historia y Liderazgo" => {
        "q1" => "¿Cómo nació la empresa y cuál fue el problema u oportunidad que la detonó?",
        "q2" => "¿En qué año inició y cuáles han sido los 3 hitos más importantes desde entonces?",
        "q3" => "¿Qué decisiones del pasado explican mejor “por qué hoy están donde están”?",
        "q4" => "¿Cuál es la nacionalidad y edad del dueño o dueños?",
        "q5" => "¿Cuál es tu rol real hoy y en qué te estás metiendo que no deberías?",
        "q6" => "¿Qué cosas dependen de ti para funcionar y por qué siguen dependiendo de ti?",
        "q7" => "¿Si tú te ausentas 2 semanas, qué se rompe primero y qué se detiene por completo?"
      },
      "Estrategia y Cliente Ideal" => {
        "q8" => "¿Qué decisiones quieres seguir tomando tú sí o sí y cuáles te urge delegar?",
        "q9" => "¿Qué reglas no negociables quieres instalar para que la empresa opere sola?",
        "q10" => "¿Qué ritmo de gestión quieres (semanal, mensual, trimestral) y qué debe decidirse ahí?",
        "q11" => "¿Qué servicios son estratégicos para crecer y cuáles ya no deberían existir?",
        "q12" => "¿Qué NO van a hacer aunque el cliente lo pida y qué excepciones están prohibidas?",
        "q13" => "¿Quién es el cliente ideal y cuál es el cliente que ya no quieres atender?",
        "q14" => "¿Qué les compran en realidad hoy y por qué los eligen a ustedes?"
      },
      "Operación y Calidad" => {
        "q15" => "¿Qué canal es el más confiable hoy y cuál quieres desarrollar sí o sí?",
        "q16" => "¿Cuál es el cuello de botella principal y qué costo tiene en ventas, calidad o estrés?",
        "q17" => "¿Cuáles son los errores/incidencias más caros y qué tanto están dispuestos a “tolerar”?",
        "q18" => "¿Cuál es tu definición de “crecer bien” sin desorden y cómo lo medirías?",
        "q19" => "¿Qué señal te diría que ya no se debe vender más hasta estabilizar?"
      },
      "Crecimiento y Finanzas" => {
        "q20" => "¿Qué roles clave faltan para que la empresa no dependa de ti?",
        "q21" => "¿Quiénes son tus 3 puestos críticos y qué tan reemplazables son hoy?",
        "q22" => "¿Cuál es tu regla de oro de caja (mínimo, anticipos, plazos) y qué no se negocia?",
        "q23" => "¿Qué línea/cliente/servicio te deja más utilidad real y cuál te drena energía y dinero?",
        "q24" => "¿Qué es lo que más te preocupa que pueda salir mal?"
      },
      "Plan de Acción" => {
        "q25" => "¿Qué tendría que pasar en 90 días para que digas “este plan valió la pena”?",
        "q26" => "¿En 12 meses, cómo se vería una empresa autónoma para ti?",
        "q27" => "¿Qué es prioridad #1 hoy y por qué?",
        "q28" => "¿Qué intentaron antes para mejorar y por qué no se sostuvo?",
        "q29" => "¿Qué no estás dispuesto a cambiar aunque sea “lo ideal”?",
        "q30" => "¿Qué tiempo real puedes comprometer por semana?"
      }
    }
  end

  # 2. AUTODIAGNÓSTICO CUANTITATIVO (Escala 1-5 - 25 Preguntas)
  # Se utiliza para generar la gráfica de telaraña (Radar Chart)
  def get_autodiagnostico_questions
    {
      "Dirección y Estrategia" => {
        "a1" => "La empresa cuenta con una misión, visión y valores definidos, y la dirección los tiene claros.",
        "a2" => "Existe una estrategia definida (a qué clientes se dirige, qué ofrece y cómo se diferencia de la competencia).",
        "a3" => "Se establecen objetivos anuales y metas medibles, y la dirección los utiliza como base para gestionar el negocio.",
        "a4" => "Se realiza un seguimiento periódico al cumplimiento de los objetivos y se toman decisiones para corregir desviaciones.",
        "a5" => "La operación diaria está lo suficientemente delegada y el negocio no depende exclusivamente del dueño o de una sola persona clave."
      },
      "Administración y Finanzas" => {
        "a6" => "La empresa cuenta con registros contables ordenados y elabora estados financieros mensuales básicos (estado de resultados y flujo de efectivo).",
        "a7" => "Se conoce con claridad el costo de los productos o servicios, incluyendo mano de obra, materiales y gastos indirectos.",
        "a8" => "Se monitorea la rentabilidad del negocio (márgenes, utilidad) y se usan estos datos para tomar decisiones.",
        "a9" => "Se gestiona el flujo de efectivo de forma anticipada (proyección de ingresos y egresos, planeación de pagos y cobros).",
        "a10" => "Existe un presupuesto o control de gastos y se revisa periódicamente para evitar desviaciones importantes."
      },
      "Operación y Procesos" => {
        "a11" => "Los procesos clave del negocio (venta, servicio, producción, facturación, atención a clientes, etc.) están identificados y descritos.",
        "a12" => "Existen estándares de trabajo (pasos claros, tiempos, checklist) que guían cómo debe hacerse cada proceso importante.",
        "a13" => "Se miden indicadores operativos básicos (tiempos de respuesta, errores, retrabajos, incumplimientos) y se registran de manera consistente.",
        "a14" => "Las herramientas y sistemas utilizados (software, formatos, plantillas) soportan adecuadamente la operación y no generan retrabajo innecesario.",
        "a15" => "Se realizan mejoras periódicas en los procesos a partir de problemas detectados, datos o sugerencias del equipo (no solo cuando hay crisis)."
      },
      "Ventas y Mercadotecnia" => {
        "a16" => "La empresa tiene claro a quién quiere venderle, qué ofrece y por qué un cliente debería elegirnos, y eso se comunica de la misma forma en toda la empresa.",
        "a17" => "La empresa tiene una forma constante de conseguir nuevos clientes (por ejemplo, recomendaciones, redes, llamadas, alianzas, publicidad) y no depende solo de la suerte.",
        "a18" => "La empresa tiene un proceso claro para vender (pasos definidos desde el primer contacto hasta el cierre), y el equipo lo sigue de manera parecida.",
        "a19" => "La empresa lleva control de los resultados de ventas (cuántos prospectos llegan, cuántos se convierten en clientes, cuánto se vende y en cuánto tiempo se cierra) y usa esa información para mejorar.",
        "a20" => "La empresa da seguimiento a los clientes después de vender, cuida su satisfacción y busca que vuelvan a comprar o recomienden, para no estar perdiendo clientes."
      },
      "Organización y C. Humano" => {
        "a21" => "Existe una estructura organizacional clara (organigrama) y las personas saben a quién reportan y cuáles son sus responsabilidades.",
        "a22" => "Se cuenta con descripciones de puesto para los roles clave, incluyendo funciones y responsabilidades principales.",
        "a23" => "Existe un proceso definido de reclutamiento e inducción para las nuevas personas que ingresan a la empresa.",
        "a24" => "Se realiza algún tipo de evaluación de desempeño o retroalimentación formal al personal, al menos una vez al año.",
        "a25" => "El clima laboral (comunicación, respeto, colaboración) se percibe en general como positivo y favorece el compromiso con la empresa."
      }
    }
  end

  def get_autodiagnostico_analysis(key, score)
  score = score.to_i
  
  data = {
    # ==========================================
    # DIRECCIÓN Y ESTRATEGIA (a1 - a5)
    # ==========================================
    "a1" => {
      1 => { text: "No tenemos misión/visión/valores definidos, o nadie los conoce.", dictamen: "No existe una guía directiva compartida; el rumbo depende de urgencias y criterios personales, lo que genera decisiones inconsistentes y poca alineación del equipo.", recs: ["Definir MVV en sesión de 1–2 hrs.", "Dejarlo en 1 hoja simple.", "Comunicarlo con ejemplos prácticos (qué sí/qué no)."] },
      2 => { text: "Hay algo escrito, pero no lo usamos ni está claro para todos.", dictamen: "La MVV existe pero no gobierna la gestión; se percibe como documento, no como regla de decisión, generando incongruencias entre discurso y operación.", recs: ["Simplificar MVV (sin texto de relleno).", "Convertir valores en 3–5 conductas observables.", "Integrarlo a inducción y juntas."] },
      3 => { text: "Tenemos MVV, pero solo se usa en algunas decisiones.", dictamen: "La dirección es parcial; hay momentos de alineación y momentos de dispersión, lo que provoca prioridades cambiantes y mensajes mixtos.", recs: ["Definir criterios de decisión basados en MVV.", "Aterrizar MVV por área.", "Revisarlo mensual 10 min en dirección."] },
      4 => { text: "Está claro y normalmente guía decisiones y comportamientos.", dictamen: "Hay claridad y consistencia en la mayoría de decisiones; el siguiente riesgo es que dependa de interpretaciones y no de métricas.", recs: ["Institucionalizar la revisión en juntas mensuales.", "Conectar evaluación de desempeño a valores."] },
      5 => { text: "Es parte de la cultura vivida; es la base de toda la planificación.", dictamen: "Cultura y estrategia alineadas. Hay una identidad fuerte que atrae talento y clientes afines.", recs: ["Auditar la congruencia anualmente.", "Revisar estrategia a largo plazo (3-5 años)."] }
    },
    "a2" => {
      1 => { text: "No tenemos una estrategia clara; vendemos lo que nos pidan.", dictamen: "La empresa compite por precio y sobrevive el día a día. Alta vulnerabilidad ante cambios de mercado y competidores.", recs: ["Definir cliente ideal (quién sí, quién no).", "Escribir propuesta de valor en 1 párrafo.", "Analizar rentabilidad por servicio."] },
      2 => { text: "Tenemos idea de la estrategia, pero no está bajada a papel.", dictamen: "La estrategia está solo en la cabeza del dueño. El equipo no sabe cómo aportar valor diferenciado.", recs: ["Plasmar el modelo de negocio en un CANVAS.", "Comunicar el foco comercial al equipo.", "Definir 1 diferenciador clave."] },
      3 => { text: "Hay estrategia definida, pero a veces tomamos proyectos fuera de ella.", dictamen: "Falta disciplina estratégica; se asumen costos ocultos por proyectos no alineados, afectando el margen.", recs: ["Crear matriz de calificación de prospectos.", "Aprender a decir 'no' a clientes no rentables.", "Revisar estrategia trimestralmente."] },
      4 => { text: "Estrategia clara y casi todo el equipo opera alineado a ella.", dictamen: "Buen enfoque; la empresa crece ordenadamente y capitaliza su nicho de mercado.", recs: ["Analizar nuevas líneas de negocio alineadas.", "Profundizar barreras de entrada a competidores."] },
      5 => { text: "Estrategia robusta, diferenciada y comunicada a toda la empresa.", dictamen: "Posicionamiento experto. La empresa dicta reglas en su segmento y los clientes la buscan por su valor.", recs: ["Mantener vigilancia de tendencias e innovación.", "Crear un ecosistema de servicios/productos."] }
    },
    "a3" => {
      1 => { text: "No hay metas anuales; solo trabajamos el día a día.", dictamen: "Crecimiento por inercia, no por diseño. Falta de motivación y dirección para el equipo, que solo reacciona a urgencias.", recs: ["Fijar 3 metas clave para este año.", "Convertirlas en números claros (ej. ventas, costos).", "Publicarlas a todo el equipo."] },
      2 => { text: "Tenemos metas, pero no están medidas en números.", dictamen: "La ambigüedad genera conformismo. Si no se puede medir, no se puede gestionar ni exigir.", recs: ["Usar metodología SMART para las metas.", "Definir un indicador (KPI) por meta.", "Asignar 1 responsable por cada una."] },
      3 => { text: "Hay metas medibles, pero solo las conoce dirección.", dictamen: "El equipo opera sin propósito numérico; esfuerzo fragmentado y poca responsabilidad sobre resultados finales.", recs: ["Compartir metas en reunión general.", "Desglosar metas por área o gerente.", "Crear un tablero visual básico."] },
      4 => { text: "Metas claras, medidas y bajadas a los líderes.", dictamen: "Alineación hacia resultados. Permite evaluar desempeño y ajustar recursos con base en objetivos reales.", recs: ["Hacer revisión mensual de cumplimiento.", "Vincular incentivos a cumplimiento de meta."] },
      5 => { text: "Toda la empresa tiene metas numéricas alineadas a la estrategia.", dictamen: "Cultura de resultados. Cada persona sabe cómo su trabajo impacta el éxito global de la empresa.", recs: ["Revisar metas trimestralmente (OKR).", "Aumentar nivel de exigencia progresivamente."] }
    },
    "a4" => {
      1 => { text: "No medimos ni revisamos resultados periódicamente.", dictamen: "Se maneja a ciegas. Los problemas y desviaciones se detectan demasiado tarde, usualmente cuando ya hay crisis.", recs: ["Implementar junta de resultados mensual (1 hora).", "Revisar solo los 3 indicadores clave.", "Documentar acuerdos básicos."] },
      2 => { text: "A veces nos sentamos a ver números, pero sin formato fijo.", dictamen: "Seguimiento reactivo e informal; no hay rendición de cuentas sistemática y los compromisos se olvidan.", recs: ["Crear reporte mensual estandarizado (1 página).", "Fijar día y hora de junta mensual inamovible.", "Enviar formato previo a la reunión."] },
      3 => { text: "Revisamos mensualmente, pero pocas veces corregimos desviaciones.", dictamen: "Hay diagnóstico pero no acción. Las juntas son informativas, no ejecutivas; los problemas se repiten.", recs: ["Implementar minuta de compromisos.", "Asignar responsable y fecha a cada acción.", "Iniciar cada junta revisando acuerdos pasados."] },
      4 => { text: "Hacemos juntas periódicas, medimos y tomamos acciones.", dictamen: "Gestión proactiva; permite corregir el rumbo rápidamente y mantener el control de la operación.", recs: ["Analizar causas raíz de desviaciones repetidas.", "Acortar duración de junta, enfocada en decisiones."] },
      5 => { text: "Seguimiento estricto, análisis de causas y corrección ágil.", dictamen: "Ejecución disciplinada. El negocio es predecible y capaz de adaptarse velozmente al entorno.", recs: ["Implementar tableros en tiempo real (BI).", "Capacitar a líderes en análisis de datos complejos."] }
    },
    "a5" => {
      1 => { text: "El dueño hace casi todo; si no está, el negocio se detiene.", dictamen: "Riesgo total de continuidad; el negocio se detiene por falta de estructura, procesos y reemplazos.", recs: ["Identificar procesos críticos dependientes del dueño.", "Definir responsables alternos (backup).", "Documentar SOPs mínimos y capacitar."] },
      2 => { text: "Hay algo delegado, pero las decisiones clave siguen centralizadas.", dictamen: "La operación avanza, pero lenta; la autoridad no está clara y todo se atasca en aprobaciones.", recs: ["Definir niveles de autoridad por rol.", "Crear matriz RACI (quién decide qué).", "Capacitación enfocada en decisiones frecuentes."] },
      3 => { text: "La operación funciona, pero ciertos temas dependen del dueño.", dictamen: "Dependencia parcial: hay áreas o momentos donde el flujo se detiene, limitando el crecimiento.", recs: ["Listar 3 dependencias principales.", "Crear plan de sustitución por etapas.", "Implementar indicadores por rol para control."] },
      4 => { text: "En general está delegada; el dueño no está en el día a día.", dictamen: "Buen nivel de autonomía; el riesgo es que la estructura sea frágil si no hay documentación e indicadores.", recs: ["Documentar procesos clave (lo esencial).", "Implementar KPIs por puesto crítico.", "Revisión mensual de desempeño por área."] },
      5 => { text: "La empresa opera sin el dueño; hay estructura y reemplazos.", dictamen: "Empresa institucionalizada: continuidad alta, bajo riesgo y mejor capacidad de escalar sin depender de una persona.", recs: ["Crear plan de sucesión y desarrollo de líderes.", "Realizar auditorías internas ligeras.", "Fomentar la mejora continua anual."] }
    },

    # ==========================================
    # FINANZAS Y CONTABILIDAD (a6 - a10)
    # ==========================================
    "a6" => {
      1 => { text: "No tenemos contabilidad ordenada ni estados financieros.", dictamen: "No existe visibilidad financiera confiable; las decisiones se toman a ciegas y hay riesgo de fugas de liquidez.", recs: ["Ordenar contabilidad y pólizas de ingreso/egreso.", "Generar Estado de Resultados y Flujo mensual.", "Definir responsable y calendario de cierre."] },
      2 => { text: "Hay contabilidad, pero está incompleta o llega tarde.", dictamen: "La información existe, pero no es oportuna ni útil; se pierde control y se vuelve reactivo ante problemas financieros.", recs: ["Establecer fecha de corte mensual inamovible.", "Depurar catálogo contable.", "Revisión mensual de variaciones principales."] },
      3 => { text: "Hacemos estados financieros, pero no siempre están al día.", dictamen: "Hay avance, pero disciplina irregular; la empresa opera con incertidumbre en meses críticos.", recs: ["Checklist de cierre contable.", "Conciliación bancaria mensual obligatoria.", "Crear tablero simple con 5-8 indicadores financieros."] },
      4 => { text: "Tenemos estados financieros mensuales y normalmente están bien.", dictamen: "Control financiero base sólido; permite entender tendencias y tomar decisiones soportadas en datos.", recs: ["Clasificar gastos fijos vs variables.", "Definir reglas de ahorro por rubro.", "Analizar rentabilidad real por área/cliente."] },
      5 => { text: "Información financiera precisa y en tiempo real para decidir.", dictamen: "Madurez financiera total; protege la rentabilidad, facilita proyecciones y asegura liquidez sana.", recs: ["Revisiones trimestrales de estructura de costos.", "Optimizar estrategia fiscal y flujos de inversión."] }
    },
    "a7" => {
      1 => { text: "No costeamos formalmente; ponemos el precio a ojo.", dictamen: "Riesgo de margen negativo (vender a pérdida sin saberlo); imposibilidad de escalar de forma rentable.", recs: ["Listar todos los insumos de 3 productos/servicios clave.", "Calcular costo de mano de obra directa.", "Prorratear un % de gastos fijos."] },
      2 => { text: "Calculamos material directo, pero olvidamos indirectos.", dictamen: "Rentabilidad ilusoria; los costos ocultos (indirectos) se comen el margen real del negocio.", recs: ["Incluir sueldos operativos en el costeo.", "Estimar cuota de gastos fijos (renta, luz) por servicio.", "Revisar margen bruto teórico vs real."] },
      3 => { text: "Costeamos bien, pero no actualizamos los precios si hay cambios.", dictamen: "Pérdida silenciosa de margen ante inflación o proveedores; el precio queda rezagado.", recs: ["Actualizar lista de precios/costos trimestralmente.", "Avisar ajustes a clientes clave con anticipación.", "Analizar impacto financiero de mermas."] },
      4 => { text: "El costeo es completo y se revisa con cierta frecuencia.", dictamen: "Seguridad en márgenes operativos; facilita estrategias de descuento y promociones sin riesgo financiero.", recs: ["Estandarizar cotizador con cálculo de margen oculto.", "Medir rentabilidad real al terminar el proyecto/servicio."] },
      5 => { text: "Costeo detallado, automatizado y actualizado constantemente.", dictamen: "Precisión máxima; se controla cada peso, optimizando precios e identificando qué servicios impulsar.", recs: ["Analizar sensibilidad de precios vs volumen.", "Auditoría anual de eficiencia en estructura de costos."] }
    },
    "a8" => {
      1 => { text: "No medimos rentabilidad, solo vemos cuánto hay en el banco.", dictamen: "Falsa sensación de seguridad (el efectivo no es utilidad); no se sabe qué da a ganar y qué quita dinero.", recs: ["Separar cuentas personales de las del negocio.", "Calcular Utilidad Bruta mensual.", "Calcular Utilidad Neta (tras gastos fijos e impuestos)."] },
      2 => { text: "Sabemos si hubo utilidad general, pero no por servicio.", dictamen: "Gestión superficial; se puede estar subsidiando servicios malos con los buenos sin saberlo.", recs: ["Elegir los 5 productos más vendidos y revisar margen.", "Identificar el margen unitario exacto.", "Evaluar aumento de precio en los de bajo margen."] },
      3 => { text: "Analizamos márgenes, pero no lo usamos para decidir.", dictamen: "La información es estéril; se sigue operando igual aunque los números indiquen que hay que cambiar.", recs: ["Tomar 1 decisión mensual basada en margen.", "Crear plan de acción para el servicio menos rentable.", "Eliminar productos/servicios que generen pérdida."] },
      4 => { text: "Medimos y usamos márgenes para impulsar lo que deja ganancia.", dictamen: "Optimización del portafolio; se maximiza el esfuerzo comercial hacia la rentabilidad, no solo al volumen.", recs: ["Fijar meta de margen mínimo para clientes nuevos.", "Alinear comisiones de venta al margen, no solo al ingreso."] },
      5 => { text: "Gestión avanzada de rentabilidad por producto, cliente y área.", dictamen: "Enfoque estratégico láser; crecimiento maximizando la creación de valor y eliminando ineficiencias sistemáticamente.", recs: ["Segmentar clientes por rentabilidad (Clase A, B, C).", "Diseñar estrategias exclusivas de fidelización para clientes A."] }
    },
    "a9" => {
      1 => { text: "No planeamos flujo; pagamos lo que urge con lo que hay.", dictamen: "Modo supervivencia; alto estrés financiero, riesgo de impago a nómina, proveedores o SAT.", recs: ["Hacer tabla básica semanal: Ingresos esperados vs Pagos.", "Congelar pagos no urgentes y compras.", "Activar cobranza intensa e inmediata."] },
      2 => { text: "Proyectamos a grandes rasgos, pero siempre hay sorpresas.", dictamen: "Proyección no confiable; falta registro de compromisos reales, causando sobresaltos y pago de recargos.", recs: ["Crear archivo de Flujo de Efectivo a 4 semanas.", "Registrar todas las cuentas por pagar fijas.", "Estimar ingresos solo con probabilidad alta."] },
      3 => { text: "Llevamos flujo, pero batallamos porque clientes pagan tarde.", dictamen: "Control interno funcional, pero fallo en política comercial; se financia al cliente sin capacidad para ello.", recs: ["Ajustar política de crédito (pedir anticipos mayores).", "Rutina semanal estricta de cobranza preventiva.", "Revisar antigüedad de saldos."] },
      4 => { text: "Tenemos flujo a 4-8 semanas y lo controlamos bastante bien.", dictamen: "Tranquilidad operativa; permite prever valles de liquidez y negociar pagos con anticipación, evitando crisis.", recs: ["Proyectar flujo a 13 semanas.", "Definir fondo de reserva mínimo (1 mes de operación).", "Negociar mejores plazos con proveedores clave."] },
      5 => { text: "Proyección a 13 semanas, gestión estricta y reservas sólidas.", dictamen: "Control absoluto; la empresa tiene liquidez para aprovechar oportunidades e invertir en crecimiento táctico.", recs: ["Analizar ciclos de conversión de efectivo.", "Crear estrategias de inversión para excedentes temporales."] }
    },
    "a10" => {
      1 => { text: "No tenemos presupuesto, gastamos según va saliendo.", dictamen: "Descontrol del gasto; tendencia a desperdiciar liquidez en meses buenos y sufrir en meses malos.", recs: ["Crear presupuesto mensual de gastos fijos.", "Definir un único responsable de autorizar pagos.", "Comparar lo gastado vs presupuestado a fin de mes."] },
      2 => { text: "Hay control informal, pero no se revisa consistentemente.", dictamen: "El control no previene desviaciones; se detecta el sobregiro tarde y se vuelve una corrección reactiva.", recs: ["Formato simple: presupuesto vs real vs variación.", "Junta mensual fija de revisión de gastos (30 min).", "Fijar límites de gasto por departamento."] },
      3 => { text: "Tenemos presupuesto, pero a menudo no se cumple.", dictamen: "Falta disciplina operativa; se generan desviaciones recurrentes sin corrección estructural.", recs: ["Identificar los 3 rubros con mayor desviación histórica.", "Aplicar acciones correctivas específicas por rubro.", "Ajustar presupuesto con base en la tendencia real validada."] },
      4 => { text: "Controlamos gastos y revisamos desviaciones con regularidad.", dictamen: "Control sano; se previenen excesos y se mantiene estabilidad. Permite prever rentabilidad.", recs: ["Auditoría ligera y periódica a proveedores principales.", "Reglas de ahorro por rubro (metas de eficiencia).", "Separar claramente centros de costos."] },
      5 => { text: "Presupuesto robusto; revisión periódica con acciones correctivas.", dictamen: "Gestión madura: el gasto está bajo control estricto y protege la rentabilidad de forma consistente.", recs: ["Implementar metodología de Presupuesto Base Cero anual.", "Vincular ahorros demostrados a bonos de eficiencia gerencial."] }
    },

    # ==========================================
    # OPERACIONES Y PROCESOS (a11 - a15)
    # ==========================================
    "a11" => {
      1 => { text: "No tenemos procesos definidos; cada quien hace lo que puede.", dictamen: "La operación depende de personas, no de procesos. Resultados inestables, promesas rotas y dificultad para crecer.", recs: ["Identificar 5–8 procesos comerciales/operativos clave.", "Documentarlos en flujo simple (1 página c/u).", "Definir responsables por proceso."] },
      2 => { text: "Hay procesos, pero están incompletos o solo algunos los siguen.", dictamen: "Existen lineamientos, pero falta estandarización; el desempeño varía y se pierde calidad ante el cliente.", recs: ["Unificar la 'forma estándar' de operar y atender.", "Documentar escenarios frecuentes de falla.", "Capacitar a todo el equipo para alinear la ejecución."] },
      3 => { text: "Tenemos procesos descritos, pero no se usan siempre.", dictamen: "Disciplina intermitente; provoca retrabajo y pérdida de control ante picos de demanda o rotación de personal.", recs: ["Actualizar trimestralmente los procesos críticos.", "Crear checklists mínimos por etapa clave.", "Realizar auditorías ligeras de cumplimiento."] },
      4 => { text: "Procesos clave bien definidos y el equipo los sigue.", dictamen: "Operación predecible; base sólida que permite delegar y escalar el negocio sin generar caos interno.", recs: ["Medir el cumplimiento de procesos (tiempos, fallas).", "Eliminar pasos o firmas innecesarias (metodología Lean).", "Vincular los procesos a descripciones de puesto."] },
      5 => { text: "Estandarización total; procesos optimizados y auditados.", dictamen: "Alta eficiencia operativa; el sistema trabaja para el negocio, asegurando calidad, velocidad y bajo costo.", recs: ["Implementar auditorías cruzadas entre áreas.", "Automatizar tareas repetitivas con software/RPA.", "Formar comités internos de mejora continua."] }
    },
    "a12" => {
      1 => { text: "No hay estándares; el resultado depende de la memoria.", dictamen: "Riesgo alto de fallas y calidad variable; imposibilidad de garantizar la misma experiencia al cliente repetidamente.", recs: ["Listar las 3 tareas operativas que más fallan.", "Hacer 1 checklist simple y visual para cada tarea.", "Hacer obligatorio el uso del checklist."] },
      2 => { text: "A veces explicamos cómo hacerlo, pero no hay manuales.", dictamen: "El conocimiento está centralizado; el entrenamiento de nuevos es lento y los errores por olvido son comunes.", recs: ["Grabar videos rápidos (celular/pantalla) de las tareas.", "Crear una carpeta compartida con guías paso a paso.", "Escribir manuales básicos (1-2-3) para actividades críticas."] },
      3 => { text: "Hay manuales, pero son complicados o se olvidan en el cajón.", dictamen: "Burocracia inútil; las herramientas existen pero no son prácticas, por lo que el personal las ignora.", recs: ["Simplificar manuales a 1 hoja visual o diagrama.", "Poner los estándares a la vista en la zona de trabajo.", "Supervisar por qué no se usan y ajustar formato."] },
      4 => { text: "Usamos estándares visuales y checklists que funcionan bien.", dictamen: "Calidad constante; el equipo sabe qué se espera y las herramientas facilitan el trabajo haciéndolo seguro.", recs: ["Revisión semestral de checklists con los usuarios.", "Líderes deben verificar proactivamente el uso del estándar.", "Vincular el uso de estándares a métricas de calidad."] },
      5 => { text: "Estándares integrados al flujo de trabajo (a prueba de errores).", dictamen: "Cero defectos operativos; la forma de trabajar previene el error antes de que ocurra (poka-yokes, validaciones de software).", recs: ["Implementar controles digitales obligatorios (sistemas).", "Certificar internamente a los operadores en sus procesos.", "Invertir en tecnología que evite intervención manual riesgosa."] }
    },
    "a13" => {
      1 => { text: "No medimos tiempos, errores ni quejas; apagamos fuegos.", dictamen: "Gestión reactiva; no se sabe qué falla ni por qué, lo que hace imposible mejorar de forma sistemática.", recs: ["Definir 1 métrica de calidad (ej. % quejas) y 1 de tiempo.", "Empezar a medir manualmente (pizarrón o Excel).", "Revisar los números obtenidos cada viernes."] },
      2 => { text: "A veces contamos los errores cuando hay un problema grave.", dictamen: "Visibilidad sesgada; solo se atiende lo que 'explota', mientras la ineficiencia diaria sigue costando dinero.", recs: ["Llevar bitácora continua de errores y retrabajos.", "Identificar el error más frecuente del mes.", "Definir una meta básica para reducir ese error."] },
      3 => { text: "Medimos algunas cosas, pero los datos no son muy confiables.", dictamen: "Esfuerzo de medición sin impacto; la captura es pesada o inexacta, por lo que nadie usa la data para decidir.", recs: ["Simplificar la forma de capturar la información.", "Asignar responsable único de recolectar el dato.", "Cruzar datos para validar que la información sea lógica."] },
      4 => { text: "Medimos KPIs operativos y usamos la información para evaluar.", dictamen: "Operación transparente; se identifican cuellos de botella y se evalúa el desempeño de forma objetiva.", recs: ["Implementar tablero visual en el área de trabajo.", "Fijar metas progresivas de reducción de tiempos/errores.", "Realizar juntas rápidas (15 min) para analizar el tablero."] },
      5 => { text: "KPIs en tiempo real, automatizados y analizados constantemente.", dictamen: "Madurez analítica; la empresa predice problemas, optimiza recursos al máximo y garantiza calidad estricta.", recs: ["Configurar alertas automáticas por desviaciones de KPI.", "Correlacionar métricas operativas con impacto financiero.", "Capacitar mandos medios en análisis estadístico."] }
    },
    "a14" => {
      1 => { text: "Todo es papel, memoria o WhatsApp; no hay orden.", dictamen: "Caos operativo y pérdida de información vital; pérdida de horas hombre buscando datos, nula trazabilidad.", recs: ["Migrar comunicación clave de WhatsApp a correos/herramientas formales.", "Centralizar archivos en nube (Google Drive / OneDrive).", "Digitalizar formatos de registro diarios."] },
      2 => { text: "Tenemos Excel, pero cada quien lo usa a su modo.", dictamen: "Silos de información; hay herramientas pero no estándares, causando duplicidad y datos contradictorios.", recs: ["Estandarizar formatos (bloquear celdas, reglas claras).", "Capacitar en el uso correcto y obligatorio de la herramienta.", "Prohibir archivos locales; obligar uso en red."] },
      3 => { text: "Tenemos un sistema de software, pero hacemos mucho por fuera.", dictamen: "Inversión subutilizada; doble captura de datos porque el sistema no se adapta o hay resistencia al cambio.", recs: ["Hacer lista de funciones del sistema que no se utilizan.", "Identificar por qué prefieren Excel y corregir el sistema.", "Hacer obligatorio que el flujo pase por el software."] },
      4 => { text: "Las herramientas soportan la operación sin doble captura.", dictamen: "Flujo ágil; la tecnología ahorra tiempo, reduce errores de dedo y facilita la supervisión remota.", recs: ["Integrar sistemas (ej. CRM con Facturación).", "Depurar reportes o pantallas que nadie lee.", "Explorar módulos adicionales del software actual."] },
      5 => { text: "Sistemas totalmente integrados (ERP) automatizando flujos.", dictamen: "Operación 100% digitalizada; el software es el esqueleto de la empresa, maximizando productividad y control.", recs: ["Explorar herramientas de IA para análisis predictivo.", "Realizar auditoría anual de ciberseguridad.", "Mejorar la interfaz (UX) para el usuario interno."] }
    },
    "a15" => {
      1 => { text: "No hay tiempo para mejorar; trabajamos como siempre.", dictamen: "Estancamiento garantizado; se repiten los mismos errores, los costos no bajan y el cliente sufre el impacto.", recs: ["Hacer reunión mensual de '¿Qué falló y cómo lo arreglamos?'", "Escuchar y anotar las 2 quejas principales del mes.", "Escoger y ejecutar solo 1 pequeña mejora al mes."] },
      2 => { text: "A veces arreglamos cosas cuando hay crisis o quejas fuertes.", dictamen: "Mejora reactiva (parches); se actúa por urgencia con soluciones temporales que no atacan la raíz del problema.", recs: ["Al fallar, preguntar '¿Por qué?' 5 veces hasta hallar la raíz.", "Documentar el cambio para estandarizar la solución.", "Asignar responsables claros de ejecutar la corrección."] },
      3 => { text: "Mejoramos, pero sin método; los proyectos se quedan a medias.", dictamen: "Buenas intenciones sin ejecución; pérdida de energía en ideas que no aterrizan ni se miden.", recs: ["Crear lista priorizada de mejoras (Backlog).", "No iniciar una mejora hasta terminar y medir la anterior.", "Definir siempre fecha límite y un único responsable."] },
      4 => { text: "Identificamos problemas, analizamos causas y mejoramos.", dictamen: "Cultura funcional de mejora; los procesos se hacen robustos con el tiempo y los errores no se repiten.", recs: ["Involucrar más al personal operativo en dar soluciones.", "Premiar públicamente las ideas implementadas exitosamente.", "Medir impacto económico o de tiempo tras cada mejora."] },
      5 => { text: "Cultura de mejora continua arraigada (Kaizen/Lean) en todos.", dictamen: "Excelencia operativa; el equipo busca proactivamente optimizar velocidad, costo y calidad a diario.", recs: ["Institucionalizar comités de mejora transversal.", "Vincular métricas de eficiencia a bonos operativos.", "Compartir mejores prácticas documentadas internamente."] }
    },

    # ==========================================
    # COMERCIAL Y VENTAS (a16 - a20)
    # ==========================================
    "a16" => {
      1 => { text: "No tenemos claro a quién vendemos ni por qué nos eligen.", dictamen: "Ceguera comercial; se vende 'a quien caiga', generando inestabilidad, guerras de precio y clientes incompatibles.", recs: ["Definir el Perfil de Cliente Ideal (ICP) en 1 hoja.", "Escribir propuesta de valor central en 1 sola frase.", "Listar 3 razones concretas por las que somos mejores."] },
      2 => { text: "Más o menos lo sabemos, pero no está bien definido.", dictamen: "Mensaje inconsistente; cada vendedor explica distinto, perdiendo efectividad e identidad de marca.", recs: ["Redactar un 'Pitch' comercial estándar (discurso de ventas).", "Alinear a operación sobre lo que ventas está prometiendo.", "Crear plantilla institucional para cotizaciones."] },
      3 => { text: "Sí está definido, pero no siempre se comunica igual.", dictamen: "Base comercial existente pero dispersa; falta disciplina para mantener el foco estratégico en el nicho.", recs: ["Reforzar mensaje comercial en juntas de ventas (10 min).", "Hacer lista de clientes/proyectos 'Sí' y clientes 'No'.", "Revisar grabaciones o correos reales de ventas."] },
      4 => { text: "Está claro y casi siempre se comunica de forma estandarizada.", dictamen: "Posicionamiento sólido; el cliente percibe autoridad y profesionalismo, facilitando el cierre.", recs: ["Medir tasa de conversión agrupada por canal de origen.", "Crear manual para manejo de objeciones frecuentes.", "Desarrollar material digital de apoyo (brochures, casos de éxito)."] },
      5 => { text: "Estrategia clara y diferenciación competitiva demostrada.", dictamen: "Ventaja de mercado absoluta; el crecimiento es planificado, la marca tiene peso y se cobra por valor real.", recs: ["Explorar mercados adyacentes o nuevos nichos premium.", "Refinar oferta basada en feedback de clientes AAA.", "Implementar metodologías de venta consultiva avanzada."] }
    },
    "a17" => {
      1 => { text: "Esperamos a que lleguen clientes o dependemos de conocidos.", dictamen: "Riesgo crítico de supervivencia; crecimiento estancado y dependencia total de factores externos o clientes actuales.", recs: ["Definir 2 canales de prospección activa inmediata.", "Bloquear tiempo semanal (ej. 4 hrs) solo para buscar clientes.", "Crear base de datos inicial de 50 prospectos objetivo."] },
      2 => { text: "A veces buscamos clientes, pero nos detenemos si hay trabajo.", dictamen: "Ciclo de 'picos y valles'; genera meses de saturación operativa seguidos de sequía de ingresos.", recs: ["Establecer meta inamovible de prospectos nuevos por semana.", "No detener prospección bajo ninguna excusa operativa.", "Registrar contactos en Excel para no perder seguimiento."] },
      3 => { text: "Tenemos canales de búsqueda, pero no los medimos bien.", dictamen: "Esfuerzo comercial ciego; sin métricas es imposible saber qué funciona, desperdiciando tiempo y dinero.", recs: ["Medir cuántos prospectos reales genera cada canal al mes.", "Calcular cuántos contactos se necesitan para cerrar 1 venta.", "Asignar presupuesto fijo a las campañas que sí funcionan."] },
      4 => { text: "Canales constantes; sabemos cuántos prospectos llegan.", dictamen: "Generación predecible de demanda; permite planear flujos de caja y operaciones con certidumbre.", recs: ["Optimizar inversión hacia el canal con mejor retorno (ROI).", "Mejorar el filtro de prospectos para no perder tiempo con 'malos leads'.", "Diversificar para no depender de 1 sola fuente (ej. Google + Alianzas)."] },
      5 => { text: "Sistema robusto, predecible y multicanal de generación de leads.", dictamen: "Motor de crecimiento automatizado; el equipo de ventas tiene flujo constante de oportunidades precalificadas.", recs: ["Implementar automatización de marketing (Lead Nurturing).", "Analizar costo de adquisición de clientes (CAC) por canal.", "Desarrollar programas institucionales de alianzas estratégicas."] }
    },
    "a18" => {
      1 => { text: "No hay proceso; cada quien vende como cree mejor.", dictamen: "Venta artesanal e inescalable; depende del humor y talento individual. Imposible capacitar a nuevos.", recs: ["Escribir los 4 pasos clave de la venta (ej. contacto > reunión > cotización > cierre).", "Obligar a seguir este flujo mínimo indispensable.", "Fijar regla: máximo 24h para enviar una cotización."] },
      2 => { text: "Conocemos los pasos, pero pocos los anotan o siguen.", dictamen: "Caos administrativo; cotizaciones en el olvido, falta de seguimiento sistemático y clientes que se enfrían.", recs: ["Implementar un checklist o formato obligatorio de venta.", "Junta semanal estricta de revisión de cotizaciones vivas.", "Definir guión básico de qué hacer si el cliente dice 'lo pensaré'."] },
      3 => { text: "Hay proceso definido, pero a veces saltamos pasos o seguimientos.", dictamen: "Disciplina irregular; se escapan ventas en la recta final por descuidos o falta de insistencia profesional.", recs: ["Obligar uso de un CRM básico o Excel estructurado.", "Auditar periódicamente que no se envíen propuestas sin perfilar.", "Crear regla: Contactar al menos 3-5 veces antes de dar por perdido."] },
      4 => { text: "El equipo sigue el proceso y no se pierden oportunidades.", dictamen: "Maquinaria comercial funcional; el orden y seguimiento disciplinado aumentan directamente la tasa de conversión.", recs: ["Auditar interacciones (llamadas/correos) para refinar guiones.", "Automatizar tareas de registro para que el vendedor solo venda.", "Medir el porcentaje de conversión de etapa a etapa (Embudo)."] },
      5 => { text: "Proceso estandarizado, apoyado en CRM y mejora continua.", dictamen: "Ventas como sistema de ingeniería; resultados predecibles, métricas claras e integración rápida de nuevos talentos.", recs: ["Automatizar recordatorios y tareas dentro del CRM.", "Análisis profundo de motivos de pérdida para cambiar producto/precio.", "Capacitación en técnicas de cierre avanzado y venta cruzada."] }
    },
    "a19" => {
      1 => { text: "No sabemos cuántos cotizamos ni por qué no nos compran.", dictamen: "Ceguera táctica; sin historial de pérdida, se repiten errores y no se sabe si falla el precio, producto o vendedor.", recs: ["Llevar registro obligatorio: Nombre, Producto, Monto, Estatus.", "Exigir anotar el motivo real por el cual NO compró el prospecto.", "Sumar a fin de mes cotizaciones ganadas vs perdidas."] },
      2 => { text: "Sabemos qué cerramos, pero no registramos lo que perdimos.", dictamen: "Visión incompleta; ignorar la tasa de rechazo impide hacer ajustes estratégicos urgentes en la empresa.", recs: ["Hacer del 'motivo de pérdida' un dato forzoso en reportes.", "Revisar los proyectos perdidos en la junta mensual.", "Llamar a prospectos perdidos para preguntar qué faltó."] },
      3 => { text: "Llevamos registro, pero no usamos la info para mejorar.", dictamen: "Captura burocrática sin análisis; se gasta tiempo en llenar tablas que nadie usa para tomar decisiones.", recs: ["Calcular métrica clave: Tasa de conversión (% de éxito).", "Identificar el paso del proceso donde más clientes abandonan.", "Implementar al menos 1 mejora comercial mensual basada en la data."] },
      4 => { text: "Analizamos nuestra conversión y motivos de pérdida para corregir.", dictamen: "Gestión inteligente y competitiva; el equipo aprende de sus fallas y calibra la estrategia para ganar más.", recs: ["Comparar tasas de conversión entre vendedores para compartir tácticas.", "Medir la duración del ciclo de ventas (días promedio para cerrar).", "Ajustar el perfil de prospectos basándose en las victorias."] },
      5 => { text: "Métricas en tiempo real, tableros y predicciones de ventas.", dictamen: "Dominio absoluto del embudo; predicción certera de ingresos (forecasting) que permite tomar decisiones de gran escala.", recs: ["Utilizar análisis predictivo y calificación de leads por puntos.", "Vincular los esquemas de compensación a KPIs de conversión.", "Proyectar escenarios de demanda y ajustar presupuesto."] }
    },
    "a20" => {
      1 => { text: "No damos seguimiento postventa ni medimos satisfacción.", dictamen: "Se desperdicia la recompra; los problemas operativos estallan tarde y los clientes insatisfechos destruyen reputación.", recs: ["Implementar contacto de seguimiento post-entrega (a las 24-72 hrs).", "Hacer 1 a 3 preguntas fijas sobre satisfacción.", "Crear registro centralizado de quejas o incidencias."] },
      2 => { text: "A veces preguntamos cómo les fue, pero no hay sistema.", dictamen: "Atención al cliente irregular; se apagan fuegos pero no se fideliza. Se pierden referidos por falta de presencia.", recs: ["Diseñar calendario de seguimiento periódico (ej. 30/60 días).", "Crear plantillas base para correos o mensajes de contacto.", "Nombrar a un responsable claro de la experiencia postventa."] },
      3 => { text: "Damos seguimiento, pero sin formatos ni medimos recompra.", dictamen: "Intención positiva pero sin estructura; no se capitaliza la relación con el cliente ni se mide el valor a largo plazo.", recs: ["Medir formalmente el % de clientes que vuelven a comprar.", "Definir protocolo inamovible (tiempos) para responder quejas.", "Mandar encuesta digital muy breve al concluir el servicio."] },
      4 => { text: "Cuidamos al cliente, logramos recompra y pedimos recomendación.", dictamen: "Servicio al cliente convertido en activo de ventas; alta lealtad que blinda contra la competencia por precio.", recs: ["Estructurar un programa formal de referidos.", "Segmentar clientes (A/B/C) y dar tratos VIP a los mejores.", "Crear métrica de Retención (Churn Rate)."] },
      5 => { text: "Sistema integral de éxito del cliente, métricas y fidelización.", dictamen: "Experiencia de clase mundial; los clientes son promotores activos y la retención asegura ingresos recurrentes sólidos.", recs: ["Implementar tableros de recompra y Net Promoter Score (NPS).", "Establecer juntas trimestrales de revisión de feedback de clientes.", "Estandarizar procesos de onboarding para clientes nuevos."] }
    },

    # ==========================================
    # RH (PERSONAS Y CULTURA) (a21 - a25)
    # ==========================================
    "a21" => {
      1 => { text: "No hay organigrama claro; no saben a quién reportan.", dictamen: "Confusión de líneas de mando; genera conflictos interpersonales, duplicidad de tareas y lentitud en resolución.", recs: ["Trazar organigrama simple (líneas claras de quién reporta a quién).", "Anotar 3 responsabilidades primordiales por cada puesto.", "Establecer la regla de oro: 'Un solo jefe por persona'."] },
      2 => { text: "Hay idea de estructura, pero no formalizada o no se respeta.", dictamen: "Estructura frágil y de palabra; colapsa en momentos de crisis porque la gente acude al dueño ignorando a los jefes.", recs: ["Publicar organigrama impreso o enviarlo institucionalmente.", "Reunión gerencial para aclarar fronteras entre departamentos.", "Centralizar lista de 'quién aprueba qué' para dudas comunes."] },
      3 => { text: "La estructura existe, pero con confusión en roles fronterizos.", dictamen: "Orden parcial pero con zonas grises operativas; causa que las tareas críticas se queden sin hacer (se avientan la culpa).", recs: ["Mapear las 5 actividades que más generan choque inter-áreas.", "Definir a un 'Responsable Final' único por actividad (RACI).", "Actualizar el organigrama y formalizar los cambios."] },
      4 => { text: "Estructura clara, responsabilidades conocidas y respetadas.", dictamen: "Jerarquía sana y funcional; permite el flujo de trabajo ágil, rendición de cuentas objetiva y fácil inducción.", recs: ["Revisión y actualización anual de descripciones de puesto.", "Agregar indicadores de éxito (KPIs) a cada puesto estratégico.", "Exigir que los mandos medios respeten la cadena de mando."] },
      5 => { text: "Estructura robusta y roles diseñados para escalamiento.", dictamen: "Organización de alto rendimiento; cada persona conoce su impacto y la empresa puede crecer ordenadamente.", recs: ["Analizar y nivelar los tramos de control (ej. máximo 7 reportes directos).", "Diseñar la estructura objetivo para los próximos 2 años.", "Definir matriz de competencias futuras."] }
    },
    "a22" => {
      1 => { text: "No hay perfiles de puesto; la gente hace lo que va saliendo.", dictamen: "Contratación a ciegas; empleados sin rumbo, causando frustración temprana, bajo rendimiento y rotación acelerada.", recs: ["Crear formato base: Objetivo del puesto y 5 funciones clave.", "Levantar los perfiles urgentes (los más problemáticos actuales).", "Usarlo como base obligatoria para la próxima contratación."] },
      2 => { text: "Hay algo escrito, pero desactualizado o es letra muerta.", dictamen: "Burocracia inútil; la teoría no coincide con la realidad operativa, generando falsas expectativas y quejas por injusticias.", recs: ["Pedir a cada persona clave que liste sus tareas actuales.", "El supervisor debe depurar y validar esa lista (30 min/rol).", "Entregar el documento final firmado a cada colaborador."] },
      3 => { text: "Hay perfiles reales pero solo para gerencias o roles clave.", dictamen: "Avance incompleto; hay orden arriba pero la base operativa (donde está el mayor volumen) sigue en caos funcional.", recs: ["Completar descripciones para el 100% de la plantilla.", "Asegurar que cada perfil especifique a quién reporta.", "Usar el perfil como base para las revisiones anuales."] },
      4 => { text: "Perfiles claros, vigentes y usados para contratar/evaluar.", dictamen: "Gestión de personal profesional; permite reclutar con precisión, capacitar sin inventar y medir desempeño objetivamente.", recs: ["Añadir competencias blandas requeridas (ej. trabajo en equipo).", "Ligar el perfil de puesto con planes de capacitación interna.", "RH debe auditar semestralmente el cumplimiento de perfiles."] },
      5 => { text: "Perfiles integrales ligados a KPIs y planes de desarrollo.", dictamen: "Estrategia avanzada de talento; retiene al mejor personal alineando su éxito individual con las metas de la empresa.", recs: ["Revisar perfiles ante cualquier automatización o nuevo software.", "Crear rutas claras de ascenso (career paths) basadas en el perfil."] }
    },
    "a23" => {
      1 => { text: "Contratamos al primero que llega, sin inducción real.", dictamen: "Alto riesgo corporativo; malas contrataciones generan errores graves inmediatos, pérdida de tiempo y afectación al cliente.", recs: ["Definir 3-4 preguntas innegociables para las entrevistas.", "Hacer recorrido y presentación formal el Día 1 (30 min).", "Asignar un colaborador experimentado como 'Guía' por 1 semana."] },
      2 => { text: "Entrevistamos básico, pero la inducción es 'aprender viendo'.", dictamen: "Curva de aprendizaje ineficiente; se satura a los más antiguos y el nuevo empleado comete errores evitables.", recs: ["Crear checklist de ingreso (correo, lugar, herramientas listas).", "Documento de 1 hoja con reglas inquebrantables (horarios, pagos).", "Armar cronograma de capacitación para la primera semana."] },
      3 => { text: "Hay reclutamiento, pero la inducción técnica falla.", dictamen: "Filtro inicial bueno, pero asimilación débil; hay riesgo de que estropeen procesos por falta de estándar enseñado.", recs: ["Tener manuales o videos de las 3 tareas vitales del puesto.", "Aplicar una evaluación rápida al terminar la primera semana.", "Agendar reuniones de revisión con el jefe al día 15 y 30."] },
      4 => { text: "Proceso formal de selección e inducción estructurada.", dictamen: "Atracción efectiva de talento; curva de productividad acelerada y el empleado genera arraigo con la marca más rápido.", recs: ["Comenzar a medir la tasa de rotación temprana (primeros 90 días).", "Implementar dinámicas de cultura/valores durante la entrevista.", "Enviar información institucional digital antes del primer día laboral."] },
      5 => { text: "Proceso estandarizado, auditado y mejora continua en Onboarding.", dictamen: "Máquina de talento; filtro de alta precisión y asimilación impecable que blinda la cultura organizacional.", recs: ["Medir costo y tiempo promedio de cobertura de vacantes.", "Desarrollar 'Academia Interna' o LMS de capacitación digital.", "Crear programa de recompensas por referidos internos exitosos."] }
    },
    "a24" => {
      1 => { text: "No evaluamos; solo regañamos cuando algo sale mal.", dictamen: "Gestión punitiva y destructiva; genera miedo, desmotivación inmediata y oculta los problemas hasta que es tarde.", recs: ["Iniciar charla mensual de 15 min (Jefe-Colaborador).", "Preguntar: '¿Qué hiciste bien?' y '¿En qué te puedo ayudar?'.", "Definir 1 acción de mejora mutua para el siguiente mes."] },
      2 => { text: "Damos retroalimentación de pasillo, sin registro escrito.", dictamen: "Mejor que nada, pero no hay acuerdos ni evidencia; imposibilita justificar despidos o promociones objetivamente.", recs: ["Crear formato exprés (Bien / A Mejorar / Necesidades).", "Ambas partes deben firmarlo y archivarlo en su expediente.", "Realizar esta dinámica obligatoriamente 2 veces al año."] },
      3 => { text: "Evaluamos con formato, pero no pasa nada con el resultado.", dictamen: "Burocracia inútil que frustra al equipo; la falta de consecuencias (positivas o negativas) anula el valor del ejercicio.", recs: ["Ligar la evaluación a indicadores numéricos, no solo a 'actitud'.", "Exigir 1 meta de desarrollo técnico o personal por evaluación.", "La empresa debe cumplir su parte (dar capacitación o equipo)."] },
      4 => { text: "Evaluación formal periódica (con KPIs) y feedback útil.", dictamen: "Cultura de mejora e impulso al mérito; el personal tiene claridad absoluta de dónde está y qué le falta para crecer.", recs: ["Vincular calificación con esquema de bonos o revisiones salariales.", "Capacitar a los jefes para evitar sesgos al calificar.", "Implementar evaluaciones de 360 grados o feedback entre pares."] },
      5 => { text: "Gestión de desempeño total vinculada a crecimiento y bonos.", dictamen: "Meritocracia blindada; el sistema retiene de forma natural a los mejores talentos y expulsa el bajo rendimiento justamente.", recs: ["Mudar a 'Feedback Continuo' soportado por software especializado.", "Usar metodología 9-Box para identificar alto potencial.", "Acelerar planes de sucesión inmediata para talentos top."] }
    },
    "a25" => {
      1 => { text: "Hay muchos conflictos y nulo compromiso del personal.", dictamen: "Cultura tóxica y de alto riesgo; productividad en picada, sabotajes pasivos y pérdida inminente de buenos elementos.", recs: ["Hacer entrevistas de salida para detectar causas reales sin juzgar.", "Intervenir conflictos agudos (reunión mediada por gerencia).", "Redactar e imponer 3 reglas innegociables de respeto interno."] },
      2 => { text: "Buen ambiente en unos equipos, hostilidad en otros.", dictamen: "Cultura fragmentada dependiente del carácter de cada líder; genera fricción entre departamentos y desgaste.", recs: ["Aplicar la misma encuesta de clima a toda la empresa.", "Exigir a cada jefe 2 acciones de mejora mensuales para su equipo.", "Directivos deben monitorear directamente el avance."] },
      3 => { text: "Clima en general aceptable, pero comunicación deficiente.", dictamen: "Ambiente pasivo pero funcional; el riesgo está en que problemas no hablados estallen bajo momentos de alta presión.", recs: ["Instaurar junta semanal operativa de equipo (15 min de alineación).", "Crear canal formal y seguro para reportar problemas.", "Definir tiempos límite de respuesta interna inter-áreas."] },
      4 => { text: "Ambiente positivo, de respeto y colaboración normal.", dictamen: "Cultura sana que protege la estabilidad operativa; es imperativo no descuidarla frente al crecimiento acelerado.", recs: ["Institucionalizar reconocimientos semanales o mensuales por logros.", "Forzar la convivencia inter-áreas mediante proyectos conjuntos.", "Fijar métrica de Clima Organizacional (semestral mínima)."] },
      5 => { text: "Ambiente excepcional, alto compromiso y orgullo de marca.", dictamen: "Ventaja competitiva interna; el equipo da el 'extra' voluntariamente, defiende a la empresa y atrae talento orgánicamente.", recs: ["Mapear y documentar las prácticas que hacen exitosa la cultura.", "Formar a nuevos líderes exigiendo que repliquen este estilo.", "Celebrar públicamente aniversarios y victorias estratégicas."] }
    }
  }

  # Salvaguarda: Retorna el hash evaluado o un fallback genérico robusto
  result = data.dig(key, score) || { 
    text: "Respuesta no catalogada (Nivel #{score}).", 
    dictamen: "Requiere validación cualitativa directa en sesión estratégica.", 
    recs: ["Agendar diagnóstico de profundidad con consultor asignado."] 
  }

  result
end

  # 3. EVALUACIÓN DE MEMBRESÍA (Clasificación del prospecto)
  # Devuelve texto, opciones y puntaje asociado.
  def get_membership_questions
    {
      "Perfil" => {
        "m1" => {
          text: "¿Cuántos empleados tiene tu empresa (incluyéndote)?",
          options: { "1–3" => 5, "4–10" => 10, "11–30" => 15, "31–100" => 20, "101+" => 20 }
        },
        "m2" => {
          text: "Facturación promedio mensual <br> (últimos 3 meses, en USD)".html_safe,
          options: { "<$200k" => 5, "$200k–$1M" => 10, "$1M–$5M" => 15, "$5M–$15M" => 20, ">$15M" => 20 }
        },
        "m3" => {
          text: "Años operando (desde que empezó a vender)",
          options: { "<1" => 2, "1–3" => 4, "3–7" => 6, "7–15" => 8, "15+" => 10 }
        }
      },
      "Complejidad" => {
        "m4" => {
          text: "¿Cuántas unidades / ubicaciones o <br> frentes operativos tienen?".html_safe,
          options: { "1" => 2, "2–3" => 5, "4–10" => 8, "10+" => 10 }
        },
        "m5" => {
          text: "¿Cuántas líneas de producto / servicio <br> venden activamente?".html_safe,
          options: { "1" => 2, "2–5" => 5, "6–15" => 8, "16+" => 10 }
        },
        "m6" => {
          text: "¿Con qué frecuencia tus clientes te piden condiciones formales y medibles <br> (tiempos garantizados de respuesta / entrega, evidencia, reportes, auditorías o penalizaciones)?".html_safe,
          options: { "Prácticamente nunca" => 3, "A veces" => 6, "Sí, frecuente" => 10 }
        }
      }
    }
  end

  # Método de utilidad para evaluar la membresía recomendada basada en el puntaje
  def get_membership_level(score)
    case score.to_i
    when 0..39
      "Básica"
    when 40..59
      "Gold"
    when 60..100
      "Platinum"
    else
      "No determinada"
    end
  end

  def get_membership_option_text(key, value)
    # Aplanamos el hash de categorías para buscar solo por ID de pregunta (m1, m2, etc)
    all_questions = get_membership_questions.values.reduce({}, :merge)
    question = all_questions[key]

    return value if question.nil? || question[:options].nil?

    # Buscamos la clave (texto) que corresponde al valor numérico guardado
    # Usamos to_i porque en el helper los valores son enteros (5, 10...)
    option_text = question[:options].key(value.to_i)

    option_text || value # Si no lo encuentra, devuelve el número original por seguridad
  end

  # 4. BUSCADOR DE TEXTO (Método de utilidad para el Admin)
  # Recibe una llave (ej: "q1", "a5", "m3") y devuelve la pregunta correspondiente
  def get_question_text(key)
    # Buscamos en el cuestionario narrativo (llaves q1...q30)
    get_categorized_questions.each do |_, questions|
      return questions[key] if questions.key?(key)
    end

    # Buscamos en el autodiagnóstico (llaves a1...a25)
    get_autodiagnostico_questions.each do |_, questions|
      return questions[key] if questions.key?(key)
    end

    # Buscamos en evaluación de membresía (llaves m1...m6)
    get_membership_questions.each do |_, questions|
      return questions[key][:text] if questions.key?(key)
    end

    "Pregunta no identificada (#{key})"
  end

end