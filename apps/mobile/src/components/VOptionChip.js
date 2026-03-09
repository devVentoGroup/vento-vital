import React from "react";
import { Pressable, Text } from "react-native";

export function VOptionChip({ theme, label, active = false, onPress, disabled = false, style, textStyle }) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      style={({ pressed }) => [
        {
          borderWidth: 1.1,
          borderColor: active ? theme.colors.progressBorder : theme.colors.borderStrong,
          backgroundColor: active ? theme.colors.mintSoft : theme.colors.cardAlt,
          borderRadius: 999,
          paddingHorizontal: 12,
          paddingVertical: 7,
          opacity: disabled ? 0.65 : pressed ? 0.88 : 1
        },
        style
      ]}
    >
      <Text
        style={[
          {
            color: active ? theme.colors.mintDark : theme.colors.textSecondary,
            fontSize: 12,
            fontWeight: "600",
            fontFamily: "AvenirNext-DemiBold",
            letterSpacing: 0.1
          },
          textStyle
        ]}
      >
        {label}
      </Text>
    </Pressable>
  );
}
