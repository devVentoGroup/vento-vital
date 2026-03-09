import React, { useEffect, useRef } from "react";
import { Animated } from "react-native";

export function SkeletonBlock({ height = 16, radius = 8, theme, style }) {
  const opacity = useRef(new Animated.Value(0.35)).current;

  useEffect(() => {
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(opacity, {
          toValue: 0.7,
          duration: 750,
          useNativeDriver: true
        }),
        Animated.timing(opacity, {
          toValue: 0.35,
          duration: 750,
          useNativeDriver: true
        })
      ])
    );
    loop.start();
    return () => loop.stop();
  }, [opacity]);

  return (
    <Animated.View
      style={[
        {
          height,
          borderRadius: radius,
          backgroundColor: theme.mode === "dark" ? "#2A2733" : "#E6E1EA",
          opacity
        },
        style
      ]}
    />
  );
}
