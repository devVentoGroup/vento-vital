# Vento Vital - Catalog Seed v1 2026-03-13

Estado: `draft de ejecucion`

Depende de:

- `docs/VITAL-EXERCISE-CATALOG-SPEC-2026-03-13.md`
- `docs/VITAL-CORE-MODEL-2026-03-13.md`
- `docs/VITAL-V2-SPEC-2026-03-13.md`
- `docs/VITAL-DECISION-RULES-v1-2026-03-13.md`

Proposito: aterrizar el catalogo maestro de Vital en una primera semilla concreta y utilizable para producto, priorizando amplitud real, compatibilidad con muchos entornos y utilidad para el motor adaptativo.

---

## 1. Objetivo de la semilla v1

La semilla `v1` no intenta contener todos los ejercicios del mundo.

Si intenta:

- cubrir los patrones mas importantes
- cubrir los equipos mas comunes
- cubrir sustituciones realistas
- cubrir fuerza, hipertrofia, cardio, potencia, movilidad y recuperacion
- permitir una primera generacion de planes y alternativas con criterio

En otras palabras:

esta semilla debe ser lo bastante amplia para que Vital ya se sienta inteligente, aunque todavia no tenga la cola larga completa del catalogo final.

---

## 2. Criterios de inclusion

Un ejercicio o equipo entra en la semilla `v1` si cumple al menos una de estas condiciones:

1. aparece con frecuencia en gym comercial o home gym
2. cubre un patron clave
3. sirve como sustituto util de otros ejercicios
4. tiene alta utilidad para varios objetivos
5. es importante para entornos limitados
6. es importante para cardio o capacidad aerobica
7. es importante para movilidad, preparacion o rehab basica

---

## 3. Criterios de exclusion temporal

Se pueden dejar para versiones posteriores:

- variaciones extremadamente raras
- implementos muy exoticos con baja cobertura
- skills elite muy especificas
- ejercicios redundantes sin valor diferencial
- variantes con poca utilidad si ya existe otra mejor representada

---

## 4. Tamano objetivo de la semilla v1

Recomendacion inicial:

- `equipment_item`: 120-180 items
- `exercise_family`: 80-120 familias
- `exercise_variant`: 350-700 variantes

Ese rango ya permite un sistema serio sin intentar meter 5.000 ejercicios desde el dia 1.

---

## 5. Equipamiento base incluido

## 5.1 Bodyweight / minimal setup

- floor_space
- wall
- bench_or_box
- pull_up_bar
- dip_bars
- gym_rings
- sliders
- towel_anchor
- weighted_vest

## 5.2 Barbells and plates

- olympic_barbell
- ez_bar
- short_bar
- trap_bar
- axle_bar
- safety_squat_bar
- landmine_setup
- bumper_plates
- change_plates

## 5.3 Dumbbells and kettlebells

- fixed_dumbbells
- adjustable_dumbbells
- kettlebell_standard
- kettlebell_competition

## 5.4 Racks and stations

- power_rack
- squat_stand
- smith_machine
- cable_station_dual
- lat_pulldown_station
- seated_cable_row_station

## 5.5 Selectorized machines

- machine_chest_press
- machine_shoulder_press
- machine_row
- machine_lat_pulldown
- machine_low_row
- machine_leg_extension
- machine_leg_curl_seated
- machine_leg_curl_lying
- machine_adductor
- machine_abductor
- machine_glute_kickback
- machine_calf_raise
- machine_rotary_torso
- machine_ab_crunch
- machine_biceps_curl
- machine_triceps_extension
- machine_pec_deck
- machine_reverse_pec_deck

## 5.6 Plate loaded machines

- plate_loaded_leg_press
- hack_squat_machine
- pendulum_squat_machine
- plate_loaded_chest_press
- plate_loaded_incline_press
- plate_loaded_shoulder_press
- plate_loaded_row
- plate_loaded_high_row
- plate_loaded_low_row
- plate_loaded_pulldown
- plate_loaded_preacher_curl
- plate_loaded_hip_thrust
- plate_loaded_calf_raise

## 5.7 Functional tools

