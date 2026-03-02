# Vento Vital - Roadmap Maestro v2

Documento vivo para construir Vento Vital con foco realista:
- Uso principal: bienestar y entrenamiento de colaboradores de Vento Group.
- Uso paralelo: modo personal (self-use) con la misma base de producto.
- Enfoque: app de ejecucion diaria ("HOY") + plan adaptativo explicable.

Fecha de inicio: 2026-03-01
Owner producto: Vento Group / Founder
Estado: Draft operativo

---

## 1. Vision y posicionamiento

Vento Vital no es "otra app de rutinas". Es un sistema operativo de habitos fisicos:
- Convierte objetivos y restricciones del usuario en un plan accionable.
- Lo baja a un timeline diario simple.
- Aprende con datos minimos y hace ajustes pequenos, visibles y explicables.

### 1.1 Tesis
Si la persona abre la app y en menos de 10 segundos entiende "que hago hoy", la adherencia sube.

### 1.2 No es (guardrail de producto)
- No es un dispositivo medico.
- No diagnostica enfermedades.
- No reemplaza atencion medica, nutricional o fisioterapeutica profesional.
- No debe usarse para evaluar desempeno laboral de empleados.

---

## 2. Alcance real: empresa + personal

Para resolver tu necesidad personal sin romper el caso empresa, el producto tendra 2 contextos:

### 2.1 Contexto Personal
- Usuario individual.
- Datos privados solo para el usuario.
- Enfasis en adherencia, progresion y salud general.

### 2.2 Contexto Equipo (Vento Group)
- Uso voluntario para bienestar.
- Datos visibles al administrador solo agregados y anonimizados.
- Prohibido mostrar datos individuales a managers de linea.
- Prohibido usar datos para decisiones de RRHH o compensacion.

### 2.3 Regla critica de confianza
Separacion estricta entre:
- Datos de bienestar (Vital).
- Datos laborales (asistencia, productividad, evaluaciones, etc.).

---

## 3. Usuarios objetivo (Jobs To Be Done)

### 3.1 Segmentos principales
- Salud general: mas energia, mejor sueno, moverse mas.
- Perdida de grasa: bajar grasa manteniendo musculo.
- Hipertrofia: ganar masa.
- Fuerza: mejorar PRs / 1RM.
- Deportista mixto: deporte + fuerza complementaria.
- Minimalista: solo quiere una lista clara de hoy.

### 3.2 JTBD central
"Cuando tengo un objetivo fisico pero poco tiempo mental, quiero que la app me diga exactamente que hacer hoy y me ajuste el plan sin volverlo complicado."

---

## 4. Principios de producto (no negociables)

1. Simplicidad operativa diaria.
2. Personalizacion progresiva (sin friccion inicial).
3. Ajustes explicables (nada de cambios "magicos").
4. Seguridad primero (filtros de riesgo antes de recomendar carga).
5. Privacidad por diseno.
6. Calidad medible por KPIs, no por sensacion.

---

## 5. Modos de uso

### 5.1 Modo Ejecutor (default)
- Pantalla principal HOY.
- Checklist y registro minimo.
- Cero configuracion durante el dia.

### 5.2 Modo Disenador (avanzado)
- Editar plantillas, reglas, progresiones, nutricion opcional.
- Visible solo para usuarios avanzados o coaches.

### 5.3 Modo Empresa (switch de capacidades)
- Mismas funciones base.
- Reportes internos solo agregados.
- Hard-block para exportar datos sensibles individuales.

---

## 6. Seguridad, riesgo legal y cumplimiento minimo viable

Esta seccion se implementa desde Fase 0, no al final.

### 6.1 Posicion regulatoria del producto
- Clasificacion inicial: app de bienestar general (no medico).
- Todas las recomendaciones deben estar redactadas como guia de entrenamiento/estilo de vida.
- Evitar lenguaje de diagnostico o tratamiento clinico.

