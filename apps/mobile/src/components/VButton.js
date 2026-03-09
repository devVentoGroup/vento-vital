import React from "react";
import { Pressable, Text } from "react-native";

export function VButton({ theme, title, onPress, disabled, loading = false, variant = "primary", style }) {
  const isPrimary = variant === "primary";
  const buttonStyle = {
    borderRadius: 16,
    minHeight: isPrimary ? 50 : 44,
    justifyContent: "center",
    alignItems: "center",
    borderWidth: isPrimary ? 0 : 1,
    borderColor: isPrimary ? "transparent" : theme.colors.borderStrong,
    backgroundColor: isPrimary ? theme.colors.cta : theme.colors.cardAlt,
    opacity: disabled ? 0.65 : 1
  };
  const textStyle = {
    color: isPrimary ? theme.colors.ctaText : theme.colors.textPrimary,
    fontWeight: "700",
    fontSize: 15,
    fontFamily: "AvenirNext-DemiBold",
    letterSpacing: 0.1
  };

  return (
    <Pressable
      style={({ pressed }) => [
        buttonStyle,
        isPrimary && pressed ? { backgroundColor: theme.colors.ctaPressed } : null,
        !isPrimary && pressed ? { borderColor: theme.colors.progressBorder, backgroundColor: theme.colors.surface } : null,
        style
      ]}
      disabled={disabled}
      onPress={onPress}
    >
      <Text style={textStyle}>{loading ? "Procesando..." : title}</Text>
    </Pressable>
  );
}
