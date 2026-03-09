import React from "react";
import { View } from "react-native";

export function PageShell({ theme, profile, children }) {
  return (
    <View
      style={{
        position: "relative",
        padding: theme.spacing.md,
        gap: theme.spacing.sm,
        maxWidth: profile.formFactor === "tablet" ? 920 : 760,
        alignSelf: "center",
        width: "100%"
      }}
    >
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: -80,
          right: -50,
          width: 210,
          height: 210,
          borderRadius: 999,
          backgroundColor: theme.colors.ambientA
        }}
      />
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: 180,
          left: -90,
          width: 230,
          height: 230,
          borderRadius: 999,
          backgroundColor: theme.colors.ambientB
        }}
      />
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          bottom: -120,
          right: -80,
          width: 220,
          height: 220,
          borderRadius: 999,
          backgroundColor: theme.colors.ambientC
        }}
      />
      {children}
    </View>
  );
}
