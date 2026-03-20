import React from "react";
import { Text, View } from "react-native";
import { VCard } from "../../components/VCard";

function createStyles(theme) {
  return {
    card: { gap: 12 },
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
    intro: {
      color: theme.colors.textSecondary,
      fontSize: 13,
      lineHeight: 18,
      fontFamily: "AvenirNext-Regular"
    },
    row: {
      flexDirection: "row",
      gap: 8
    },
    metricCard: {
      flex: 1,
      borderWidth: 1,
      borderRadius: 16,
      paddingHorizontal: 10,
      paddingVertical: 12,
      gap: 4
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
      color: theme.colors.accentBrandStrong,
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
    <VCard theme={theme} style={styles.card} tone="muted">
      <View style={styles.titleRow}>
        <Text style={styles.title}>Estado del día</Text>
        <Text style={styles.subtitle}>{`${total} tareas`}</Text>
      </View>
      <Text style={styles.intro}>Un resumen rápido para entender ejecución, foco activo y lo que sigue pendiente.</Text>
      <View style={styles.row}>
        <View style={[styles.metricCard, { backgroundColor: theme.colors.accentHealthSoft, borderColor: theme.colors.progressBorder }]}>
          <Text style={styles.metric}>Hechas</Text>
          <Text style={styles.valueDone}>{completedCount}</Text>
        </View>
        <View
          style={[
            styles.metricCard,
            {
              backgroundColor: theme.colors.accentBrandSoft,
              borderColor: theme.colors.borderStrong
            }
          ]}
        >
          <Text style={styles.metric}>En curso</Text>
          <Text style={styles.valueProgress}>{inProgressCount}</Text>
        </View>
        <View style={[styles.metricCard, { backgroundColor: theme.colors.card, borderColor: theme.colors.borderStrong }]}>
          <Text style={styles.metric}>Pendientes</Text>
          <Text style={styles.valuePending}>{pendingCount}</Text>
        </View>
      </View>
    </VCard>
  );
}