### 6.2 Safety Gate obligatorio en onboarding
Antes de generar plan:
- Preguntas de aptitud fisica basicas (tipo PAR-Q+ simplificado).
- Red flags: dolor toracico, mareos severos, lesion aguda, poscirugia, embarazo de riesgo, etc.
- Si hay red flags: bloqueo de plan intenso + recomendacion explicita de consulta profesional.

### 6.3 Suplementos (guardrail fuerte)
- Fase temprana: solo recordatorios de suplementos definidos por el usuario.
- Prohibido recomendar dosificaciones medicas.
- Prohibido combinar recomendaciones para menores de edad.

### 6.4 IA (Form Check / Body Scan)
- Opt-in explicito.
- Consentimiento separado por modulo.
- Procesamiento on-device cuando sea posible.
- Mostrar nivel de confianza de resultado.
- Nunca mostrar conclusiones clinicas.

### 6.5 Privacidad y datos sensibles
- Consentimiento granular por tipo de dato.
- Cifrado en transito y en reposo.
- Politica de retencion y borrado total por usuario.
- Registro de auditoria de accesos administrativos.
- Separacion de llaves por entorno (dev/staging/prod).

### 6.6 Empleados y riesgo laboral
- Uso voluntario y documentado.
- Transparencia de para que se usan los datos.
- Reportes individuales solo para el propio usuario.
- Reportes para empresa solo agregados, anonimos y con umbral minimo de muestra.

### 6.7 Fatiga y carga (alcance de responsabilidad)
- El score de fatiga es un indicador de entrenamiento, no una evaluacion clinica.
- La app sugiere reducir/ajustar carga, pero no emite diagnosticos medicos.
- Si aparecen sintomas de riesgo (dolor agudo persistente, mareo, dolor toracico), bloquear sesion y recomendar atencion profesional.
- Toda recomendacion automatica debe incluir nivel de confianza y razon de cambio.

---

## 7. Arquitectura funcional

### 7.1 Dominio de datos (v1)
- `User`
- `HealthProfile`
- `GoalProfile`
- `AvailabilityProfile`
- `Program`
- `ProgramVersion`
- `TaskTemplate`
- `TaskInstance`
- `SessionLog`
- `BodyMetrics`
- `WeeklyReview`
- `AdaptiveDecisionLog`
- `NotificationPlan`
- `ConsentRecord`
- `MuscleLoadSnapshot`
- `RecoverySignal`
- `FatigueScore`
- `ReadinessScore`
- `WearableSync`
- `GameProfile`
- `XPEvent`
- `LevelState`
- `Badge`
- `Season`
- `LeagueMembership`
- `WeeklyLeaderboardSnapshot`
- `Squad`
- `SquadMembership`
- `Challenge`
- `ChallengeProgress`
- `FairPlayEvent`

### 7.2 Motor central
- Plan Builder (seleccion de arquetipo + parametrizacion).
- Rules Engine (frecuencias y reprogramacion flexible).
- Autopilot (ajustes pequenos con limites).
- Game Engine (puntos, niveles, ligas, retos, fair-play).

### 7.3 Regla tecnica clave
Ningun ajuste automatico se aplica sin:
- Validar seguridad.
- Registrar razon del cambio.
- Registrar impacto esperado.

---

## 8. Onboarding progresivo (universal)

### 8.1 Nivel 1 - Quick Start (30-60s, obligatorio)
- Objetivo principal.
- Dias disponibles por semana (2-6).
- Tiempo por sesion (20-90 min).
- Equipo disponible.
- Nivel de experiencia.

Salida: plan base funcional desde el minuto 1.

### 8.2 Nivel 2 - Guided (opcional, 2-3 min)
- Horario preferido.
- Preferencia nutricional (porciones/macros).
- Lesiones/limitaciones.
- Actividad recurrente (deporte, caminatas, clases, etc.).

