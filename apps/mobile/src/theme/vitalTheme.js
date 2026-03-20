const SHARED_COLORS = {
  mintPrimary: "#67C6A3",
  mintPrimaryDark: "#3E9B79",
  mintPrimarySoft: "#9FDCC3",
  mintSoft: "#EEF7F2",
  mintSurface: "#D7EADF",
  mintDark: "#225A48",
  vitalAccent: "#C95A73",
  vitalAccentDark: "#983A51",
  vitalAccentSoft: "#FBECEF",
  roseGold: "#B07B72",
  roseGoldHighlight: "#E8C1B8",
  graphite: "#19161B",
  stone: "#6D646D"
};

const LIGHT_THEME = {
  mode: "light",
  colors: {
    ...SHARED_COLORS,
    bg: "#F5F0ED",
    surface: "#EEE6E2",
    card: "#FFFDFC",
    cardAlt: "#F8F1EE",
    cardMuted: "#F2E8E4",
    surfaceHero: "#F6EBE8",
    textPrimary: "#19161B",
    textSecondary: "#6B616A",
    textMuted: "#978B94",
    border: "#E4D9D3",
    borderStrong: "#D3C5BE",
    cta: SHARED_COLORS.vitalAccent,
    ctaPressed: SHARED_COLORS.vitalAccentDark,
    ctaText: "#FFF7F8",
    success: SHARED_COLORS.mintDark,
    warning: "#9F5B1A",
    error: "#B43C53",
    progressTrack: "#EADFD9",
    progressBorder: "#D9C6BE",
    accentBrand: SHARED_COLORS.vitalAccent,
    accentBrandSoft: SHARED_COLORS.vitalAccentSoft,
    accentBrandStrong: "#8D2C47",
    accentHealth: SHARED_COLORS.mintPrimary,
    accentHealthSoft: SHARED_COLORS.mintSoft,
    ambientA: "rgba(201, 90, 115, 0.15)",
    ambientB: "rgba(232, 193, 184, 0.18)",
    ambientC: "rgba(106, 97, 106, 0.08)",
    overlay: "rgba(16, 24, 40, 0.14)"
  }
};

const DARK_THEME = {
  mode: "dark",
  colors: {
    ...SHARED_COLORS,
    bg: "#100E12",
    surface: "#17141A",
    card: "#1D1920",
    cardAlt: "#252029",
    cardMuted: "#2D2631",
    surfaceHero: "#251C22",
    textPrimary: "#F7F2F1",
    textSecondary: "#C2B7BF",
    textMuted: "#958B94",
    border: "#302932",
    borderStrong: "#433842",
    cta: SHARED_COLORS.vitalAccent,
    ctaPressed: "#E26B89",
    ctaText: "#FFF7F8",
    success: "#7FD0B2",
    warning: "#F59E0B",
    error: "#F07A90",
    progressTrack: "#352B31",
    progressBorder: "#5B4851",
    accentBrand: "#E27A96",
    accentBrandSoft: "#3A1F28",
    accentBrandStrong: "#F3A4B8",
    accentHealth: "#67C6A3",
    accentHealthSoft: "#19332C",
    ambientA: "rgba(201, 90, 115, 0.20)",
    ambientB: "rgba(176, 123, 114, 0.16)",
    ambientC: "rgba(103, 198, 163, 0.10)",
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
      label: { fontSize: 11, lineHeight: 15, fontWeight: "700", letterSpacing: 0.8, fontFamily: "AvenirNext-DemiBold" },
      h1: { fontSize: 28, lineHeight: 34, fontWeight: "700", letterSpacing: -0.4, fontFamily: "AvenirNext-Bold" },
      h2: { fontSize: 20, lineHeight: 26, fontWeight: "700", letterSpacing: -0.2, fontFamily: "AvenirNext-DemiBold" },
      title: { fontSize: 16, lineHeight: 22, fontWeight: "600", letterSpacing: -0.1, fontFamily: "AvenirNext-DemiBold" },
      body: { fontSize: 15, lineHeight: 21, fontWeight: "500", fontFamily: "AvenirNext-Regular" },
      caption: { fontSize: 12, lineHeight: 16, fontWeight: "500", letterSpacing: 0.15, fontFamily: "AvenirNext-Regular" }
    },
    elevations: {
      card: isDark
        ? {
            shadowColor: "#000000",
            shadowOpacity: 0.18,
            shadowRadius: 18,
            shadowOffset: { width: 0, height: 10 },
            elevation: 0
          }
        : {
            shadowColor: "#241A20",
            shadowOpacity: 0.08,
            shadowRadius: 18,
            shadowOffset: { width: 0, height: 8 },
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
      dotBg: theme.colors.accentHealth,
      dotBorder: theme.colors.accentHealth,
      label: "Hecho",
      cardBg: theme.colors.accentHealthSoft,
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
      dotBg: theme.colors.accentBrand,
      dotBorder: theme.colors.accentBrand,
      label: "En curso",
      cardBg: theme.colors.accentBrandSoft,
      statusColor: isDark ? theme.colors.accentBrandStrong : theme.colors.accentBrandStrong
    },
    pending: {
      dotBg: theme.colors.card,
      dotBorder: theme.colors.borderStrong,
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
      tint: isDark ? "#321F25" : "#FCEEF1",
      border: isDark ? "#6D4250" : "#E5B7C2",
      text: isDark ? "#F0A7BA" : "#8D2C47",
      label: "Entrenamiento"
    },
    nutrition: {
      tint: isDark ? "#1A2A2A" : "#EDF6F5",
      border: isDark ? "#335455" : "#B6D7D3",
      text: isDark ? "#91D0C6" : "#245E5B",
      label: "Nutrición"
    },
    habits: {
      tint: isDark ? "#292331" : "#F6F0F8",
      border: isDark ? "#61506D" : "#D7C3DF",
      text: isDark ? "#D4B8E3" : "#6E4E79",
      label: "Hábitos"
    },
    recovery: {
      tint: isDark ? "#31261E" : "#FBF1E7",
      border: isDark ? "#6D5540" : "#E4C19B",
      text: isDark ? "#E4C29A" : "#94613B",
      label: "Recuperación"
    }
  };
  return map[moduleKey] || map.training;
}
