import React from "react";
import { View } from "react-native";

export function PageShell({ theme, profile, children }) {
  return (
    <View
      style={{
        position: "relative",
        padding: theme.spacing.md,
        gap: theme.spacing.md,
        maxWidth: profile.formFactor === "tablet" ? 920 : 760,
        alignSelf: "center",
        width: "100%"
      }}
    >
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: -72,
          right: -42,
          width: 220,
          height: 220,
          borderRadius: 999,
          backgroundColor: theme.colors.ambientA
        }}
      />
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: 210,
          left: -78,
          width: 210,
          height: 210,
          borderRadius: 999,
          backgroundColor: theme.colors.ambientB
        }}
      />
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          bottom: -100,
          right: -56,
          width: 180,
          height: 180,
          borderRadius: 999,
          backgroundColor: theme.colors.ambientC
        }}
      />
      {children}
    </View>
  );
}