- long_resistance_band
- mini_band
- suspension_trainer
- medicine_ball
- slam_ball
- wall_ball
- battle_ropes
- sandbag_light
- sandbag_heavy
- plyo_box
- cones
- agility_ladder
- hurdles
- mace
- clubs

## 5.8 Cardio

- treadmill
- curved_treadmill
- upright_bike
- spin_bike
- recumbent_bike
- bike_erg
- air_bike
- row_erg
- ski_erg
- elliptical
- stair_climber
- stepmill
- versa_climber
- jump_rope

## 5.9 Strongman and loaded movement

- sled_push
- sled_pull
- yoke
- farmers_handles
- frame_carry
- log
- atlas_stone
- circus_dumbbell
- keg

## 5.10 Recovery and support

- foam_roller
- lacrosse_ball
- massage_gun
- mobility_stick
- ankle_wedge
- lifting_straps
- lifting_belt

---

## 6. Familias de ejercicio prioritarias

## 6.1 Squat

- back_squat_family
- front_squat_family
- goblet_squat_family
- split_squat_family
- lunge_family
- step_up_family
- leg_press_family
- hack_squat_family
- belt_squat_family
- pistol_squat_family
- wall_sit_family

## 6.2 Hinge

- conventional_deadlift_family
- sumo_deadlift_family
- romanian_deadlift_family
- trap_bar_deadlift_family
- good_morning_family
- hip_thrust_family
- glute_bridge_family
- kettlebell_hinge_family
- back_extension_family
- pull_through_family

## 6.3 Horizontal push

- bench_press_family
- incline_press_family
- dumbbell_press_family
- push_up_family
- ring_push_up_family
- machine_chest_press_family
- cable_press_family
- floor_press_family

## 6.4 Vertical push

- overhead_press_family
- dumbbell_shoulder_press_family
- kettlebell_press_family
- push_press_family
- jerk_family
- machine_shoulder_press_family
- landmine_press_family
- handstand_push_up_family

## 6.5 Horizontal pull

- barbell_row_family
- dumbbell_row_family
- cable_row_family
- machine_row_family
- chest_supported_row_family
- inverted_row_family
- ring_row_family

## 6.6 Vertical pull

- pull_up_family
- chin_up_family
- lat_pulldown_family
- assisted_pull_up_family
- rope_climb_family

## 6.7 Lower isolation

- leg_extension_family
- leg_curl_family
- adductor_family
- abductor_family
- calf_raise_family
- tibialis_raise_family
- glute_kickback_family

## 6.8 Upper isolation

- lateral_raise_family
- rear_delt_family
- biceps_curl_family
- hammer_curl_family
- preacher_curl_family
- triceps_pushdown_family
- overhead_triceps_extension_family
- skullcrusher_family
- wrist_curl_family

## 6.9 Core

- crunch_family
- reverse_crunch_family
- hanging_leg_raise_family
- ab_wheel_family
- plank_family
- side_plank_family
- dead_bug_family
- bird_dog_family
- pallof_press_family
- chop_family
- anti_rotation_family

## 6.10 Carries and loaded movement

- farmers_carry_family
- suitcase_carry_family
- front_rack_carry_family
- overhead_carry_family
- sandbag_carry_family
- yoke_carry_family
- sled_push_family
- sled_drag_family

## 6.11 Cardio

- treadmill_family
- bike_family
- air_bike_family
- row_erg_family
- ski_erg_family
- elliptical_family
- stair_climber_family
- jump_rope_family
- shuttle_run_family

## 6.12 Power and plyometric

- vertical_jump_family
- broad_jump_family
- box_jump_family
- depth_jump_family
- single_leg_hop_family
- skater_bound_family
- med_ball_slam_family
- med_ball_throw_family
- rotational_throw_family

## 6.13 Olympic / explosive

- clean_family
- power_clean_family
- snatch_family
- power_snatch_family
- high_pull_family
- jerk_family

## 6.14 Kettlebell

- kettlebell_swing_family
- kettlebell_clean_family
- kettlebell_snatch_family
- Turkish_get_up_family
- kettlebell_press_family
- kettlebell_row_family
- kettlebell_carry_family

## 6.15 Calisthenics

- dip_family
- pull_up_skill_family
- handstand_family
- L_sit_family
- muscle_up_family
- front_lever_family
- back_lever_family
- planche_family

