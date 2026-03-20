import React, { useEffect, useMemo, useRef, useState } from "react";
import { Animated, Pressable, ScrollView, Text, View } from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { PageShell } from "../components/PageShell";
import { HoyScreen } from "../screens/HoyScreen";
import { ProfileScreen } from "../screens/ProfileScreen";
import { SummaryScreen } from "../screens/SummaryScreen";

const TAB_KEYS = {
  HOY: "hoy",
  SUMMARY: "summary",
  PROFILE: "profile"
};

function createStyles(theme) {
  return {
    header: {
      borderWidth: 1,
      borderColor: theme.colors.borderStrong,
      borderRadius: theme.radius.xxl,
      overflow: "hidden",
      ...theme.elevations.card
    },
    headerInner: {
      padding: theme.spacing.lg,
      gap: 12
    },
    eyebrow: {
      ...theme.typography.label,
      color: theme.colors.accentBrandStrong
    },
    title: { ...theme.typography.h1, color: theme.colors.textPrimary },
    subtitle: { color: theme.colors.textSecondary, fontSize: 14, lineHeight: 20, fontFamily: "AvenirNext-Regular" },
    subtitleStrong: {
      color: theme.colors.textPrimary,
      fontSize: 12,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold",
      opacity: 0.8
    },
    tabBar: {
      flexDirection: "row",
      borderWidth: 1,
      borderColor: theme.colors.borderStrong,
      borderRadius: theme.radius.xxl,
      padding: 6,
      gap: 6,
      overflow: "hidden",
      backgroundColor: theme.colors.card,
      ...theme.elevations.card
    },
    tabBarInner: {
      flexDirection: "row",
      flex: 1,
      gap: 6
    },
    tabButton: {
      flex: 1,
      minHeight: 46,
      borderRadius: 16,
      justifyContent: "center",
      alignItems: "center",
      borderWidth: 1,
      borderColor: "transparent",
      backgroundColor: theme.colors.card
    },
    tabButtonActive: {
      backgroundColor: theme.colors.accentBrandSoft,
      borderColor: theme.colors.borderStrong
    },
    tabText: {
      color: theme.colors.textSecondary,
      fontWeight: "600",
      fontSize: 14,
      fontFamily: "AvenirNext-DemiBold",
      letterSpacing: 0.2
    },
    tabTextActive: {
      color: theme.colors.accentBrandStrong
    },
    activePill: {
      marginTop: 5,
      width: 24,
      height: 3,
      borderRadius: 999,
      backgroundColor: theme.colors.accentBrand
    }
  };
}

function renderActiveTab(tab, props) {
  if (tab === TAB_KEYS.SUMMARY) return <SummaryScreen {...props} />;
  if (tab === TAB_KEYS.PROFILE) return <ProfileScreen {...props} />;
  return <HoyScreen {...props} />;
}

export function MainTabs({ theme, profile, caps, flow }) {
  const [activeTab, setActiveTab] = useState(TAB_KEYS.HOY);
  const styles = useMemo(() => createStyles(theme), [theme]);
  const screenProps = { theme, profile, caps, flow };
  const transition = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    transition.setValue(0);
    Animated.timing(transition, {
      toValue: 1,
      duration: 220,
      useNativeDriver: true
    }).start();
  }, [activeTab, transition]);

  useEffect(() => {
    if (activeTab === TAB_KEYS.SUMMARY && flow.hasSession) {
      flow.loadWeeklyTrend().catch(() => {});
    }
  }, [activeTab]);

  const animatedStyle = useMemo(
    () => ({
      opacity: transition,
      transform: [
        {
          translateY: transition.interpolate({
            inputRange: [0, 1],
            outputRange: [8, 0]
          })
        }
      ]
    }),
    [transition]
  );

  return (
    <ScrollView>
      <PageShell theme={theme} profile={profile}>
        <View style={styles.header}>
          <LinearGradient
            colors={
              theme.mode === "dark"
                ? [theme.colors.surfaceHero, theme.colors.card, theme.colors.bg]
                : [theme.colors.surfaceHero, theme.colors.card, theme.colors.surface]
            }
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
            style={styles.headerInner}
          >
            <Text style={styles.eyebrow}>VENTO ECOSYSTEM · VITAL</Text>
            <Text style={styles.title}>Vento Vital</Text>
            <Text style={styles.subtitle}>Dirección diaria para entrenar, recuperarte y sostener hábitos sin perder claridad.</Text>
            <Text style={styles.subtitleStrong}>Ejecución diaria con criterio, contexto y una identidad más Vento.</Text>
          </LinearGradient>
        </View>

        <View style={styles.tabBar}>
          <View style={styles.tabBarInner}>
            <Pressable
              style={({ pressed }) => [
                styles.tabButton,
                activeTab === TAB_KEYS.HOY ? styles.tabButtonActive : null,
                pressed ? { opacity: 0.9, borderColor: theme.colors.borderStrong } : null
              ]}
              onPress={() => setActiveTab(TAB_KEYS.HOY)}
            >
              <Text style={[styles.tabText, activeTab === TAB_KEYS.HOY ? styles.tabTextActive : null]}>HOY</Text>
              {activeTab === TAB_KEYS.HOY ? <View style={styles.activePill} /> : null}
            </Pressable>
            <Pressable
              style={({ pressed }) => [
                styles.tabButton,
                activeTab === TAB_KEYS.SUMMARY ? styles.tabButtonActive : null,
                pressed ? { opacity: 0.9, borderColor: theme.colors.borderStrong } : null
              ]}
              onPress={() => setActiveTab(TAB_KEYS.SUMMARY)}
            >
              <Text style={[styles.tabText, activeTab === TAB_KEYS.SUMMARY ? styles.tabTextActive : null]}>Resumen</Text>
              {activeTab === TAB_KEYS.SUMMARY ? <View style={styles.activePill} /> : null}
            </Pressable>
            <Pressable
              style={({ pressed }) => [
                styles.tabButton,
                activeTab === TAB_KEYS.PROFILE ? styles.tabButtonActive : null,
                pressed ? { opacity: 0.9, borderColor: theme.colors.borderStrong } : null
              ]}
              onPress={() => setActiveTab(TAB_KEYS.PROFILE)}
            >
              <Text style={[styles.tabText, activeTab === TAB_KEYS.PROFILE ? styles.tabTextActive : null]}>Perfil</Text>
              {activeTab === TAB_KEYS.PROFILE ? <View style={styles.activePill} /> : null}
            </Pressable>
          </View>
        </View>

        <Animated.View style={animatedStyle}>{renderActiveTab(activeTab, screenProps)}</Animated.View>
      </PageShell>
    </ScrollView>
  );
}
