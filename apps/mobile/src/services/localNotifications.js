import * as Notifications from "expo-notifications";
import { listTodayNotificationIntents } from "../api/notificationsApi";

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: false,
    shouldSetBadge: false
  })
});

function toDateOnlyISO(date) {
  return date.toISOString().slice(0, 10);
}

function parseNotifyAt(value) {
  if (!value) return null;
  const at = new Date(value);
  return Number.isNaN(at.getTime()) ? null : at;
}

function buildNotificationContent(intent) {
  const type = intent.task_type || "task";
  return {
    title: "Vento Vital",
    body: `${intent.title || "Tarea"} · ${type}`,
    data: {
      source: "today_notification_intent",
      task_instance_id: intent.task_instance_id || null,
      task_type: type
    }
  };
}

export async function ensureLocalNotificationPermissions() {
  const existing = await Notifications.getPermissionsAsync();
  if (existing.granted || existing.ios?.status === Notifications.IosAuthorizationStatus.PROVISIONAL) {
    return true;
  }
  const requested = await Notifications.requestPermissionsAsync();
  return Boolean(requested.granted || requested.ios?.status === Notifications.IosAuthorizationStatus.PROVISIONAL);
}

export async function syncTodayLocalNotifications(jwt, targetDate = null) {
  const granted = await ensureLocalNotificationPermissions();
  if (!granted) {
    throw new Error("Permisos de notificaciones denegados");
  }

  const intents = await listTodayNotificationIntents(jwt, targetDate);
  await Notifications.cancelAllScheduledNotificationsAsync();

  const now = Date.now();
  let scheduled = 0;
  const ignored = [];

  for (const intent of intents) {
    const notifyAt = parseNotifyAt(intent.notify_at);
    if (!notifyAt) {
      ignored.push({ reason: "invalid_notify_at", intent });
      continue;
    }
    if (notifyAt.getTime() <= now) {
      ignored.push({ reason: "past_time", intent });
      continue;
    }

    await Notifications.scheduleNotificationAsync({
      content: buildNotificationContent(intent),
      trigger: {
        type: Notifications.SchedulableTriggerInputTypes.DATE,
        date: notifyAt
      }
    });
    scheduled += 1;
  }

  return {
    date: targetDate || toDateOnlyISO(new Date()),
    totalIntents: intents.length,
    scheduledCount: scheduled,
    ignoredCount: ignored.length
  };
}