### 8.3 Nivel 3 - Pro (opcional)
- Priorizaciones musculares.
- Tolerancia de volumen.
- Reglas de recuperacion.
- Parametros avanzados de periodizacion.

---

## 9. Plan Builder (detallado)

### 9.1 Pipeline de generacion
1. Perfil de entrada.
2. Seleccion de arquetipo base.
3. Parametrizacion segun objetivo/tiempo/equipo.
4. Calendarizacion flexible (con o sin hora fija).
5. Materializacion de tareas diarias.

### 9.2 Arquetipos base v1
- Minimal 2 dias.
- Full Body 3 dias.
- Upper/Lower 4 dias.
- Fat-loss 4 dias (fuerza + cardio).
- Strength 3-4 dias.

### 9.3 Parametros que ajusta
- Volumen semanal por grupo muscular.
- Rango de repeticiones.
- Descansos y densidad.
- Cardio minimo efectivo.
- Deload cada 4-6 semanas (segun fatiga/adherencia).
- Sustituciones por equipo disponible.

### 9.4 Explainability obligatoria
Cada plan y cada ajuste mostrara:
- "Que cambio"
- "Por que"
- "Con que datos"

---

## 10. Core UX: HOY

Pantalla HOY siempre priorizada:
- Lista ordenada de tareas accionables.
- Estado de cada tarea: pendiente, en curso, completada, pospuesta.
- Si no hay horario fijo: sugerencia de ventana recomendada.
- Si se pierde un entreno: reprogramacion dentro de semana con limite de carga.

### 10.1 Regla anti-friccion
Maximo 1 decision compleja por sesion de uso diario.

### 10.2 Fallback inteligente
Si el usuario no puede hacer la sesion completa:
- Version 15 min.
- Version 30 min.
- Version completa.

---

## 11. Autopilot (ajuste adaptativo controlado)

### 11.1 Inputs minimos
- Adherencia semanal (%).
- Volumen ejecutado vs planificado.
- RPE/RIR promedio.
- Energia/sueno (check-in rapido).
- Peso/cintura (opt-in).

### 11.2 Outputs permitidos (max 1-3 por semana)
- Subir o bajar volumen.
- Cambiar rep range.
- Reordenar sesiones.
- Ajustar cardio.
- Ajustar porciones/macros si nutricion activa.

### 11.3 Guardrails matematicos
- Limite de cambio por microciclo.
- Minimo de datos para decidir.
- Ventana de suavizado (evitar reaccionar a ruido diario).
- "Cooldown" de ajustes para no oscilar.

### 11.4 Motor de Carga y Fatiga Muscular (Load Intelligence v1)
Objetivo:
- Estimar carga efectiva por grupo muscular y estado de recuperacion para adaptar rutina sin perder progresion.

Inputs por sesion:
- Duracion.
- RPE de sesion.
- Series efectivas por ejercicio.
- Reps y carga (si existen).
- RIR promedio.
- Calidad de sueno/energia (manual, 10 segundos).
- Dolor percibido por grupo muscular (escala simple 0-5).

Inputs opcionales de wearables (v2):
- FC en reposo.
- HRV.
- Sueno total y eficiencia.

Metricas base:
- `Internal Load` = duracion (min) x session RPE.
- `Muscle Stimulus Score` por grupo muscular = series efectivas ponderadas por intensidad relativa.
- `Acute Load` = carga acumulada ultimos 7 dias (EWMA).
- `Chronic Load` = carga acumulada ultimos 28 dias (EWMA).
- `Fatigue Index` = funcion de carga aguda, recuperacion y dolor percibido.
- `Readiness Score` (0-100) por dia.

Reglas de decision v1:
- Si `Fatigue Index` alto en grupo muscular X, reducir 20-40% del volumen de X por 48-72h.
- Si `Readiness Score` bajo, convertir sesion pesada a sesion tecnica o version 30 min.
- Si `Acute/Chronic` supera umbral de seguridad definido, bloquear aumento de carga esa semana.
- Si 2 semanas con buena recuperacion y adherencia alta, permitir progresion incremental.

