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

  # 3. BUSCADOR DE TEXTO (Método de utilidad para el Admin)
  # Recibe una llave (ej: "q1" o "a5") y devuelve la pregunta correspondiente
  def get_question_text(key)
    # Primero buscamos en el cuestionario narrativo (llaves q1...q30)
    get_categorized_questions.each do |_, questions|
      return questions[key] if questions.key?(key)
    end

    # Si no está ahí, buscamos en el autodiagnóstico (llaves a1...a25)
    get_autodiagnostico_questions.each do |_, questions|
      return questions[key] if questions.key?(key)
    end

    "Pregunta no identificada (#{key})"
  end
end