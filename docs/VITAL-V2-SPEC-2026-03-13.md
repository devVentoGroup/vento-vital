# Vento Vital - V2 Spec 2026-03-13

Estado: `draft de ejecucion`

Depende de:

- `docs/VITAL-ROADMAP-MAESTRO-2026-03-13.md`
- `docs/VITAL-V1-SPEC-2026-03-13.md`
- `docs/VITAL-CORE-MODEL-2026-03-13.md`

Objetivo de este documento: definir `V2` como la capa de entorno real de entrenamiento para que Vital deje de recomendar en abstracto y empiece a entender con que recursos cuenta realmente la persona.

---

## 1. Objetivo exacto de V2

`V2` convierte el entorno de entrenamiento en un dominio real del producto.

La pregunta que `V2` responde es:

> "Donde entrenas, con que entrenas y cuales son las limitaciones reales de ese entorno?"

Si `V1` resuelve identidad visual y operacion diaria, `V2` resuelve la infraestructura real sobre la que luego el motor adaptativo debe decidir.

---

## 2. Resultado esperado al terminar V2

Cuando `V2` este bien implementada, Vital deberia poder:

- manejar uno o varios perfiles de entrenamiento
- distinguir entre gym grande, gym pequeño, casa, hotel u otros contextos
- saber que equipamiento existe y cual no
- buscar y activar recursos reales del entorno
- usar ese contexto como restriccion para futuras recomendaciones y sustituciones

El usuario deberia sentir:

- "Esta app entiende mi realidad"
- "No me esta sugiriendo ejercicios imposibles"
- "Puedo cambiar de contexto sin romper el sistema"

---

## 3. No objetivos de V2

Para no mezclar fases, `V2` no debe incluir aun:

- generacion completa de rutina por entorno
- sustituciones automaticas avanzadas en todos los casos
- logica profunda de progreso por maquina
- sincronizacion con sensores o inventario externo
- recomendacion nutricional por entorno
- analitica avanzada de uso del equipamiento
- IA sobre catalogo o fotos de equipos

`V2` define y captura el entorno.
`V4` y versiones posteriores lo explotaran plenamente.

---

## 4. North Star de UX

La experiencia base de `V2` debe sentirse asi:

> "Configurar mi entorno es facil, tecnico y realista; y cada seleccion que hago tiene un impacto claro en lo que Vital podra recomendarme."

Consecuencias practicas:

- listas densas
- categorias claras
- busqueda siempre visible
- activacion y desactivacion rapida
- edicion minima por item
- cero UI blanda o confusa

---

## 5. Tesis de producto para V2

El entrenamiento no ocurre en el vacio.

Dos personas con el mismo objetivo pueden necesitar rutinas completamente distintas si cambian:

- el lugar donde entrenan
- el tiempo real que tienen
- el equipamiento disponible
- las restricciones del espacio

Por eso `EnvironmentProfile` no es una preferencia secundaria.
Es una pieza estructural del sistema.

---

## 6. Casos de uso que V2 debe soportar

### 6.1 Una persona entrena en varios lugares

Ejemplo:

- gimnasio comercial entre semana
- casa el fin de semana

Vital debe permitir varios perfiles y cambiar entre ellos.

### 6.2 El usuario tiene un gym limitado

Ejemplo:

- solo smith
- bandas
- mancuernas
- sin poleas

Vital debe reconocer esa limitacion.

### 6.3 El usuario viaja

Ejemplo:

- hotel con cinta y poco mas

Vital debe permitir activar un perfil temporal.

### 6.4 El usuario quiere afinar detalles

Ejemplo:

- si hay prensa, pero no hack squat
- si hay battle ropes, pero no air bike

Vital debe trabajar a nivel de recurso real, no solo tipo de gym.

---

## 7. Entidades de V2

## 7.1 `training_environment_profile`

Representa un contexto real de entrenamiento.

Campos conceptuales:

- `id`
- `user_id`
- `name`
- `color_token`
- `environment_type`
- `is_primary`
- `is_active`
- `notes`
- `created_at`
- `updated_at`

Valores sugeridos para `environment_type`:

- `full_gym`
- `small_gym`
- `home_gym`
- `outdoor`
- `hotel`
- `limited_access`
- `other`

### Reglas

- un usuario puede tener varios perfiles
- solo uno puede ser `primary`
- un perfil puede archivarse sin borrarse

## 7.2 `equipment_category`

Agrupa recursos por familia.

Categorias iniciales sugeridas:

- `selectorized_machines`
- `plate_loaded_machines`
- `cable_machines`
- `free_weights`
- `bars`
- `benches`
- `bands`
- `cardio`
- `bodyweight`
- `functional`
- `recovery_tools`

## 7.3 `equipment_item_catalog`