## 6.16 Mobility / prep / rehab

- CARs_family
- dynamic_mobility_family
- static_stretch_family
- activation_family
- scapular_control_family
- hip_control_family
- ankle_mobility_family
- tendon_isometric_family
- balance_proprioception_family
- neck_isometric_family

---

## 7. Variantes semilla prioritarias

## 7.1 Squat and knee dominant

- high_bar_back_squat
- low_bar_back_squat
- paused_back_squat
- box_back_squat
- front_squat
- paused_front_squat
- goblet_squat
- goblet_box_squat
- Bulgarian_split_squat
- front_foot_elevated_split_squat
- reverse_lunge
- walking_lunge
- lateral_lunge
- step_up
- high_step_up
- leg_press
- single_leg_leg_press
- hack_squat
- smith_squat
- belt_squat
- wall_sit
- pistol_squat_progression

## 7.2 Hinge and posterior chain

- conventional_deadlift
- sumo_deadlift
- trap_bar_deadlift
- romanian_deadlift_barbell
- romanian_deadlift_dumbbell
- single_leg_RDL
- kickstand_RDL
- good_morning
- hip_thrust_barbell
- hip_thrust_machine
- glute_bridge
- cable_pull_through
- kettlebell_swing
- back_extension
- reverse_hyper_if_available

## 7.3 Horizontal push

- bench_press
- paused_bench_press
- close_grip_bench_press
- incline_barbell_press
- dumbbell_flat_press
- dumbbell_incline_press
- floor_press
- machine_chest_press
- plate_loaded_chest_press
- push_up_incline
- push_up_standard
- push_up_deficit
- push_up_feet_elevated
- ring_push_up
- cable_press_standing

## 7.4 Vertical push

- strict_barbell_press
- seated_dumbbell_press
- standing_dumbbell_press
- machine_shoulder_press
- plate_loaded_shoulder_press
- landmine_press_half_kneeling
- kettlebell_strict_press
- push_press
- split_jerk
- push_jerk
- handstand_hold_progression
- handstand_push_up_progression

## 7.5 Horizontal pull

- bent_over_barbell_row
- Pendlay_row
- chest_supported_dumbbell_row
- one_arm_dumbbell_row
- seated_cable_row
- machine_row
- machine_high_row
- inverted_row
- ring_row
- T_bar_row_if_available

## 7.6 Vertical pull

- pull_up_band_assisted
- pull_up_eccentric
- strict_pull_up
- chin_up
- neutral_grip_pull_up
- weighted_pull_up
- lat_pulldown_pronated
- lat_pulldown_neutral
- single_arm_pulldown
- banded_lat_pulldown

## 7.7 Upper isolation

- dumbbell_lateral_raise
- cable_lateral_raise
- rear_delt_fly_dumbbell
- reverse_pec_deck
- barbell_curl
- dumbbell_supinating_curl
- hammer_curl
- preacher_curl_machine
- cable_pushdown
- overhead_cable_triceps_extension
- skullcrusher_EZ
- wrist_curl
- reverse_wrist_curl

## 7.8 Lower isolation

- leg_extension_machine
- seated_leg_curl
- lying_leg_curl
- adductor_machine
- abductor_machine
- standing_calf_raise
- seated_calf_raise
- tibialis_raise
- glute_kickback_machine
- cable_glute_kickback

## 7.9 Core and trunk

- crunch
- cable_crunch
- reverse_crunch
- hanging_knee_raise
- hanging_leg_raise
- ab_wheel_rollout
- front_plank
- side_plank
- dead_bug
- bird_dog
- pallof_press
- cable_chop
- cable_lift
- suitcase_carry

## 7.10 Carries and loaded movement

- farmers_carry
- heavy_farmers_carry
- suitcase_carry
- front_rack_carry
- overhead_carry
- sandbag_bear_hug_carry
- yoke_carry
- sled_push_heavy
- sled_push_conditioning
- sled_drag_backward

## 7.11 Cardio and conditioning

