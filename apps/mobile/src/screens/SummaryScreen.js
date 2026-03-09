import React, { useMemo } from "react";
import { Text, View } from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { SkeletonBlock } from "../components/SkeletonBlock";
import { VButton } from "../components/VButton";
import { VCard } from "../components/VCard";
import { VSectionHeader } from "../components/VSectionHeader";
import { getModuleStyle } from "../theme/vitalTheme";
const MODULE_LABELS = {
  training: "entrenamiento",
  nutrition: "nutrición",
  habits: "hábitos",
  recovery: "recuperación"
};

function createStyles(theme) {
  return {
    section: { padding: theme.spacing.sm, gap: theme.spacing.xs },
    hero: {
      borderRadius: theme.radius.xxl,
      borderWidth: 1,
      borderColor: theme.colors.progressBorder,
      overflow: "hidden"
    },
    heroInner: {
      padding: theme.spacing.md,
      gap: 10
    },
    heroTitle: {
      color: theme.colors.textPrimary,
      ...theme.typography.h1
    },
    heroSub: {
      color: theme.colors.textSecondary,
      fontSize: 13,
      lineHeight: 18,
      fontFamily: "AvenirNext-Regular"
    },
    subtitle: { fontSize: 13, color: theme.colors.textSecondary },
    metricRow: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center",
      paddingVertical: 6,
      gap: 12
    },
    metricsGrid: {
      flexDirection: "row",
      gap: 8
    },
    metricCard: {
      flex: 1,
      ...theme.blocks.metric,
      borderColor: theme.colors.border,
      backgroundColor: theme.colors.card,
      gap: 4
    },
    metricCardLabel: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      fontFamily: "AvenirNext-Regular"
    },
    metricCardValue: {
      color: theme.colors.textPrimary,
      fontSize: 16,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    metricLabel: {
      color: theme.colors.textSecondary,
      fontSize: 13
    },
    metricValue: {
      color: theme.colors.textPrimary,
      fontSize: 14,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    callout: {
      marginTop: 8,
      ...theme.blocks.panel,
      backgroundColor: theme.colors.mintSoft,
      borderColor: theme.colors.progressBorder,
      gap: 6
    },
    calloutTitle: {
      color: theme.colors.mintDark,
      fontWeight: "700",
      fontSize: 13,
      fontFamily: "AvenirNext-DemiBold"
    },
    calloutText: {
      color: theme.colors.mintDark,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    trendCard: {
      marginTop: 8,
      borderRadius: theme.radius.xl,
      backgroundColor: theme.colors.card,
      borderWidth: 1,
      borderColor: theme.colors.border,
      padding: theme.spacing.sm,
      gap: 8,
      ...theme.elevations.card
    },
    trendTitle: {
      color: theme.colors.textPrimary,
      fontWeight: "600",
      fontSize: 13,
      fontFamily: "AvenirNext-DemiBold"
    },
    barsRow: {
      flexDirection: "row",
      alignItems: "flex-end",
      gap: 8,
      height: 90
    },
    barWrap: {
      flex: 1,
      alignItems: "center",
      justifyContent: "flex-end",
      gap: 6
    },
    barTrack: {
      width: "100%",
      maxWidth: 24,
      height: 72,
      borderRadius: 999,
      backgroundColor: theme.colors.progressTrack,
      justifyContent: "flex-end",
      overflow: "hidden"
    },
    barFill: {
      width: "100%",
      borderRadius: 999,
      backgroundColor: theme.colors.mintPrimary
    },
    barLabel: {
      fontSize: 10,
      color: theme.colors.textSecondary,
      fontFamily: "AvenirNext-Regular"
    },
    moduleBlock: {
      gap: 8
    },
    moduleTop: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center"
    },
    moduleTag: {
      borderRadius: 999,
      borderWidth: 1,
      paddingHorizontal: 8,
      paddingVertical: 4
    },
    moduleTagText: {
      fontSize: 11,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    moduleTrack: {
      height: 8,
      borderRadius: 999,
      backgroundColor: theme.colors.progressTrack,
      overflow: "hidden"
    },
    moduleFill: {
      height: "100%",
      borderRadius: 999
    },
    actionCard: {
      marginTop: 8,
      ...theme.blocks.action,
      backgroundColor: theme.colors.surface,
      borderColor: theme.colors.border,
      gap: 8
    },
    actionTitle: {
      color: theme.colors.textPrimary,
      fontWeight: "700",
      fontSize: 13,
      fontFamily: "AvenirNext-DemiBold"
    },
    actionItem: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    planningCard: {
      marginTop: 8,
      ...theme.blocks.action,
      backgroundColor: theme.colors.card,
      borderColor: theme.colors.border,
      gap: 8
    },
    planningItem: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    planningTitle: {
      color: theme.colors.textPrimary,
      fontWeight: "700",
      fontSize: 13,
      fontFamily: "AvenirNext-DemiBold"
    },
    cycleGrid: {
      gap: 8
    },
    cycleRow: {
      borderRadius: theme.radius.lg,
      borderWidth: 1,
      borderColor: theme.colors.border,
      backgroundColor: theme.colors.surface,
      paddingHorizontal: 10,
      paddingVertical: 8,
      gap: 2
    },
    cycleModule: {
      color: theme.colors.textPrimary,
      fontWeight: "700",
      fontSize: 12,
      fontFamily: "AvenirNext-DemiBold"
    },
    cycleValue: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 16,
      fontFamily: "AvenirNext-Regular"
    },
    error: {
      color: theme.colors.error,
      fontSize: 12
    },
    retryButton: { marginTop: 6 }
  };
}

