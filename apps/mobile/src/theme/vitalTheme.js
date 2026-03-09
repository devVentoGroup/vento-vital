const SHARED_COLORS = {
  mintPrimary: "#34D399",
  mintPrimaryDark: "#10B981",
  mintPrimarySoft: "#6EE7B7",
  mintSoft: "#ECFDF5",
  mintSurface: "#D1FAE5",
  mintDark: "#065F46",
  vitalAccent: "#E2006A",
  roseGold: "#B76E79",
  roseGoldHighlight: "#F2C6C0"
};

const LIGHT_THEME = {
  mode: "light",
  colors: {
    ...SHARED_COLORS,
    bg: "#F7F5F8",
    surface: "#F2EEF2",
    card: "#FFFFFF",
    cardAlt: "#FBFAFC",
    textPrimary: "#1B1A1F",
    textSecondary: "#6F6A77",
    textMuted: "#9892A4",
    border: "#E6E1EA",
    borderStrong: "#D8D0E2",
    cta: SHARED_COLORS.mintPrimary,
    ctaPressed: SHARED_COLORS.mintPrimaryDark,
    ctaText: "#063B2C",
    success: "#0F766E",
    warning: "#92400E",
    error: "#B91C1C",
    progressTrack: "#D1FAE5",
    progressBorder: "#A7F3D0",
    ambientA: "rgba(52, 211, 153, 0.12)",
    ambientB: "rgba(125, 211, 252, 0.10)",
    ambientC: "rgba(244, 114, 182, 0.08)",
    overlay: "rgba(16, 24, 40, 0.14)"
  }
};

const DARK_THEME = {
  mode: "dark",
  colors: {
    ...SHARED_COLORS,
    bg: "#0F0E12",
    surface: "#15141B",
    card: "#1B1A22",
    cardAlt: "#211F29",
    textPrimary: "#F7F5F8",
    textSecondary: "#B9B4C1",
    textMuted: "#8F889E",
    border: "#2A2733",
    borderStrong: "#3A3547",
    cta: SHARED_COLORS.mintPrimary,
    ctaPressed: SHARED_COLORS.mintPrimaryDark,
    ctaText: "#03251C",
    success: "#34D399",
    warning: "#F59E0B",
    error: "#F87171",
    progressTrack: "#173A31",
    progressBorder: "#1F5E4F",
    ambientA: "rgba(16, 185, 129, 0.18)",
    ambientB: "rgba(56, 189, 248, 0.14)",
    ambientC: "rgba(236, 72, 153, 0.10)",
    overlay: "rgba(0, 0, 0, 0.30)"
  }
};

const SPACING = {
  xs: 8,
  sm: 12,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 40
};

const RADIUS = {
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24
};

export function getVitalTheme(colorScheme) {
  const base = colorScheme === "dark" ? DARK_THEME : LIGHT_THEME;
  const isDark = base.mode === "dark";
  return {
    ...base,
    spacing: SPACING,
    radius: RADIUS,
    typography: {
      h1: { fontSize: 28, lineHeight: 34, fontWeight: "700", letterSpacing: -0.4, fontFamily: "AvenirNext-Bold" },
      h2: { fontSize: 20, lineHeight: 26, fontWeight: "700", letterSpacing: -0.2, fontFamily: "AvenirNext-DemiBold" },
      title: { fontSize: 16, lineHeight: 22, fontWeight: "600", letterSpacing: -0.1, fontFamily: "AvenirNext-DemiBold" },
      body: { fontSize: 15, lineHeight: 21, fontWeight: "500", fontFamily: "AvenirNext-Regular" },
      caption: { fontSize: 12, lineHeight: 16, fontWeight: "500", letterSpacing: 0.15, fontFamily: "AvenirNext-Regular" }
    },
    elevations: {
      card: isDark
        ? {
            shadowColor: "transparent",
            shadowOpacity: 0,
            shadowRadius: 0,
            shadowOffset: { width: 0, height: 0 },
            elevation: 0
          }
        : {
            shadowColor: "#0B2A1F",
            shadowOpacity: 0.12,
            shadowRadius: 20,
            shadowOffset: { width: 0, height: 10 },
            elevation: 4
          }
    },
    motion: {
      pressScale: 0.98,
      fast: 130,
      medium: 240
    },
    blocks: {
      section: {
        padding: SPACING.sm,
        gap: SPACING.xs
      },
      hero: {
        borderRadius: RADIUS.xl,
        borderWidth: 1
      },
      panel: {
        borderWidth: 1,
        borderRadius: RADIUS.lg,
        padding: SPACING.sm
      },
      metric: {
        borderWidth: 1,
        borderRadius: 14,
        padding: 10
      },
      action: {
        borderWidth: 1,
        borderRadius: RADIUS.xl,
        padding: SPACING.sm
      }
    }
  };
}

export function getTaskStatusStyle(status, theme) {
  const isDark = theme.mode === "dark";
  const map = {
    completed: {
      dotBg: theme.colors.mintPrimary,
      dotBorder: theme.colors.mintPrimary,
      label: "Hecho",
      cardBg: isDark ? "#12362D" : theme.colors.mintSoft,
      statusColor: theme.colors.mintDark
    },
    snoozed: {
      dotBg: theme.colors.card,
      dotBorder: theme.colors.textSecondary,
      label: "Pospuesta",
      cardBg: theme.colors.card,
      statusColor: theme.colors.textSecondary
    },
    skipped: {
      dotBg: theme.colors.card,
      dotBorder: theme.colors.textSecondary,
      label: "Omitida",
      cardBg: theme.colors.card,
      statusColor: theme.colors.textSecondary
    },
    in_progress: {
      dotBg: theme.colors.mintPrimary,
      dotBorder: theme.colors.mintPrimary,
      label: "En curso",
      cardBg: isDark ? "#12362D" : theme.colors.mintSoft,
      statusColor: theme.colors.mintDark
    },
    pending: {
      dotBg: theme.colors.card,
      dotBorder: theme.colors.progressBorder,
      label: "Pendiente",
      cardBg: theme.colors.card,
      statusColor: theme.colors.textSecondary
    }
  };
  return map[status] || map.pending;
}

export function getModuleStyle(moduleKey, theme) {
  const isDark = theme.mode === "dark";
  const map = {
    training: {
      tint: isDark ? "#1E2A1F" : "#F0FDF4",
      border: isDark ? "#365A45" : "#86EFAC",
      text: isDark ? "#86EFAC" : "#166534",
      label: "Entrenamiento"
    },
    nutrition: {
      tint: isDark ? "#1B2E2C" : "#ECFEFF",
      border: isDark ? "#2C6C67" : "#67E8F9",
      text: isDark ? "#7EE7DE" : "#0F766E",
      label: "Nutrición"
    },
    habits: {
      tint: isDark ? "#25242F" : "#FAF5FF",
      border: isDark ? "#5B4F88" : "#D8B4FE",
      text: isDark ? "#C4B5FD" : "#6D28D9",
      label: "Hábitos"
    },
    recovery: {
      tint: isDark ? "#2A231A" : "#FFF7ED",
      border: isDark ? "#8A6840" : "#FDBA74",
      text: isDark ? "#FCD9A8" : "#B45309",
      label: "Recuperación"
    }
  };
  return map[moduleKey] || map.training;
}
