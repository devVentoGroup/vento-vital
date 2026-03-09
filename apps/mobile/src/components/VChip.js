import React from "react";
import { Pressable, Text, View } from "react-native";

export function VChip({ theme, label, active = false, onPress, style, textStyle, interactive = true }) {
  const baseStyle = {
    borderWidth: 1.1,
    borderColor: active ? theme.colors.progressBorder : theme.colors.borderStrong,
    backgroundColor: active ? theme.colors.mintSoft : theme.colors.cardAlt,
    borderRadius: 999,
    paddingHorizontal: 12,
    paddingVertical: 7,
    minHeight: 34,
    justifyContent: "center"
  };
  const baseText = {
    color: active ? theme.colors.mintDark : theme.colors.textSecondary,
    fontSize: 12,
    fontWeight: "600",
    fontFamily: "AvenirNext-DemiBold",
    letterSpacing: 0.1
  };

  if (interactive) {
    return (
      <Pressable
        style={({ pressed }) => [
          baseStyle,
          pressed ? { opacity: 0.88, borderColor: theme.colors.progressBorder } : null,
          style
        ]}
        onPress={onPress}
      >
        <Text style={[baseText, textStyle]}>{label}</Text>
      </Pressable>
    );
  }

  return (
    <View style={[baseStyle, style]}>
      <Text style={[baseText, textStyle]}>{label}</Text>
    </View>
  );
}