function getRecommendation(avgPct, hasData) {
  if (!hasData) return "Aún no hay datos suficientes de 7 días. Mantén constancia diaria para activar recomendaciones más precisas.";
  if (avgPct >= 80) return "Adherencia excelente. Mantén el ritmo y prioriza recuperación para sostener el progreso.";
  if (avgPct >= 55) return "Vas bien. Reduce fricción en 1 tarea clave diaria para subir consistencia semanal.";
  return "Adherencia baja. Enfócate primero en completar 1 tarea clave por día antes de escalar volumen.";
}

function getActionPlan({ summary, moduleRows, modulePreferences, safetyStatus }) {
  const actions = [];
  if (!summary.hasData) {
    actions.push("Completa al menos 1 tarea diaria durante 7 días para activar recomendaciones con mayor precisión.");
  }
  const weakModules = moduleRows.filter((m) => m.total > 0 && m.pct < 55).slice(0, 2);
  weakModules.forEach((m) => {
    actions.push(`Prioriza ${MODULE_LABELS[m.moduleKey] || m.moduleKey} esta semana para subir adherencia.`);
  });
  const enabledModules = (modulePreferences || []).filter((m) => m.is_enabled);
  if (enabledModules.length <= 2) {
    actions.push("Tu plan está enfocado. Optimiza consistencia antes de agregar nuevos módulos.");
  } else {
    actions.push("Tienes varios módulos activos. Mantén máximo 1 tarea crítica por módulo al día.");
  }
  if (safetyStatus?.requires_professional_check) {
    actions.push("Seguridad en observación: evita carga intensa y prioriza recuperación hasta nueva evaluación.");
  }
  return actions.slice(0, 3);
}

