import React from "react";
import { Pressable, Text, View } from "react-native";
import { getModuleStyle, getTaskStatusStyle } from "../../theme/vitalTheme";

const REASON_LABELS = {
  balanced_priority: "Prioridad balanceada",
  low_adherence: "Recuperar constancia",
  low_adherence_sport_focus: "Foco deportivo",
  low_readiness: "Readiness bajo",
  safety_blocked: "Bloqueo de seguridad",
  sport_focus_priority: "Prioridad deportiva",
  interference_load_guard: "Control de carga"
};

function createStyles(theme) {
  return {
    row: {
      flexDirection: "row",
      gap: theme.spacing.sm
    },
    timelineCol: {
      width: 58,
      alignItems: "center",
      paddingTop: 2
    },
    hourText: {
      fontSize: 12,
      color: theme.colors.textSecondary,
      marginBottom: 6
    },
    dot: {
      width: 13,
      height: 13,
      borderRadius: 999,
      borderWidth: 2
    },
    line: {
      width: 2,
      flex: 1,
      backgroundColor: theme.colors.borderStrong,
      marginTop: 6
    },
    card: {
      flex: 1,
      borderWidth: 1,
      borderColor: theme.colors.borderStrong,
      borderRadius: theme.radius.lg,
      padding: theme.spacing.sm,
      gap: 12,
      ...theme.elevations.card
    },
    headRow: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "flex-start",
      gap: 10
    },
    title: {
      fontSize: 17,
      fontWeight: "600",
      color: theme.colors.textPrimary,
      lineHeight: 22,
      fontFamily: "AvenirNext-DemiBold"
    },
    titleWrap: {
      flex: 1,
      gap: 4
    },
    statusChip: {
      alignSelf: "flex-start",
      borderRadius: 999,
      paddingHorizontal: 8,
      paddingVertical: 4,
      borderWidth: 1
    },
    statusChipText: {
      fontSize: 11,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    scoreBadge: {
      borderRadius: 999,
      borderWidth: 1,
      paddingHorizontal: 10,
      paddingVertical: 4
    },
    scoreBadgeText: {
      fontSize: 11,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    chipsRow: {
      flexDirection: "row",
      flexWrap: "wrap",
      gap: 8
    },
    moduleTag: {
      alignSelf: "flex-start",
      borderRadius: 999,
      borderWidth: 1,
      paddingHorizontal: 10,
      paddingVertical: 4
    },
    moduleTagText: {
      fontSize: 11,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    reasonCodeTag: {
      alignSelf: "flex-start",
      borderRadius: 999,
      borderWidth: 1,
      paddingHorizontal: 10,
      paddingVertical: 4,
      borderColor: theme.colors.border,
      backgroundColor: theme.colors.cardAlt
    },
    reasonCodeText: {
      fontSize: 11,
      fontWeight: "700",
      color: theme.colors.textSecondary,
      fontFamily: "AvenirNext-DemiBold"
    },
    meta: {
      fontSize: 13,
      color: theme.colors.textSecondary,
      lineHeight: 18
    },
    reasonCard: {
      borderRadius: 12,
      borderWidth: 1,
      borderColor: theme.colors.borderStrong,
      backgroundColor: theme.mode === "dark" ? "#172220" : "#F3FCF8",
      paddingHorizontal: 10,
      paddingVertical: 8,
      gap: 4
    },
    reasonLabel: {
      fontSize: 10,
      fontWeight: "700",
      letterSpacing: 0.5,
      color: theme.colors.textMuted,
      fontFamily: "AvenirNext-DemiBold"
    },
    actionRow: {
      flexDirection: "row",
      gap: 8
    },
    btnPrimary: {
      flex: 1,
      backgroundColor: theme.colors.cta,
      borderRadius: 12,
      paddingVertical: 9,
      alignItems: "center"
    },
    btnSecondary: {
      flex: 1,
      borderWidth: 1,
      borderColor: theme.colors.border,
      backgroundColor: theme.colors.surface,
      borderRadius: 12,
      paddingVertical: 9,
      alignItems: "center"
    },
    btnTertiary: {
      flex: 1,
      borderWidth: 1,
      borderColor: theme.colors.vitalAccent,
      backgroundColor: theme.mode === "dark" ? "#321226" : "#FFF0F7",
      borderRadius: 12,
      paddingVertical: 9,
      alignItems: "center"
    },
    btnPrimaryText: {
      color: theme.colors.ctaText,
      fontWeight: "700",
      fontSize: 12,
      fontFamily: "AvenirNext-DemiBold"
    },
    btnSecondaryText: {
      color: theme.colors.textPrimary,
      fontWeight: "600",
      fontSize: 12,
      fontFamily: "AvenirNext-DemiBold"
    },
    btnTertiaryText: {
      color: theme.colors.vitalAccent,
      fontWeight: "600",
      fontSize: 12,
      fontFamily: "AvenirNext-DemiBold"
    },
    actionInfo: {
      color: theme.mode === "dark" ? "#93C5FD" : "#1D4ED8",
      fontSize: 12,
      lineHeight: 16
    },
    statusText: {
      fontSize: 12
    },
    reasonText: {
      fontSize: 12,
      color: theme.colors.textSecondary,
      lineHeight: 17
    },
    safetyText: {
      fontSize: 12,
      fontWeight: "700",
      color: theme.colors.warning
    },
    blockedWrap: {
      borderRadius: 12,
      borderWidth: 1,
      borderColor: theme.colors.warning,
      backgroundColor: theme.mode === "dark" ? "#2E2316" : "#FFF7ED",
      paddingHorizontal: 10,
      paddingVertical: 8
    },
    blockedText: {
      fontSize: 12,
      color: theme.colors.warning,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    }
  };
}

export function TaskTimelineCard({
  task,
  actionState,
  disabled,
  onComplete,
  onSnooze,
  onReprogram,
  isLast,
  theme
}) {
  const styles = createStyles(theme);
  const s = getTaskStatusStyle(task.status, theme);
  const moduleStyle = getModuleStyle(task.moduleKey, theme);
  const isBlocked = task.safetyState === "blocked";
  const isLoading = Boolean(actionState?.loading);
  const actionDisabled = disabled || isLoading || isBlocked;
  const reasonCode = String(task.reasonCode || "balanced_priority");
  const reasonCodeLabel = REASON_LABELS[reasonCode] || "Prioridad inteligente";

  return (
    <View style={styles.row}>
      <View style={styles.timelineCol}>
        <Text style={styles.hourText}>Ahora</Text>
        <View style={[styles.dot, { backgroundColor: s.dotBg, borderColor: s.dotBorder }]} />
        {!isLast ? <View style={styles.line} /> : null}
      </View>
      <View style={[styles.card, { backgroundColor: s.cardBg }]}>
        <View style={styles.headRow}>
          <View style={styles.titleWrap}>
            <Text style={styles.title}>{task.title}</Text>
            <View style={[styles.statusChip, { borderColor: s.dotBorder, backgroundColor: s.cardBg }]}>
              <Text style={[styles.statusChipText, { color: s.statusColor }]}>{s.label}</Text>
            </View>
          </View>
          <View style={[styles.scoreBadge, { borderColor: theme.colors.progressBorder, backgroundColor: theme.colors.mintSoft }]}>
            <Text style={[styles.scoreBadgeText, { color: theme.colors.mintDark }]}>{`Prioridad ${task.priorityScore ?? 0}`}</Text>
          </View>
        </View>
        <View style={styles.chipsRow}>
          <View style={[styles.moduleTag, { borderColor: moduleStyle.border, backgroundColor: moduleStyle.tint }]}>
            <Text style={[styles.moduleTagText, { color: moduleStyle.text }]}>{moduleStyle.label}</Text>
          </View>
          <View style={styles.reasonCodeTag}>
            <Text style={styles.reasonCodeText}>{reasonCodeLabel}</Text>
          </View>
        </View>
        <Text style={styles.meta}>{task.meta}</Text>
        {isBlocked ? (
          <View style={styles.blockedWrap}>
            <Text style={styles.blockedText}>Bloqueado por seguridad para este módulo.</Text>
          </View>
        ) : null}
        <View style={styles.reasonCard}>
          <Text style={styles.reasonLabel}>¿POR QUÉ ESTÁ AQUÍ?</Text>
          <Text style={styles.reasonText}>
            {isBlocked ? "Esta tarea se bloqueó por seguridad." : task.reasonText || "Tarea priorizada por tu contexto del día."}
          </Text>
        </View>
        <View style={styles.actionRow}>
          <Pressable
            style={({ pressed }) => [
              styles.btnPrimary,
              actionDisabled ? { opacity: 0.55 } : null,
              pressed && !actionDisabled ? { backgroundColor: theme.colors.ctaPressed } : null
            ]}
            disabled={actionDisabled}
            onPress={onComplete}
          >
            <Text style={styles.btnPrimaryText}>Hecho</Text>
          </Pressable>
          <Pressable
            style={({ pressed }) => [
              styles.btnSecondary,
              actionDisabled ? { opacity: 0.55 } : null,
              pressed && !actionDisabled ? { borderColor: theme.colors.progressBorder } : null
            ]}
            disabled={actionDisabled}
            onPress={onSnooze}
          >
            <Text style={styles.btnSecondaryText}>Posponer</Text>
          </Pressable>
          <Pressable
            style={({ pressed }) => [
              styles.btnTertiary,
              actionDisabled ? { opacity: 0.55 } : null,
              pressed && !actionDisabled ? { borderColor: theme.colors.vitalAccent, opacity: 0.9 } : null
            ]}
            disabled={actionDisabled}
            onPress={onReprogram}
          >
            <Text style={styles.btnTertiaryText}>Mañana</Text>
          </Pressable>
        </View>
        {actionState?.message ? <Text style={styles.actionInfo}>{actionState.message}</Text> : null}
      </View>
    </View>
  );
}