Explainability en UI:
- "Hoy bajamos 2 series de piernas por fatiga alta (score 78/100) y sueno bajo 2 dias."
- "Mantenemos progresion en torso por buena recuperacion (score 34/100)."

Guardrails duros:
- No aumentar carga semanal total mas de 10-15% sin justificacion fuerte.
- No aplicar mas de 3 cambios estructurales por semana.
- Siempre ofrecer override manual en Modo Disenador con log de auditoria.

---

## 12. Nutricion y suplementos (scope controlado)

### 12.1 Nutricion v1 (simple)
- Sistema por porciones.
- Plantillas de comidas.
- Recordatorios de hidratacion.
- Weekly Review de tendencia (no obsesion diaria).

### 12.2 Suplementos v1 (solo opt-in, recordatorio)
- Stack configurable por usuario.
- Horarios y adherencia.
- Alertas de seguridad basicas (por ejemplo, evitar duplicidad horaria).

### 12.3 Lo que NO entra en v1
- Recomendaciones medicas.
- Prescripcion de dosis clinicas.
- Claims terapeuticos.

---

## 13. IA opcional (cuando haya base solida)

### 13.1 Form Check v1 (antes de Body Scan)
- 6 ejercicios clave.
- Feedback tecnico simple: postura, rango, tempo.
- Score de confianza.
- Recomendaciones no clinicas.

### 13.2 Body Scan v1
- Solo tendencia corporal, no diagnostico.
- Consentimiento separado.
- Transparencia de precision y limites.

---

## 14. KPIs y metricas de exito

### 14.1 North Star Metric
`Weekly Action Completion Rate` = tareas clave completadas / tareas clave planificadas.

### 14.2 KPIs de producto
- Activacion D1: usuario completa onboarding + 1 tarea de HOY.
- Adherencia W2/W4/W8.
- Retencion D30 / D90.
- Completion rate por tipo de tarea.
- Tiempo promedio para completar primera accion (TTFA).

### 14.3 KPIs de resultado (opt-in)
- Tendencia de fuerza (carga o reps en ejercicios base).
- Tendencia de peso/cintura.
- Percepcion de energia y sueno.

### 14.4 KPIs de seguridad y confianza
- % usuarios bloqueados por Safety Gate.
- % ajustes revertidos por fatiga.
- Reportes de recomendaciones no seguras.
- NPS de "confianza en recomendaciones".

### 14.5 KPIs especificos de Load Intelligence
- % sesiones adaptadas por fatiga sin perdida de adherencia semanal.
- Precision percibida del score de fatiga (encuesta post-sesion).
- Reduccion de "sesiones fallidas" por sobrecarga.
- Reduccion de picos de carga no planificados.
- % recomendaciones aceptadas vs ignoradas.

### 14.6 KPIs de gamificacion y competencia saludable
- Participacion semanal en sistema de juego (usuarios activos en retos/ligas).
- Delta de adherencia entre cohortes con juego activado vs control.
- Retencion D30 en usuarios con ligas activadas.
- % usuarios que cambian a modo privado (friccion competitiva).
- % flags de fair-play por cada 1.000 sesiones.
- `Wellbeing Guardrail Rate`: % usuarios que reciben ajuste de carga y mantienen adherencia.

---

## 15. Roadmap por fases (con Definition of Done)

## Fase -1: Discovery, riesgo y base legal (2 semanas)
Objetivo:
- Definir marco de bienestar no medico + uso interno voluntario.

Entregables:
- Politica de uso y disclaimers.
- Consentimientos por modulo.
- Matriz de riesgos (producto, legal, datos, reputacion).

DoD:
- Documento legal validado.
- Flujos de consentimiento disenados.

Salida KPI:
- 100% features clasificados por riesgo.

