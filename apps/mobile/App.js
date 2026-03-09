import React, { useMemo } from "react";
import { Text, View, useColorScheme } from "react-native";
import { StatusBar } from "expo-status-bar";
import { SafeAreaProvider, SafeAreaView } from "react-native-safe-area-context";
import { MainTabs } from "./src/navigation/MainTabs";
import { useHoyFlow } from "./src/features/hoy/useHoyFlow";
import { getDeviceProfile } from "./src/platform/deviceProfile";
import { getSurfaceCapabilities } from "./src/platform/surfaceConfig";
import { LoginScreen } from "./src/screens/LoginScreen";
import { OnboardingScreen } from "./src/screens/OnboardingScreen";
import { getVitalTheme } from "./src/theme/vitalTheme";

export default function App() {
  const colorScheme = useColorScheme();
  const theme = useMemo(() => getVitalTheme(colorScheme), [colorScheme]);
  const profile = getDeviceProfile();
  const caps = getSurfaceCapabilities(profile.formFactor);
  const flow = useHoyFlow();

  return (
    <SafeAreaProvider>
      <SafeAreaView style={{ flex: 1, backgroundColor: theme.colors.bg }}>
        <StatusBar style={theme.mode === "dark" ? "light" : "dark"} />
        {flow.isBootstrappingSession ? (
          <View style={{ flex: 1, alignItems: "center", justifyContent: "center", padding: 24 }}>
            <Text style={{ color: theme.colors.textPrimary, fontSize: 16, fontWeight: "600" }}>Cargando sesión...</Text>
          </View>
        ) : flow.hasSession && !flow.hasCompletedOnboarding ? (
          <OnboardingScreen theme={theme} flow={flow} />
        ) : flow.hasSession ? (
          <MainTabs theme={theme} profile={profile} caps={caps} flow={flow} />
        ) : (
          <LoginScreen theme={theme} flow={flow} />
        )}
      </SafeAreaView>
    </SafeAreaProvider>
  );
}
