import React from "react";
import { View } from "react-native";

export function VCard({ theme, children, style, elevated = true, tone = "card" }) {
  const backgroundColor =
    tone === "surface" ? theme.colors.surface : tone === "alt" ? theme.colors.cardAlt : tone === "muted" ? theme.colors.cardMuted : theme.colors.card;
  return (
    <View
      style={[
        {
          backgroundColor,
          borderWidth: 1,
          borderColor: tone === "surface" ? theme.colors.border : theme.colors.borderStrong,
          borderRadius: theme.radius.xxl,
          padding: theme.spacing.sm,
          gap: theme.spacing.xs,
          overflow: "hidden"
        },
        elevated ? theme.elevations.card : null,
        style
      ]}
    >
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: 1,
          backgroundColor: theme.mode === "dark" ? "rgba(255,255,255,0.06)" : "rgba(255,255,255,0.75)"
        }}
      />
      <View
        pointerEvents="none"
        style={{
          position: "absolute",
          top: -48,
          right: -24,
          width: 120,
          height: 120,
          borderRadius: 999,
          backgroundColor: theme.mode === "dark" ? "rgba(255,255,255,0.03)" : "rgba(201, 90, 115, 0.05)"
        }}
      />
      {children}
    </View>
  );
}
