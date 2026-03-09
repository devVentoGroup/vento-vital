import React, { useEffect, useMemo, useState } from "react";
import { Text, View } from "react-native";
import * as Haptics from "expo-haptics";
import { LinearGradient } from "expo-linear-gradient";
import { getProfile, saveProfile } from "../api/profileApi";
import { SkeletonBlock } from "../components/SkeletonBlock";
import { VButton } from "../components/VButton";
import { VCard } from "../components/VCard";
import { VInput } from "../components/VInput";
import { VOptionChip } from "../components/VOptionChip";
import { VSectionHeader } from "../components/VSectionHeader";

const CONTEXT_OPTIONS = [
  { key: "personal", label: "Personal" },
  { key: "employee", label: "Empleado" }
];

const COMPETITION_OPTIONS = [
  { key: "private", label: "Privado" },
  { key: "friends", label: "Amigos" },
  { key: "team", label: "Equipo" },
  { key: "public", label: "Público" }
];

const MODULE_CONFIG_OPTIONS = {
  training: [
    {
      key: "focus",
      label: "Foco",
      values: [
        { value: "strength", label: "Fuerza" },
        { value: "hypertrophy", label: "Hipertrofia" },
        { value: "consistency", label: "Constancia" }
      ]
    },
    {
      key: "intensity",
      label: "Intensidad",
      values: [
        { value: "low", label: "Baja" },
        { value: "medium", label: "Media" },
        { value: "high", label: "Alta" }
      ]
    }
  ],
  nutrition: [
    {
      key: "tracking_mode",
      label: "Seguimiento",
      values: [
        { value: "light", label: "Ligero" },
        { value: "balanced", label: "Balanceado" },
        { value: "strict", label: "Estricto" }
      ]
    },
    {
      key: "meal_structure",
      label: "Estructura",
      values: [
        { value: "flexible", label: "Flexible" },
        { value: "3_meals", label: "3 comidas" },
        { value: "4_meals", label: "4 comidas" }
      ]
    }
  ],
  habits: [
    {
      key: "habit_mode",
      label: "Modo",
      values: [
        { value: "minimal", label: "Minimo" },
        { value: "balanced", label: "Balanceado" },
        { value: "deep", label: "Profundo" }
      ]
    },
    {
      key: "reminder_density",
      label: "Recordatorios",
      values: [
        { value: "low", label: "Bajos" },
        { value: "medium", label: "Medios" },
        { value: "high", label: "Altos" }
      ]
    }
  ],
  recovery: [
    {
      key: "recovery_focus",
      label: "Foco",
      values: [
        { value: "sleep", label: "Sueno" },
        { value: "mobility", label: "Movilidad" },
        { value: "stress", label: "Estres" }
      ]
    },
    {
      key: "recovery_load",
      label: "Carga",
      values: [
        { value: "soft", label: "Suave" },
        { value: "balanced", label: "Balanceada" },
        { value: "intense", label: "Intensa" }
      ]
    }
  ]
};

const MODULE_DISPLAY = {
  training: "Entrenamiento",
  nutrition: "Nutrición",
  habits: "Hábitos",
  recovery: "Recuperación"
};

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

const CYCLE_FOCUS_OPTIONS = [
  { key: "balanced", label: "Balanceado" },
  { key: "sport_performance", label: "Rendimiento deportivo" },
  { key: "gym_power", label: "Potencia y fuerza" },
  { key: "recovery_first", label: "Recuperación prioritaria" }
];

function createStyles(theme) {
  return {
    section: { ...theme.blocks.section },
    hero: {
      borderWidth: 1,
      borderColor: theme.colors.progressBorder,
      borderRadius: theme.radius.xxl,
      overflow: "hidden",
      ...theme.elevations.card
    },
    heroInner: {
      padding: theme.spacing.md,
      gap: 10
    },
    heroTitle: {
      color: theme.colors.textPrimary,
      ...theme.typography.h1
    },
    heroSubtitle: {
      color: theme.colors.textSecondary,
      fontSize: 13,
      lineHeight: 18,
      fontFamily: "AvenirNext-Regular"
    },
    heroRow: {
      flexDirection: "row",
      gap: 8,
      flexWrap: "wrap"
    },
    subtitle: { fontSize: 13, color: theme.colors.textSecondary },
    divider: {
      height: 1,
      backgroundColor: theme.colors.border
    },
    statusRow: {
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 8
    },
    statusChip: {
      borderWidth: 1,
      borderRadius: 999,
      paddingHorizontal: 10,
      paddingVertical: 6
    },
    statusChipText: {
      fontSize: 11,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    row: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      paddingVertical: 6
    },
    label: {
      color: theme.colors.textSecondary,
      fontSize: 13,
      fontFamily: "AvenirNext-DemiBold"
    },
    value: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      fontWeight: "600",
      fontFamily: "AvenirNext-DemiBold"
    },
    optionsRow: {
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 8
    },
    moduleConfigCard: {
      ...theme.blocks.panel,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardAlt,
      gap: 8
    },
    moduleConfigTitle: {
      color: theme.colors.textPrimary,
      fontSize: 13,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    moduleConfigLabel: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      fontFamily: "AvenirNext-Regular"
    },
    sportsHint: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    error: { color: theme.colors.error, fontSize: 12, fontFamily: "AvenirNext-DemiBold" },
    success: { color: theme.colors.success, fontSize: 12, fontFamily: "AvenirNext-DemiBold" }
  };
}