---

## Fase 0: Fundaciones tecnicas (3-4 semanas)
Objetivo:
- Crear base robusta para escalar sin deuda toxica.

Entregables:
- Arquitectura Domain/Data/UI separada.
- Modelo Program + TaskTemplate + TaskInstance + ProgramVersion.
- Rules Engine v1 (daily/weekly/every-other-day/flexible-within-week).
- Notificaciones locales.
- Telemetria base y feature flags.

DoD:
- Cobertura de pruebas en logica critica.
- Logs de eventos clave funcionando.
- Versionado de programas activo.

Salida KPI:
- Crash-free sessions > 99.5% en alpha.

---

## Fase 1: Producto usable (4 semanas)
Objetivo:
- Entregar valor diario sin complejidad.

Entregables:
- Pantalla HOY.
- Checklist + snooze + reprogramar.
- Biblioteca starter (2-6 dias).
- Registro minimo: hecho/no + RPE simple + peso opcional.

DoD:
- Usuario nuevo completa primer dia en menos de 5 min.
- Reprogramacion semanal estable.

Salida KPI:
- Activacion D1 >= 55%.
- Completion semanal >= 45% en alpha interna.

---

## Fase 2: Entrenamiento serio (4-5 semanas)
Objetivo:
- Elevar calidad de ejecucion del entreno.

Entregables:
- Sesion en vivo (sets, reps, carga, RIR, timer).
- Progresion deterministica por ejercicio.
- Sustituciones por equipo rule-based.

DoD:
- No se pierde historial de sesion.
- Progresion aplica segun reglas definidas.

Salida KPI:
- >= 70% sesiones registradas con datos completos.

---

## Fase 2B: Game Loop v1 (2-3 semanas)
Objetivo:
- Introducir motivacion ludica sin aumentar riesgo ni complejidad.

Entregables:
- XP por tareas de HOY (entreno, recovery, sueno, adherencia).
- Niveles personales y badges base.
- Streak inteligente con "pausa protegida" por enfermedad/fatiga alta.
- Retos personales semanales (sin ranking social aun).

DoD:
- El juego no agrega mas de 1 tap extra al flujo diario.
- No se otorgan puntos por sobrepasar limites de seguridad.
- El usuario puede desactivar elementos competitivos.

Salida KPI:
- +8 a +12 puntos de completion semanal vs cohorte sin juego.

---

## Fase 3: Plan Builder universal (5-6 semanas)
Objetivo:
- Generacion automatica robusta para perfiles diversos.

Entregables:
- Onboarding Quick + Guided.
- Seleccion de arquetipo + parametrizacion.
- Explainability de plan generado.

DoD:
- Test matrix de casos edge aprobada.
- Sin planes invalidos en QA.

Salida KPI:
- >= 80% usuarios perciben plan "adecuado a mi realidad".

---

## Fase 4: Weekly Review + nutricion simple (4 semanas)
Objetivo:
- Cerrar loop de mejora semanal con baja friccion.

Entregables:
- Weekly Review automatizada.
- Nutricion por porciones.
- Regla "14 dias sin cambio -> ajuste puntual".

DoD:
- Ajustes semanales visibles y explicados.
- Sin cambios extremos de una semana a otra.

Salida KPI:
- +10 puntos en adherencia W4 vs Fase 1.

---

## Fase 5: Autopilot avanzado + Load Intelligence v1 (4-6 semanas)
Objetivo:
- Ajuste adaptativo estable y seguro.

Entregables:
- Motor de ajustes con limites por microciclo.
- AdaptiveDecisionLog para trazabilidad.
- UI de "que cambio y por que".
- Motor de carga/fatiga por grupo muscular (sin wearables obligatorios).
- Readiness Score diario y reglas de degradacion de sesion (full -> 30 min -> tecnica).

