import React, { useMemo, useState } from "react";
import { Animated, Text, View } from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { SkeletonBlock } from "../components/SkeletonBlock";
import { VButton } from "../components/VButton";
import { VCard } from "../components/VCard";
import { VChip } from "../components/VChip";
import { VSectionHeader } from "../components/VSectionHeader";
import { HoySummaryCard } from "../features/hoy/HoySummaryCard";
import { TaskTimelineCard } from "../features/hoy/TaskTimelineCard";
import { getModuleStyle } from "../theme/vitalTheme";

const SOURCE_LABELS = {
  none: "pendiente",
  feed: "actualizado",
  legacy_today_tasks: "modo compatibilidad"
};

const MODULE_LABELS = {
  training: "Entrenamiento",
  nutrition: "Nutrición",
  habits: "Hábitos",
  recovery: "Recuperación"
};

function createStyles(theme) {
  return {
    section: { ...theme.blocks.section, gap: theme.spacing.md },
    error: { color: theme.colors.error },
    heroCard: {
      borderRadius: theme.radius.xxl,
      borderWidth: 1,
      borderColor: theme.colors.borderStrong,
      overflow: "hidden",
      ...theme.elevations.card
    },
    heroInner: {
      padding: theme.spacing.lg,
      gap: 16
    },
    heroEyebrow: {
      ...theme.typography.label,
      color: theme.colors.accentBrandStrong
    },
    heroTop: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "flex-start",
      gap: 8
    },
    heroTitleWrap: {
      flex: 1,
      gap: 8
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
    heroSourcePill: {
      borderRadius: 999,
      paddingHorizontal: 10,
      paddingVertical: 6,
      borderWidth: 1,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.accentBrandSoft
    },
    heroSourceText: {
      color: theme.colors.accentBrandStrong,
      fontSize: 11,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    modulesRow: {
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 8
    },
    actionsRow: {
      flexDirection: "row",
      gap: 10
    },
    actionPrimary: {
      flex: 1
    },
    actionSecondary: {
      minWidth: 136
    },
    emptyCard: {
      ...theme.blocks.panel,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.cardMuted,
      gap: 6
    },
    emptyTitle: {
      color: theme.colors.textPrimary,
      fontSize: 14,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    emptyText: {
      color: theme.colors.textSecondary,
      fontSize: 13,
      lineHeight: 18,
      fontFamily: "AvenirNext-Regular"
    },
    timelineWrap: { gap: theme.spacing.sm },
    focusCard: {
      ...theme.blocks.panel,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.colors.accentBrandSoft,
      gap: 8
    },
    focusTitle: {
      color: theme.colors.accentBrandStrong,
      fontSize: 12,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    focusTask: {
      color: theme.colors.textPrimary,
      fontSize: 14,
      lineHeight: 19,
      fontFamily: "AvenirNext-DemiBold"
    },
    moduleSection: {
      gap: 8,
      padding: theme.spacing.xs,
      borderRadius: theme.radius.lg
    },
    moduleHeader: {
      alignSelf: "flex-start",
      borderRadius: 999,
      borderWidth: 1,
      paddingHorizontal: 10,
      paddingVertical: 6
    },
    moduleHeaderText: {
      fontSize: 12,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    progressCard: {
      ...theme.blocks.metric,
      backgroundColor: theme.colors.cardMuted,
      borderColor: theme.colors.borderStrong,
      gap: 8
    },
    progressHeader: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center"
    },
    progressTitle: {
      color: theme.colors.textPrimary,
      fontWeight: "600",
      fontSize: 14,
      fontFamily: "AvenirNext-DemiBold"
    },
    progressValue: {
      color: theme.colors.accentBrandStrong,
      fontWeight: "700",
      fontSize: 14,
      fontFamily: "AvenirNext-DemiBold"
    },
    progressTrack: {
      height: 8,
      borderRadius: 999,
      backgroundColor: theme.colors.progressTrack,
      overflow: "hidden"
    },
    progressFill: {
      height: "100%",
      width: "100%",
      borderRadius: 999,
      alignSelf: "flex-start"
    }
  };
}

export function HoyScreen({ theme, flow }) {
  const styles = createStyles(theme);
  const [moduleFilter, setModuleFilter] = useState("all");
  const [statusFilter, setStatusFilter] = useState("all");
  const showSkeleton = flow.loading && flow.tasks.length === 0;
  const filteredTasks = useMemo(
    () =>
      flow.tasks.filter((task) => {
        const byModule = moduleFilter === "all" ? true : (task.moduleKey || "training") === moduleFilter;
        const byStatus = statusFilter === "all" ? true : task.status === statusFilter;
        return byModule && byStatus;
      }),
    [flow.tasks, moduleFilter, statusFilter]
  );
  const groupedTasks = filteredTasks.reduce((acc, task) => {
    const key = task.moduleKey || "training";
    if (!acc[key]) acc[key] = [];
    acc[key].push(task);
    return acc;
  }, {});
  const moduleKeys = Object.keys(groupedTasks);
  const nextTask = filteredTasks.find((t) => t.status === "in_progress") || filteredTasks.find((t) => t.status === "pending") || null;
  const activeModules = (flow.modulePreferences || []).filter((m) => m.is_enabled).map((m) => m.module_key);
  const sourceLabel = SOURCE_LABELS[flow.lastHoySource] || flow.lastHoySource;
  const todayLabel = new Date().toLocaleDateString("es-CO", {
    weekday: "long",
    day: "numeric",
    month: "long"
  });
  const hasSafetyFlag = Boolean(flow.safetyStatus?.requires_professional_check);
  const heroSubtitleText = useMemo(() => {
    const modulesText =
      activeModules.length > 0
        ? activeModules.map((m) => MODULE_LABELS[m] || m).join(" · ")
        : "Aún no has activado módulos desde Perfil";
    if (hasSafetyFlag) {
      return `${todayLabel}. Vital mantendrá hoy un enfoque más cuidadoso mientras revisas tu estado y cargas activas.`;
    }
    return `${todayLabel}. Vista diaria para ejecutar sobre ${modulesText} sin perder claridad en qué es realmente importante hoy.`;
  }, [todayLabel, activeModules, hasSafetyFlag]);

  return (
    <>
      <View style={styles.heroCard}>
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
          <Text style={styles.heroEyebrow}>CENTRO DE DECISIÓN DIARIA</Text>
          <View style={styles.heroTop}>
            <View style={styles.heroTitleWrap}>
              <Text style={styles.heroTitle}>HOY</Text>
              <Text style={styles.heroSubtitle}>{heroSubtitleText}</Text>
            </View>
            <View style={styles.heroSourcePill}>
              <Text style={styles.heroSourceText}>{sourceLabel}</Text>
            </View>
          </View>
          {activeModules.length > 0 ? (
            <View style={styles.modulesRow}>
              {activeModules.map((moduleKey) => (
                <VChip
                  key={`active-${moduleKey}`}
                  theme={theme}
                  label={MODULE_LABELS[moduleKey] || moduleKey}
                  active
                  interactive={false}
                  style={{
                    borderColor: getModuleStyle(moduleKey, theme).border,
                    backgroundColor: getModuleStyle(moduleKey, theme).tint
                  }}
                  textStyle={{
                    color: getModuleStyle(moduleKey, theme).text,
                    fontSize: 11,
                    fontWeight: "700",
                    fontFamily: "AvenirNext-DemiBold"
                  }}
                />
              ))}
            </View>
          ) : null}
          <View style={styles.actionsRow}>
            <VButton
              theme={theme}
              title="Actualizar HOY"
              style={styles.actionPrimary}
              loading={flow.loading}
              disabled={!flow.canLoad}
              onPress={flow.onLoadToday}
            />
            <VButton
              theme={theme}
              title="Cerrar sesión"
              variant="secondary"
              style={styles.actionSecondary}
              disabled={!flow.hasSession}
              onPress={flow.onLogout}
            />
          </View>
          {flow.error ? <Text style={styles.error}>{flow.error}</Text> : null}
        </LinearGradient>
      </View>

      <VCard theme={theme} style={styles.section} tone="muted">
        <VSectionHeader theme={theme} title="Timeline de HOY" subtitle="Prioridad visible, contexto claro y acciones rápidas para no perder ritmo." />
        {!showSkeleton ? (
          <View style={{ gap: 8 }}>
            <View style={styles.modulesRow}>
              <VChip
                theme={theme}
                label="Todos los módulos"
                active={moduleFilter === "all"}
                onPress={() => setModuleFilter("all")}
              />
              {activeModules.map((moduleKey) => (
                <VChip
                  key={`filter-module-${moduleKey}`}
                  theme={theme}
                  label={MODULE_LABELS[moduleKey] || moduleKey}
                  active={moduleFilter === moduleKey}
                  onPress={() => setModuleFilter(moduleKey)}
                />
              ))}
            </View>
            <View style={styles.modulesRow}>
              <VChip theme={theme} label="Todos" active={statusFilter === "all"} onPress={() => setStatusFilter("all")} />
              <VChip
                theme={theme}
                label="Pendientes"
                active={statusFilter === "pending"}
                onPress={() => setStatusFilter("pending")}
              />
              <VChip
                theme={theme}
                label="En curso"
                active={statusFilter === "in_progress"}
                onPress={() => setStatusFilter("in_progress")}
              />
              <VChip
                theme={theme}
                label="Completadas"
                active={statusFilter === "completed"}
                onPress={() => setStatusFilter("completed")}
              />
            </View>
          </View>
        ) : null}
        {!showSkeleton && nextTask ? (
          <View style={styles.focusCard}>
            <Text style={styles.focusTitle}>Siguiente acción recomendada</Text>
            <Text style={styles.focusTask}>{nextTask.title}</Text>
            <VButton
              theme={theme}
              title="Marcar como hecha"
              onPress={() => flow.onCompleteTask(nextTask.id)}
              disabled={!flow.hasSession}
            />
          </View>
        ) : null}
        {showSkeleton ? null : flow.tasks.length === 0 ? (
          <View style={styles.emptyCard}>
            <Text style={styles.emptyTitle}>No hay tareas para hoy</Text>
            <Text style={styles.emptyText}>
              {activeModules.length > 0
                ? `Módulos activos: ${activeModules.map((m) => MODULE_LABELS[m] || m).join(", ")}. Pulsa "Actualizar HOY" para cargar tu plan de hoy.`
                : "Activa al menos un módulo desde Perfil para generar tareas en HOY."}
            </Text>
          </View>
        ) : filteredTasks.length === 0 ? (
          <View style={styles.emptyCard}>
            <Text style={styles.emptyTitle}>No hay tareas para este filtro</Text>
            <Text style={styles.emptyText}>Cambia el módulo o estado para ver más tareas del día.</Text>
          </View>
        ) : null}
        <HoySummaryCard
          theme={theme}
          completedCount={flow.completedCount}
          inProgressCount={flow.inProgressCount}
          pendingCount={flow.pendingCount}
        />
        <View style={styles.progressCard}>
          {showSkeleton ? (
            <>
              <SkeletonBlock theme={theme} height={14} radius={8} style={{ width: "42%" }} />
              <SkeletonBlock theme={theme} height={8} radius={999} />
            </>
          ) : (
            <>
              <View style={styles.progressHeader}>
                <Text style={styles.progressTitle}>Progreso diario</Text>
                <Text style={styles.progressValue}>
                  {flow.completedCount}/{flow.tasks.length} · {flow.progressPct}%
                </Text>
              </View>
              <View style={styles.progressTrack}>
                <Animated.View style={[styles.progressFill, { transform: [{ scaleX: flow.progressScale }] }]}>
                  <LinearGradient
                    colors={[theme.colors.accentBrand, theme.colors.accentHealth]}
                    start={{ x: 0, y: 0.5 }}
                    end={{ x: 1, y: 0.5 }}
                    style={{ flex: 1, borderRadius: 999 }}
                  />
                </Animated.View>
              </View>
            </>
          )}
        </View>
        {showSkeleton ? (
          <View style={styles.timelineWrap}>
            <SkeletonBlock theme={theme} height={78} radius={16} />
            <SkeletonBlock theme={theme} height={78} radius={16} />
            <SkeletonBlock theme={theme} height={78} radius={16} />
          </View>
        ) : (
          <View style={styles.timelineWrap}>
            {moduleKeys.map((moduleKey) => (
              <View
                key={moduleKey}
                style={[
                  styles.moduleSection,
                  {
                    backgroundColor: getModuleStyle(moduleKey, theme).tint
                  }
                ]}
              >
                <View
                  style={[
                    styles.moduleHeader,
                    {
                      borderColor: getModuleStyle(moduleKey, theme).border
                    }
                  ]}
                >
                  <Text style={[styles.moduleHeaderText, { color: getModuleStyle(moduleKey, theme).text }]}>
                    {getModuleStyle(moduleKey, theme).label}
                  </Text>
                </View>
                {groupedTasks[moduleKey].map((task, index) => (
                  <TaskTimelineCard
                    key={task.id}
                    task={task}
                    actionState={flow.actionStateByTask[task.id]}
                    disabled={!flow.hasSession}
                    onComplete={() => flow.onCompleteTask(task.id)}
                    onSnooze={() => flow.onSnoozeTask(task.id)}
                    onReprogram={() => flow.onReprogramTask(task.id)}
                    isLast={index === groupedTasks[moduleKey].length - 1}
                    theme={theme}
                  />
                ))}
              </View>
            ))}
          </View>
        )}
      </VCard>
    </>
  );
}
