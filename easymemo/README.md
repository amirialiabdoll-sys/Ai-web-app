# EasyMemo

Easy Memo - Organize your notes and images with customizable folders and reminders

## Build Instructions

1. Generate keystore (run once):
```bash
cd android/app
keytool -genkey -v -keystore easymemo-release.keystore -alias easymemo -keyalg RSA -keysize 2048 -validity 10000
```

2. Create key.properties in android/ folder with your keystore details

3. Build APK:
```bash
flutter build apk --release
```

4. Or use Codemagic for automated builds