DoD:
- Max 1-3 cambios/semana.
- Cero oscilacion por ruido en simulaciones.
- Ninguna recomendacion supera limite de carga semanal definido.
- Ajustes por fatiga explicados en lenguaje simple en HOY.

Salida KPI:
- Mejora de adherencia en cohortes con autopilot activado.
- Disminucion de sesiones interrumpidas por fatiga alta.

---

## Fase 6: Sync y multi-device (3 semanas)
Objetivo:
- Evitar perdida de progreso y mejorar continuidad.

Entregables:
- Backup/restore seguro.
- Sincronizacion entre dispositivos.
- Resolucion de conflictos basica (last-write + merge rules).

DoD:
- Migracion entre dispositivos sin perdida de datos criticos.

Salida KPI:
- Churn por cambio de dispositivo < 5%.

---

## Fase 7: Form Check IA (opt-in) (6+ semanas)
Objetivo:
- Mejorar tecnica sin friccion.

Entregables:
- Analisis de 6 ejercicios base.
- Feedback tecnico resumido + score de confianza.

DoD:
- Precision minima definida por benchmark interno.
- Consentimiento separado funcional.

Salida KPI:
- >= 60% usuarios de Form Check reportan utilidad alta.

---

## Fase 8: Body Scan IA (opt-in) (6+ semanas)
Objetivo:
- Medicion adicional de tendencia corporal para usuarios avanzados.

Entregables:
- Flujo de captura, tendencia y confianza.
- Politica de retencion especifica de imagenes.

DoD:
- Explicaciones de limitaciones visibles.
- Controles de privacidad auditables.

Salida KPI:
- Adopcion saludable sin afectar confianza general.

---

## Fase 9: Track empresa (separado de core B2C)
Objetivo:
- Bienestar corporativo sin invadir privacidad individual.

Entregables:
- Dashboards anonimizados por equipo.
- Reportes de adopcion y adherencia agregada.
- Controles de acceso por rol.

DoD:
- No existe forma de ver datos individuales de salud desde panel manager.

Salida KPI:
- Programas activos por sede/area.

---

## 16. Criterios de calidad mundial (Top Tier)

Para considerar Vento Vital "Top Mundial", debe cumplir:
- Producto: experiencia diaria superior a apps promedio en TTFA y adherencia.
- Ciencia aplicada: progresiones y ajustes explicables y estables.
- Seguridad: cero recomendaciones peligrosas detectadas en QA + guardrails activos.
- Privacidad: controles auditables, consentimiento claro, borrado real.
- Ingenieria: crash-free > 99.7%, observabilidad completa, releases predecibles.

---

## 17. Matriz de pruebas obligatoria

### 17.1 Casos funcionales
- Cambios de objetivo (fuerza -> fat loss).
- Reduccion abrupta de tiempo disponible.
- Lesion reportada a mitad de programa.
- Semana con 0 adherencia.
- Reprogramaciones multiples.

### 17.2 Casos de seguridad
- Usuario con red flag en onboarding.
- Fatiga alta + sueno bajo + RPE alto.
- Intento de sobrecarga no segura.

### 17.3 Casos de datos y sync
- Offline prolongado.
- Dos dispositivos editando mismo dia.
- Restore tras reinstalacion.

---

## 18. Lo que se recorta para mantener foco

No entra antes de PMF:
- Marketplace complejo de programas.
- Comunidad social masiva.
- Gamificacion social masiva sin guardrails de salud, privacidad y fair-play.
- Recomendaciones avanzadas de suplementos.
- Expansiones corporativas profundas.

---

## 19. Plan de ejecucion de los proximos 90 dias

### Sprint 1-2
- Fase -1 completa.
- Fase 0 iniciada con modelo de datos y telemetry.

### Sprint 3-4
- HOY funcional.
- Checklist, snooze, reprogramacion.
- Alpha interna con 10-20 usuarios.

### Sprint 5-6
- Sesion en vivo v1.
- Progresion deterministica.

