import React from "react";
import { VChip } from "./VChip";

export function VOptionChip({ theme, label, active = false, onPress, disabled = false, style, textStyle }) {
  return (
    <VChip
      theme={theme}
      label={label}
      active={active}
      onPress={onPress}
      interactive={!disabled}
      style={[disabled ? { opacity: 0.65 } : null, style]}
      textStyle={textStyle}
    />
  );
}
