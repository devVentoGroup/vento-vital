export const SURFACE_CAPABILITIES = {
  phone: {
    supportsFullHoy: true,
    supportsLocalNotifications: true,
    supportsWearBridge: true
  },
  tablet: {
    supportsFullHoy: true,
    supportsLocalNotifications: true,
    supportsWearBridge: true
  },
  watch: {
    supportsFullHoy: false,
    supportsLocalNotifications: true,
    supportsWearBridge: false
  }
};

export function getSurfaceCapabilities(formFactor) {
  return SURFACE_CAPABILITIES[formFactor] || SURFACE_CAPABILITIES.phone;
}
