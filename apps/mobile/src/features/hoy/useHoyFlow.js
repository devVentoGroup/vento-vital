import { useEffect, useMemo, useRef, useState } from "react";
import { Animated, Vibration } from "react-native";
import * as Haptics from "expo-haptics";
import { loginWithPassword, refreshWithToken } from "../../api/authApi";
import { loadOnboardingV2Done, saveOnboardingV2Done } from "../../api/onboardingStore";
import { clearSession, loadSession, saveSession } from "../../api/sessionStore";
import { completeOnboarding } from "../../api/onboardingApi";
import { completeTask, getTodayFeed, getTodayTasks, reprogramTask, snoozeTask } from "../../api/hoyApi";
import { getMyModulePreferences, updateMyModulePreferences } from "../../api/modulesApi";
import { getSafetyStatus } from "../../api/safetyApi";
import { trackEvent } from "../../api/telemetryApi";
import { upsertNotificationPlan } from "../../api/notificationsApi";
import { getSportsProfile, updateSportsProfile } from "../../api/sportsProfileApi";
import { getCycleAdjustment, getWeeklyPlan } from "../../api/planningApi";
import { presentHoyTasks } from "./hoyPresenter";
import { syncTodayLocalNotifications } from "../../services/localNotifications";
import { getWeeklySummary } from "../../api/summaryApi";
import { applyAiWeeklyPlan, previewAiWeeklyPlan } from "../../api/aiApi";
import { getNutritionProfile, listNutritionDailyLogs, updateNutritionProfile, upsertNutritionDailyLog } from "../../api/nutritionApi";

function toDateOnlyISO(date) {
  return date.toISOString().slice(0, 10);
}

function startOfTodayLocal() {
  const now = new Date();
  return new Date(now.getFullYear(), now.getMonth(), now.getDate());
}

function computeExpiresAt(expiresInSeconds) {
  if (!expiresInSeconds || Number.isNaN(Number(expiresInSeconds))) return null;
  return Date.now() + Number(expiresInSeconds) * 1000;
}

function isExpiringSoon(expiresAt, leadMs = 90 * 1000) {
  if (!expiresAt) return false;
  return Date.now() + leadMs >= Number(expiresAt);
}

function toBoundedDays(daysPerWeek) {
  const n = Number(daysPerWeek);
  if (!Number.isFinite(n)) return 3;
  return Math.max(2, Math.min(6, Math.round(n)));
}

function toUserError(err, fallback) {
  const message = String(err?.message || "").trim();
  if (/network request failed/i.test(message)) {
    return "No pudimos conectar con el servicio. Revisa tu conexión e intenta de nuevo.";
  }
  if (/failed to fetch|load failed/i.test(message)) {
    return "No fue posible conectar con el servicio. Revisa tu red e intenta de nuevo.";
  }
  if (/missing bearer token/i.test(message)) {
    return "Sesión inválida. Cierra sesión e inicia de nuevo.";
  }
  if (/jwt|token/i.test(message)) {
    return "Tu sesión expiró. Ingresa nuevamente para continuar.";
  }
  return message || fallback;
}