Catalogo maestro compartido de recursos.

Campos conceptuales:

- `id`
- `category_key`
- `key`
- `label`
- `aliases`
- `movement_patterns`
- `supports_load`
- `supports_unilateral`
- `supports_cardio_metrics`
- `sport_tags`
- `default_metadata`

Ejemplos iniciales sacados de tus referencias:

- `maquina_press_hombros`
- `maquina_remo`
- `maquina_aductores`
- `maquina_gluteos`
- `poleas_cruzadas`
- `polea_alta_baja`
- `smith_machine`
- `battle_ropes`
- `cuerda_saltar`
- `bicicleta_estatica`
- `eliptica`
- `cinta_correr`
- `ski_erg`
- `air_bike`
- `bandas_elasticas`
- `bandas_mini`

## 7.4 `profile_equipment_item`

Relacion entre perfil y recurso.

Campos conceptuales:

- `profile_id`
- `equipment_item_id`
- `is_available`
- `custom_label`
- `starting_load_kg_optional`
- `condition_state`
- `notes`
- `updated_at`

### Reglas

- el catalogo no se duplica por usuario
- la disponibilidad si se guarda por perfil
- la customizacion debe ser minima en V2

## 7.5 `profile_constraints`

Restricciones del contexto.

Campos conceptuales:

- `profile_id`
- `session_space_level`
- `noise_limit`
- `impact_limit`
- `ceiling_limit`
- `drop_weights_allowed`
- `outdoor_access`
- `climate_exposure`
- `default_session_time_min`

En `V2` esto puede empezar simple y ampliarse despues.

---

## 8. Pantallas de V2

## 8.1 `Entornos`

Lista de perfiles de entrenamiento.

### Debe mostrar

- nombre del perfil
- tipo de entorno
- color
- cantidad de equipos activos
- si es perfil principal

### Acciones

- crear perfil
- editar perfil
- activar como principal
- archivar

### Resultado UX esperado

Pantalla corta, clara y operativa.
No dashboard.
No marketing.

## 8.2 `Crear / Editar Perfil`

Pantalla simple para definir un perfil de entrenamiento.

### Campos minimos

- nombre del perfil
- tipo de entorno
- color
- principal o no
- nota opcional

### Principio UX

Debe sentirse como configuracion seria, no como onboarding blando.

## 8.3 `Seleccionar Tipo de Entorno`

Pantalla de opciones en lista.

Opciones iniciales:

- gimnasio grande
- gimnasio pequeño
- casa
- outdoor
- hotel
- otro

Cada opcion debe explicar brevemente que representa.

## 8.4 `Equipamiento del Perfil`

Es la pantalla mas importante de `V2`.

### Debe incluir

- header con nombre del perfil
- buscador siempre visible
- lista agrupada por categoria
- filas por recurso
- check o toggle fuerte de disponibilidad
- accion secundaria `Editar` si aplica
- `Editar todo` por categoria cuando tenga sentido

### Cada fila debe mostrar

- imagen o placeholder
- nombre del recurso
- metadato secundario corto
- accion `Editar`
- estado disponible / no disponible

### Comportamiento esperado

- check activa o desactiva
- buscar filtra por nombre y alias
- categorias pueden colapsarse a futuro, pero no es obligatorio en V2

## 8.5 `Editar Recurso`

Pantalla minima para detalles por item.

### Campos posibles

- nombre personalizado
- disponibilidad
- carga inicial sugerida
- notas

No debe crecer demasiado en `V2`.

---

## 9. Flujo principal de usuario

1. entrar a `Perfil` o `Entornos`
2. crear perfil nuevo
3. definir nombre, color y tipo
4. abrir `Equipamiento del perfil`
5. buscar y activar recursos disponibles
6. guardar perfil como principal si aplica
7. dejar ese perfil listo para alimentar el sistema

---

## 10. Reglas de negocio de V2

### 10.1 Reglas de perfiles

- un usuario puede tener multiples perfiles
- solo uno puede ser principal
- un perfil inactivo no debe usarse para recomendaciones por defecto

### 10.2 Reglas de equipamiento

- si un recurso no existe en el perfil, no debe asumirse disponible
- el catalogo maestro debe ser unico
- la seleccion es por perfil, no global

### 10.3 Reglas de consistencia

- cambiar de perfil cambia el universo de recursos disponibles
- perfiles distintos pueden compartir parte del catalogo
- no se deben crear duplicados innecesarios del mismo equipo

### 10.4 Reglas de impacto futuro

Estas reglas pueden no disparar cambios visibles aun, pero deben quedar preparadas:

