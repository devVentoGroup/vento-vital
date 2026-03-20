# Vento Vital - Catalog Seed Data v1 2026-03-13

Estado: `draft operativo`

Depende de:

- `docs/VITAL-EXERCISE-CATALOG-SPEC-2026-03-13.md`
- `docs/VITAL-CATALOG-SEED-v1-2026-03-13.md`
- `docs/VITAL-CORE-MODEL-2026-03-13.md`

Proposito: bajar la semilla del catalogo a una forma tabular util para carga inicial, seed manual o posterior transformacion a contratos y base de datos.

---

## 1. Alcance de esta semilla de datos

Esta version no intenta listar todos los ejercicios del mundo.

Si intenta:

- dejar una primera base concreta y utilizable
- cubrir muchos entornos
- cubrir patrones clave
- cubrir sustituciones de alto valor
- servir como base real para producto, datos y reglas

Estructura:

- tabla de equipos
- tabla de familias
- tabla de variantes

---

## 2. Convenciones

### 2.1 `difficulty_tier`

- `very_low`
- `low`
- `medium`
- `high`
- `very_high`

### 2.2 `fatigue_cost`

- `low`
- `medium`
- `high`

### 2.3 `env_tags`

- `full_gym`
- `small_gym`
- `home_gym`
- `hotel`
- `outdoor`
- `limited_access`

### 2.4 `goal_tags`

- `strength`
- `hypertrophy`
- `fat_loss`
- `general_fitness`
- `sport_performance`
- `recovery`
- `power`
- `conditioning`

---

## 3. Equipment seed

