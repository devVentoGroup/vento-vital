import React from "react";
import { TextInput, View } from "react-native";

export function VInput({
  theme,
  value,
  onChangeText,
  placeholder,
  style,
  placeholderTextColor,
  secureTextEntry,
  autoCapitalize = "none",
  autoCorrect = false,
  keyboardType = "default"
}) {
  const [focused, setFocused] = React.useState(false);
  return (
    <View
      style={[
        {
          borderWidth: 1.2,
          borderColor: focused ? theme.colors.progressBorder : theme.colors.border,
          borderRadius: theme.radius.md,
          minHeight: 48,
          paddingHorizontal: 12,
          justifyContent: "center",
          backgroundColor: theme.colors.cardAlt
        },
        focused
          ? {
              shadowColor: theme.mode === "dark" ? "transparent" : "#22C55E",
              shadowOpacity: theme.mode === "dark" ? 0 : 0.12,
              shadowRadius: theme.mode === "dark" ? 0 : 12,
              shadowOffset: { width: 0, height: 4 },
              elevation: theme.mode === "dark" ? 0 : 2
            }
          : null,
        style
      ]}
    >
      <TextInput
        style={{
          minHeight: 40,
          color: theme.colors.textPrimary,
          fontFamily: "AvenirNext-Regular",
          fontSize: 15
        }}
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={placeholderTextColor || theme.colors.textMuted}
        secureTextEntry={secureTextEntry}
        autoCapitalize={autoCapitalize}
        autoCorrect={autoCorrect}
        keyboardType={keyboardType}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
      />
    </View>
  );
}
