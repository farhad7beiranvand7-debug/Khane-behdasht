from pathlib import Path

root = Path(__file__).resolve().parents[1]
app = root / "android" / "app"
manifest = app / "src" / "main" / "AndroidManifest.xml"

if not manifest.exists():
    raise SystemExit(
        "Android project not found. Run: "
        "flutter create . --platforms=android"
    )

text = manifest.read_text(encoding="utf-8")

# Add notification permissions only if they are not already present.
if "android.permission.POST_NOTIFICATIONS" not in text:
    marker = "<application"

    permissions = """    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />

    """

    text = text.replace(marker, permissions + marker, 1)

# Add flutter_local_notifications receivers if needed.
receiver_block = """
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver
            android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
"""

if "ScheduledNotificationReceiver" not in text:
    text = text.replace(
        "</application>",
        receiver_block + "\n    </application>",
        1,
    )

# Set application label.
import re

text = re.sub(
    r'android:label="[^"]*"',
    'android:label="خانه بهداشت پزشک خانواده"',
    text,
    count=1,
)

manifest.write_text(text, encoding="utf-8")

print("Prepared Android project without changing namespace/applicationId.")
