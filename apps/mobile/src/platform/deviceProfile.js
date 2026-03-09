import { Dimensions, Platform } from "react-native";

const TABLET_MIN = 768;

export function getDeviceProfile() {
  const { width, height } = Dimensions.get("window");
  const shortest = Math.min(width, height);
  const formFactor = shortest >= TABLET_MIN ? "tablet" : "phone";

  return {
    platform: Platform.OS,
    width,
    height,
    formFactor
  };
}
