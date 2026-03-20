import React from "react";
import { Pressable, Text } from "react-native";

export function VButton({ theme, title, onPress, disabled, loading = false, variant = "primary", style }) {
  const isPrimary = variant === "primary";
  const isSecondary = variant === "secondary";
  const buttonStyle = {
    borderRadius: 18,
    minHeight: isPrimary ? 52 : 46,
    justifyContent: "center",
    alignItems: "center",
    borderWidth: 1,
    borderColor: isPrimary ? theme.colors.accentBrand : theme.colors.borderStrong,
    backgroundColor: isPrimary ? theme.colors.cta : isSecondary ? theme.colors.card : theme.colors.cardAlt,
    opacity: disabled ? 0.65 : 1
  };
  const textStyle = {
    color: isPrimary ? theme.colors.ctaText : theme.colors.textPrimary,
    fontWeight: "700",
    fontSize: 14,
    fontFamily: "AvenirNext-DemiBold",
    letterSpacing: 0.2
  };

  return (
    <Pressable
      style={({ pressed }) => [
        buttonStyle,
        isPrimary && pressed ? { backgroundColor: theme.colors.ctaPressed } : null,
        !isPrimary && pressed ? { borderColor: theme.colors.accentBrand, backgroundColor: theme.colors.cardAlt } : null,
        style
      ]}
      disabled={disabled}
      onPress={onPress}
    >
      <Text style={textStyle}>{loading ? "Procesando..." : title}</Text>
    </Pressable>
  );
}