- si un ejercicio necesita recurso no disponible, el motor futuro no debe usarlo como opcion principal
- si el entorno es `hotel` o `limited_access`, Vital debera favorecer sesiones compatibles
- si solo existe equipamiento cardio, Vital debe reconocer esa realidad y no insistir con fuerza basada en maquinas inexistentes

---

## 11. Catalogo inicial recomendado

Para no desbordar `V2`, conviene empezar con un catalogo fuerte pero limitado.

### 11.1 Selectorized machines

- press de pecho
- press de hombros
- remo
- jalon al pecho
- aductores
- abductores
- gluteos
- curl de pierna
- extension de pierna
- gemelos
- rotacion de torso

### 11.2 Plate loaded machines

- prensa
- smith
- remo alto
- remo bajo
- press inclinado
- press horizontal
- jalon
- predicador
- hip thrust

### 11.3 Cable machines

- poleas cruzadas
- polea alta baja
- jalon de polea
- remo en polea

### 11.4 Cardio

- bicicleta estatica
- eliptica
- remo
- cinta
- escaladora
- ski erg
- air bike

### 11.5 Functional / accessories

- battle ropes
- cuerda para saltar
- bandas elasticas
- bandas mini

### 11.6 Free weight essentials

- barra corta
- barra hexagonal
- mancuernas
- discos
- banco plano
- banco ajustable

---

## 12. Reglas de UX visual para V2

`V2` debe heredar la direccion de `V1`.

### Debe sentirse

- oscuro
- tecnico
- ordenado
- preciso
- rapido

### Debe evitar

- cards gigantes para cada item
- formularios esponjosos
- exceso de color
- informacion redundante

### Regla de densidad

Las listas de equipamiento deben sentirse cercanas a:

- inventario util
- catalogo configurable
- biblioteca tecnica

No deben sentirse como:

- onboarding emocional
- ecommerce
- red social

---

## 13. Integracion con el Core Model

`V2` aterriza principalmente este dominio:

- `EnvironmentProfile`

Y empieza a conectar con:

- `SportProfile`
- `RoutineEngine`
- `ExplanationEngine`

Impacto conceptual:

- `EnvironmentProfile` restringe el universo de ejercicios posibles
- `RoutineEngine` usara luego esa informacion para sustituciones y seleccion
- `ExplanationEngine` podra decir por que se eligio una variante compatible con el entorno

---

## 14. Archivos y zonas probables de implementacion

UI actual a tocar o extender:

- `apps/mobile/src/screens/ProfileScreen.js`
- nuevas pantallas dentro de `apps/mobile/src/screens/`
- nuevas features dentro de `apps/mobile/src/features/`
- `apps/mobile/src/components/`
- `apps/mobile/src/theme/vitalTheme.js`

Modelo y contratos futuros:

- `packages/contracts`
- `supabase` o API correspondiente

---

## 15. Orden de implementacion recomendado

1. definir entidades y contrato minimo
2. crear `Entornos`
3. crear `Crear / Editar Perfil`
4. crear `Equipamiento del Perfil`
5. agregar buscador y activacion por item
6. agregar `Editar Recurso`
7. conectar perfil principal con estado de usuario

Regla:

no intentar resolver recomendaciones automaticas completas dentro de `V2`.

---

## 16. Riesgos de V2

### 16.1 Riesgo: catalogo demasiado grande demasiado temprano

Mitigacion:

- comenzar con un catalogo base fuerte, no infinito

### 16.2 Riesgo: V2 se convierta en inventario sin impacto

Mitigacion:

- dejar claro desde UX y producto que esta configuracion alimenta futuras recomendaciones

### 16.3 Riesgo: demasiada friccion al configurar

Mitigacion:

- permitir seleccion rapida
- no exigir metadatos complejos en cada item

### 16.4 Riesgo: mezcla rara entre V1 y V2

Mitigacion:

- respetar el lenguaje visual de V1
- no introducir otra identidad ni otro sistema de componentes

---

## 17. Criterio de aceptacion final

`V2` se considera exitosa si:

- el usuario puede crear y gestionar varios entornos reales
- puede registrar equipamiento disponible de manera rapida
- el sistema ya queda listo para usar ese contexto en decisiones futuras
- la UI se mantiene tecnica, clara y Vento
- Vital se acerca mas a un sistema real y menos a una app abstracta

---

## 18. Lo que sigue despues de V2

Documentos siguientes sugeridos:

1. `VITAL-V3-SPEC.md`
   - estado diario real
   - sueño, energia, estres, dolor, tiempo disponible

2. `VITAL-DECISION-RULES-v1.md`
   - reglas iniciales de sustitucion por entorno
   - bloqueos y elegibilidad
   - priorizacion minima

Recomendacion:

despues de `V2`, el siguiente paso mas poderoso es `V3`, porque ahi Vital empieza a combinar entorno real con estado real del dia.