### Sprint 7-8
- Onboarding Quick/Guided + Plan Builder v1.
- Weekly Review inicial.
- Game Loop v1 (XP, niveles, badges, retos personales).

Meta 90 dias:
- Producto util diario para colaboradores y uso personal.
- Base segura para escalar sin deuda estructural.

---

## 20. Decisiones que se deben cerrar esta semana

1. Definir politica exacta de uso interno voluntario (empresa).
2. Acordar alcance legal minimo del Safety Gate.
3. Congelar arquetipos iniciales del Plan Builder (max 5).
4. Congelar KPIs de salida por fase.
5. Aprobar stack tecnico y estrategia de telemetry.
6. Aprobar reglas de puntuacion y limites de fair-play.

---

## 21. Resumen ejecutivo final

La vision original sigue viva, pero ahora tiene estructura de ejecucion real:
- Core diario fuerte (HOY).
- Personalizacion progresiva real.
- Autopilot explicable.
- Seguridad y legal incorporados desde el inicio.
- Camino claro para escalar a empresa sin romper privacidad.

Este documento es la base para construir una app de nivel mundial sin perder foco.

---

## 22. Innovaciones "Top Mundial" (backlog priorizado)

Estas innovaciones se activan por etapas, sin romper foco del producto base.

### 22.1 Prioridad alta (post Fase 5)
- `Dynamic Session Morphing`: la sesion se auto-adapta en tiempo real (pesada -> moderada -> tecnica) segun fatiga durante la ejecucion.
- `Muscle Heatmap`: mapa corporal con carga acumulada y estado de recuperacion por grupo muscular.
- `Recovery Prescription`: recomendaciones concretas de recuperacion (movilidad, sueno, hidratacion, descarga activa) basadas en score.
- `Smart Deload`: deload automatico contextual, no solo por calendario fijo.

### 22.2 Prioridad media (post Fase 6)
- `Wearable Fusion`: fusion de HRV, FC reposo, sueno y carga interna para mejorar precision del Readiness Score.
- `Performance Forecast`: prediccion de rendimiento por ejercicio para la proxima sesion.
- `Plateau Detector`: detector de estancamiento con propuestas de cambio (volumen, intensidad, frecuencia o ejercicio).

### 22.3 Prioridad avanzada (post Fase 7/8)
- `Digital Twin de entrenamiento`: simulador de escenarios ("si subo volumen de espalda 2 semanas, que impacto esperado tengo").
- `Technique + Load Co-Pilot`: combinar Form Check con estado de fatiga para ajustar no solo cuanto entrenar, sino como ejecutar.
- `Context-Aware Planning`: adaptar el dia segun contexto real (poco sueno, turno largo, viaje, enfermedad leve reportada).

### 22.4 Regla de oro para innovar
No se lanza ninguna "feature wow" si degrada:
- claridad en HOY,
- seguridad,
- privacidad,
- adherencia semanal.

---

## 23. Sistema de juego competitivo (Game System v1-v3)

Objetivo:
- Volver la salud y el entrenamiento mas divertidos y constantes.
- Competir de forma justa sin premiar conductas riesgosas.

### 23.1 Principios de diseno del juego
- Competencia por progreso relativo, no por genetica.
- Recompensar constancia y recuperacion inteligente, no solo volumen bruto.
- El usuario decide su nivel de exposicion social: privado, amigos, equipo.
- Ninguna mecanica de juego puede empujar sobreentrenamiento.

### 23.2 Puntuacion base (v1)

Unidades:
- `XP` para nivel personal.
- `Vital Score` semanal (0-1000) para ligas.

XP por tarea diaria (referencia inicial):
- Entreno completado segun plan: 40 XP.
- Recovery/sueno completado: 20 XP.
- Check-in de energia/fatiga: 10 XP.
- Weekly Review completada: 30 XP.

