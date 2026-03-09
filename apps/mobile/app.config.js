const IS_DEV = process.env.APP_VARIANT === "development";

const NAME = IS_DEV ? "Vento Vital Dev" : "Vento Vital";
const SLUG = "vento-vital";
const SCHEME = IS_DEV ? "vento-vital-dev" : "vento-vital";
const IOS_BUNDLE_ID = IS_DEV ? "com.ventogroup.vital.dev" : "com.ventogroup.vital";
const ANDROID_PACKAGE = IS_DEV ? "com.ventogroup.vital.dev" : "com.ventogroup.vital";

export default {
  expo: {
    name: NAME,
    slug: SLUG,
    scheme: SCHEME,
    version: "0.1.0",
    orientation: "portrait",
    userInterfaceStyle: "light",
    splash: {
      resizeMode: "contain",
      backgroundColor: "#ffffff"
    },
    assetBundlePatterns: ["**/*"],
    ios: {
      supportsTablet: true,
      bundleIdentifier: IOS_BUNDLE_ID
    },
    android: {
      package: ANDROID_PACKAGE
    },
    plugins: ["expo-secure-store", "expo-notifications"],
    extra: {
      appVariant: IS_DEV ? "development" : "production",
      eas: {
        projectId: "33dc1d74-c38c-4603-997f-daca66af5f95"
      }
    }
  }
};
