import React from "react";
import { Text, View } from "react-native";
import { LinearGradient } from "expo-linear-gradient";
import { VButton } from "../components/VButton";
import { VCard } from "../components/VCard";
import { VInput } from "../components/VInput";
import { VSectionHeader } from "../components/VSectionHeader";

function createStyles(theme) {
  return {
    container: {
      flex: 1,
      justifyContent: "center",
      padding: theme.spacing.md
    },
    hero: {
      ...theme.blocks.hero,
      borderColor: theme.colors.progressBorder,
      overflow: "hidden"
    },
    heroInner: {
      padding: theme.spacing.sm,
      gap: 8
    },
    badge: {
      alignSelf: "flex-start",
      borderRadius: 999,
      borderWidth: 1,
      borderColor: theme.colors.progressBorder,
      backgroundColor: theme.colors.mintSoft,
      paddingHorizontal: 10,
      paddingVertical: 4
    },
    badgeText: {
      color: theme.colors.mintDark,
      fontSize: 11,
      fontWeight: "700",
      fontFamily: "AvenirNext-DemiBold"
    },
    helper: {
      color: theme.colors.textSecondary,
      fontSize: 12,
      lineHeight: 17,
      fontFamily: "AvenirNext-Regular"
    },
    error: {
      color: theme.colors.error,
      fontSize: 12
    }
  };
}

export function LoginScreen({ theme, flow }) {
  const styles = createStyles(theme);
  const heroColors = theme.mode === "dark" ? [theme.colors.surface, theme.colors.bg] : [theme.colors.mintSoft, theme.colors.surface];

  return (
    <View style={styles.container}>
      <VCard theme={theme} tone="surface" style={{ padding: theme.spacing.md, gap: theme.spacing.sm }}>
        <View style={styles.hero}>
          <LinearGradient colors={heroColors} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} style={styles.heroInner}>
            <View style={styles.badge}>
              <Text style={styles.badgeText}>Inicio de sesión</Text>
            </View>
            <VSectionHeader
              theme={theme}
              title="Vento Vital"
              subtitle="Ingresa con tu cuenta para ver tu plan diario, resumen semanal y perfil."
            />
          </LinearGradient>
        </View>
        <VInput
          theme={theme}
          value={flow.email}
          onChangeText={flow.setEmail}
          placeholder="Correo"
          keyboardType="email-address"
        />
        <VInput
          theme={theme}
          value={flow.password}
          onChangeText={flow.setPassword}
          placeholder="Contraseña"
          secureTextEntry
        />
        <VButton
          theme={theme}
          title={flow.authLoading ? "Ingresando..." : "Iniciar sesión"}
          disabled={!flow.canLogin}
          onPress={flow.onLogin}
        />
        <Text style={styles.helper}>Usa el mismo correo y contraseña que registraste en Supabase Auth.</Text>
        {flow.authError ? <Text style={styles.error}>{flow.authError}</Text> : null}
      </VCard>
    </View>
  );
}