- treadmill_walk
- treadmill_incline_walk
- treadmill_run_intervals
- upright_bike_easy
- spin_bike_tempo
- bike_erg_steady
- air_bike_intervals
- row_erg_steady
- row_erg_power_intervals
- ski_erg_intervals
- elliptical_steady
- stair_climber_steady
- jump_rope_basic
- jump_rope_intervals
- shuttle_run_short

## 7.12 Power and plyometric

- countermovement_jump
- squat_jump
- box_jump
- broad_jump
- hurdle_jump
- depth_jump
- single_leg_hop
- skater_bound
- med_ball_slam
- med_ball_chest_pass
- med_ball_rotational_throw
- med_ball_scoop_toss

## 7.13 Olympic / explosive barbell

- front_squat_olympic
- power_clean
- hang_power_clean
- squat_clean
- power_snatch
- hang_power_snatch
- squat_snatch
- clean_pull
- snatch_pull
- high_pull
- split_jerk

## 7.14 Kettlebell

- kettlebell_deadlift
- kettlebell_swing_two_hand
- kettlebell_swing_one_hand
- kettlebell_clean
- kettlebell_snatch
- kettlebell_goblet_squat
- kettlebell_front_rack_squat
- kettlebell_press
- kettlebell_push_press
- kettlebell_row
- Turkish_get_up_full
- kettlebell_halo
- kettlebell_carry_suitcase

## 7.15 Calisthenics and bodyweight skills

- dip_assisted
- dip_strict
- pull_up_progression
- chin_up_progression
- L_sit_tuck
- L_sit_full
- muscle_up_progression
- handstand_wall
- handstand_free_progression
- front_lever_tuck
- back_lever_tuck
- pseudo_planche_push_up

## 7.16 Mobility, prep, rehab

- shoulder_CARs
- hip_CARs
- ankle_CARs
- thoracic_rotation_mobility
- couch_stretch
- hamstring_dynamic_sweep
- wall_slide
- band_external_rotation
- glute_bridge_iso
- calf_isometric
- split_squat_isometric
- single_leg_balance_reach
- neck_isometric_flexion
- neck_isometric_extension
- neck_isometric_lateral

---

## 8. Distribucion por entorno

La semilla debe poder mapearse rapidamente a entornos.

## 8.1 Full gym

Debe poder usar casi toda la semilla.

## 8.2 Small gym

Priorizar:

- smith
- poleas
- mancuernas
- algunas maquinas
- cardio basico

## 8.3 Home gym

Priorizar:

- bodyweight
- mancuernas
- barra si existe
- bandas
- kettlebells
- banco
- cardio simple

## 8.4 Hotel / limited access

Priorizar:

- bodyweight
- bandas
- cardio basico
- DB light/moderate si existen
- movilidad
- carries simples

## 8.5 Outdoor

Priorizar:

- locomotion
- running
- carries
- sled si existe
- bodyweight
- plyometric simple

---

## 9. Semilla de patrones de sustitucion

Estas sustituciones iniciales deberian quedar cubiertas por la semilla.

### Push

- bench_press -> dumbbell_flat_press -> machine_chest_press -> push_up_standard -> push_up_incline
- strict_barbell_press -> seated_dumbbell_press -> machine_shoulder_press -> landmine_press_half_kneeling

### Pull

- weighted_pull_up -> strict_pull_up -> lat_pulldown_pronated -> banded_lat_pulldown -> ring_row
- bent_over_barbell_row -> chest_supported_dumbbell_row -> machine_row -> seated_cable_row -> ring_row

### Squat

- high_bar_back_squat -> front_squat -> smith_squat -> goblet_squat -> goblet_box_squat
- leg_press -> belt_squat -> smith_squat -> split_squat -> step_up

### Hinge

- conventional_deadlift -> trap_bar_deadlift -> romanian_deadlift_barbell -> romanian_deadlift_dumbbell -> kettlebell_deadlift
- hip_thrust_barbell -> hip_thrust_machine -> glute_bridge -> cable_pull_through

### Cardio

- air_bike_intervals -> row_erg_power_intervals -> ski_erg_intervals -> treadmill_run_intervals
- incline_walk -> elliptical_steady -> upright_bike_easy -> row_erg_steady

---

## 10. Priorizacion por objetivo

La semilla `v1` debe poder responder bien al menos a estos objetivos:

