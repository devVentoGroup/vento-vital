import React, { useEffect, useMemo, useState } from "react";
import { ScrollView, Text, View } from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import * as Haptics from "expo-haptics";
import { VButton } from "../components/VButton";
import { VCard } from "../components/VCard";
import { VOptionChip } from "../components/VOptionChip";
import { VSectionHeader } from "../components/VSectionHeader";

const OBJECTIVE_OPTIONS = [
  { key: "general_health", label: "Salud general", hint: "Energía diaria, constancia y bienestar." },
  { key: "hypertrophy", label: "Hipertrofia", hint: "Ganar masa con progresión estructurada." },
  { key: "strength", label: "Fuerza", hint: "Subir rendimiento en patrones base." }
];

const DAY_OPTIONS = [2, 3, 4, 5, 6];
const MINUTES_OPTIONS = [20, 30, 45, 60, 75, 90];
const PROFILE_CONTEXT_OPTIONS = [
  { key: "personal", label: "Personal", hint: "Sistema personal de entrenamiento, salud y hábitos." },
  { key: "employee", label: "Empleado", hint: "Rutina condicionada por turnos, operación o agenda laboral." }
];
const MODULE_OPTIONS = [
  { key: "training", label: "Entrenamiento" },
  { key: "nutrition", label: "Nutrición" },
  { key: "habits", label: "Hábitos" },
  { key: "recovery", label: "Recuperación" }
];
const SPORT_OPTIONS = [
  { key: "football", label: "Fútbol" },
  { key: "gym", label: "Gimnasio" },
  { key: "volleyball", label: "Voleibol" },
  { key: "taekwondo", label: "Taekwondo" },
  { key: "basketball", label: "Basquet" },
  { key: "cycling", label: "Ciclismo" },
  { key: "swimming", label: "Natación" },
  { key: "padel", label: "Padel" }
];
const SPORTS_OBJECTIVES = [
  { key: "performance", label: "Rendimiento" },
  { key: "strength", label: "Fuerza" },
  { key: "aesthetics", label: "Estética" },
  { key: "fat_loss", label: "Pérdida de grasa" },
  { key: "health", label: "Salud general" }
];
const SAFETY_QUESTIONS = [
  { key: "chest_pain", label: "Dolor torácico reciente" },
  { key: "dizziness", label: "Mareos severos" },
  { key: "severe_injury", label: "Lesión aguda importante" },
  { key: "post_surgery", label: "Poscirugía reciente" },
  { key: "pregnancy_risk", label: "Embarazo de riesgo" }
];
const EXPERIENCE_OPTIONS = [
  { key: "beginner", label: "Principiante", hint: "Vital reducirá complejidad y priorizará constancia." },
  { key: "intermediate", label: "Intermedio", hint: "Vital puede trabajar progresión base con más especificidad." },
  { key: "advanced", label: "Avanzado", hint: "Vital asumirá más tolerancia de carga y decisión deportiva." }
];
const STEP_META = [
  { id: 1, title: "Bienvenida", eyebrow: "Paso 1 · Inicio" },
  { id: 2, title: "Tu base", eyebrow: "Paso 2 · Base" },
  { id: 3, title: "Tu contexto", eyebrow: "Paso 3 · Contexto" },
  { id: 4, title: "Tu primera vista", eyebrow: "Paso 4 · Resultado" }
];

function getLabelByKey(options, key, fallback = "Sin definir") {
  return options.find((item) => item.key === key)?.label || fallback;
}

function getExperienceLabel(experienceLevel) {
  return getLabelByKey(EXPERIENCE_OPTIONS, experienceLevel, "Intermedio");
}