| key | equipment_class | label | portable | supports_load_progression | env_tags | notes |
|---|---|---|---|---|---|---|
| floor_space | bodyweight | Floor Space | yes | no | home_gym,hotel,outdoor,limited_access | Base minima para trabajo corporal |
| wall | bodyweight | Wall | no | no | home_gym,hotel,limited_access | Soporte para drills y push-up inclinada |
| bench_or_box | bodyweight | Bench or Box | no | no | full_gym,small_gym,home_gym | Caja o banco estable |
| pull_up_bar | bodyweight_with_anchor | Pull-Up Bar | no | bodyweight_load | full_gym,small_gym,home_gym,hotel | Barra fija o rack |
| dip_bars | bodyweight_with_anchor | Dip Bars | no | bodyweight_load | full_gym,small_gym,home_gym | Paralelas o station |
| gym_rings | suspension | Gym Rings | yes | bodyweight_load | full_gym,home_gym,outdoor | Requiere anclaje |
| suspension_trainer | suspension | Suspension Trainer | yes | bodyweight_load | home_gym,hotel,outdoor,limited_access | TRX o similar |
| sliders | bodyweight | Sliders | yes | no | home_gym,hotel | Core y lower body |
| weighted_vest | bodyweight | Weighted Vest | yes | yes | home_gym,outdoor,limited_access | Lastre portable |
| olympic_barbell | barbell | Olympic Barbell | no | yes | full_gym,small_gym,home_gym | Barra estandar |
| ez_bar | barbell | EZ Bar | no | yes | full_gym,small_gym,home_gym | Curvas para curls y extensions |
| short_bar | barbell | Short Bar | no | yes | small_gym,home_gym | Espacios reducidos |
| trap_bar | barbell | Trap Bar | no | yes | full_gym,small_gym,home_gym | Deadlift y carry |
| axle_bar | barbell | Axle Bar | no | yes | full_gym,home_gym | Grip y strongman |
| safety_squat_bar | barbell | Safety Squat Bar | no | yes | full_gym,small_gym | Squat con menor demanda de hombro |
| landmine_setup | barbell | Landmine Setup | no | yes | full_gym,small_gym,home_gym | Pivot fijo |
| bumper_plates | barbell | Bumper Plates | no | yes | full_gym,small_gym,home_gym | WL y tirones |
| fixed_dumbbells | dumbbell | Fixed Dumbbells | no | yes | full_gym,small_gym,home_gym,hotel | Alta cobertura |
| adjustable_dumbbells | dumbbell | Adjustable Dumbbells | yes | yes | home_gym,hotel | Home gym valioso |
| kettlebell_standard | kettlebell | Standard Kettlebell | yes | yes | full_gym,small_gym,home_gym,hotel | Swing, carry, press |
| kettlebell_competition | kettlebell | Competition Kettlebell | yes | yes | full_gym,home_gym | Peso y tamano uniforme |
| power_rack | bodyweight_with_anchor | Power Rack | no | no | full_gym,small_gym,home_gym | Soporte de barra y dominadas |
| squat_stand | bodyweight_with_anchor | Squat Stand | no | no | small_gym,home_gym | Menos versatil que rack |
| smith_machine | machine_plate_loaded | Smith Machine | no | yes | full_gym,small_gym | Muy util para sustitucion |
| cable_station_dual | cable | Dual Adjustable Pulley | no | yes | full_gym,small_gym | Functional trainer |
| lat_pulldown_station | cable | Lat Pulldown Station | no | yes | full_gym,small_gym | Vertical pull |
| seated_cable_row_station | cable | Seated Cable Row Station | no | yes | full_gym,small_gym | Horizontal pull |
| machine_chest_press | machine_selectorized | Machine Chest Press | no | yes | full_gym,small_gym | Push estable |
| machine_shoulder_press | machine_selectorized | Machine Shoulder Press | no | yes | full_gym,small_gym | Vertical push estable |
| machine_row | machine_selectorized | Machine Row | no | yes | full_gym,small_gym | Horizontal pull estable |
| machine_lat_pulldown | machine_selectorized | Machine Lat Pulldown | no | yes | full_gym,small_gym | Vertical pull guiado |
| machine_low_row | machine_selectorized | Machine Low Row | no | yes | full_gym,small_gym | Row bajo |
| machine_leg_extension | machine_selectorized | Machine Leg Extension | no | yes | full_gym,small_gym | Knee extension aislada |
| machine_leg_curl_seated | machine_selectorized | Machine Leg Curl Seated | no | yes | full_gym,small_gym | Hamstring |
| machine_leg_curl_lying | machine_selectorized | Machine Leg Curl Lying | no | yes | full_gym,small_gym | Hamstring alterna |
| machine_adductor | machine_selectorized | Machine Adductor | no | yes | full_gym,small_gym | Adductores |
| machine_abductor | machine_selectorized | Machine Abductor | no | yes | full_gym,small_gym | Abductores |
| machine_glute_kickback | machine_selectorized | Machine Glute Kickback | no | yes | full_gym,small_gym | Glute focus |
| machine_calf_raise | machine_selectorized | Machine Calf Raise | no | yes | full_gym,small_gym | Gemelos |
| machine_rotary_torso | machine_selectorized | Machine Rotary Torso | no | yes | full_gym,small_gym | Rotacional guiado |
| machine_ab_crunch | machine_selectorized | Machine Ab Crunch | no | yes | full_gym,small_gym | Core guiado |
| machine_biceps_curl | machine_selectorized | Machine Biceps Curl | no | yes | full_gym,small_gym | Brazo aislado |
| machine_triceps_extension | machine_selectorized | Machine Triceps Extension | no | yes | full_gym,small_gym | Brazo aislado |
| machine_pec_deck | machine_selectorized | Machine Pec Deck | no | yes | full_gym,small_gym | Fly guiado |
| machine_reverse_pec_deck | machine_selectorized | Machine Reverse Pec Deck | no | yes | full_gym,small_gym | Rear delt |
| plate_loaded_leg_press | machine_plate_loaded | Plate Loaded Leg Press | no | yes | full_gym,small_gym | Squat sustituto |
| hack_squat_machine | machine_plate_loaded | Hack Squat Machine | no | yes | full_gym | Knee dominant |
| pendulum_squat_machine | machine_plate_loaded | Pendulum Squat Machine | no | yes | full_gym | Variacion fuerte lower |
| plate_loaded_chest_press | machine_plate_loaded | Plate Loaded Chest Press | no | yes | full_gym,small_gym | Push pesado |
| plate_loaded_incline_press | machine_plate_loaded | Plate Loaded Incline Press | no | yes | full_gym | Upper push |
| plate_loaded_shoulder_press | machine_plate_loaded | Plate Loaded Shoulder Press | no | yes | full_gym | Vertical push |
| plate_loaded_row | machine_plate_loaded | Plate Loaded Row | no | yes | full_gym,small_gym | Pull pesado |
| plate_loaded_high_row | machine_plate_loaded | Plate Loaded High Row | no | yes | full_gym | Upper back |
| plate_loaded_low_row | machine_plate_loaded | Plate Loaded Low Row | no | yes | full_gym | Mid back |
| plate_loaded_pulldown | machine_plate_loaded | Plate Loaded Pulldown | no | yes | full_gym | Vertical pull |
| plate_loaded_preacher_curl | machine_plate_loaded | Plate Loaded Preacher Curl | no | yes | full_gym | Curl estable |
| plate_loaded_hip_thrust | machine_plate_loaded | Plate Loaded Hip Thrust | no | yes | full_gym | Glute focus |
| plate_loaded_calf_raise | machine_plate_loaded | Plate Loaded Calf Raise | no | yes | full_gym | Gemelos pesados |
| long_resistance_band | band | Long Resistance Band | yes | yes | home_gym,hotel,outdoor,limited_access | Alta versatilidad |
| mini_band | band | Mini Band | yes | yes | home_gym,hotel,outdoor,limited_access | Activation y lower |
| medicine_ball | medicine_ball | Medicine Ball | yes | yes | full_gym,small_gym,home_gym,outdoor | Throws y potencia |
| slam_ball | medicine_ball | Slam Ball | yes | yes | full_gym,small_gym,home_gym,outdoor | Slams |
| wall_ball | medicine_ball | Wall Ball | yes | yes | full_gym,small_gym | Throws especificos |
| battle_ropes | functional | Battle Ropes | no | no | full_gym,small_gym,outdoor | Conditioning |
| sandbag_light | sandbag | Light Sandbag | yes | yes | home_gym,outdoor,limited_access | Carries y squats |
| sandbag_heavy | sandbag | Heavy Sandbag | yes | yes | full_gym,home_gym,outdoor | Strongman / conditioning |
| plyo_box | functional | Plyo Box | no | no | full_gym,small_gym,home_gym | Jumps y step-ups |
| cones | functional | Cones | yes | no | full_gym,outdoor | Agility y shuttles |
| agility_ladder | functional | Agility Ladder | yes | no | full_gym,outdoor | Coordination |
| hurdles | functional | Hurdles | yes | no | full_gym,outdoor | Plyo y speed |
| mace | club_mace | Mace | yes | yes | home_gym,limited_access | Rotacional y shoulders |
| clubs | club_mace | Clubs | yes | yes | home_gym,limited_access | Shoulder prep |
| treadmill | cardio_machine | Treadmill | no | speed_resistance | full_gym,small_gym,hotel | Walk/run |
| curved_treadmill | cardio_machine | Curved Treadmill | no | speed_resistance | full_gym | Sprint y skill |
| upright_bike | cardio_machine | Upright Bike | no | resistance | full_gym,small_gym,hotel | Cardio accesible |
| spin_bike | cardio_machine | Spin Bike | no | resistance | full_gym,small_gym | Tempo e intervals |
| recumbent_bike | cardio_machine | Recumbent Bike | no | resistance | full_gym,hotel | Bajo impacto |
| bike_erg | cardio_ergometer | Bike Erg | no | resistance | full_gym,small_gym,home_gym | Potencia y base |
| air_bike | cardio_ergometer | Air Bike | no | resistance | full_gym,small_gym,home_gym | HIIT y full body |
| row_erg | cardio_ergometer | Row Erg | no | resistance | full_gym,small_gym,home_gym | Base y intervals |
| ski_erg | cardio_ergometer | Ski Erg | no | resistance | full_gym,small_gym | Upper + conditioning |
| elliptical | cardio_machine | Elliptical | no | resistance | full_gym,small_gym,hotel | Bajo impacto |
| stair_climber | cardio_machine | Stair Climber | no | resistance | full_gym,small_gym | Lower conditioning |
| stepmill | cardio_machine | Stepmill | no | resistance | full_gym | Lower conditioning |
| versa_climber | cardio_machine | Versa Climber | no | resistance | full_gym | Vertical conditioning |
| jump_rope | cardio_machine | Jump Rope | yes | no | home_gym,hotel,outdoor,limited_access | Portable conditioning |
| sled_push | sled | Sled Push | no | yes | full_gym,outdoor | Lower power/conditioning |
| sled_pull | sled | Sled Pull | no | yes | full_gym,outdoor | Pull/conditioning |
| yoke | strongman_implement | Yoke | no | yes | full_gym,outdoor | Carry heavy |
| farmers_handles | strongman_implement | Farmers Handles | no | yes | full_gym,outdoor | Carry/grip |
| frame_carry | strongman_implement | Frame Carry | no | yes | full_gym,outdoor | Carry strongman |
| log | strongman_implement | Log | no | yes | full_gym | Overhead strongman |
| atlas_stone | strongman_implement | Atlas Stone | no | yes | full_gym,outdoor | Load pattern |
| circus_dumbbell | strongman_implement | Circus Dumbbell | no | yes | full_gym | Overhead unilateral |
| keg | strongman_implement | Keg | no | yes | full_gym,outdoor | Strongman load |
| foam_roller | recovery_tool | Foam Roller | yes | no | home_gym,hotel,full_gym | Recovery/prep |
| lacrosse_ball | recovery_tool | Lacrosse Ball | yes | no | home_gym,hotel,limited_access | Release puntual |
| massage_gun | recovery_tool | Massage Gun | yes | no | home_gym,hotel | Soft tissue prep |
| mobility_stick | recovery_tool | Mobility Stick | yes | no | home_gym,full_gym | Mobility assist |
| ankle_wedge | recovery_tool | Ankle Wedge | yes | no | home_gym,full_gym | Squat/ankle support |
| lifting_straps | recovery_tool | Lifting Straps | yes | no | full_gym,small_gym,home_gym | Pull assistance |
| lifting_belt | recovery_tool | Lifting Belt | yes | no | full_gym,small_gym,home_gym | Heavy support |

---

## 4. Exercise family seed