function toggleListItem(current, key) {
  if (current.includes(key)) return current.filter((x) => x !== key);
  return [...current, key];
}

export function ProfileScreen({ theme, profile, flow }) {
  const styles = createStyles(theme);
  const [displayName, setDisplayName] = useState("");
  const [timezone, setTimezone] = useState("America/Bogota");
  const [profileContext, setProfileContext] = useState("personal");
  const [competitionMode, setCompetitionMode] = useState("private");
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [configSaving, setConfigSaving] = useState(false);
  const [sportsSaving, setSportsSaving] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [selectedModuleKey, setSelectedModuleKey] = useState("training");
  const [selectedSports, setSelectedSports] = useState([]);
  const [primarySport, setPrimarySport] = useState("");
  const [selectedObjectives, setSelectedObjectives] = useState([]);
  const [cycleFocus, setCycleFocus] = useState("balanced");
  const [hydrationGoal, setHydrationGoal] = useState("2");
  const [mealsPerDay, setMealsPerDay] = useState("3");

  const activeModuleCount = (flow.modulePreferences || []).filter((m) => m.is_enabled).length;

  function pulse() {
    Haptics.selectionAsync().catch(() => {});
  }

  const canSave = useMemo(() => flow.hasSession && timezone.trim().length > 0 && !saving, [flow.hasSession, timezone, saving]);

  useEffect(() => {
    let cancelled = false;

    async function run() {
      if (!flow.hasSession || !flow.jwt) return;
      setLoading(true);
      setError("");
      setSuccess("");
      try {
        const data = await getProfile(flow.jwt.trim());
        if (cancelled || !data) return;
        setDisplayName(data.display_name || "");
        setTimezone(data.timezone || "America/Bogota");
        setProfileContext(data.profile_context || "personal");
        setCompetitionMode(data.competition_mode || "private");
      } catch (err) {
        if (!cancelled) setError(err.message || "No se pudo cargar perfil");
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    run();
    return () => {
      cancelled = true;
    };
  }, [flow.hasSession, flow.jwt]);

  useEffect(() => {
    if (!flow.hasSession) return;
    flow.loadModulePreferences().catch(() => {});
    flow.loadSportsProfile().catch(() => {});
  }, [flow.hasSession, flow.jwt]);

  useEffect(() => {
    const data = flow.sportsProfile;
    if (!data) return;
    const sports = Array.isArray(data.sports) ? data.sports : [];
    const sportKeys = sports.map((s) => s?.key).filter(Boolean);
    setSelectedSports(sportKeys);
    setPrimarySport(typeof data.primary_sport === "string" ? data.primary_sport : sportKeys[0] || "");
    setSelectedObjectives(Array.isArray(data.global_objectives) ? data.global_objectives : []);
    setCycleFocus(data?.cycle_config?.dominant_focus || "balanced");
  }, [flow.sportsProfile]);

  useEffect(() => {
    const np = flow.nutritionProfile;
    if (!np) return;
    setHydrationGoal(String(np.hydration_goal_l ?? 2));
    setMealsPerDay(String(np.meals_per_day ?? 3));
  }, [flow.nutritionProfile]);

  async function onSave() {
    if (!canSave) return;
    setSaving(true);
    setError("");
    setSuccess("");
    try {
      await saveProfile(flow.jwt.trim(), {
        display_name: displayName,
        timezone,
        profile_context: profileContext,
        competition_mode: competitionMode
      });
      setSuccess("Perfil guardado");
    } catch (err) {
      setError(err.message || "No se pudo guardar perfil");
    } finally {
      setSaving(false);
    }
  }

  async function onSaveModuleConfig(moduleKey, key, value) {
    if (!flow.hasSession) return;
    setConfigSaving(true);
    setError("");
    try {
      await flow.onUpdateModuleConfig(moduleKey, { [key]: value });
    } catch (err) {
      setError(err.message || "No se pudo guardar configuración");
    } finally {
      setConfigSaving(false);
    }
  }

  function onToggleSport(sportKey) {
    pulse();
    setSelectedSports((prev) => {
      const next = toggleListItem(prev, sportKey);
      if (!next.includes(primarySport)) setPrimarySport(next[0] || "");
      return next;
    });
  }

  function onToggleObjective(objectiveKey) {
    pulse();
    setSelectedObjectives((prev) => toggleListItem(prev, objectiveKey));
  }

  async function onSaveSportsProfile() {
    if (!flow.hasSession) return;
    if (selectedSports.length === 0) {
      setError("Selecciona al menos 1 deporte para guardar perfil deportivo.");
      return;
    }
    setSportsSaving(true);
    setError("");
    try {
      const sports = selectedSports.map((key, idx) => ({
        key,
        priority: idx === 0 ? "A" : idx === 1 ? "B" : "C",
        level: "intermediate"
      }));
      const result = await flow.saveSportsProfile({
        sports,
        primary_sport: primarySport || selectedSports[0],
        global_objectives: selectedObjectives,
        constraints: {
          include_modules: (flow.modulePreferences || []).filter((m) => m.is_enabled).map((m) => m.module_key)
        },
        cycle_config: {
          dominant_focus: cycleFocus,
          cycle_weeks: 4
        }
      });
      if (result) setSuccess("Perfil deportivo guardado");
    } finally {
      setSportsSaving(false);
    }
  }

  async function onSaveNutritionProfile() {
    const hydration = Number(hydrationGoal);
    const meals = Number(mealsPerDay);
    await flow.saveNutritionProfile({
      hydration_goal_l: Number.isFinite(hydration) ? hydration : 2,
      meals_per_day: Number.isFinite(meals) ? Math.max(1, Math.min(8, Math.round(meals))) : 3
    });
  }

  return (
    <>
      <View style={styles.hero}>
        <LinearGradient
          colors={theme.mode === "dark" ? ["#142720", theme.colors.surface] : ["#E7FBF3", "#FFFFFF"]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.heroInner}
        >
          <Text style={styles.heroTitle}>Perfil</Text>
          <Text style={styles.heroSubtitle}>Controla módulos, enfoque deportivo y preferencias de tu plan.</Text>
          <View style={styles.heroRow}>
            <View style={[styles.statusChip, { borderColor: theme.colors.progressBorder, backgroundColor: theme.colors.mintSoft }]}>
              <Text style={[styles.statusChipText, { color: theme.colors.mintDark }]}>{flow.hasSession ? "Sesión activa" : "Sin sesión"}</Text>
            </View>
            <View style={[styles.statusChip, { borderColor: theme.colors.border, backgroundColor: theme.colors.card }]}>
              <Text style={[styles.statusChipText, { color: theme.colors.textPrimary }]}>{`Dispositivo ${profile.formFactor}`}</Text>
            </View>
          </View>
        </LinearGradient>
      </View>

      <VCard theme={theme} tone="surface" style={styles.section}>
        <VSectionHeader theme={theme} title="Datos de cuenta" subtitle="Configuración personal de tu perfil." />
        {loading ? (
          <>
            <SkeletonBlock theme={theme} height={42} radius={12} />
            <SkeletonBlock theme={theme} height={42} radius={12} />
            <SkeletonBlock theme={theme} height={28} radius={10} style={{ width: "85%" }} />
            <SkeletonBlock theme={theme} height={28} radius={10} style={{ width: "90%" }} />
          </>
        ) : (
          <>
            <VInput theme={theme} value={displayName} onChangeText={setDisplayName} placeholder="Nombre visible" />
            <VInput
              theme={theme}
              value={timezone}
              onChangeText={setTimezone}
              placeholder="Zona horaria (ej: America/Bogota)"
            />

            <Text style={styles.label}>Contexto</Text>
            <View style={styles.optionsRow}>
              {CONTEXT_OPTIONS.map((opt) => (
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
            <View style={styles.divider} />

            <Text style={styles.label}>Modo de competencia</Text>
            <View style={styles.optionsRow}>
              {COMPETITION_OPTIONS.map((opt) => (
                <VOptionChip
                  key={opt.key}
                  theme={theme}
                  active={competitionMode === opt.key}
                  onPress={() => {
                    pulse();
                    setCompetitionMode(opt.key);
                  }}
                  label={opt.label}
                />
              ))}
            </View>

            <VButton theme={theme} title={saving ? "Guardando..." : "Guardar perfil"} onPress={onSave} disabled={!canSave} />
            {error ? <Text style={styles.error}>{error}</Text> : null}
            {success ? <Text style={styles.success}>{success}</Text> : null}
          </>
        )}
      </VCard>

      <VCard theme={theme} tone="surface" style={styles.section}>
        <VSectionHeader theme={theme} title="Módulos activos" subtitle="Activa solo lo que necesitas para tu flujo diario." />
        <View style={styles.statusRow}>
          <View style={[styles.statusChip, { borderColor: theme.colors.progressBorder, backgroundColor: theme.colors.mintSoft }]}>
            <Text style={[styles.statusChipText, { color: theme.colors.mintDark }]}>{`Activos ${activeModuleCount}`}</Text>
          </View>
          <View
            style={[
              styles.statusChip,
              {
                borderColor: flow.safetyStatus?.requires_professional_check ? theme.colors.warning : theme.colors.progressBorder,
                backgroundColor: flow.safetyStatus?.requires_professional_check ? "#FEF3C7" : theme.colors.mintSoft
              }
            ]}
          >
            <Text
              style={[
                styles.statusChipText,
                { color: flow.safetyStatus?.requires_professional_check ? theme.colors.warning : theme.colors.mintDark }
              ]}
            >
              {flow.safetyStatus?.requires_professional_check ? "Revisión recomendada" : "Sin alertas críticas"}
            </Text>
          </View>
        </View>
        <View style={styles.optionsRow}>
          {(flow.modulePreferences || []).map((m) => (
            <VOptionChip
              key={m.module_key}
              theme={theme}
              active={m.is_enabled}
              onPress={() => {
                pulse();
                flow.onToggleModule(m.module_key, !m.is_enabled);
              }}
              disabled={flow.modulesLoading}
              label={`${m.is_enabled ? "Activo" : "Inactivo"} · ${MODULE_DISPLAY[m.module_key] || m.module_key}`}
            />
          ))}
        </View>
        {!flow.modulesLoading && (flow.modulePreferences || []).length === 0 ? (
          <Text style={styles.subtitle}>No se encontraron módulos para esta cuenta. Recarga sesión o completa onboarding.</Text>
        ) : null}
        <View style={styles.divider} />
        <View style={styles.optionsRow}>
          {(flow.modulePreferences || [])
            .filter((m) => m.is_enabled)
            .map((m) => (
              <VOptionChip
                key={`cfg-${m.module_key}`}
                theme={theme}
                active={selectedModuleKey === m.module_key}
                onPress={() => {
                  pulse();
                  setSelectedModuleKey(m.module_key);
                }}
                label={`Configuración · ${MODULE_DISPLAY[m.module_key] || m.module_key}`}
              />
            ))}
        </View>
        {(flow.modulePreferences || []).some((m) => m.module_key === selectedModuleKey && m.is_enabled) ? (
          <View style={styles.moduleConfigCard}>
            <Text style={styles.moduleConfigTitle}>{`Personalización ${MODULE_DISPLAY[selectedModuleKey] || selectedModuleKey}`}</Text>
            {(MODULE_CONFIG_OPTIONS[selectedModuleKey] || []).map((field) => {
              const moduleItem = (flow.modulePreferences || []).find((m) => m.module_key === selectedModuleKey);
              const currentValue = moduleItem?.config?.[field.key] || field.values[0]?.value;
              return (
                <View key={`${selectedModuleKey}-${field.key}`} style={{ gap: 6 }}>
                  <Text style={styles.moduleConfigLabel}>{field.label}</Text>
                  <View style={styles.optionsRow}>
                    {field.values.map((opt) => (
                      <VOptionChip
                        key={`${field.key}-${opt.value}`}
                        theme={theme}
                        active={currentValue === opt.value}
                        onPress={() => {
                          pulse();
                          onSaveModuleConfig(selectedModuleKey, field.key, opt.value);
                        }}
                        disabled={configSaving || flow.modulesLoading}
                        label={opt.label}
                      />
                    ))}
                  </View>
                </View>
              );
            })}
          </View>
        ) : null}
        {flow.modulesError ? <Text style={styles.error}>{flow.modulesError}</Text> : null}
        {flow.safetyStatus?.requires_professional_check ? (
          <Text style={styles.error}>Seguridad: revisión profesional recomendada.</Text>
        ) : null}
      </VCard>

      <VCard theme={theme} tone="surface" style={styles.section}>
        <VSectionHeader
          theme={theme}
          title="Perfil deportivo compuesto"
          subtitle="Personaliza deportes, foco de ciclo y objetivos globales."
        />
        <Text style={styles.label}>Deportes activos</Text>
        <View style={styles.optionsRow}>
          {SPORT_OPTIONS.map((sport) => (
            <VOptionChip
              key={sport.key}
              theme={theme}
              active={selectedSports.includes(sport.key)}
              onPress={() => onToggleSport(sport.key)}
              label={sport.label}
            />
          ))}
        </View>
        <View style={styles.divider} />
        <Text style={styles.label}>Deporte principal</Text>
        <View style={styles.optionsRow}>
          {selectedSports.length === 0 ? (
            <Text style={styles.sportsHint}>Selecciona al menos un deporte para definir prioridad.</Text>
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
        <View style={styles.divider} />
        <Text style={styles.label}>Objetivos globales</Text>
        <View style={styles.optionsRow}>
          {SPORTS_OBJECTIVES.map((obj) => (
            <VOptionChip
              key={obj.key}
              theme={theme}
              active={selectedObjectives.includes(obj.key)}
              onPress={() => onToggleObjective(obj.key)}
              label={obj.label}
            />
          ))}
        </View>
        <View style={styles.divider} />
        <Text style={styles.label}>Foco dominante del ciclo</Text>
        <View style={styles.optionsRow}>
          {CYCLE_FOCUS_OPTIONS.map((focus) => (
            <VOptionChip
              key={focus.key}
              theme={theme}
              active={cycleFocus === focus.key}
              onPress={() => {
                pulse();
                setCycleFocus(focus.key);
              }}
              label={focus.label}
            />
          ))}
        </View>
        <VButton
          theme={theme}
          title={sportsSaving || flow.sportsProfileLoading ? "Guardando..." : "Guardar perfil deportivo"}
          onPress={onSaveSportsProfile}
          disabled={!flow.hasSession || sportsSaving || flow.sportsProfileLoading}
        />
        {flow.sportsProfileError ? <Text style={styles.error}>{flow.sportsProfileError}</Text> : null}
      </VCard>

      <VCard theme={theme} tone="surface" style={styles.section}>
        <VSectionHeader
          theme={theme}
          title="Notificaciones"
          subtitle="Sincroniza recordatorios locales según tu plan activo."
        />
        <VButton
          theme={theme}
          variant="secondary"
          onPress={flow.onSyncTodayNotifications}
          title={flow.notificationsLoading ? "Sincronizando..." : "Sincronizar notificaciones de hoy"}
          disabled={!flow.hasSession || flow.notificationsLoading}
        />
        {flow.notificationsError ? <Text style={styles.error}>{flow.notificationsError}</Text> : null}
        {flow.notificationsResult ? (
          <Text style={styles.success}>
            {`Programadas: ${flow.notificationsResult.scheduledCount} · omitidas: ${flow.notificationsResult.ignoredCount}`}
          </Text>
        ) : null}
      </VCard>

      <VCard theme={theme} tone="surface" style={styles.section}>
        <VSectionHeader
          theme={theme}
          title="Nutricion avanzada"
          subtitle="Ajusta hidratacion y estructura diaria para personalizar recomendaciones."
        />
        <VInput
          theme={theme}
          value={hydrationGoal}
          onChangeText={setHydrationGoal}
          placeholder="Hidratacion objetivo (L)"
          keyboardType="decimal-pad"
        />
        <VInput
          theme={theme}
          value={mealsPerDay}
          onChangeText={setMealsPerDay}
          placeholder="Comidas por dia"
          keyboardType="number-pad"
        />
        <View style={styles.optionsRow}>
          <VButton
            theme={theme}
            variant="secondary"
            title={flow.nutritionLoading ? "Cargando..." : "Cargar perfil nutricional"}
            onPress={() => flow.loadNutritionProfile(true)}
            disabled={flow.nutritionLoading || !flow.hasSession}
            style={{ flex: 1 }}
          />
          <VButton
            theme={theme}
            title={flow.nutritionLoading ? "Guardando..." : "Guardar nutricion"}
            onPress={onSaveNutritionProfile}
            disabled={flow.nutritionLoading || !flow.hasSession}
            style={{ flex: 1 }}
          />
        </View>
        {flow.nutritionError ? <Text style={styles.error}>{flow.nutritionError}</Text> : null}
      </VCard>
    </>
  );
}