export function SummaryScreen({ theme, flow }) {
  const styles = createStyles(theme);
  const showSkeleton = flow.summaryLoading || !flow.hasSession;
  const showPlanningSkeleton = flow.planningLoading || !flow.hasSession;
  const trend = flow.weeklyTrend || [];
  const moduleTrend = flow.weeklyModuleTrend || {};
  const weeklyPlan = flow.weeklyPlan || [];
  const cycleAdjustments = flow.cycleAdjustments || [];

  const summary = useMemo(() => {
    if (trend.length === 0) {
      return { avgPct: 0, totalTasks: 0, totalCompleted: 0, hasData: false };
    }
    const totalTasks = trend.reduce((acc, d) => acc + d.total, 0);
    const totalCompleted = trend.reduce((acc, d) => acc + d.completed, 0);
    const avgPct = totalTasks > 0 ? Math.round((totalCompleted / totalTasks) * 100) : 0;
    return { avgPct, totalTasks, totalCompleted, hasData: totalTasks > 0 };
  }, [trend]);

  const recommendation = useMemo(() => getRecommendation(summary.avgPct, summary.hasData), [summary.avgPct, summary.hasData]);
  const actionPlan = useMemo(
    () =>
      getActionPlan({
        summary,
        moduleRows: Object.entries(moduleTrend).map(([moduleKey, m]) => ({
          moduleKey,
          total: m.total || 0,
          completed: m.completed || 0,
          pct: m.pct || 0
        })),
        modulePreferences: flow.modulePreferences || [],
        safetyStatus: flow.safetyStatus || null
      }),
    [summary, moduleTrend, flow.modulePreferences, flow.safetyStatus]
  );
  const moduleRows = useMemo(
    () =>
      Object.entries(moduleTrend)
        .map(([moduleKey, m]) => ({
          moduleKey,
          total: m.total || 0,
          completed: m.completed || 0,
          pct: m.pct || 0
        }))
        .sort((a, b) => b.pct - a.pct),
    [moduleTrend]
  );

  const planningRows = useMemo(
    () =>
      [...weeklyPlan]
        .sort((a, b) => (b.priority_hint || 0) - (a.priority_hint || 0))
        .slice(0, 6),
    [weeklyPlan]
  );

  return (
    <>
      <View style={styles.hero}>
        <LinearGradient
          colors={theme.mode === "dark" ? ["#12261F", theme.colors.surface] : ["#E7FBF3", "#FFFFFF"]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.heroInner}
        >
          <Text style={styles.heroTitle}>Resumen</Text>
          <Text style={styles.heroSub}>Tu avance semanal y recomendaciones claras para decidir mejor qué hacer hoy.</Text>
        </LinearGradient>
      </View>
      <VCard theme={theme} tone="surface" style={styles.section}>
        <VSectionHeader theme={theme} title="Panorama semanal" subtitle="Adherencia e insights accionables." />
        {flow.summaryError ? <Text style={styles.error}>{flow.summaryError}</Text> : null}
        {flow.summaryError ? (
          <VButton
            theme={theme}
            variant="secondary"
            style={styles.retryButton}
            title="Reintentar resumen"
            onPress={() => flow.loadWeeklyTrend(true)}
          />
        ) : null}
        {showSkeleton ? (
          <>
            <SkeletonBlock theme={theme} height={14} radius={8} style={{ width: "45%" }} />
            <SkeletonBlock theme={theme} height={14} radius={8} style={{ width: "60%" }} />
            <SkeletonBlock theme={theme} height={14} radius={8} style={{ width: "55%" }} />
            <View style={styles.trendCard}>
              <SkeletonBlock theme={theme} height={14} radius={8} style={{ width: "50%" }} />
              <SkeletonBlock theme={theme} height={72} radius={12} />
            </View>
            <View style={styles.callout}>
              <SkeletonBlock theme={theme} height={14} radius={8} style={{ width: "40%" }} />
              <SkeletonBlock theme={theme} height={12} radius={8} />
              <SkeletonBlock theme={theme} height={12} radius={8} style={{ width: "85%" }} />
            </View>
          </>
        ) : (
          <>
            <View style={styles.metricsGrid}>
              <View style={[styles.metricCard, { backgroundColor: theme.colors.mintSoft, borderColor: theme.colors.progressBorder }]}>
                <Text style={styles.metricCardLabel}>Adherencia</Text>
                <Text style={[styles.metricCardValue, { color: theme.colors.mintDark }]}>{summary.avgPct}%</Text>
              </View>
              <View style={styles.metricCard}>
                <Text style={styles.metricCardLabel}>Tareas</Text>
                <Text style={styles.metricCardValue}>{summary.totalTasks}</Text>
              </View>
              <View style={styles.metricCard}>
                <Text style={styles.metricCardLabel}>Completadas</Text>
                <Text style={styles.metricCardValue}>{summary.totalCompleted}</Text>
              </View>
            </View>

            <View style={styles.trendCard}>
              <Text style={styles.trendTitle}>Tendencia 7 días</Text>
              <View style={styles.barsRow}>
                {trend.map((d) => {
                  const label = d.date.slice(5);
                  const barHeight = Math.max(4, Math.round((d.pct / 100) * 72));
                  return (
                    <View key={d.date} style={styles.barWrap}>
                      <View style={styles.barTrack}>
                        <View style={[styles.barFill, { height: barHeight }]} />
                      </View>
                      <Text style={styles.barLabel}>{label}</Text>
                    </View>
                  );
                })}
              </View>
            </View>

            <View style={styles.trendCard}>
              <Text style={styles.trendTitle}>Rendimiento por módulo</Text>
              {moduleRows.length === 0 ? (
                <Text style={styles.subtitle}>Sin datos por módulo en esta semana.</Text>
              ) : (
                moduleRows.map((row) => (
                  <View key={row.moduleKey} style={styles.moduleBlock}>
                    <View style={styles.moduleTop}>
                      <View
                        style={[
                          styles.moduleTag,
                          {
                            backgroundColor: getModuleStyle(row.moduleKey, theme).tint,
                            borderColor: getModuleStyle(row.moduleKey, theme).border
                          }
                        ]}
                      >
                        <Text style={[styles.moduleTagText, { color: getModuleStyle(row.moduleKey, theme).text }]}>
                          {getModuleStyle(row.moduleKey, theme).label}
                        </Text>
                      </View>
                      <Text style={styles.metricValue}>{`${row.completed}/${row.total} · ${row.pct}%`}</Text>
                    </View>
                    <View style={styles.moduleTrack}>
                      <View
                        style={[
                          styles.moduleFill,
                          {
                            width: `${Math.max(2, row.pct)}%`,
                            backgroundColor: getModuleStyle(row.moduleKey, theme).border
                          }
                        ]}
                      />
                    </View>
                  </View>
                ))
              )}
            </View>

            <View style={styles.callout}>
              <Text style={styles.calloutTitle}>Recomendación</Text>
              <Text style={styles.calloutText}>{recommendation}</Text>
            </View>

            <View style={styles.actionCard}>
              <Text style={styles.actionTitle}>Plan de acción semanal</Text>
              {actionPlan.map((line, idx) => (
                <Text key={`action-${idx}`} style={styles.actionItem}>{`${idx + 1}. ${line}`}</Text>
              ))}
            </View>

            <View style={styles.planningCard}>
              <Text style={styles.planningTitle}>Prioridades de la semana</Text>
              {flow.planningError ? <Text style={styles.error}>{flow.planningError}</Text> : null}
              {showPlanningSkeleton ? (
                <>
                  <SkeletonBlock theme={theme} height={12} radius={8} />
                  <SkeletonBlock theme={theme} height={12} radius={8} style={{ width: "92%" }} />
                  <SkeletonBlock theme={theme} height={12} radius={8} style={{ width: "84%" }} />
                </>
              ) : planningRows.length === 0 ? (
                <Text style={styles.subtitle}>No hay prioridades semanales disponibles.</Text>
              ) : (
                planningRows.map((row, idx) => (
                  <Text key={`${row.plan_date}-${row.module_key}-${idx}`} style={styles.planningItem}>
                    {`${idx + 1}. ${row.plan_date} · ${getModuleStyle(row.module_key, theme).label} · ${row.title}`}
                  </Text>
                ))
              )}
            </View>

            <View style={styles.planningCard}>
              <Text style={styles.planningTitle}>Ajuste del ciclo (hoy)</Text>
              {showPlanningSkeleton ? (
                <>
                  <SkeletonBlock theme={theme} height={34} radius={12} />
                  <SkeletonBlock theme={theme} height={34} radius={12} />
                </>
              ) : cycleAdjustments.length === 0 ? (
                <Text style={styles.subtitle}>No hay ajustes de ciclo para hoy.</Text>
              ) : (
                <View style={styles.cycleGrid}>
                  {cycleAdjustments.map((row, idx) => (
                    <View key={`${row.module_key}-${idx}`} style={styles.cycleRow}>
                      <Text style={styles.cycleModule}>{getModuleStyle(row.module_key, theme).label}</Text>
                      <Text style={styles.cycleValue}>{`Fase ${row.phase || "base"} · volumen ${row.volume_delta_pct ?? 0}% · intensidad ${row.intensity_delta_pct ?? 0}%`}</Text>
                      <Text style={styles.cycleValue}>{row.reason_text || "Ajuste estándar por estado del ciclo."}</Text>
                    </View>
                  ))}
                </View>
              )}
            </View>

            <View style={styles.planningCard}>
              <Text style={styles.planningTitle}>Asistente IA semanal</Text>
              <Text style={styles.planningItem}>
                Genera una propuesta semanal explicable y aplicala directo a tu plan.
              </Text>
              <VButton
                theme={theme}
                title={flow.aiLoading ? "Generando..." : "Generar propuesta IA"}
                onPress={() => flow.onPreviewAiPlan()}
                disabled={flow.aiLoading || !flow.hasSession}
              />
              {flow.aiPreview ? (
                <>
                  <Text style={styles.planningItem}>{`Resumen: ${flow.aiPreview.summary || "Sin resumen"}`}</Text>
                  <Text style={styles.planningItem}>{`Confianza: ${Math.round(Number(flow.aiPreview.confidence_score || 0))}%`}</Text>
                  <VButton
                    theme={theme}
                    variant="secondary"
                    title={flow.aiLoading ? "Aplicando..." : "Aplicar propuesta IA"}
                    onPress={flow.onApplyAiPlan}
                    disabled={flow.aiLoading || !flow.hasSession}
                  />
                </>
              ) : null}
              {flow.aiError ? <Text style={styles.error}>{flow.aiError}</Text> : null}
            </View>

            <View style={styles.planningCard}>
              <Text style={styles.planningTitle}>Nutricion avanzada</Text>
              {flow.nutritionProfile ? (
                <>
                  <Text style={styles.planningItem}>{`Hidratacion objetivo: ${flow.nutritionProfile.hydration_goal_l || 2} L`}</Text>
                  <Text style={styles.planningItem}>{`Comidas por dia: ${flow.nutritionProfile.meals_per_day || 3}`}</Text>
                </>
              ) : (
                <Text style={styles.planningItem}>Aun no has configurado tu perfil nutricional.</Text>
              )}
              <VButton
                theme={theme}
                variant="secondary"
                title={flow.nutritionLoading ? "Actualizando..." : "Refrescar nutricion"}
                onPress={() => flow.loadNutritionProfile(true)}
                disabled={flow.nutritionLoading || !flow.hasSession}
              />
              {flow.nutritionError ? <Text style={styles.error}>{flow.nutritionError}</Text> : null}
            </View>
          </>
        )}
      </VCard>
    </>
  );
}