| family_key | primary_pattern | default_stimulus | base_envs | notes |
|---|---|---|---|---|
| back_squat_family | squat_bilateral | strength,hypertrophy | full_gym,small_gym,home_gym | Lower bilateral base |
| front_squat_family | squat_bilateral | strength,hypertrophy | full_gym,small_gym,home_gym | Upright squat pattern |
| goblet_squat_family | squat_bilateral | hypertrophy,general_fitness | home_gym,hotel,limited_access | Lower stable fallback |
| split_squat_family | squat_unilateral | hypertrophy,sport_performance | full_gym,small_gym,home_gym,hotel | High utility |
| lunge_family | squat_unilateral | hypertrophy,general_fitness | full_gym,small_gym,home_gym,outdoor | Locomotion lower |
| step_up_family | squat_unilateral | general_fitness,sport_performance | full_gym,small_gym,home_gym,hotel | Low setup |
| leg_press_family | squat_bilateral | hypertrophy,strength | full_gym,small_gym | Machine lower |
| hack_squat_family | squat_bilateral | hypertrophy,strength | full_gym | Machine lower heavy |
| belt_squat_family | squat_bilateral | hypertrophy,strength | full_gym,small_gym | Lower with less spinal load |
| pistol_squat_family | squat_unilateral | general_fitness,skill | home_gym,hotel,outdoor | Bodyweight progression |
| conventional_deadlift_family | hinge_bilateral | strength | full_gym,small_gym,home_gym | Posterior chain heavy |
| sumo_deadlift_family | hinge_bilateral | strength | full_gym,small_gym,home_gym | Wide stance hinge |
| romanian_deadlift_family | hinge_bilateral | hypertrophy,strength | full_gym,small_gym,home_gym | Hip hinge staple |
| trap_bar_deadlift_family | hinge_bilateral | strength,general_fitness | full_gym,small_gym,home_gym | Friendly heavy hinge |
| good_morning_family | hinge_bilateral | hypertrophy,strength_skill | full_gym,home_gym | Higher skill hinge |
| hip_thrust_family | hinge_bilateral | hypertrophy | full_gym,small_gym,home_gym | Glute dominant |
| glute_bridge_family | hinge_bilateral | hypertrophy,recovery | home_gym,hotel,limited_access | Low setup hinge |
| kettlebell_hinge_family | hinge_bilateral | power,general_fitness | home_gym,hotel,limited_access | Swing driven |
| back_extension_family | hinge_bilateral | hypertrophy,recovery | full_gym,small_gym | Posterior accessory |
| bench_press_family | horizontal_push | strength,hypertrophy | full_gym,small_gym,home_gym | Upper base |
| incline_press_family | horizontal_push | hypertrophy,strength | full_gym,small_gym,home_gym | Upper chest emphasis |
| dumbbell_press_family | horizontal_push | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | Accessible press |
| push_up_family | horizontal_push | general_fitness,hypertrophy | home_gym,hotel,outdoor,limited_access | Universal press |
| ring_push_up_family | horizontal_push | hypertrophy,stability | home_gym,full_gym | More unstable push |
| machine_chest_press_family | horizontal_push | hypertrophy | full_gym,small_gym | Stable push |
| cable_press_family | horizontal_push | hypertrophy,stability | full_gym,small_gym | Standing press variations |
| floor_press_family | horizontal_push | strength,hypertrophy | home_gym,small_gym | Limited ROM press |
| overhead_press_family | vertical_push | strength | full_gym,small_gym,home_gym | Vertical push base |
| dumbbell_shoulder_press_family | vertical_push | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | Accessible push |
| kettlebell_press_family | vertical_push | strength,stability | home_gym,small_gym | Unilateral option |
| push_press_family | vertical_push | power,strength | full_gym,small_gym,home_gym | Dynamic push |
| jerk_family | vertical_push | power,strength_skill | full_gym,small_gym,home_gym | Explosive overhead |
| machine_shoulder_press_family | vertical_push | hypertrophy | full_gym,small_gym | Stable vertical push |
| landmine_press_family | vertical_push | general_fitness,stability | full_gym,small_gym,home_gym | Shoulder-friendly press |
| handstand_push_up_family | vertical_push | skill,strength | home_gym,full_gym | Bodyweight push skill |
| barbell_row_family | horizontal_pull | strength,hypertrophy | full_gym,small_gym,home_gym | Pull base |
| dumbbell_row_family | horizontal_pull | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | Very portable |
| cable_row_family | horizontal_pull | hypertrophy | full_gym,small_gym | Stable pull |
| machine_row_family | horizontal_pull | hypertrophy | full_gym,small_gym | Machine pull |
| chest_supported_row_family | horizontal_pull | hypertrophy | full_gym,small_gym | Lower fatigue row |
| inverted_row_family | horizontal_pull | general_fitness,skill | home_gym,hotel,outdoor | Bodyweight pull |
| ring_row_family | horizontal_pull | general_fitness,stability | home_gym,outdoor | Suspension pull |
| pull_up_family | vertical_pull | strength,skill | full_gym,small_gym,home_gym | Vertical pull base |
| chin_up_family | vertical_pull | strength,hypertrophy | full_gym,small_gym,home_gym | Supinated pull |
| lat_pulldown_family | vertical_pull | hypertrophy | full_gym,small_gym | Stable pulldown |
| assisted_pull_up_family | vertical_pull | skill,general_fitness | full_gym,home_gym | Regression family |
| lateral_raise_family | horizontal_push | hypertrophy | full_gym,small_gym,home_gym,hotel | Delts isolation |
| rear_delt_family | horizontal_pull | hypertrophy | full_gym,small_gym,home_gym | Rear shoulder |
| biceps_curl_family | horizontal_pull | hypertrophy | full_gym,small_gym,home_gym,hotel | Arm isolation |
| hammer_curl_family | horizontal_pull | hypertrophy | full_gym,small_gym,home_gym,hotel | Grip/brachialis |
| preacher_curl_family | horizontal_pull | hypertrophy | full_gym,small_gym | Stable arm |
| triceps_pushdown_family | vertical_push | hypertrophy | full_gym,small_gym | Cable triceps |
| overhead_triceps_extension_family | vertical_push | hypertrophy | full_gym,small_gym,home_gym | Long head focus |
| skullcrusher_family | horizontal_push | hypertrophy | full_gym,small_gym,home_gym | Elbow extension load |
| leg_extension_family | squat_bilateral | hypertrophy | full_gym,small_gym | Quad isolation |
| leg_curl_family | hinge_bilateral | hypertrophy | full_gym,small_gym | Hamstring isolation |
| adductor_family | hip_abduction_adduction | hypertrophy,recovery | full_gym,small_gym | Hip adductors |
| abductor_family | hip_abduction_adduction | hypertrophy,recovery | full_gym,small_gym | Hip abductors |
| calf_raise_family | ankle_foot_complex | hypertrophy,sport_performance | full_gym,small_gym,home_gym | Calves |
| tibialis_raise_family | ankle_foot_complex | sport_performance,recovery | home_gym,small_gym | Shin support |
| glute_kickback_family | hinge_unilateral | hypertrophy | full_gym,small_gym,home_gym | Glute accessory |
| crunch_family | anti_extension | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | Trunk flexion |
| reverse_crunch_family | anti_extension | general_fitness | home_gym,hotel | Lower trunk flexion |
| hanging_leg_raise_family | anti_extension | strength,skill | full_gym,small_gym,home_gym | Hanging core |
| ab_wheel_family | anti_extension | strength,stability | home_gym,small_gym | Anti-extension |
| plank_family | anti_extension | stability,recovery | home_gym,hotel,outdoor | Core basic |
| side_plank_family | anti_lateral_flexion | stability,recovery | home_gym,hotel,outdoor | Lateral trunk |
| dead_bug_family | anti_extension | recovery,stability | home_gym,hotel | Core control |
| bird_dog_family | anti_rotation | recovery,stability | home_gym,hotel | Core/spine control |
| pallof_press_family | anti_rotation | stability,sport_performance | full_gym,small_gym,home_gym | Anti-rotation staple |
| chop_family | rotation | sport_performance,hypertrophy | full_gym,small_gym,home_gym | Rotary trunk |
| farmers_carry_family | carry | strength,conditioning | full_gym,small_gym,home_gym,outdoor | Grip/full body |
| suitcase_carry_family | carry | stability,conditioning | home_gym,hotel,outdoor | Anti-lateral flexion |
| front_rack_carry_family | carry | strength,stability | full_gym,small_gym,home_gym | Upper/front core |
| overhead_carry_family | carry | stability,sport_performance | full_gym,small_gym,home_gym | Shoulder/core |
| sandbag_carry_family | carry | conditioning,strength | home_gym,outdoor | Odd object |
| yoke_carry_family | carry | strength | full_gym,outdoor | Strongman |
| sled_push_family | locomotion | conditioning,power | full_gym,outdoor | Low skill conditioning |
| sled_drag_family | locomotion | conditioning,recovery | full_gym,outdoor | Pull conditioning |
| treadmill_family | gait_cyclical | conditioning,fat_loss | full_gym,small_gym,hotel | Walk/run |
| bike_family | gait_cyclical | conditioning,recovery | full_gym,small_gym,hotel | Cycling modalities |
| air_bike_family | gait_cyclical | conditioning,power | full_gym,small_gym,home_gym | HIIT full body |
| row_erg_family | gait_cyclical | conditioning,aerobic_base | full_gym,small_gym,home_gym | Erg row |
| ski_erg_family | gait_cyclical | conditioning | full_gym,small_gym | Upper cyclical |
| elliptical_family | gait_cyclical | conditioning,recovery | full_gym,small_gym,hotel | Low impact |
| stair_climber_family | gait_cyclical | conditioning | full_gym,small_gym | Lower focused cardio |
| jump_rope_family | gait_cyclical | conditioning,sport_performance | home_gym,hotel,outdoor | Portable cardio |
| vertical_jump_family | jump | power,sport_performance | full_gym,small_gym,home_gym,outdoor | Bilateral jump |
| broad_jump_family | jump | power,sport_performance | home_gym,outdoor | Horizontal power |
| box_jump_family | jump | power,sport_performance | full_gym,small_gym,home_gym | Jump to platform |
| depth_jump_family | jump | power,sport_performance | full_gym,small_gym | Higher impact plyo |
| single_leg_hop_family | hop | power,sport_performance | home_gym,outdoor | Unilateral plyo |
| skater_bound_family | bound | power,sport_performance | home_gym,outdoor | Lateral bound |
| med_ball_slam_family | throw | power,conditioning | full_gym,small_gym,home_gym,outdoor | Vertical slam |
| med_ball_throw_family | throw | power,sport_performance | full_gym,small_gym,outdoor | Linear throw |
| rotational_throw_family | throw | power,sport_performance | full_gym,small_gym,outdoor | Rotary power |
| clean_family | hinge_bilateral | power,strength_skill | full_gym,small_gym,home_gym | Olympic family |
| power_clean_family | hinge_bilateral | power | full_gym,small_gym,home_gym | Catch high |
| snatch_family | hinge_bilateral | power,strength_skill | full_gym,small_gym,home_gym | Olympic family |
| power_snatch_family | hinge_bilateral | power | full_gym,small_gym,home_gym | Catch high |
| high_pull_family | hinge_bilateral | power | full_gym,small_gym,home_gym | Pull explosive |
| kettlebell_swing_family | hinge_bilateral | power,conditioning | home_gym,hotel,limited_access | High utility |
| kettlebell_clean_family | hinge_bilateral | power,strength | home_gym,small_gym | Rack power |
| kettlebell_snatch_family | hinge_bilateral | power,conditioning | home_gym,small_gym | Overhead hinge |
| Turkish_get_up_family | mobility_dynamic | stability,recovery | home_gym,small_gym | Whole body skill |
| kettlebell_press_family | vertical_push | strength,stability | home_gym,small_gym | Unilateral press |
| kettlebell_row_family | horizontal_pull | hypertrophy,general_fitness | home_gym,hotel | Portable pull |
| kettlebell_carry_family | carry | strength,conditioning | home_gym,hotel,outdoor | Portable carry |
| dip_family | vertical_push | strength,hypertrophy | full_gym,small_gym,home_gym | BW push |
| L_sit_family | anti_extension | skill,strength | full_gym,home_gym | Compression/core |
| muscle_up_family | vertical_pull | skill,power | full_gym,home_gym,outdoor | Advanced calisthenics |
| handstand_family | vertical_push | skill,stability | home_gym,full_gym | Skill support |
| front_lever_family | horizontal_pull | skill,strength | full_gym,home_gym | Advanced posterior skill |
| back_lever_family | horizontal_pull | skill,strength | full_gym,home_gym | Advanced extension skill |
| planche_family | horizontal_push | skill,strength | home_gym,full_gym | Advanced push skill |
| CARs_family | mobility_articular | recovery,mobility | home_gym,hotel,limited_access | Joint prep |
| dynamic_mobility_family | mobility_dynamic | recovery,mobility | home_gym,hotel,outdoor | Session prep |
| static_stretch_family | mobility_dynamic | recovery | home_gym,hotel | Cooldown/recovery |
| activation_family | corrective_activation | recovery,stability | home_gym,hotel,limited_access | Prep work |
| scapular_control_family | scapular_control | recovery,stability | home_gym,small_gym | Shoulder support |
| hip_control_family | corrective_activation | recovery,stability | home_gym,hotel | Lower support |
| ankle_mobility_family | mobility_articular | recovery,sport_performance | home_gym,hotel | Gait/squat support |
| tendon_isometric_family | corrective_activation | recovery,rehab | home_gym,hotel,limited_access | Pain modulation |
| balance_proprioception_family | corrective_integration | recovery,rehab | home_gym,hotel,outdoor | RTS support |
| neck_isometric_family | neck | recovery,sport_performance | home_gym,hotel,limited_access | Combat/contact support |