Multiplicadores:
- `Consistency Multiplier` (1.0 a 1.4) por adherencia semanal.
- `Safety Multiplier` (0.6 a 1.0) si el usuario ignora alertas de seguridad.
- `Fair-Play Multiplier` (0.0 a 1.0) si se detecta comportamiento anomalo.

Formula:
- `XP Final = XP Base x Consistency x Safety x FairPlay`

### 23.3 Vital Score (ranking semanal)

Componentes:
- 45% adherencia al plan.
- 25% progreso relativo a su baseline personal.
- 20% recuperacion/sueno/fatiga gestionada.
- 10% fair-play y calidad de registro.

Regla de salud:
- Si el usuario excede limites de carga definidos por motor de fatiga, el score semanal se recorta y se activa recomendacion de descarga.

### 23.4 Niveles y categorias personales

Niveles (ejemplo inicial):
- L1-L5: Rookie.
- L6-L12: Consistente.
- L13-L20: Avanzado.
- L21+: Elite sostenible.

Diseno clave:
- Subir de nivel da desbloqueos cosmeticos, retos y analiticas.
- No da permisos para entrenar mas agresivo por defecto.

### 23.5 Ligas competitivas (v2)

Estructura:
- Bronce, Plata, Oro, Platino, Titan.
- Temporadas de 6-8 semanas.
- Ranking semanal dentro de grupos de tamano similar.

Promocion/descenso:
- Top 20% asciende.
- Bottom 15% desciende.
- Zona media se mantiene.

Regla de justicia:
- Emparejar por "capacidad inicial" y adherencia historica, no por peso corporal.

### 23.6 Squads y competencia por equipos (v2)

Formato:
- Equipos de 4-8 usuarios.
- Score de equipo basado en mediana + bonus por participacion amplia (evita depender de un solo crack).

Eventos:
- "Semana de consistencia".
- "Reto de recuperacion inteligente".
- "Reto anti-sedentarismo".

### 23.7 Retos (v1-v3)

Tipos:
- Personal: objetivo individual.
- Social: con amigos/squad.
- Corporativo: por sede/area en modo anonimo.

Duraciones:
- Flash (24-72h), semanal, quincenal.

Premios:
- Badges, titulos, acceso a retos especiales, recompensas internas no monetarias.

### 23.8 Fair-play y anti-cheat

Flags automaticos:
- Volumen/carga imposible vs historial reciente.
- RPE incoherente con carga reportada.
- Multiples sesiones duplicadas en ventana corta.
- Patron repetitivo no humano.

Respuesta del sistema:
- Flag suave: score congelado + pedir confirmacion.
- Flag medio: multiplicador fair-play reducido.
- Flag alto: exclusion temporal de leaderboard y revision.

### 23.9 Guardrails de bienestar (critico)

- Sin ranking de peso corporal.
- Sin ranking de apariencia fisica.
- Sin recompensas por entrenar lesionado o con fatiga critica.
- "Pausa protegida" por enfermedad, lesion o fatiga alta para no romper streak.
- Opcion "modo privado permanente".

### 23.10 UX del juego dentro de HOY

Elementos minimos:
- Barra de progreso diaria (XP ganado hoy).
- Objetivo semanal visible.
- Estado de liga (si aplica).
- Explicacion corta de por que gano/perdio puntos.

Regla UX:
- Maximo 1 bloque de juego en HOY; nunca debe tapar tareas de salud.

### 23.11 Modelo de datos minimo para juego

Tablas clave:
- `game_profiles`
- `xp_events`
- `level_states`
- `seasons`
- `league_memberships`
- `weekly_leaderboard_snapshots`
- `challenges`
- `challenge_progress`
- `fair_play_events`

### 23.12 Plan de rollout

v1 (post Fase 2):
- XP + niveles + badges + retos personales.

v2 (post Fase 5):
- Ligas, temporadas, squads y fair-play avanzado.

v3 (post Fase 6):
- Competencia corporativa anonima + eventos especiales por sede.