export function useHoyFlow() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [jwt, setJwt] = useState("");
  const [tasks, setTasks] = useState([]);
  const [error, setError] = useState("");
  const [authError, setAuthError] = useState("");
  const [authLoading, setAuthLoading] = useState(false);
  const [loading, setLoading] = useState(false);
  const [summaryLoading, setSummaryLoading] = useState(false);
  const [summaryError, setSummaryError] = useState("");
  const [isBootstrappingSession, setIsBootstrappingSession] = useState(true);
  const [sessionMeta, setSessionMeta] = useState(null);
  const [actionStateByTask, setActionStateByTask] = useState({});
  const [weeklyTrend, setWeeklyTrend] = useState([]);
  const [weeklyModuleTrend, setWeeklyModuleTrend] = useState({});
  const [weeklySummaryKey, setWeeklySummaryKey] = useState(null);
  const [weeklyPlan, setWeeklyPlan] = useState([]);
  const [cycleAdjustments, setCycleAdjustments] = useState([]);
  const [planningLoading, setPlanningLoading] = useState(false);
  const [planningError, setPlanningError] = useState("");
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState(false);
  const [onboardingLoading, setOnboardingLoading] = useState(false);
  const [onboardingError, setOnboardingError] = useState("");
  const [modulePreferences, setModulePreferences] = useState([]);
  const [modulesLoading, setModulesLoading] = useState(false);
  const [modulesError, setModulesError] = useState("");
  const [sportsProfile, setSportsProfile] = useState(null);
  const [sportsProfileLoading, setSportsProfileLoading] = useState(false);
  const [sportsProfileError, setSportsProfileError] = useState("");
  const [aiPreview, setAiPreview] = useState(null);
  const [aiLoading, setAiLoading] = useState(false);
  const [aiError, setAiError] = useState("");
  const [nutritionProfile, setNutritionProfile] = useState(null);
  const [nutritionLogs, setNutritionLogs] = useState([]);
  const [nutritionLoading, setNutritionLoading] = useState(false);
  const [nutritionError, setNutritionError] = useState("");
  const [safetyStatus, setSafetyStatus] = useState(null);
  const [notificationsLoading, setNotificationsLoading] = useState(false);
  const [notificationsResult, setNotificationsResult] = useState(null);
  const [notificationsError, setNotificationsError] = useState("");
  const [lastHoySource, setLastHoySource] = useState("none");
  const [healthStatus, setHealthStatus] = useState("");
  const [lastOperation, setLastOperation] = useState("sin operaciones");
  const [lastOperationAt, setLastOperationAt] = useState(null);
  const progressScale = useRef(new Animated.Value(0)).current;

  const hasSession = jwt.trim().length > 0;
  const canLogin = useMemo(() => email.trim().length > 0 && password.trim().length > 0 && !authLoading, [email, password, authLoading]);
  const canLoad = useMemo(() => hasSession && !loading, [hasSession, loading]);
  const completedCount = useMemo(() => tasks.filter((t) => t.status === "completed").length, [tasks]);
  const inProgressCount = useMemo(() => tasks.filter((t) => t.status === "in_progress").length, [tasks]);
  const pendingCount = useMemo(() => tasks.filter((t) => t.status === "pending").length, [tasks]);
  const progressPct = useMemo(() => {
    if (tasks.length === 0) return 0;
    return Math.round((completedCount / tasks.length) * 100);
  }, [completedCount, tasks.length]);

  useEffect(() => {
    Animated.timing(progressScale, {
      toValue: progressPct / 100,
      duration: 450,
      useNativeDriver: true
    }).start();
  }, [progressPct, progressScale]);

  function markOperation(label) {
    setLastOperation(label);
    setLastOperationAt(new Date().toISOString());
  }

  async function persistSession({ accessToken, refreshToken, expiresIn, email: emailOverride }) {
    const expiresAt = computeExpiresAt(expiresIn);
    const nextMeta = {
      refreshToken: refreshToken || sessionMeta?.refreshToken || null,
      expiresAt,
      email: typeof emailOverride === "string" ? emailOverride : sessionMeta?.email || ""
    };
    setJwt(accessToken);
    setSessionMeta(nextMeta);
    await saveSession({
      accessToken,
      refreshToken: nextMeta.refreshToken,
      expiresAt: nextMeta.expiresAt,
      email: nextMeta.email
    });
  }

  async function refreshSessionIfNeeded(force = false) {
    if (!sessionMeta?.refreshToken) return jwt.trim();
    const shouldRefresh = force || isExpiringSoon(sessionMeta.expiresAt);
    if (!shouldRefresh) return jwt.trim();

    const refreshed = await refreshWithToken(sessionMeta.refreshToken);
    await persistSession({
      accessToken: refreshed.accessToken,
      refreshToken: refreshed.refreshToken,
      expiresIn: refreshed.expiresIn,
      email: sessionMeta.email
    });
    return refreshed.accessToken;
  }

  useEffect(() => {
    let cancelled = false;

    async function bootstrapSession() {
      try {
        const session = await loadSession();
        if (cancelled || !session?.accessToken) return;
        const emailValue = typeof session.email === "string" ? session.email : "";
        if (emailValue.trim().length > 0) setEmail(emailValue);
        setSessionMeta({
          refreshToken: session.refreshToken || null,
          expiresAt: session.expiresAt || null,
          email: emailValue
        });
        setJwt(session.accessToken);
        const isOnboardingDone = await loadOnboardingV2Done(emailValue);
        if (!cancelled) setHasCompletedOnboarding(isOnboardingDone);

        if (session.refreshToken && (!session.expiresAt || isExpiringSoon(session.expiresAt, 0))) {
          const refreshed = await refreshWithToken(session.refreshToken);
          if (!cancelled) {
            await persistSession({
              accessToken: refreshed.accessToken,
              refreshToken: refreshed.refreshToken,
              expiresIn: refreshed.expiresIn,
              email: emailValue
            });
          }
        }
      } finally {
        if (!cancelled) setIsBootstrappingSession(false);
      }
    }

    bootstrapSession();
    return () => {
      cancelled = true;
    };
  }, []);

  useEffect(() => {
    if (!hasSession || !sessionMeta?.refreshToken || !sessionMeta?.expiresAt) return undefined;

    const msUntilRefresh = Math.max(1000, Number(sessionMeta.expiresAt) - Date.now() - 90 * 1000);
    const timer = setTimeout(() => {
      refreshSessionIfNeeded(true).catch(async () => {
        await clearSession();
        setJwt("");
        setSessionMeta(null);
        setTasks([]);
      });
    }, msUntilRefresh);

    return () => clearTimeout(timer);
  }, [hasSession, sessionMeta?.refreshToken, sessionMeta?.expiresAt]);

  async function onLogin() {
    markOperation("login_iniciado");
    setAuthError("");
    setError("");
    setAuthLoading(true);
    try {
      const session = await loginWithPassword(email.trim(), password);
      await persistSession({
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresIn: session.expiresIn || null,
        email: email.trim()
      });
      const onboardingDone = await loadOnboardingV2Done(email.trim());
      setHasCompletedOnboarding(onboardingDone);
      await loadModulePreferences(true).catch(() => {});
      await loadNutritionProfile(true).catch(() => {});
      markOperation("login_ok");
    } catch (err) {
      setAuthError(toUserError(err, "Error iniciando sesión"));
      markOperation("login_error");
    } finally {
      setAuthLoading(false);
    }
  }

  async function loadModulePreferences(force = false) {
    if (!hasSession) return [];
    if (!force && modulePreferences.length > 0) return modulePreferences;
    setModulesLoading(true);
    setModulesError("");
    try {
      const token = await refreshSessionIfNeeded();
      const [prefs, safety] = await Promise.all([getMyModulePreferences(token), getSafetyStatus(token)]);
      setModulePreferences(Array.isArray(prefs) ? prefs : []);
      setSafetyStatus(safety || null);
      return Array.isArray(prefs) ? prefs : [];
    } catch (err) {
      setModulesError(toUserError(err, "No se pudieron cargar módulos"));
      return [];
    } finally {
      setModulesLoading(false);
    }
  }

  async function updateModulePreferences(modules) {
    setModulesError("");
    setModulesLoading(true);
    try {
      const token = await refreshSessionIfNeeded();
      const prefs = await updateMyModulePreferences(token, modules);
      setModulePreferences(Array.isArray(prefs) ? prefs : []);
      return Array.isArray(prefs) ? prefs : [];
    } catch (err) {
      setModulesError(toUserError(err, "No se pudieron actualizar módulos"));
      throw err;
    } finally {
      setModulesLoading(false);
    }
  }

  async function onCompleteOnboarding({
    objective,
    profileContext,
    daysPerWeek,
    minutesPerSession,
    modules,
    experienceLevel,
    sportsProfile,
    safety
  }) {
    setOnboardingError("");
    setOnboardingLoading(true);
    try {
      const token = await refreshSessionIfNeeded();
      await completeOnboarding(token, {
        objective: objective || "general_health",
        profile_context: profileContext || "personal",
        days_per_week: toBoundedDays(daysPerWeek),
        minutes_per_session: Math.max(20, Math.min(90, Math.round(Number(minutesPerSession) || 45))),
        modules: Array.isArray(modules) ? modules : [],
        experience_level: experienceLevel || "beginner",
        sports_profile: sportsProfile || null,
        safety: safety || {}
      });
      await saveOnboardingV2Done(sessionMeta?.email || email, true);
      await trackEvent(
        token,
        "onboarding_completed_v2",
        {
          modules: Array.isArray(modules) ? modules : [],
          objective: objective || "general_health",
          experience_level: experienceLevel || "beginner"
        },
        "app",
        "v1"
      ).catch(() => {});
      setHasCompletedOnboarding(true);
      await loadModulePreferences(true);
      await loadSportsProfile(true);
      await loadNutritionProfile(true);
      await onLoadToday();
    } catch (err) {
      setOnboardingError(toUserError(err, "No se pudo completar onboarding"));
    } finally {
      setOnboardingLoading(false);
    }
  }

  async function refreshTodayTasks(token) {
    try {
      const feed = await getTodayFeed(token);
      setTasks(presentHoyTasks(feed));
      setLastHoySource("feed");
    } catch {
      const data = await getTodayTasks(token);
      setTasks(presentHoyTasks(data));
      setLastHoySource("legacy_today_tasks");
    }
  }

  async function onLoadToday() {
    markOperation("hoy_carga_iniciada");
    setError("");
    setLoading(true);
    try {
      if (Array.isArray(modulePreferences) && modulePreferences.length > 0) {
        const activeCount = modulePreferences.filter((m) => m.is_enabled).length;
        if (activeCount === 0) {
          setError("No tienes módulos activos. Activa al menos uno desde Perfil.");
          return;
        }
      }
      const token = await refreshSessionIfNeeded();
      await refreshTodayTasks(token);
      markOperation("hoy_carga_ok");
    } catch (err) {
      setError(toUserError(err, "Error cargando HOY"));
      setLastHoySource("none");
      markOperation("hoy_carga_error");
    } finally {
      setLoading(false);
    }
  }

  async function loadWeeklyTrend(force = false) {
    if (!hasSession) return;

    const todayKey = toDateOnlyISO(startOfTodayLocal());
    if (!force && weeklySummaryKey === todayKey && weeklyTrend.length > 0) {
      return;
    }

    setSummaryLoading(true);
    setSummaryError("");
    markOperation("resumen_carga_iniciada");
    try {
      const token = await refreshSessionIfNeeded();
      const summary = await getWeeklySummary(token, null);
      const rows = Array.isArray(summary?.trend) ? summary.trend : [];
      setWeeklyTrend(rows);
      setWeeklyModuleTrend(summary?.module_trend || {});
      setWeeklyPlan(Array.isArray(summary?.planning_rows) ? summary.planning_rows : []);
      setCycleAdjustments(Array.isArray(summary?.cycle_adjustments) ? summary.cycle_adjustments : []);
      setNutritionProfile(summary?.nutrition_profile || null);
      setWeeklySummaryKey(todayKey);
      markOperation("resumen_carga_ok");
    } catch (err) {
      setSummaryError(toUserError(err, "No se pudo cargar el resumen semanal"));
      markOperation("resumen_carga_error");
    } finally {
      setSummaryLoading(false);
    }
  }

  async function loadPlanningInsights(force = false, summaryKey = null) {
    if (!hasSession) return;
    if (!force && summaryKey && weeklySummaryKey === summaryKey && weeklyPlan.length > 0 && cycleAdjustments.length > 0) {
      return;
    }
    setPlanningLoading(true);
    setPlanningError("");
    try {
      const token = await refreshSessionIfNeeded();
      const today = toDateOnlyISO(startOfTodayLocal());
      const weekStartDate = new Date(startOfTodayLocal());
      const day = weekStartDate.getDay();
      const diffToMonday = day === 0 ? 6 : day - 1;
      weekStartDate.setDate(weekStartDate.getDate() - diffToMonday);
      const weekStart = toDateOnlyISO(weekStartDate);

      const [weekly, cycle] = await Promise.all([
        getWeeklyPlan(token, weekStart, "performance"),
        getCycleAdjustment(token, today)
      ]);

      setWeeklyPlan(Array.isArray(weekly) ? weekly : []);
      setCycleAdjustments(Array.isArray(cycle) ? cycle : []);
    } catch (err) {
      setPlanningError(toUserError(err, "No se pudo cargar planning semanal/ciclo"));
    } finally {
      setPlanningLoading(false);
    }
  }

  async function onPreviewAiPlan(targetDate = null) {
    if (!hasSession) {
      setAiError("Inicia sesión para generar propuesta IA.");
      return null;
    }
    setAiError("");
    setAiLoading(true);
    try {
      const token = await refreshSessionIfNeeded();
      const data = await previewAiWeeklyPlan(token, targetDate);
      setAiPreview(data || null);
      return data || null;
    } catch (err) {
      setAiError(toUserError(err, "No se pudo generar la propuesta IA"));
      return null;
    } finally {
      setAiLoading(false);
    }
  }

  async function onApplyAiPlan() {
    if (!hasSession) {
      setAiError("Inicia sesión para aplicar propuesta IA.");
      return null;
    }
    if (!aiPreview?.weekly_blocks) {
      setAiError("No hay propuesta IA disponible para aplicar.");
      return null;
    }
    setAiError("");
    setAiLoading(true);
    try {
      const token = await refreshSessionIfNeeded();
      const data = await applyAiWeeklyPlan(token, {
        weekly_blocks: aiPreview.weekly_blocks
      });
      await loadWeeklyTrend(true);
      await onLoadToday();
      return data || null;
    } catch (err) {
      setAiError(toUserError(err, "No se pudo aplicar la propuesta IA"));
      return null;
    } finally {
      setAiLoading(false);
    }
  }

  async function loadNutritionProfile(force = false) {
    if (!hasSession) return null;
    if (!force && nutritionProfile) return nutritionProfile;
    setNutritionLoading(true);
    setNutritionError("");
    try {
      const token = await refreshSessionIfNeeded();
      const data = await getNutritionProfile(token);
      setNutritionProfile(data || null);
      return data || null;
    } catch (err) {
      setNutritionError(toUserError(err, "No se pudo cargar perfil nutricional"));
      return null;
    } finally {
      setNutritionLoading(false);
    }
  }

  async function saveNutritionProfile(payload) {
    if (!hasSession) {
      setNutritionError("Inicia sesión para guardar perfil nutricional.");
      return null;
    }
    setNutritionLoading(true);
    setNutritionError("");
    try {
      const token = await refreshSessionIfNeeded();
      const data = await updateNutritionProfile(token, payload || {});
      setNutritionProfile(data || null);
      return data || null;
    } catch (err) {
      setNutritionError(toUserError(err, "No se pudo guardar perfil nutricional"));
      return null;
    } finally {
      setNutritionLoading(false);
    }
  }

  async function saveNutritionDailyLog({ inputDate = null, payload = {} }) {
    if (!hasSession) {
      setNutritionError("Inicia sesión para registrar nutricion diaria.");
      return null;
    }
    setNutritionLoading(true);
    setNutritionError("");
    try {
      const token = await refreshSessionIfNeeded();
      const row = await upsertNutritionDailyLog(token, inputDate, payload);
      const logs = await listNutritionDailyLogs(token);
      setNutritionLogs(logs);
      return row || null;
    } catch (err) {
      setNutritionError(toUserError(err, "No se pudo guardar el log nutricional"));
      return null;
    } finally {
      setNutritionLoading(false);
    }
  }

  async function runTaskAction(taskId, actionName, runner) {
    setError("");
    setActionStateByTask((prev) => ({
      ...prev,
      [taskId]: { loading: true, message: `${actionName}...` }
    }));
    try {
      await refreshSessionIfNeeded();
      await runner();
      const token = await refreshSessionIfNeeded();
      await refreshTodayTasks(token);
      const taskRef = tasks.find((t) => t.id === taskId) || null;
      await trackEvent(
        token,
        "hoy_recommendation_accepted",
        {
          action: actionName.toLowerCase(),
          task_id: taskId,
          module_key: taskRef?.moduleKey || null,
          reason_code: taskRef?.reasonCode || null
        },
        "app",
        "v1"
      ).catch(() => {});
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {
        Vibration.vibrate(12);
      });
      setActionStateByTask((prev) => ({
        ...prev,
        [taskId]: { loading: false, message: "Actualizado correctamente." }
      }));
    } catch (err) {
      setActionStateByTask((prev) => ({
        ...prev,
        [taskId]: { loading: false, message: toUserError(err, "No se pudo actualizar la tarea.") }
      }));
    }
  }

  function onCompleteTask(taskId) {
    return runTaskAction(taskId, "Hecho", () => completeTask(jwt.trim(), taskId, { source: "mobile_app" }));
  }

  function onSnoozeTask(taskId) {
    const ninetyMinutesLater = new Date(Date.now() + 90 * 60 * 1000).toISOString();
    return runTaskAction(taskId, "Posponer", () => snoozeTask(jwt.trim(), taskId, ninetyMinutesLater));
  }

  function onReprogramTask(taskId) {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return runTaskAction(taskId, "Mover a mañana", () => reprogramTask(jwt.trim(), taskId, toDateOnlyISO(tomorrow)));
  }

  function onLogout() {
    setJwt("");
    setSessionMeta(null);
    setTasks([]);
    setError("");
    setActionStateByTask({});
    setNotificationsResult(null);
    setNotificationsError("");
    setSummaryError("");
    setWeeklyPlan([]);
    setCycleAdjustments([]);
    setPlanningError("");
    setHasCompletedOnboarding(false);
    setOnboardingError("");
    setModulePreferences([]);
    setSportsProfile(null);
    setSportsProfileError("");
    setSafetyStatus(null);
    clearSession();
  }

  async function onSyncTodayNotifications() {
    if (!hasSession) {
      setNotificationsError("Inicia sesion para sincronizar notificaciones.");
      markOperation("notificaciones_error_sin_sesion");
      return;
    }
    markOperation("notificaciones_sync_iniciada");
    setNotificationsLoading(true);
    setNotificationsError("");
    setNotificationsResult(null);
    try {
      const token = await refreshSessionIfNeeded();
      await upsertNotificationPlan(token, {
        task_type: "workout",
        schedule: {
          type: "fixed_time",
          hour: 7,
          minute: 30,
          timezone: "America/Bogota"
        },
        enabled: true
      });
      const result = await syncTodayLocalNotifications(token);
      setNotificationsResult(result);
      markOperation("notificaciones_sync_ok");
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success).catch(() => {
        Vibration.vibrate(16);
      });
    } catch (err) {
      setNotificationsError(toUserError(err, "No se pudo sincronizar notificaciones"));
      markOperation("notificaciones_sync_error");
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error).catch(() => {
        Vibration.vibrate(24);
      });
    } finally {
      setNotificationsLoading(false);
    }
  }

  function getModuleEnabled(moduleKey) {
    const item = modulePreferences.find((m) => m.module_key === moduleKey);
    return Boolean(item?.is_enabled);
  }

  async function onToggleModule(moduleKey, enabled) {
    try {
      const next = modulePreferences.map((m) =>
        m.module_key === moduleKey ? { ...m, is_enabled: Boolean(enabled) } : m
      );
      const activeCount = next.filter((m) => m.is_enabled).length;
      if (activeCount === 0) {
        setModulesError("Debes mantener al menos 1 módulo activo.");
        return;
      }
      const token = await refreshSessionIfNeeded();
      await updateModulePreferences(next.map((m) => ({ module_key: m.module_key, is_enabled: m.is_enabled, config: m.config || {} })));
      await trackEvent(
        token,
        "module_toggled",
        {
          module_key: moduleKey,
          enabled: Boolean(enabled)
        },
        "app",
        "v1"
      ).catch(() => {});
      await onLoadToday();
    } catch (err) {
      setModulesError(toUserError(err, "No se pudo actualizar el módulo"));
    }
  }

  async function onUpdateModuleConfig(moduleKey, nextConfig) {
    if (!hasSession) {
      setModulesError("Inicia sesión para configurar módulos.");
      return;
    }
    setModulesError("");
    try {
      const target = modulePreferences.find((m) => m.module_key === moduleKey);
      if (!target || !target.is_enabled) {
        setModulesError("Activa el módulo antes de editar su configuración.");
        return;
      }
      const next = modulePreferences.map((m) =>
        m.module_key === moduleKey
          ? {
              ...m,
              config: {
                ...(m.config || {}),
                ...(nextConfig || {})
              }
            }
          : m
      );
      const token = await refreshSessionIfNeeded();
      await updateModulePreferences(next.map((m) => ({ module_key: m.module_key, is_enabled: m.is_enabled, config: m.config || {} })));
      await trackEvent(
        token,
        "module_config_updated",
        {
          module_key: moduleKey,
          config: nextConfig || {}
        },
        "app",
        "v1"
      ).catch(() => {});
      await onLoadToday();
    } catch (err) {
      setModulesError(toUserError(err, "No se pudo guardar la configuración del módulo"));
    }
  }

  async function onRefreshSystemState() {
    if (!hasSession) {
      setHealthStatus("Sin sesion activa.");
      markOperation("estado_refresh_sin_sesion");
      return;
    }
    markOperation("estado_refresh_iniciado");
    setHealthStatus("Verificando estado...");
    try {
      await loadModulePreferences(true);
      await loadSportsProfile(true);
      await loadNutritionProfile(true);
      await loadWeeklyTrend(true);
      await onLoadToday();
      setHealthStatus("Estado actualizado.");
      markOperation("estado_refresh_ok");
    } catch (err) {
      setHealthStatus(toUserError(err, "No se pudo actualizar el estado"));
      markOperation("estado_refresh_error");
    }
  }

  async function loadSportsProfile(force = false) {
    if (!hasSession) return null;
    if (!force && sportsProfile) return sportsProfile;
    setSportsProfileLoading(true);
    setSportsProfileError("");
    try {
      const token = await refreshSessionIfNeeded();
      const data = await getSportsProfile(token);
      setSportsProfile(data || null);
      return data || null;
    } catch (err) {
      setSportsProfileError(toUserError(err, "No se pudo cargar perfil deportivo"));
      return null;
    } finally {
      setSportsProfileLoading(false);
    }
  }

  async function saveSportsProfile(payload) {
    if (!hasSession) {
      setSportsProfileError("Inicia sesion para guardar perfil deportivo.");
      return null;
    }
    setSportsProfileLoading(true);
    setSportsProfileError("");
    try {
      const token = await refreshSessionIfNeeded();
      const data = await updateSportsProfile(token, payload || {});
      setSportsProfile(data || null);
      await trackEvent(
        token,
        "sports_profile_updated",
        {
          sports_count: Array.isArray(data?.sports) ? data.sports.length : 0,
          primary_sport: data?.primary_sport || null
        },
        "app",
        "v1"
      ).catch(() => {});
      return data || null;
    } catch (err) {
      setSportsProfileError(toUserError(err, "No se pudo guardar perfil deportivo"));
      return null;
    } finally {
      setSportsProfileLoading(false);
    }
  }

  return {
    email,
    password,
    jwt,
    tasks,
    error,
    authError,
    authLoading,
    loading,
    actionStateByTask,
    summaryLoading,
    isBootstrappingSession,
    weeklyTrend,
    weeklyModuleTrend,
    weeklyPlan,
    cycleAdjustments,
    planningLoading,
    planningError,
    summaryError,
    hasCompletedOnboarding,
    onboardingLoading,
    onboardingError,
    modulePreferences,
    modulesLoading,
    modulesError,
    sportsProfile,
    sportsProfileLoading,
    sportsProfileError,
    aiPreview,
    aiLoading,
    aiError,
    nutritionProfile,
    nutritionLogs,
    nutritionLoading,
    nutritionError,
    safetyStatus,
    notificationsLoading,
    notificationsResult,
    notificationsError,
    lastHoySource,
    healthStatus,
    lastOperation,
    lastOperationAt,
    progressScale,
    hasSession,
    canLogin,
    canLoad,
    completedCount,
    inProgressCount,
    pendingCount,
    progressPct,
    setEmail,
    setPassword,
    onLogin,
    onLoadToday,
    loadModulePreferences,
    updateModulePreferences,
    loadSportsProfile,
    saveSportsProfile,
    loadNutritionProfile,
    saveNutritionProfile,
    saveNutritionDailyLog,
    onPreviewAiPlan,
    onApplyAiPlan,
    onCompleteOnboarding,
    loadWeeklyTrend,
    loadPlanningInsights,
    onToggleModule,
    onUpdateModuleConfig,
    getModuleEnabled,
    onSyncTodayNotifications,
    onRefreshSystemState,
    onLogout,
    onCompleteTask,
    onSnoozeTask,
    onReprogramTask
  };
}
