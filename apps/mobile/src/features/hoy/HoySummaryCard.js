import React from "react";
import { Text, View } from "react-native";

function createStyles(theme) {
  return {
    card: {
      backgroundColor: theme.colors.card,
      borderWidth: 1,
      borderColor: theme.colors.border,
      borderRadius: theme.radius.xl,
      padding: theme.spacing.sm,
      gap: 10,
      ...theme.elevations.card
    },
    titleRow: {
      flexDirection: "row",
      justifyContent: "space-between",
      alignItems: "center"
    },
    title: {
      fontSize: 15,
      fontWeight: "700",
      color: theme.colors.textPrimary,
      fontFamily: "AvenirNext-DemiBold"
    },
    subtitle: {
      fontSize: 12,
      color: theme.colors.textSecondary,
      fontFamily: "AvenirNext-Regular"
    },
    row: {
      flexDirection: "row",
      gap: 8
    },
    metricCard: {
      flex: 1,
      borderWidth: 1,
      borderRadius: 14,
      paddingHorizontal: 10,
      paddingVertical: 10
    },
    metric: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      fontFamily: "AvenirNext-Regular"
    },
    valueDone: {
      color: theme.colors.mintDark,
      fontWeight: "700",
      fontSize: 14,
      fontFamily: "AvenirNext-DemiBold"
    },
    valueProgress: {
      color: theme.colors.mintDark,
      fontWeight: "700",
      fontSize: 14,
      fontFamily: "AvenirNext-DemiBold"
    },
    valuePending: {
      color: theme.colors.textPrimary,
      fontWeight: "700",
      fontSize: 14,
      fontFamily: "AvenirNext-DemiBold"
    }
  };
}

export function HoySummaryCard({ theme, completedCount, inProgressCount, pendingCount }) {
  const styles = createStyles(theme);
  const total = completedCount + inProgressCount + pendingCount;

  return (
    <View style={styles.card}>
      <View style={styles.titleRow}>
        <Text style={styles.title}>Estado del día</Text>
        <Text style={styles.subtitle}>{`${total} tareas`}</Text>
      </View>
      <View style={styles.row}>
        <View style={[styles.metricCard, { backgroundColor: theme.colors.mintSoft, borderColor: theme.colors.progressBorder }]}>
          <Text style={styles.metric}>Hechas</Text>
          <Text style={styles.valueDone}>{completedCount}</Text>
        </View>
        <View
          style={[
            styles.metricCard,
            {
              backgroundColor: theme.colors.mintSoft,
              borderColor: theme.colors.progressBorder
            }
          ]}
        >
          <Text style={styles.metric}>En curso</Text>
          <Text style={styles.valueProgress}>{inProgressCount}</Text>
        </View>
        <View style={[styles.metricCard, { backgroundColor: theme.colors.card, borderColor: theme.colors.border }]}>
          <Text style={styles.metric}>Pendientes</Text>
          <Text style={styles.valuePending}>{pendingCount}</Text>
        </View>
      </View>
    </View>
  );
}