---

## 5. Exercise variant seed

| variant_key | family_key | equipment_key | movement_pattern | difficulty_tier | fatigue_cost | goal_tags | env_tags | substitution_group |
|---|---|---|---|---|---|---|---|---|
| high_bar_back_squat | back_squat_family | olympic_barbell | squat_bilateral | high | high | strength,hypertrophy | full_gym,small_gym,home_gym | squat_main_loaded |
| low_bar_back_squat | back_squat_family | olympic_barbell | squat_bilateral | high | high | strength | full_gym,small_gym,home_gym | squat_main_loaded |
| paused_back_squat | back_squat_family | olympic_barbell | squat_bilateral | high | high | strength | full_gym,small_gym,home_gym | squat_main_loaded |
| box_back_squat | back_squat_family | olympic_barbell | squat_bilateral | medium | high | strength | full_gym,small_gym,home_gym | squat_main_loaded |
| front_squat | front_squat_family | olympic_barbell | squat_bilateral | high | high | strength,hypertrophy | full_gym,small_gym,home_gym | squat_main_loaded |
| paused_front_squat | front_squat_family | olympic_barbell | squat_bilateral | high | high | strength | full_gym,small_gym,home_gym | squat_main_loaded |
| goblet_squat | goblet_squat_family | kettlebell_standard | squat_bilateral | low | medium | hypertrophy,general_fitness | home_gym,hotel,limited_access | squat_main_light |
| goblet_box_squat | goblet_squat_family | kettlebell_standard | squat_bilateral | low | low | recovery,general_fitness | home_gym,hotel,limited_access | squat_main_light |
| Bulgarian_split_squat | split_squat_family | fixed_dumbbells | squat_unilateral | medium | high | hypertrophy,sport_performance | full_gym,small_gym,home_gym,hotel | unilateral_knee_dominant |
| front_foot_elevated_split_squat | split_squat_family | fixed_dumbbells | squat_unilateral | medium | high | hypertrophy | full_gym,small_gym,home_gym | unilateral_knee_dominant |
| reverse_lunge | lunge_family | fixed_dumbbells | squat_unilateral | medium | medium | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | unilateral_knee_dominant |
| walking_lunge | lunge_family | fixed_dumbbells | squat_unilateral | medium | medium | hypertrophy,conditioning | full_gym,small_gym,home_gym,outdoor | unilateral_knee_dominant |
| lateral_lunge | lunge_family | fixed_dumbbells | squat_unilateral | medium | medium | sport_performance,general_fitness | full_gym,small_gym,home_gym,outdoor | frontal_plane_lower |
| step_up | step_up_family | bench_or_box | squat_unilateral | low | medium | general_fitness,sport_performance | full_gym,small_gym,home_gym,hotel | unilateral_knee_dominant |
| high_step_up | step_up_family | bench_or_box | squat_unilateral | medium | medium | hypertrophy,sport_performance | full_gym,small_gym,home_gym | unilateral_knee_dominant |
| leg_press | leg_press_family | plate_loaded_leg_press | squat_bilateral | low | high | hypertrophy,strength | full_gym,small_gym | machine_knee_dominant |
| single_leg_leg_press | leg_press_family | plate_loaded_leg_press | squat_unilateral | medium | high | hypertrophy | full_gym,small_gym | machine_knee_dominant |
| hack_squat | hack_squat_family | hack_squat_machine | squat_bilateral | medium | high | hypertrophy,strength | full_gym | machine_knee_dominant |
| smith_squat | back_squat_family | smith_machine | squat_bilateral | medium | high | hypertrophy,strength | full_gym,small_gym | squat_main_loaded |
| belt_squat | belt_squat_family | dip_bars | squat_bilateral | medium | high | hypertrophy,strength | full_gym,small_gym | machine_knee_dominant |
| wall_sit | wall_sit_family | wall | squat_bilateral | very_low | low | recovery,general_fitness | home_gym,hotel,limited_access | isometric_knee_dominant |
| conventional_deadlift | conventional_deadlift_family | olympic_barbell | hinge_bilateral | high | high | strength | full_gym,small_gym,home_gym | heavy_hinge |
| sumo_deadlift | sumo_deadlift_family | olympic_barbell | hinge_bilateral | high | high | strength | full_gym,small_gym,home_gym | heavy_hinge |
| trap_bar_deadlift | trap_bar_deadlift_family | trap_bar | hinge_bilateral | medium | high | strength,general_fitness | full_gym,small_gym,home_gym | heavy_hinge |
| romanian_deadlift_barbell | romanian_deadlift_family | olympic_barbell | hinge_bilateral | medium | high | hypertrophy,strength | full_gym,small_gym,home_gym | hinge_main |
| romanian_deadlift_dumbbell | romanian_deadlift_family | fixed_dumbbells | hinge_bilateral | medium | medium | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | hinge_main |
| single_leg_RDL | romanian_deadlift_family | fixed_dumbbells | hinge_unilateral | medium | medium | sport_performance,hypertrophy | full_gym,small_gym,home_gym,hotel | unilateral_hinge |
| kickstand_RDL | romanian_deadlift_family | fixed_dumbbells | hinge_unilateral | low | medium | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | unilateral_hinge |
| good_morning | good_morning_family | olympic_barbell | hinge_bilateral | high | high | strength_skill,hypertrophy | full_gym,home_gym | hinge_secondary |
| hip_thrust_barbell | hip_thrust_family | olympic_barbell | hinge_bilateral | medium | medium | hypertrophy | full_gym,small_gym,home_gym | glute_bridge_loaded |
| hip_thrust_machine | hip_thrust_family | plate_loaded_hip_thrust | hinge_bilateral | low | medium | hypertrophy | full_gym | glute_bridge_loaded |
| glute_bridge | glute_bridge_family | floor_space | hinge_bilateral | very_low | low | recovery,general_fitness | home_gym,hotel,limited_access | glute_bridge_loaded |
| cable_pull_through | pull_through_family | cable_station_dual | hinge_bilateral | low | medium | hypertrophy,general_fitness | full_gym,small_gym | hinge_main |
| kettlebell_swing | kettlebell_hinge_family | kettlebell_standard | hinge_bilateral | medium | medium | power,conditioning | home_gym,hotel,limited_access | hinge_power |
| back_extension | back_extension_family | bench_or_box | hinge_bilateral | low | medium | hypertrophy,recovery | full_gym,small_gym | hinge_secondary |
| bench_press | bench_press_family | olympic_barbell | horizontal_push | medium | high | strength,hypertrophy | full_gym,small_gym,home_gym | horizontal_press_main |
| paused_bench_press | bench_press_family | olympic_barbell | horizontal_push | high | high | strength | full_gym,small_gym,home_gym | horizontal_press_main |
| close_grip_bench_press | bench_press_family | olympic_barbell | horizontal_push | medium | high | strength,hypertrophy | full_gym,small_gym,home_gym | horizontal_press_main |
| incline_barbell_press | incline_press_family | olympic_barbell | horizontal_push | medium | high | hypertrophy,strength | full_gym,small_gym,home_gym | horizontal_press_main |
| dumbbell_flat_press | dumbbell_press_family | fixed_dumbbells | horizontal_push | low | medium | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | horizontal_press_main |
| dumbbell_incline_press | dumbbell_press_family | fixed_dumbbells | horizontal_push | low | medium | hypertrophy | full_gym,small_gym,home_gym | horizontal_press_main |
| floor_press | floor_press_family | olympic_barbell | horizontal_push | medium | medium | strength,hypertrophy | full_gym,small_gym,home_gym | horizontal_press_main |
| machine_chest_press | machine_chest_press_family | machine_chest_press | horizontal_push | very_low | medium | hypertrophy | full_gym,small_gym | horizontal_press_stable |
| plate_loaded_chest_press | machine_chest_press_family | plate_loaded_chest_press | horizontal_push | low | medium | hypertrophy,strength | full_gym,small_gym | horizontal_press_stable |
| push_up_incline | push_up_family | wall | horizontal_push | very_low | low | general_fitness,recovery | home_gym,hotel,limited_access | horizontal_press_bodyweight |
| push_up_standard | push_up_family | floor_space | horizontal_push | low | medium | general_fitness,hypertrophy | home_gym,hotel,outdoor,limited_access | horizontal_press_bodyweight |
| push_up_deficit | push_up_family | bench_or_box | horizontal_push | medium | medium | hypertrophy | home_gym,small_gym | horizontal_press_bodyweight |
| push_up_feet_elevated | push_up_family | bench_or_box | horizontal_push | medium | medium | hypertrophy | home_gym,small_gym | horizontal_press_bodyweight |
| ring_push_up | ring_push_up_family | gym_rings | horizontal_push | medium | medium | hypertrophy,stability | home_gym,full_gym | horizontal_press_bodyweight |
| cable_press_standing | cable_press_family | cable_station_dual | horizontal_push | low | low | hypertrophy,stability | full_gym,small_gym | horizontal_press_stable |
| strict_barbell_press | overhead_press_family | olympic_barbell | vertical_push | medium | high | strength | full_gym,small_gym,home_gym | vertical_press_main |
| seated_dumbbell_press | dumbbell_shoulder_press_family | fixed_dumbbells | vertical_push | low | medium | hypertrophy | full_gym,small_gym,home_gym,hotel | vertical_press_main |
| standing_dumbbell_press | dumbbell_shoulder_press_family | fixed_dumbbells | vertical_push | low | medium | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | vertical_press_main |
| machine_shoulder_press | machine_shoulder_press_family | machine_shoulder_press | vertical_push | very_low | medium | hypertrophy | full_gym,small_gym | vertical_press_stable |
| plate_loaded_shoulder_press | machine_shoulder_press_family | plate_loaded_shoulder_press | vertical_push | low | medium | hypertrophy,strength | full_gym | vertical_press_stable |
| landmine_press_half_kneeling | landmine_press_family | landmine_setup | vertical_push | low | low | general_fitness,stability | full_gym,small_gym,home_gym | vertical_press_stable |
| kettlebell_strict_press | kettlebell_press_family | kettlebell_standard | vertical_push | medium | medium | strength,stability | home_gym,small_gym,hotel | vertical_press_main |
| push_press | push_press_family | olympic_barbell | vertical_push | high | high | power,strength | full_gym,small_gym,home_gym | vertical_press_power |
| split_jerk | jerk_family | olympic_barbell | vertical_push | very_high | high | power,strength_skill | full_gym,small_gym,home_gym | vertical_press_power |
| push_jerk | jerk_family | olympic_barbell | vertical_push | high | high | power,strength_skill | full_gym,small_gym,home_gym | vertical_press_power |
| handstand_hold_progression | handstand_family | wall | vertical_push | high | low | skill,stability | home_gym,full_gym | vertical_press_skill |
| handstand_push_up_progression | handstand_push_up_family | wall | vertical_push | very_high | medium | skill,strength | home_gym,full_gym | vertical_press_skill |
| bent_over_barbell_row | barbell_row_family | olympic_barbell | horizontal_pull | medium | high | strength,hypertrophy | full_gym,small_gym,home_gym | horizontal_pull_main |
| Pendlay_row | barbell_row_family | olympic_barbell | horizontal_pull | high | high | strength | full_gym,small_gym,home_gym | horizontal_pull_main |
| chest_supported_dumbbell_row | chest_supported_row_family | fixed_dumbbells | horizontal_pull | low | medium | hypertrophy | full_gym,small_gym,home_gym | horizontal_pull_stable |
| one_arm_dumbbell_row | dumbbell_row_family | fixed_dumbbells | horizontal_pull | low | medium | hypertrophy,general_fitness | full_gym,small_gym,home_gym,hotel | horizontal_pull_main |
| seated_cable_row | cable_row_family | seated_cable_row_station | horizontal_pull | very_low | medium | hypertrophy | full_gym,small_gym | horizontal_pull_stable |
| machine_row | machine_row_family | machine_row | horizontal_pull | very_low | medium | hypertrophy | full_gym,small_gym | horizontal_pull_stable |
| machine_high_row | machine_row_family | plate_loaded_high_row | horizontal_pull | low | medium | hypertrophy | full_gym | horizontal_pull_stable |
| inverted_row | inverted_row_family | power_rack | horizontal_pull | low | medium | general_fitness,skill | home_gym,hotel,outdoor | horizontal_pull_bodyweight |
| ring_row | ring_row_family | gym_rings | horizontal_pull | low | medium | general_fitness,stability | home_gym,outdoor | horizontal_pull_bodyweight |
| pull_up_band_assisted | assisted_pull_up_family | long_resistance_band | vertical_pull | low | medium | strength,skill | full_gym,small_gym,home_gym | vertical_pull_main |
| pull_up_eccentric | assisted_pull_up_family | pull_up_bar | vertical_pull | medium | medium | strength,skill | full_gym,small_gym,home_gym | vertical_pull_main |
| strict_pull_up | pull_up_family | pull_up_bar | vertical_pull | high | high | strength,hypertrophy | full_gym,small_gym,home_gym | vertical_pull_main |
| chin_up | chin_up_family | pull_up_bar | vertical_pull | medium | high | strength,hypertrophy | full_gym,small_gym,home_gym | vertical_pull_main |
| neutral_grip_pull_up | pull_up_family | pull_up_bar | vertical_pull | high | high | strength,hypertrophy | full_gym,small_gym,home_gym | vertical_pull_main |
| weighted_pull_up | pull_up_family | weighted_vest | vertical_pull | very_high | high | strength | full_gym,small_gym,home_gym | vertical_pull_main |
| lat_pulldown_pronated | lat_pulldown_family | lat_pulldown_station | vertical_pull | very_low | medium | hypertrophy | full_gym,small_gym | vertical_pull_stable |
| lat_pulldown_neutral | lat_pulldown_family | machine_lat_pulldown | vertical_pull | very_low | medium | hypertrophy | full_gym,small_gym | vertical_pull_stable |
| single_arm_pulldown | lat_pulldown_family | cable_station_dual | vertical_pull | low | low | hypertrophy,stability | full_gym,small_gym | vertical_pull_stable |
| banded_lat_pulldown | lat_pulldown_family | long_resistance_band | vertical_pull | low | low | general_fitness,hotel | home_gym,hotel,limited_access | vertical_pull_stable |
| dumbbell_lateral_raise | lateral_raise_family | fixed_dumbbells | horizontal_push | very_low | low | hypertrophy | full_gym,small_gym,home_gym,hotel | delt_iso |
| cable_lateral_raise | lateral_raise_family | cable_station_dual | horizontal_push | low | low | hypertrophy | full_gym,small_gym | delt_iso |
| rear_delt_fly_dumbbell | rear_delt_family | fixed_dumbbells | horizontal_pull | very_low | low | hypertrophy | full_gym,small_gym,home_gym,hotel | rear_delt_iso |
| reverse_pec_deck | rear_delt_family | machine_reverse_pec_deck | horizontal_pull | very_low | low | hypertrophy | full_gym,small_gym | rear_delt_iso |
| barbell_curl | biceps_curl_family | olympic_barbell | horizontal_pull | low | low | hypertrophy | full_gym,small_gym,home_gym | arm_flexion_iso |
| dumbbell_supinating_curl | biceps_curl_family | fixed_dumbbells | horizontal_pull | very_low | low | hypertrophy | full_gym,small_gym,home_gym,hotel | arm_flexion_iso |
| hammer_curl | hammer_curl_family | fixed_dumbbells | horizontal_pull | very_low | low | hypertrophy | full_gym,small_gym,home_gym,hotel | arm_flexion_iso |
| preacher_curl_machine | preacher_curl_family | plate_loaded_preacher_curl | horizontal_pull | very_low | low | hypertrophy | full_gym | arm_flexion_iso |
| cable_pushdown | triceps_pushdown_family | cable_station_dual | vertical_push | very_low | low | hypertrophy | full_gym,small_gym | arm_extension_iso |
| overhead_cable_triceps_extension | overhead_triceps_extension_family | cable_station_dual | vertical_push | low | low | hypertrophy | full_gym,small_gym | arm_extension_iso |
| skullcrusher_EZ | skullcrusher_family | ez_bar | horizontal_push | low | medium | hypertrophy | full_gym,small_gym,home_gym | arm_extension_iso |
| leg_extension_machine | leg_extension_family | machine_leg_extension | squat_bilateral | very_low | low | hypertrophy | full_gym,small_gym | lower_iso |
| seated_leg_curl | leg_curl_family | machine_leg_curl_seated | hinge_bilateral | very_low | low | hypertrophy | full_gym,small_gym | lower_iso |
| lying_leg_curl | leg_curl_family | machine_leg_curl_lying | hinge_bilateral | very_low | low | hypertrophy | full_gym,small_gym | lower_iso |
| adductor_machine | adductor_family | machine_adductor | hip_abduction_adduction | very_low | low | hypertrophy,recovery | full_gym,small_gym | hip_iso |
| abductor_machine | abductor_family | machine_abductor | hip_abduction_adduction | very_low | low | hypertrophy,recovery | full_gym,small_gym | hip_iso |
| standing_calf_raise | calf_raise_family | machine_calf_raise | ankle_foot_complex | low | low | hypertrophy,sport_performance | full_gym,small_gym | calf_iso |
| seated_calf_raise | calf_raise_family | plate_loaded_calf_raise | ankle_foot_complex | low | low | hypertrophy,sport_performance | full_gym | calf_iso |
| tibialis_raise | tibialis_raise_family | wall | ankle_foot_complex | very_low | low | sport_performance,recovery | home_gym,hotel,limited_access | calf_iso |
| glute_kickback_machine | glute_kickback_family | machine_glute_kickback | hinge_unilateral | very_low | low | hypertrophy | full_gym,small_gym | glute_iso |
| cable_glute_kickback | glute_kickback_family | cable_station_dual | hinge_unilateral | low | low | hypertrophy | full_gym,small_gym | glute_iso |
| crunch | crunch_family | floor_space | anti_extension | very_low | low | general_fitness | home_gym,hotel,limited_access | trunk_flexion |
| cable_crunch | crunch_family | cable_station_dual | anti_extension | low | low | hypertrophy | full_gym,small_gym | trunk_flexion |
| reverse_crunch | reverse_crunch_family | floor_space | anti_extension | low | low | general_fitness | home_gym,hotel,limited_access | trunk_flexion |
| hanging_knee_raise | hanging_leg_raise_family | pull_up_bar | anti_extension | medium | medium | strength,general_fitness | full_gym,small_gym,home_gym | hanging_core |
| hanging_leg_raise | hanging_leg_raise_family | pull_up_bar | anti_extension | high | medium | strength,skill | full_gym,small_gym,home_gym | hanging_core |
| ab_wheel_rollout | ab_wheel_family | floor_space | anti_extension | medium | medium | strength,stability | home_gym,small_gym | anti_extension_core |
| front_plank | plank_family | floor_space | anti_extension | very_low | low | recovery,stability | home_gym,hotel,limited_access | anti_extension_core |
| side_plank | side_plank_family | floor_space | anti_lateral_flexion | very_low | low | recovery,stability | home_gym,hotel,limited_access | anti_lateral_core |
| dead_bug | dead_bug_family | floor_space | anti_extension | very_low | low | recovery,stability | home_gym,hotel,limited_access | anti_extension_core |
| bird_dog | bird_dog_family | floor_space | anti_rotation | very_low | low | recovery,stability | home_gym,hotel,limited_access | anti_rotation_core |
| pallof_press | pallof_press_family | cable_station_dual | anti_rotation | low | low | sport_performance,stability | full_gym,small_gym,home_gym | anti_rotation_core |
| cable_chop | chop_family | cable_station_dual | rotation | low | low | sport_performance,hypertrophy | full_gym,small_gym | rotation_core |
| farmers_carry | farmers_carry_family | fixed_dumbbells | carry | low | medium | strength,conditioning | full_gym,small_gym,home_gym,outdoor | loaded_carry |
| heavy_farmers_carry | farmers_carry_family | farmers_handles | carry | medium | high | strength | full_gym,outdoor | loaded_carry |
| suitcase_carry | suitcase_carry_family | fixed_dumbbells | carry | low | medium | stability,conditioning | full_gym,small_gym,home_gym,hotel | loaded_carry |
| front_rack_carry | front_rack_carry_family | kettlebell_standard | carry | medium | medium | strength,stability | home_gym,small_gym,outdoor | loaded_carry |
| overhead_carry | overhead_carry_family | kettlebell_standard | carry | medium | medium | stability,sport_performance | home_gym,small_gym,outdoor | loaded_carry |
| sandbag_bear_hug_carry | sandbag_carry_family | sandbag_heavy | carry | medium | high | conditioning,strength | home_gym,outdoor | loaded_carry |
| yoke_carry | yoke_carry_family | yoke | carry | high | high | strength | full_gym,outdoor | loaded_carry |
| sled_push_heavy | sled_push_family | sled_push | locomotion | low | high | strength,conditioning | full_gym,outdoor | sled_work |
| sled_push_conditioning | sled_push_family | sled_push | locomotion | low | medium | conditioning,fat_loss | full_gym,outdoor | sled_work |
| sled_drag_backward | sled_drag_family | sled_pull | locomotion | low | medium | conditioning,recovery | full_gym,outdoor | sled_work |
| treadmill_walk | treadmill_family | treadmill | gait_cyclical | very_low | low | recovery,fat_loss | full_gym,small_gym,hotel | steady_cardio |
| treadmill_incline_walk | treadmill_family | treadmill | gait_cyclical | low | medium | fat_loss,conditioning | full_gym,small_gym,hotel | steady_cardio |
| treadmill_run_intervals | treadmill_family | treadmill | gait_cyclical | medium | high | conditioning,sport_performance | full_gym,small_gym,hotel | interval_cardio |
| upright_bike_easy | bike_family | upright_bike | gait_cyclical | very_low | low | recovery,general_fitness | full_gym,small_gym,hotel | steady_cardio |
| spin_bike_tempo | bike_family | spin_bike | gait_cyclical | medium | medium | conditioning | full_gym,small_gym | steady_cardio |
| bike_erg_steady | bike_family | bike_erg | gait_cyclical | low | medium | aerobic_base,conditioning | full_gym,small_gym,home_gym | steady_cardio |
| air_bike_intervals | air_bike_family | air_bike | gait_cyclical | medium | high | conditioning,power | full_gym,small_gym,home_gym | interval_cardio |
| row_erg_steady | row_erg_family | row_erg | gait_cyclical | low | medium | aerobic_base,conditioning | full_gym,small_gym,home_gym | steady_cardio |
| row_erg_power_intervals | row_erg_family | row_erg | gait_cyclical | medium | high | conditioning,power | full_gym,small_gym,home_gym | interval_cardio |
| ski_erg_intervals | ski_erg_family | ski_erg | gait_cyclical | medium | high | conditioning | full_gym,small_gym | interval_cardio |
| elliptical_steady | elliptical_family | elliptical | gait_cyclical | very_low | low | recovery,conditioning | full_gym,small_gym,hotel | steady_cardio |
| stair_climber_steady | stair_climber_family | stair_climber | gait_cyclical | low | medium | conditioning,fat_loss | full_gym,small_gym | steady_cardio |
| jump_rope_basic | jump_rope_family | jump_rope | gait_cyclical | low | medium | conditioning,sport_performance | home_gym,hotel,outdoor,limited_access | interval_cardio |
| jump_rope_intervals | jump_rope_family | jump_rope | gait_cyclical | medium | high | conditioning,sport_performance | home_gym,hotel,outdoor,limited_access | interval_cardio |
| countermovement_jump | vertical_jump_family | floor_space | jump | low | medium | power,sport_performance | home_gym,outdoor,limited_access | jump_power |
| squat_jump | vertical_jump_family | floor_space | jump | low | medium | power,sport_performance | home_gym,outdoor,limited_access | jump_power |
| box_jump | box_jump_family | plyo_box | jump | medium | medium | power,sport_performance | full_gym,small_gym,home_gym | jump_power |
| broad_jump | broad_jump_family | floor_space | jump | low | medium | power,sport_performance | home_gym,outdoor | jump_power |
| hurdle_jump | box_jump_family | hurdles | jump | medium | high | power,sport_performance | full_gym,outdoor | jump_power |
| depth_jump | depth_jump_family | plyo_box | jump | high | high | power,sport_performance | full_gym,small_gym | jump_power |
| single_leg_hop | single_leg_hop_family | floor_space | hop | medium | high | sport_performance | home_gym,outdoor | unilateral_jump |
| skater_bound | skater_bound_family | floor_space | bound | medium | medium | sport_performance | home_gym,outdoor | unilateral_jump |
| med_ball_slam | med_ball_slam_family | slam_ball | throw | low | medium | power,conditioning | full_gym,small_gym,home_gym,outdoor | medball_power |
| med_ball_chest_pass | med_ball_throw_family | medicine_ball | throw | low | low | power,sport_performance | full_gym,small_gym,outdoor | medball_power |
| med_ball_rotational_throw | rotational_throw_family | medicine_ball | throw | medium | medium | power,sport_performance | full_gym,small_gym,outdoor | medball_power |
| med_ball_scoop_toss | rotational_throw_family | medicine_ball | throw | medium | medium | power,sport_performance | full_gym,small_gym,outdoor | medball_power |
| front_squat_olympic | front_squat_family | olympic_barbell | squat_bilateral | high | high | strength_skill,power | full_gym,small_gym,home_gym | olympic_support |
| power_clean | power_clean_family | olympic_barbell | hinge_bilateral | very_high | high | power,strength_skill | full_gym,small_gym,home_gym | olympic_pull |
| hang_power_clean | power_clean_family | olympic_barbell | hinge_bilateral | high | high | power | full_gym,small_gym,home_gym | olympic_pull |
| squat_clean | clean_family | olympic_barbell | hinge_bilateral | very_high | high | power,strength_skill | full_gym,small_gym,home_gym | olympic_pull |
| power_snatch | power_snatch_family | olympic_barbell | hinge_bilateral | very_high | high | power | full_gym,small_gym,home_gym | olympic_pull |
| hang_power_snatch | power_snatch_family | olympic_barbell | hinge_bilateral | very_high | high | power | full_gym,small_gym,home_gym | olympic_pull |
| squat_snatch | snatch_family | olympic_barbell | hinge_bilateral | very_high | high | power,strength_skill | full_gym,small_gym,home_gym | olympic_pull |
| clean_pull | high_pull_family | olympic_barbell | hinge_bilateral | high | high | power,strength | full_gym,small_gym,home_gym | olympic_pull |
| snatch_pull | high_pull_family | olympic_barbell | hinge_bilateral | high | high | power,strength | full_gym,small_gym,home_gym | olympic_pull |
| high_pull | high_pull_family | olympic_barbell | hinge_bilateral | high | high | power | full_gym,small_gym,home_gym | olympic_pull |
| kettlebell_deadlift | kettlebell_hinge_family | kettlebell_standard | hinge_bilateral | very_low | low | general_fitness | home_gym,hotel,limited_access | hinge_main |
| kettlebell_swing_two_hand | kettlebell_swing_family | kettlebell_standard | hinge_bilateral | medium | medium | power,conditioning | home_gym,hotel,limited_access | hinge_power |
| kettlebell_swing_one_hand | kettlebell_swing_family | kettlebell_standard | hinge_unilateral | medium | medium | power,conditioning | home_gym,hotel,limited_access | hinge_power |
| kettlebell_clean | kettlebell_clean_family | kettlebell_standard | hinge_bilateral | medium | medium | power,strength | home_gym,small_gym,hotel | kettlebell_complex |
| kettlebell_snatch | kettlebell_snatch_family | kettlebell_standard | hinge_bilateral | high | medium | power,conditioning | home_gym,small_gym | kettlebell_complex |
| kettlebell_goblet_squat | goblet_squat_family | kettlebell_standard | squat_bilateral | low | medium | hypertrophy,general_fitness | home_gym,hotel,limited_access | squat_main_light |
| kettlebell_front_rack_squat | front_squat_family | kettlebell_standard | squat_bilateral | medium | medium | hypertrophy,strength | home_gym,small_gym | squat_main_light |
| kettlebell_press | kettlebell_press_family | kettlebell_standard | vertical_push | medium | medium | strength,stability | home_gym,small_gym,hotel | vertical_press_main |
| kettlebell_push_press | kettlebell_press_family | kettlebell_standard | vertical_push | medium | medium | power,strength | home_gym,small_gym | vertical_press_power |
| kettlebell_row | kettlebell_row_family | kettlebell_standard | horizontal_pull | low | low | hypertrophy,general_fitness | home_gym,hotel | horizontal_pull_main |
| Turkish_get_up_full | Turkish_get_up_family | kettlebell_standard | mobility_dynamic | high | medium | stability,recovery | home_gym,small_gym | mobility_integrated |
| kettlebell_halo | Turkish_get_up_family | kettlebell_standard | mobility_dynamic | low | low | mobility,stability | home_gym,hotel | mobility_integrated |
| kettlebell_carry_suitcase | kettlebell_carry_family | kettlebell_standard | carry | low | medium | conditioning,stability | home_gym,hotel,outdoor | loaded_carry |
| dip_assisted | dip_family | dip_bars | vertical_push | medium | medium | strength,hypertrophy | full_gym,small_gym,home_gym | vertical_push_bodyweight |
| dip_strict | dip_family | dip_bars | vertical_push | high | high | strength,hypertrophy | full_gym,small_gym,home_gym | vertical_push_bodyweight |
| pull_up_progression | assisted_pull_up_family | pull_up_bar | vertical_pull | medium | medium | strength,skill | full_gym,small_gym,home_gym | vertical_pull_main |
| chin_up_progression | chin_up_family | pull_up_bar | vertical_pull | medium | medium | strength,hypertrophy | full_gym,small_gym,home_gym | vertical_pull_main |
| L_sit_tuck | L_sit_family | dip_bars | anti_extension | medium | low | skill,strength | full_gym,home_gym | bodyweight_skill_core |
| L_sit_full | L_sit_family | dip_bars | anti_extension | high | medium | skill,strength | full_gym,home_gym | bodyweight_skill_core |
| muscle_up_progression | muscle_up_family | gym_rings | vertical_pull | very_high | high | skill,power | full_gym,home_gym | advanced_skill |
| handstand_wall | handstand_family | wall | vertical_push | high | low | skill,stability | home_gym,full_gym | advanced_skill |
| handstand_free_progression | handstand_family | floor_space | vertical_push | very_high | low | skill,stability | home_gym,full_gym | advanced_skill |
| front_lever_tuck | front_lever_family | gym_rings | horizontal_pull | very_high | medium | skill,strength | full_gym,home_gym | advanced_skill |
| back_lever_tuck | back_lever_family | gym_rings | horizontal_pull | very_high | medium | skill,strength | full_gym,home_gym | advanced_skill |
| pseudo_planche_push_up | planche_family | floor_space | horizontal_push | very_high | medium | skill,strength | home_gym,full_gym | advanced_skill |
| shoulder_CARs | CARs_family | floor_space | mobility_articular | very_low | low | recovery,mobility | home_gym,hotel,limited_access | mobility_articular |
| hip_CARs | CARs_family | floor_space | mobility_articular | very_low | low | recovery,mobility | home_gym,hotel,limited_access | mobility_articular |
| ankle_CARs | CARs_family | floor_space | mobility_articular | very_low | low | recovery,mobility | home_gym,hotel,limited_access | mobility_articular |
| thoracic_rotation_mobility | dynamic_mobility_family | floor_space | mobility_dynamic | very_low | low | recovery,mobility | home_gym,hotel,limited_access | mobility_integrated |
| couch_stretch | static_stretch_family | wall | mobility_dynamic | very_low | low | recovery,mobility | home_gym,hotel,limited_access | mobility_static |
| hamstring_dynamic_sweep | dynamic_mobility_family | floor_space | mobility_dynamic | very_low | low | recovery,mobility | home_gym,hotel,outdoor | mobility_integrated |
| wall_slide | scapular_control_family | wall | scapular_control | very_low | low | recovery,stability | home_gym,hotel,limited_access | scap_prep |
| band_external_rotation | activation_family | long_resistance_band | corrective_activation | very_low | low | recovery,stability | home_gym,hotel,limited_access | shoulder_prep |
| glute_bridge_iso | activation_family | floor_space | corrective_activation | very_low | low | recovery,stability | home_gym,hotel,limited_access | lower_prep |
| calf_isometric | tendon_isometric_family | wall | corrective_activation | very_low | low | recovery,rehab | home_gym,hotel,limited_access | tendon_iso |
| split_squat_isometric | tendon_isometric_family | wall | corrective_activation | low | low | recovery,rehab | home_gym,hotel,limited_access | tendon_iso |
| single_leg_balance_reach | balance_proprioception_family | floor_space | corrective_integration | low | low | recovery,rehab | home_gym,hotel,outdoor | balance_rts |
| neck_isometric_flexion | neck_isometric_family | floor_space | neck | very_low | low | recovery,sport_performance | home_gym,hotel,limited_access | neck_basic |
| neck_isometric_extension | neck_isometric_family | floor_space | neck | very_low | low | recovery,sport_performance | home_gym,hotel,limited_access | neck_basic |
| neck_isometric_lateral | neck_isometric_family | floor_space | neck | very_low | low | recovery,sport_performance | home_gym,hotel,limited_access | neck_basic |

---

## 6. Seed notes

### 6.1 Interpretacion practica

Esta semilla ya permite:

- entrenamientos de fuerza
- hipertrofia
- general fitness
- cardio util
- opciones de home gym y hotel
- una base de potencia
- trabajo de core
- preparacion y recuperacion basica

### 6.2 Lo que todavia falta despues de esta semilla

- cola larga de maquinas poco comunes
- mas variantes de strongman
- mas progression trees de calistenia
- mas rehab especifico por articulacion
- mas deportes de nicho

---

## 7. Siguiente paso recomendado

Documentos siguientes sugeridos:

1. `VITAL-DOMAIN-SCHEMA-v1.md`
   - traducir esto a tablas y enums implementables

2. `VITAL-SUBSTITUTION-RULES-v1.md`
   - detallar sustituciones concretas por grupo

3. `VITAL-CATALOG-QA-CHECKLIST-v1.md`
   - checklist para validar coherencia del seed

Recomendacion:

el siguiente documento con mas valor tecnico es `VITAL-DOMAIN-SCHEMA-v1.md`.
