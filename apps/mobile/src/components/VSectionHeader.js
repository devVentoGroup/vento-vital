import React from "react";
import { Text, View } from "react-native";

export function VSectionHeader({ theme, title, subtitle, right }) {
  return (
    <View style={{ gap: 5 }}>
      <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center" }}>
        <Text style={{ ...theme.typography.title, color: theme.colors.textPrimary }}>{title}</Text>
        {right || null}
      </View>
      {subtitle ? (
        <Text
          style={{
            fontSize: 13,
            lineHeight: 18,
            color: theme.colors.textSecondary,
            fontFamily: "AvenirNext-Regular"
          }}
        >
          {subtitle}
        </Text>
      ) : null}
    </View>
  );
}