function getOnboardingSignature({ objective, profileContext, experienceLevel, primarySport, modules, hasCriticalSafetyFlag }) {
  if (hasCriticalSafetyFlag) {
    return {
      title: "Inicio cuidadoso y controlado",
      subtitle: "Tu configuración priorizará seguridad, claridad y una progresión más conservadora.",
      emphasis: "Cuidado primero"
    };
  }

  if (objective === "strength" && modules.includes("training")) {
    return {
      title: "Base orientada a rendimiento",
      subtitle: `Vital favorecerá sesiones más estructuradas, con foco en fuerza, constancia y soporte de recuperación alrededor de ${getLabelByKey(SPORT_OPTIONS, primarySport, "tu deporte principal")}.`,
      emphasis: "Rendimiento"
    };
  }

  if (objective === "hypertrophy" && modules.includes("nutrition")) {
    return {
      title: "Base orientada a composición",
      subtitle: "Vital combinará entrenamiento y nutrición como frente principal para que el progreso se sienta medible desde temprano.",
      emphasis: "Composición"
    };
  }

  if (profileContext === "employee") {
    return {
      title: "Base adaptada a una agenda exigente",
      subtitle: `Vital priorizará decisiones más simples y sostenibles, ajustadas a un ritmo ${getExperienceLabel(experienceLevel).toLowerCase()} y compatible con tu contexto diario.`,
      emphasis: "Sostenibilidad"
    };
  }

  return {
    title: "Base equilibrada y flexible",
    subtitle: "Vital comenzará con una estructura clara, fácil de sostener y lo bastante personal para que el sistema se sienta tuyo desde el primer uso.",
    emphasis: "Equilibrio"
  };
}

function getPrioritySignals({ modules, selectedSports, sportsObjectives, hasCriticalSafetyFlag, daysPerWeek, minutesPerSession }) {
  const modulesPriority =
    modules.length > 0 ? modules.map((key) => getLabelByKey(MODULE_OPTIONS, key, key)).slice(0, 3).join(" · ") : "Sin módulos";
  const sportsPriority =
    selectedSports.length > 0 ? selectedSports.map((key) => getLabelByKey(SPORT_OPTIONS, key, key)).slice(0, 2).join(" · ") : "Sin deportes";
  const goalsPriority =
    sportsObjectives.length > 0 ? sportsObjectives.map((key) => getLabelByKey(SPORTS_OBJECTIVES, key, key)).slice(0, 2).join(" · ") : "Salud general";

  return [
    {
      label: "Lo primero que pesará",
      value: modulesPriority
    },
    {
      label: "Lente deportivo",
      value: sportsPriority
    },
    {
      label: "Objetivos visibles",
      value: goalsPriority
    },
    {
      label: "Ritmo inicial",
      value: hasCriticalSafetyFlag ? "Suave y controlado" : `${daysPerWeek} días · ${minutesPerSession} min`
    }
  ];
}