### 10.1 Hypertrophy

Priorizar:

- patrones basicos cargables
- maquinas y mancuernas
- aislamientos utiles

### 10.2 Strength

Priorizar:

- barra
- squat / hinge / press / row / pull
- carries
- front squat y press support

### 10.3 Fat loss / general fitness

Priorizar:

- patrones globales
- cardio util
- sesiones densas
- opciones con bajo costo de setup

### 10.4 Sport performance / hybrid

Priorizar:

- unilateral lower body
- rotational work
- anti-rotation
- carries
- plyos
- cardio modality compatible

### 10.5 Recovery / caution

Priorizar:

- movilidad
- activacion
- cardio facil
- isometricos
- patrones simples de baja complejidad

---

## 11. Priorizacion por deporte

## 11.1 Strength / hypertrophy

Mayor peso en:

- squat
- hinge
- press
- row
- pulldown / pull-up
- aislamientos clave

## 11.2 Running / endurance

Mayor peso en:

- cardio modalities
- unilateral lower body
- posterior chain resistente
- core anti-rotation
- calves / tibialis

## 11.3 Team sports

Mayor peso en:

- unilateral lower body
- plyometrics
- deceleration support
- rotational work
- strength base
- capacity conditioning

## 11.4 Combat sports

Mayor peso en:

- grip
- neck
- carries
- rotational power
- anti-rotation
- posterior chain
- energy system work

## 11.5 General fitness

Mayor peso en:

- patrones basicos
- cardio accesible
- sesiones cortas compatibles

---

## 12. Tags minimos por variante en la semilla

Cada variante incluida en la semilla debe tener al menos:

- `family_key`
- `movement_pattern`
- `equipment_required`
- `difficulty_tier`
- `technical_demand`
- `fatigue_cost`
- `goal_tags`
- `sport_tags`
- `restriction_tags`
- `substitution_priority_group`

Sin esos tags, el catalogo se vuelve una lista sin cerebro.

---

## 13. Lotes recomendados de trabajo

Para poblar la semilla sin caos:

### Lote A - Base universal

- squat
- hinge
- push
- pull
- carries
- core

### Lote B - Cardio

- treadmill
- bike
- air bike
- row
- ski erg
- elliptical
- jump rope

### Lote C - Maquinas y aislamientos

- presses
- rows
- leg extension
- leg curl
- adductor / abductor
- calves
- shoulders
- arms

### Lote D - Potencia, kettlebell y funcional

- jumps
- throws
- swings
- get-up
- sleds
- sandbags

### Lote E - Mobility, prep, rehab

- CARs
- activation
- isometricos
- balance basico
- neck basico

---

## 14. Riesgos de la semilla

### 14.1 Riesgo: demasiados nombres sin estructura

Mitigacion:

- obligar tags minimos por variante

### 14.2 Riesgo: sesgo a gym comercial

Mitigacion:

- meter desde el inicio bodyweight, bandas, home gym, hotel, cardio y movilidad

### 14.3 Riesgo: demasiada cola larga demasiado pronto

Mitigacion:

- priorizar familias y variantes de mayor cobertura

### 14.4 Riesgo: sustituciones pobres

Mitigacion:

- agrupar por patron + estimulo + costo de fatiga + equipo

---

## 15. Criterio de aceptacion de la semilla

La semilla `v1` estara bien si:

- soporta los objetivos principales
- soporta los entornos principales
- soporta varios deportes base
- permite sustituciones utiles
- cubre mas que solo gym de hipertrofia
- sirve como base real del motor adaptativo

---

## 16. Siguiente paso recomendado

Documentos siguientes sugeridos:

1. `VITAL-DOMAIN-SCHEMA-v1.md`
   - traducir core model + catalogo a estructuras implementables

2. `VITAL-SUBSTITUTION-RULES-v1.md`
   - detallar reglas entre familias y equipos

3. `VITAL-CATALOG-SEED-DATA-v1.md`
   - lista tabular inicial de items concretos para importar o seedear

Recomendacion:

el siguiente documento de mayor valor practico es `VITAL-CATALOG-SEED-DATA-v1.md`, porque convierte esta semilla conceptual en una lista operativa concreta para poblar producto o base de datos.
