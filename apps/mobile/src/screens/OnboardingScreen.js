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
  { key: "personal", label: "Personal" },
  { key: "employee", label: "Empleado" }
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
  { key: "chest_pain", label: "Dolor toracico reciente" },
  { key: "dizziness", label: "Mareos severos" },
  { key: "severe_injury", label: "Lesion aguda importante" },
  { key: "post_surgery", label: "Poscirugia reciente" },
  { key: "pregnancy_risk", label: "Embarazo de riesgo" }
];
const EXPERIENCE_OPTIONS = [
  { key: "beginner", label: "Principiante" },
  { key: "intermediate", label: "Intermedio" },
  { key: "advanced", label: "Avanzado" }
];
const STEP_META = [
  { id: 1, title: "Base" },
  { id: 2, title: "Módulos y deportes" },
  { id: 3, title: "Seguridad" },
  { id: 4, title: "Disponibilidad" }
];

function createStyles(theme) {
  return {
    container: {
      flex: 1,
      padding: theme.spacing.md
    },
    content: {
      paddingBottom: theme.spacing.lg
    },
    hero: {
      ...theme.blocks.hero,
      overflow: "hidden",
      borderColor: theme.colors.progressBorder
    },
    heroInner: {
      padding: theme.spacing.sm,
      gap: 10
    },
    stepBadge: {
      alignSelf: "flex-start",
      borderWidth: 1,
      borderColor: theme.colors.progressBorder,
      backgroundColor: theme.colors.mintSoft,
      borderRadius: 999,
      paddingHorizontal: 10,
      paddingVertical: 4
    },
    stepBadgeText: {
      fontSize: 11,
      color: theme.colors.mintDark,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    progressTrack: {
      height: 6,
      borderRadius: 999,
      backgroundColor: theme.colors.progressTrack,
      overflow: "hidden"
    },
    progressFill: {
      height: "100%",
      borderRadius: 999,
      backgroundColor: theme.colors.mintPrimary
    },
    stepsRow: {
      flexDirection: "row",
      gap: 6
    },
    stepDot: {
      width: 9,
      height: 9,
      borderRadius: 999,
      borderWidth: 1
    },
    stepPanel: {
      ...theme.blocks.panel,
      borderColor: theme.colors.border,
      backgroundColor: theme.colors.card,
      gap: 8
    },
    sectionDivider: {
      height: 1,
      backgroundColor: theme.colors.border,
      marginVertical: 2
    },
    stepPanelTitle: {
      color: theme.colors.textPrimary,
      fontSize: 15,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    stepPanelSubtitle: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    sectionTitle: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    optionsRow: {
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 8
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
    ctaRow: {
      flexDirection: "row",
      gap: 8,
      marginTop: 4
    },
    guideCard: {
      ...theme.blocks.panel,
      borderColor: theme.colors.border,
      backgroundColor: theme.colors.card,
      gap: 6
    },
    guideTitle: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    guideText: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    }
  };
}

export function OnboardingScreen({ theme, flow }) {
  const styles = useMemo(() => createStyles(theme), [theme]);
  const heroColors = theme.mode === "dark" ? [theme.colors.surface, theme.colors.bg] : [theme.colors.mintSoft, theme.colors.surface];
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

  const stepGuide = useMemo(() => {
    if (step === 1) return "Define tu objetivo y nivel para crear un plan alineado contigo.";
    if (step === 2) return "Elige solo los módulos y deportes que realmente quieres usar.";
    if (step === 3) return "Validamos señales de riesgo para protegerte desde el inicio.";
    return "Ajustamos tu ritmo semanal para que el plan sea sostenible.";
  }, [step]);
  const progressPct = Math.round((step / 4) * 100);

  useEffect(() => {
    if (!flow.hasSession) return;
    flow.loadModulePreferences().catch(() => {});
  }, [flow.hasSession]);

  const hasCriticalSafetyFlag = SAFETY_QUESTIONS.some((q) => Boolean(safety[q.key]));

  function pulse() {
    Haptics.selectionAsync().catch(() => {});
  }

  function toggleModule(moduleKey) {
    pulse();
    setModules((prev) => (prev.includes(moduleKey) ? prev.filter((m) => m !== moduleKey) : [...prev, moduleKey]));
  }

  function toggleSport(sportKey) {
    pulse();
    setSelectedSports((prev) => {
      const exists = prev.includes(sportKey);
      const next = exists ? prev.filter((s) => s !== sportKey) : [...prev, sportKey];
      if (!next.includes(primarySport)) setPrimarySport(next[0] || "");
      return next;
    });
  }

  function toggleSportsObjective(objectiveKey) {
    pulse();
    setSportsObjectives((prev) =>
      prev.includes(objectiveKey) ? prev.filter((o) => o !== objectiveKey) : [...prev, objectiveKey]
    );
  }

  function toggleSafety(key) {
    pulse();
    setSafety((prev) => ({ ...prev, [key]: !prev[key] }));
  }

  function canGoNext() {
    if (step === 2) return modules.length > 0 && selectedSports.length > 0;
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
        <VCard theme={theme} tone="surface" style={{ padding: theme.spacing.md, gap: theme.spacing.sm }}>
        <View style={styles.hero}>
          <LinearGradient colors={heroColors} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={styles.heroInner}>
            <View style={styles.stepBadge}>
              <Text style={styles.stepBadgeText}>{`Paso ${step} de 4`}</Text>
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
                      borderColor: item.id <= step ? theme.colors.mintPrimaryDark : theme.colors.border,
                      backgroundColor: item.id <= step ? theme.colors.mintPrimary : theme.colors.card
                    }
                  ]}
                />
              ))}
            </View>
            <Text style={styles.helper}>{STEP_META.find((s) => s.id === step)?.title || ""}</Text>
          </LinearGradient>
        </View>

        <VSectionHeader
          theme={theme}
          title="Configura tu plan inicial"
          subtitle="Solo activamos lo que elijas. Sin combinaciones prearmadas."
        />
        <View style={styles.guideCard}>
          <Text style={styles.guideTitle}>{`Paso ${step}: ${STEP_META.find((s) => s.id === step)?.title || ""}`}</Text>
          <Text style={styles.guideText}>{stepGuide}</Text>
        </View>

        {step === 1 ? (
          <View style={styles.stepPanel}>
            <Text style={styles.stepPanelTitle}>Base de personalizacion</Text>
            <Text style={styles.stepPanelSubtitle}>Define enfoque inicial, contexto y nivel para personalizar el plan.</Text>

            <Text style={styles.sectionTitle}>Objetivo principal</Text>
            <View style={styles.optionsRow}>
              {OBJECTIVE_OPTIONS.map((opt) => (
                <VOptionChip
                  key={opt.key}
                  theme={theme}
                  active={objective === opt.key}
                  onPress={() => {
                    pulse();
                    setObjective(opt.key);
                  }}
                  label={opt.label}
                />
              ))}
            </View>
            <Text style={styles.helper}>{OBJECTIVE_OPTIONS.find((o) => o.key === objective)?.hint || ""}</Text>
            <View style={styles.sectionDivider} />

            <Text style={styles.sectionTitle}>Contexto</Text>
            <View style={styles.optionsRow}>
              {PROFILE_CONTEXT_OPTIONS.map((opt) => (
                <VOptionChip
                  key={opt.key}
                  theme={theme}
                  active={profileContext === opt.key}
                  onPress={() => {
                    pulse();
                    setProfileContext(opt.key);
                  }}
                  label={opt.label}
                />
              ))}
            </View>
            <View style={styles.sectionDivider} />

            <Text style={styles.sectionTitle}>Nivel de experiencia</Text>
            <View style={styles.optionsRow}>
              {EXPERIENCE_OPTIONS.map((opt) => (
                <VOptionChip
                  key={opt.key}
                  theme={theme}
                  active={experienceLevel === opt.key}
                  onPress={() => {
                    pulse();
                    setExperienceLevel(opt.key);
                  }}
                  label={opt.label}
                />
              ))}
            </View>
          </View>
        ) : null}

        {step === 2 ? (
          <View style={styles.stepPanel}>
            <Text style={styles.stepPanelTitle}>Modulos activos</Text>
            <Text style={styles.stepPanelSubtitle}>
              Selecciona modulos y deportes para personalizar el plan multideporte desde el inicio.
            </Text>
            <Text style={styles.sectionTitle}>Módulos activos</Text>
            <View style={styles.optionsRow}>
              {MODULE_OPTIONS.map((opt) => (
                <VOptionChip
                  key={opt.key}
                  theme={theme}
                  active={modules.includes(opt.key)}
                  onPress={() => toggleModule(opt.key)}
                  label={opt.label}
                />
              ))}
            </View>
            <Text style={styles.helper}>Puedes usar solo nutrición, solo hábitos o la combinación que prefieras.</Text>
            <Text style={styles.helper}>{`Configuración actual: ${modules.sort().join(" + ") || "sin módulos"}`}</Text>
            <View style={styles.sectionDivider} />

            <Text style={styles.sectionTitle}>Deportes activos</Text>
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
            <View style={styles.sectionDivider} />

            <Text style={styles.sectionTitle}>Deporte principal</Text>
            <View style={styles.optionsRow}>
              {selectedSports.length === 0 ? (
                <Text style={styles.helper}>Selecciona al menos un deporte activo.</Text>
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
                    label={`${SPORT_OPTIONS.find((s) => s.key === sportKey)?.label || sportKey} · principal`}
                  />
                ))
              )}
            </View>
            <View style={styles.sectionDivider} />

            <Text style={styles.sectionTitle}>Objetivos globales</Text>
            <View style={styles.optionsRow}>
              {SPORTS_OBJECTIVES.map((obj) => (
                <VOptionChip
                  key={obj.key}
                  theme={theme}
                  active={sportsObjectives.includes(obj.key)}
                  onPress={() => toggleSportsObjective(obj.key)}
                  label={obj.label}
                />
              ))}
            </View>
          </View>
        ) : null}

        {step === 3 ? (
          <View style={styles.stepPanel}>
            <Text style={styles.stepPanelTitle}>Seguridad</Text>
            <Text style={styles.stepPanelSubtitle}>Aplicamos bloqueos preventivos si detectamos señales de riesgo.</Text>
            <Text style={styles.sectionTitle}>Chequeo rápido de seguridad</Text>
            <View style={styles.optionsRow}>
              {SAFETY_QUESTIONS.map((q) => (
                <VOptionChip
                  key={q.key}
                  theme={theme}
                  active={safety[q.key]}
                  onPress={() => toggleSafety(q.key)}
                  label={`${safety[q.key] ? "Si" : "No"} · ${q.label}`}
                />
              ))}
            </View>
            {hasCriticalSafetyFlag ? (
              <Text style={styles.warning}>Se aplicarán bloqueos automáticos en módulos intensos.</Text>
            ) : null}
          </View>
        ) : null}

        {step === 4 ? (
          <View style={styles.stepPanel}>
            <Text style={styles.stepPanelTitle}>Disponibilidad</Text>
            <Text style={styles.stepPanelSubtitle}>Definimos carga semanal y tiempo objetivo por sesion.</Text>
            <Text style={styles.sectionTitle}>Dias por semana</Text>
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
                  label={`${day} dias`}
                />
              ))}
            </View>
            <View style={styles.sectionDivider} />
            <Text style={styles.sectionTitle}>Minutos por sesion</Text>
            <View style={styles.optionsRow}>
              {MINUTES_OPTIONS.map((min) => (
                <VOptionChip
                  key={min}
                  theme={theme}
                  active={minutesPerSession === min}
                  onPress={() => {
                    pulse();
                    setMinutesPerSession(min);
                  }}
                  label={`${min} min`}
                />
              ))}
            </View>
            <Text style={styles.helper}>
              {`Resumen: ${objective} · ${daysPerWeek} dias · ${minutesPerSession} min · nivel ${experienceLevel}`}
            </Text>
            {hasCriticalSafetyFlag && modules.includes("training") ? (
              <Text style={styles.warning}>
                Detectamos riesgo. Entrenamiento puede quedar bloqueado y se priorizarán módulos seguros.
              </Text>
            ) : null}
            <View style={styles.sectionDivider} />
            <Text style={styles.sectionTitle}>Resumen final</Text>
            <Text style={styles.helper}>{`Módulos: ${modules.length ? modules.join(", ") : "ninguno"}`}</Text>
            <Text style={styles.helper}>{`Deportes: ${selectedSports.length ? selectedSports.join(", ") : "ninguno"}`}</Text>
            <Text style={styles.helper}>{`Deporte principal: ${primarySport || "sin definir"}`}</Text>
          </View>
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
                setStep((s) => Math.max(1, s - 1));
              }}
            />
          ) : null}
          {step < 4 ? (
            <VButton
              theme={theme}
              style={{ flex: 1 }}
              title="Siguiente"
              disabled={!canGoNext()}
              onPress={() => {
                pulse();
                setStep((s) => Math.min(4, s + 1));
              }}
            />
          ) : (
            <VButton
              theme={theme}
              style={{ flex: 1 }}
              title={flow.onboardingLoading ? "Guardando plan..." : "Guardar y empezar"}
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