function createStyles(theme) {
  return {
    container: {
      flex: 1,
      padding: theme.spacing.md
    },
    content: {
      paddingBottom: theme.spacing.lg,
      gap: theme.spacing.md
    },
    wrapperCard: {
      padding: theme.spacing.md,
      gap: theme.spacing.md
    },
    hero: {
      borderWidth: 1,
      borderColor: theme.colors.borderStrong,
      borderRadius: theme.radius.xxl,
      overflow: "hidden",
      ...theme.elevations.card
    },
    heroInner: {
      padding: theme.spacing.lg,
      gap: 14
    },
    heroEyebrow: {
      ...theme.typography.label,
      color: theme.colors.accentBrandStrong
    },
    heroTitle: {
      color: theme.colors.textPrimary,
      ...theme.typography.h1
    },
    heroSubtitle: {
      color: theme.colors.textSecondary,
      fontSize: 14,
      lineHeight: 20,
      fontFamily: "AvenirNext-Regular"
    },
    progressWrap: {
      gap: 8
    },
    progressMetaRow: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      gap: 8
    },
    progressLabel: {
      color: theme.colors.textPrimary,
      fontSize: 12,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    progressHint: {
      color: theme.colors.textSecondary,
      fontSize: 11,
      fontFamily: "AvenirNext-Regular"
    },
    progressTrack: {
      height: 8,
      borderRadius: 999,
      backgroundColor: theme.colors.progressTrack,
      overflow: "hidden"
    },
    progressFill: {
      height: "100%",
      borderRadius: 999,
      backgroundColor: theme.colors.accentBrand
    },
    stepsRow: {
      flexDirection: "row",
      gap: 8
    },
    stepDot: {
      flex: 1,
      height: 4,
      borderRadius: 999
    },
    summaryBar: {
      ...theme.blocks.panel,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardAlt,
      gap: 4
    },
    summaryBarEyebrow: {
      ...theme.typography.label,
      color: theme.colors.accentBrandStrong
    },
    summaryBarText: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    systemBriefCard: {
      ...theme.blocks.action,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardAlt,
      gap: 10
    },
    systemBriefTitle: {
      color: theme.colors.textPrimary,
      fontSize: 15,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    systemBriefText: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 18,
      fontFamily: "AvenirNext-Regular"
    },
    pointsGrid: {
      gap: 8
    },
    pointCard: {
      ...theme.blocks.panel,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardMuted,
      gap: 4
    },
    pointTitle: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    pointText: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    signatureCard: {
      ...theme.blocks.action,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardAlt,
      gap: 8
    },
    signatureEyebrow: {
      ...theme.typography.label,
      color: theme.colors.accentBrandStrong
    },
    signatureTitle: {
      color: theme.colors.textPrimary,
      fontSize: 14,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    signatureText: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    sectionCard: {
      ...theme.blocks.action,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardMuted,
      gap: 12
    },
    sectionTitle: {
      color: theme.colors.textPrimary,
      fontSize: 15,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    sectionSubtitle: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    subsectionWrap: {
      gap: 8
    },
    fieldTitle: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    helper: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    warning: {
      color: theme.colors.warning,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-DemiBold"
    },
    error: {
      color: theme.colors.error,
      fontSize: 12,
      fontFamily: "AvenirNext-DemiBold"
    },
    optionsRow: {
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 8
    },
    divider: {
      height: 1,
      backgroundColor: theme.colors.border
    },
    architectureSummaryCard: {
      ...theme.blocks.action,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardAlt,
      gap: 10
    },
    architectureGrid: {
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 8
    },
    architectureCell: {
      flexGrow: 1,
      minWidth: 140,
      ...theme.blocks.panel,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardMuted,
      gap: 4
    },
    architectureLabel: {
      color: theme.colors.textSecondary,
      fontSize: 11,
      fontFamily: "AvenirNext-Regular"
    },
    architectureValue: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    previewHoyCard: {
      ...theme.blocks.action,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.accentBrandSoft,
      gap: 10
    },
    previewEyebrow: {
      ...theme.typography.label,
      color: theme.colors.accentBrandStrong
    },
    previewTitle: {
      color: theme.colors.textPrimary,
      fontSize: 15,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    previewText: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      lineHeight: 18,
      fontFamily: "AvenirNext-Regular"
    },
    previewList: {
      gap: 6
    },
    previewItem: {
      color: theme.colors.textPrimary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    signalsGrid: {
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 8
    },
    signalCard: {
      flexGrow: 1,
      minWidth: 140,
      ...theme.blocks.panel,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardMuted,
      gap: 4
    },
    signalLabel: {
      color: theme.colors.textSecondary,
      fontSize: 11,
      fontFamily: "AvenirNext-Regular"
    },
    signalValue: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    ctaRow: {
      flexDirection: "row",
      gap: 8
    }
  };
}

export function OnboardingScreen({ theme, flow }) {
  const styles = useMemo(() => createStyles(theme), [theme]);
  const [step, setStep] = useState(1);
  const [objective, setObjective] = useState("general_health");
  const [profileContext, setProfileContext] = useState("personal");
  const [daysPerWeek, setDaysPerWeek] = useState(3);
  const [minutesPerSession, setMinutesPerSession] = useState(45);
  const [modules, setModules] = useState(["training", "nutrition", "habits", "recovery"]);
  const [selectedSports, setSelectedSports] = useState(["gym"]);
  const [primarySport, setPrimarySport] = useState("gym");
  const [sportsObjectives, setSportsObjectives] = useState(["health"]);
  const [experienceLevel, setExperienceLevel] = useState("beginner");
  const [safety, setSafety] = useState({
    chest_pain: false,
    dizziness: false,
    severe_injury: false,
    post_surgery: false,
    pregnancy_risk: false
  });

  const progressPct = Math.round((step / STEP_META.length) * 100);
  const currentStep = STEP_META.find((item) => item.id === step) || STEP_META[0];
  const objectiveMeta = OBJECTIVE_OPTIONS.find((item) => item.key === objective) || OBJECTIVE_OPTIONS[0];
  const contextMeta = PROFILE_CONTEXT_OPTIONS.find((item) => item.key === profileContext) || PROFILE_CONTEXT_OPTIONS[0];
  const experienceMeta = EXPERIENCE_OPTIONS.find((item) => item.key === experienceLevel) || EXPERIENCE_OPTIONS[0];
  const hasCriticalSafetyFlag = SAFETY_QUESTIONS.some((question) => Boolean(safety[question.key]));
  const primarySportLabel = getLabelByKey(SPORT_OPTIONS, primarySport, "Sin definir");
  const selectedSportsLabel = selectedSports.length > 0 ? selectedSports.map((key) => getLabelByKey(SPORT_OPTIONS, key, key)).join(" · ") : "Sin deportes";
  const modulesLabel = modules.length > 0 ? modules.map((key) => getLabelByKey(MODULE_OPTIONS, key, key)).join(" · ") : "Sin módulos";
  const sportsObjectivesLabel =
    sportsObjectives.length > 0 ? sportsObjectives.map((key) => getLabelByKey(SPORTS_OBJECTIVES, key, key)).join(" · ") : "Sin objetivos";
  const onboardingSignature = useMemo(
    () =>
      getOnboardingSignature({
        objective,
        profileContext,
        experienceLevel,
        primarySport,
        modules,
        hasCriticalSafetyFlag
      }),
    [objective, profileContext, experienceLevel, primarySport, modules, hasCriticalSafetyFlag]
  );
  const prioritySignals = useMemo(
    () =>
      getPrioritySignals({
        modules,
        selectedSports,
        sportsObjectives,
        hasCriticalSafetyFlag,
        daysPerWeek,
        minutesPerSession
      }),
    [modules, selectedSports, sportsObjectives, hasCriticalSafetyFlag, daysPerWeek, minutesPerSession]
  );
  const previewNarrative = useMemo(() => {
    if (hasCriticalSafetyFlag) {
      return "Vital comenzará con una configuración cuidadosa. Priorizará control, recuperación y decisiones más seguras desde el primer día.";
    }
    if (modules.includes("training") && selectedSports.includes("gym")) {
      return "Vital abrirá con una vista centrada en entrenamiento, progreso sostenible y soporte claro para recuperación.";
    }
    if (modules.includes("training")) {
      return "Vital abrirá priorizando entrenamiento y tus deportes activos, con una estructura clara para mantener constancia sin perder enfoque.";
    }
    return "Vital abrirá con una vista ligera de hábitos, nutrición y recuperación, simple de seguir pero con dirección clara desde el inicio.";
  }, [hasCriticalSafetyFlag, modules, selectedSports]);

  useEffect(() => {
    if (!flow.hasSession) return;
    flow.loadModulePreferences().catch(() => {});
  }, [flow.hasSession]);

  function pulse() {
    Haptics.selectionAsync().catch(() => {});
  }

  function toggleModule(moduleKey) {
    pulse();
    setModules((prev) => (prev.includes(moduleKey) ? prev.filter((item) => item !== moduleKey) : [...prev, moduleKey]));
  }

  function toggleSport(sportKey) {
    pulse();
    setSelectedSports((prev) => {
      const exists = prev.includes(sportKey);
      const next = exists ? prev.filter((item) => item !== sportKey) : [...prev, sportKey];
      if (!next.includes(primarySport)) setPrimarySport(next[0] || "");
      return next;
    });
  }

  function toggleSportsObjective(objectiveKey) {
    pulse();
    setSportsObjectives((prev) =>
      prev.includes(objectiveKey) ? prev.filter((item) => item !== objectiveKey) : [...prev, objectiveKey]
    );
  }

  function toggleSafety(key) {
    pulse();
    setSafety((prev) => ({ ...prev, [key]: !prev[key] }));
  }

  function canGoNext() {
    if (step === 3) return modules.length > 0 && selectedSports.length > 0;
    return true;
  }

  async function submitOnboarding() {
    const sportsPayload = selectedSports.map((key, idx) => ({
      key,
      priority: idx === 0 ? "A" : idx === 1 ? "B" : "C",
      level: experienceLevel
    }));
    await flow.onCompleteOnboarding({
      objective,
      profileContext,
      daysPerWeek,
      minutesPerSession,
      modules,
      experienceLevel,
      sportsProfile: {
        sports: sportsPayload,
        primary_sport: primarySport || selectedSports[0] || null,
        global_objectives: sportsObjectives,
        constraints: {
          days_per_week: daysPerWeek,
          minutes_per_session: minutesPerSession
        },
        cycle_config: {
          dominant_focus: "balanced",
          cycle_weeks: 4
        }
      },
      safety
    });
  }

  return (
    <View style={styles.container}>
      <ScrollView contentContainerStyle={styles.content} showsVerticalScrollIndicator={false}>
        <VCard theme={theme} tone="muted" style={styles.wrapperCard}>
          <View style={styles.hero}>
            <LinearGradient
              colors={
                theme.mode === "dark"
                  ? [theme.colors.surfaceHero, theme.colors.card, theme.colors.surface]
                  : [theme.colors.surfaceHero, theme.colors.card, theme.colors.surface]
              }
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
              style={styles.heroInner}
            >
              <Text style={styles.heroEyebrow}>VENTO VITAL</Text>
              <Text style={styles.heroTitle}>Creamos tu punto de partida</Text>
              <Text style={styles.heroSubtitle}>
                En unos pocos pasos vamos a ajustar Vital a tu realidad para que lo primero que veas tenga sentido para ti desde el primer día.
              </Text>
              <View style={styles.progressWrap}>
                <View style={styles.progressMetaRow}>
                  <Text style={styles.progressLabel}>{currentStep.eyebrow}</Text>
                  <Text style={styles.progressHint}>{`${progressPct}% listo`}</Text>
                </View>
                <View style={styles.progressTrack}>
                  <View style={[styles.progressFill, { width: `${progressPct}%` }]} />
                </View>
                <View style={styles.stepsRow}>
                  {STEP_META.map((item) => (
                    <View
                      key={item.id}
                      style={[
                        styles.stepDot,
                        {
                          backgroundColor: item.id <= step ? theme.colors.accentBrand : theme.colors.progressTrack
                        }
                      ]}
                    />
                  ))}
                </View>
              </View>
            </LinearGradient>
          </View>

          <VSectionHeader
            theme={theme}
            title={currentStep.title}
            subtitle="Una configuración breve, clara y pensada para que tu primera experiencia se sienta personal y valiosa."
          />

          <View style={styles.summaryBar}>
            <Text style={styles.summaryBarEyebrow}>TU SELECCIÓN ACTUAL</Text>
            <Text style={styles.summaryBarText}>{`${objectiveMeta.label} · ${contextMeta.label} · ${experienceMeta.label} · ${daysPerWeek} días · ${minutesPerSession} min`}</Text>
          </View>

          {step === 1 ? (
            <>
              <View style={styles.systemBriefCard}>
                <Text style={styles.systemBriefTitle}>Tu experiencia empieza con una base hecha para ti.</Text>
                <Text style={styles.systemBriefText}>
                  Aquí definimos lo esencial para que Vital se adapte a tu objetivo, a tu ritmo y a la forma en que realmente vives y entrenas.
                </Text>
              </View>
              <View style={styles.pointsGrid}>
                <View style={styles.pointCard}>
                  <Text style={styles.pointTitle}>Qué tendrá en cuenta</Text>
                  <Text style={styles.pointText}>Tu objetivo, tu experiencia, tus deportes, tu disponibilidad y cualquier señal importante de cuidado.</Text>
                </View>
                <View style={styles.pointCard}>
                  <Text style={styles.pointTitle}>Qué verás al terminar</Text>
                  <Text style={styles.pointText}>Entrarás directamente a `HOY`, con una vista clara y lista para empezar en lugar de una pantalla de configuración fría.</Text>
                </View>
                <View style={styles.pointCard}>
                  <Text style={styles.pointTitle}>Qué mantendremos simple</Text>
                  <Text style={styles.pointText}>Solo te pediremos lo necesario para darte una experiencia fuerte desde el inicio. El resto se ajustará más adelante.</Text>
                </View>
              </View>
            </>
          ) : null}

          {step === 2 ? (
            <View style={styles.sectionCard}>
              <Text style={styles.sectionTitle}>Tu base</Text>
              <Text style={styles.sectionSubtitle}>Define el enfoque con el que Vital empezará a organizar tus recomendaciones y tu ritmo semanal.</Text>

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Foco principal</Text>
                <View style={styles.optionsRow}>
                  {OBJECTIVE_OPTIONS.map((option) => (
                    <VOptionChip
                      key={option.key}
                      theme={theme}
                      active={objective === option.key}
                      onPress={() => {
                        pulse();
                        setObjective(option.key);
                      }}
                      label={option.label}
                    />
                  ))}
                </View>
                <Text style={styles.helper}>{objectiveMeta.hint}</Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Contexto de uso</Text>
                <View style={styles.optionsRow}>
                  {PROFILE_CONTEXT_OPTIONS.map((option) => (
                    <VOptionChip
                      key={option.key}
                      theme={theme}
                      active={profileContext === option.key}
                      onPress={() => {
                        pulse();
                        setProfileContext(option.key);
                      }}
                      label={option.label}
                    />
                  ))}
                </View>
                <Text style={styles.helper}>{contextMeta.hint}</Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Nivel de experiencia</Text>
                <View style={styles.optionsRow}>
                  {EXPERIENCE_OPTIONS.map((option) => (
                    <VOptionChip
                      key={option.key}
                      theme={theme}
                      active={experienceLevel === option.key}
                      onPress={() => {
                        pulse();
                        setExperienceLevel(option.key);
                      }}
                      label={option.label}
                    />
                  ))}
                </View>
                <Text style={styles.helper}>{experienceMeta.hint}</Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Disponibilidad semanal</Text>
                <View style={styles.optionsRow}>
                  {DAY_OPTIONS.map((day) => (
                    <VOptionChip
                      key={day}
                      theme={theme}
                      active={daysPerWeek === day}
                      onPress={() => {
                        pulse();
                        setDaysPerWeek(day);
                      }}
                      label={`${day} días`}
                    />
                  ))}
                </View>
                <View style={styles.optionsRow}>
                  {MINUTES_OPTIONS.map((minute) => (
                    <VOptionChip
                      key={minute}
                      theme={theme}
                      active={minutesPerSession === minute}
                      onPress={() => {
                        pulse();
                        setMinutesPerSession(minute);
                      }}
                      label={`${minute} min`}
                    />
                  ))}
                </View>
                <Text style={styles.helper}>Esto ayuda a que Vital te proponga algo realista, sostenible y acorde a tu semana.</Text>
              </View>

              <View style={styles.signatureCard}>
                <Text style={styles.signatureEyebrow}>{onboardingSignature.emphasis}</Text>
                <Text style={styles.signatureTitle}>{onboardingSignature.title}</Text>
                <Text style={styles.signatureText}>{onboardingSignature.subtitle}</Text>
              </View>
            </View>
          ) : null}

          {step === 3 ? (
            <View style={styles.sectionCard}>
              <Text style={styles.sectionTitle}>Tu contexto</Text>
              <Text style={styles.sectionSubtitle}>Elige las áreas que quieres trabajar, los deportes que practicas y cualquier señal importante para cuidarte mejor.</Text>

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Módulos activos</Text>
                <View style={styles.optionsRow}>
                  {MODULE_OPTIONS.map((option) => (
                    <VOptionChip
                      key={option.key}
                      theme={theme}
                      active={modules.includes(option.key)}
                      onPress={() => toggleModule(option.key)}
                      label={option.label}
                    />
                  ))}
                </View>
                <Text style={styles.helper}>{modules.length > 0 ? `Seleccionaste: ${modulesLabel}` : "Activa al menos un módulo."}</Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Deportes activos</Text>
                <View style={styles.optionsRow}>
                  {SPORT_OPTIONS.map((sport) => (
                    <VOptionChip
                      key={sport.key}
                      theme={theme}
                      active={selectedSports.includes(sport.key)}
                      onPress={() => toggleSport(sport.key)}
                      label={sport.label}
                    />
                  ))}
                </View>
                <Text style={styles.helper}>
                  {selectedSports.length > 0 ? `Tus deportes activos: ${selectedSportsLabel}` : "Selecciona al menos un deporte activo."}
                </Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Deporte principal</Text>
                <View style={styles.optionsRow}>
                  {selectedSports.length === 0 ? (
                    <Text style={styles.helper}>Selecciona deportes para definir prioridad principal.</Text>
                  ) : (
                    selectedSports.map((sportKey) => (
                      <VOptionChip
                        key={`primary-${sportKey}`}
                        theme={theme}
                        active={primarySport === sportKey}
                        onPress={() => {
                          pulse();
                          setPrimarySport(sportKey);
                        }}
                        label={`${getLabelByKey(SPORT_OPTIONS, sportKey, sportKey)} · principal`}
                      />
                    ))
                  )}
                </View>
              </View>

              <View style={styles.divider} />

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Objetivos deportivos</Text>
                <View style={styles.optionsRow}>
                  {SPORTS_OBJECTIVES.map((objectiveOption) => (
                    <VOptionChip
                      key={objectiveOption.key}
                      theme={theme}
                      active={sportsObjectives.includes(objectiveOption.key)}
                      onPress={() => toggleSportsObjective(objectiveOption.key)}
                      label={objectiveOption.label}
                    />
                  ))}
                </View>
                <Text style={styles.helper}>{sportsObjectivesLabel}</Text>
              </View>

              <View style={styles.divider} />

              <View style={styles.subsectionWrap}>
                <Text style={styles.fieldTitle}>Seguridad rápida</Text>
                <View style={styles.optionsRow}>
                  {SAFETY_QUESTIONS.map((question) => (
                    <VOptionChip
                      key={question.key}
                      theme={theme}
                      active={safety[question.key]}
                      onPress={() => toggleSafety(question.key)}
                      label={`${safety[question.key] ? "Sí" : "No"} · ${question.label}`}
                    />
                  ))}
                </View>
                {hasCriticalSafetyFlag ? (
                  <Text style={styles.warning}>Vital comenzará con límites de seguridad activos para proponerte opciones más cuidadosas desde el inicio.</Text>
                ) : (
                  <Text style={styles.helper}>No marcaste señales críticas. Vital podrá comenzar con una base normal.</Text>
                )}
              </View>

              <View style={styles.signalsGrid}>
                {prioritySignals.map((signal) => (
                  <View key={signal.label} style={styles.signalCard}>
                    <Text style={styles.signalLabel}>{signal.label}</Text>
                    <Text style={styles.signalValue}>{signal.value}</Text>
                  </View>
                ))}
              </View>
            </View>
          ) : null}

          {step === 4 ? (
            <>
              <View style={styles.architectureSummaryCard}>
                <Text style={styles.sectionTitle}>Resumen de tu configuración</Text>
                <Text style={styles.sectionSubtitle}>Así quedará definida tu base inicial antes de empezar a usar Vital día a día.</Text>
                <View style={styles.architectureGrid}>
                  <View style={styles.architectureCell}>
                    <Text style={styles.architectureLabel}>Foco principal</Text>
                    <Text style={styles.architectureValue}>{objectiveMeta.label}</Text>
                  </View>
                  <View style={styles.architectureCell}>
                    <Text style={styles.architectureLabel}>Contexto</Text>
                    <Text style={styles.architectureValue}>{contextMeta.label}</Text>
                  </View>
                  <View style={styles.architectureCell}>
                    <Text style={styles.architectureLabel}>Experiencia</Text>
                    <Text style={styles.architectureValue}>{experienceMeta.label}</Text>
                  </View>
                  <View style={styles.architectureCell}>
                    <Text style={styles.architectureLabel}>Disponibilidad</Text>
                    <Text style={styles.architectureValue}>{`${daysPerWeek} días · ${minutesPerSession} min`}</Text>
                  </View>
                  <View style={styles.architectureCell}>
                    <Text style={styles.architectureLabel}>Sistema activo</Text>
                    <Text style={styles.architectureValue}>{modulesLabel}</Text>
                  </View>
                  <View style={styles.architectureCell}>
                    <Text style={styles.architectureLabel}>Deporte principal</Text>
                    <Text style={styles.architectureValue}>{primarySportLabel}</Text>
                  </View>
                </View>
              </View>

              <View style={styles.previewHoyCard}>
                <Text style={styles.previewEyebrow}>TU PRIMERA VISTA</Text>
                <Text style={styles.previewTitle}>Así se sentirá tu inicio en Vital</Text>
                <Text style={styles.previewText}>{previewNarrative}</Text>
                <View style={styles.signalsGrid}>
                  {prioritySignals.map((signal) => (
                    <View key={`preview-${signal.label}`} style={styles.signalCard}>
                      <Text style={styles.signalLabel}>{signal.label}</Text>
                      <Text style={styles.signalValue}>{signal.value}</Text>
                    </View>
                  ))}
                </View>
                <View style={styles.previewList}>
                  <Text style={styles.previewItem}>{`1. Prioridad dominante: ${objectiveMeta.label}.`}</Text>
                  <Text style={styles.previewItem}>{`2. Tu ritmo base será ${contextMeta.label} con ${daysPerWeek} días y sesiones de ${minutesPerSession} min.`}</Text>
                  <Text style={styles.previewItem}>{`3. Deporte principal: ${primarySportLabel}. Objetivos: ${sportsObjectivesLabel}.`}</Text>
                  <Text style={styles.previewItem}>
                    {hasCriticalSafetyFlag
                      ? "4. Vital empezará con mayor cuidado para proteger carga, intensidad y recuperación."
                      : "4. Vital podrá comenzar con recomendaciones normales y una base clara para tu día a día."}
                  </Text>
                </View>
              </View>
            </>
          ) : null}

          <View style={styles.ctaRow}>
            {step > 1 ? (
              <VButton
                theme={theme}
                variant="secondary"
                style={{ flex: 1 }}
                title="Anterior"
                onPress={() => {
                  pulse();
                  setStep((current) => Math.max(1, current - 1));
                }}
              />
            ) : null}

            {step < STEP_META.length ? (
              <VButton
                theme={theme}
                style={{ flex: 1 }}
                title={step === 1 ? "Construir base" : "Continuar"}
                disabled={!canGoNext()}
                onPress={() => {
                  pulse();
                  setStep((current) => Math.min(STEP_META.length, current + 1));
                }}
              />
            ) : (
              <VButton
                theme={theme}
                style={{ flex: 1 }}
                title={flow.onboardingLoading ? "Preparando tu sistema..." : "Entrar a HOY"}
                disabled={flow.onboardingLoading}
                onPress={submitOnboarding}
              />
            )}
          </View>

          {flow.onboardingError ? <Text style={styles.error}>{flow.onboardingError}</Text> : null}
        </VCard>
      </ScrollView>
    </View>
  );
}
