from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
app = root / 'android' / 'app'
manifest = app / 'src' / 'main' / 'AndroidManifest.xml'

if not manifest.exists():
    raise SystemExit('Android project not found. Run: flutter create . --platforms=android')

text = manifest.read_text(encoding='utf-8')
if 'android.permission.POST_NOTIFICATIONS' not in text:
    text = text.replace('<manifest ', '<manifest ', 1)
    marker = '<application'
    text = text.replace(marker, '    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />\n    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />\n\n    ' + marker, 1)

receiver_block = '''\n        <receiver\n            android:exported="false"\n            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />\n        <receiver\n            android:exported="false"\n            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">\n            <intent-filter>\n                <action android:name="android.intent.action.BOOT_COMPLETED" />\n                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />\n                <action android:name="android.intent.action.QUICKBOOT_POWERON" />\n                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />\n            </intent-filter>\n        </receiver>'''
if 'ScheduledNotificationReceiver' not in text:
    text = text.replace('</application>', receiver_block + '\n    </application>', 1)
manifest.write_text(text, encoding='utf-8')

# Configure the package id and label in either Groovy or Kotlin Gradle templates.
gradle_candidates = [app / 'build.gradle.kts', app / 'build.gradle']
gradle = next((p for p in gradle_candidates if p.exists()), None)
if gradle is None:
    raise SystemExit('Android app Gradle file not found')
g = gradle.read_text(encoding='utf-8')
package_id = 'ir.khane.behdasht.family'
if gradle.suffixes[-2:] == ['.gradle', '.kts']:
    g = re.sub(r'namespace\s*=\s*"[^"]+"', f'namespace = "{package_id}"', g, count=1)
    g = re.sub(r'applicationId\s*=\s*"[^"]+"', f'applicationId = "{package_id}"', g, count=1)
    g = re.sub(r'compileSdk\s*=\s*flutter\.compileSdkVersion', 'compileSdk = 35', g, count=1)
    if 'isCoreLibraryDesugaringEnabled' not in g:
        g = g.replace('compileOptions {', 'compileOptions {\n        isCoreLibraryDesugaringEnabled = true', 1)
    if 'coreLibraryDesugaring(' not in g:
        anchor = 'dependencies {'
        g = g.replace(anchor, anchor + '\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")', 1)
else:
    g = re.sub(r'namespace\s+["\'][^"\']+["\']', f'namespace "{package_id}"', g, count=1)
    g = re.sub(r'applicationId\s+["\'][^"\']+["\']', f'applicationId "{package_id}"', g, count=1)
    g = re.sub(r'compileSdk(?:Version)?\s+flutter\.compileSdkVersion', 'compileSdkVersion 35', g, count=1)
    if 'coreLibraryDesugaringEnabled true' not in g:
        g = g.replace('compileOptions {', 'compileOptions {\n        coreLibraryDesugaringEnabled true', 1)
    if 'coreLibraryDesugaring ' not in g:
        g = g.replace('dependencies {', 'dependencies {\n    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.1.4"', 1)
gradle.write_text(g, encoding='utf-8')

# Set application label in manifest.
text = manifest.read_text(encoding='utf-8')
text = re.sub(r'android:label="[^"]*"', 'android:label="خانه بهداشت پزشک خانواده"', text, count=1)
manifest.write_text(text, encoding='utf-8')

print(f'Prepared Android project: package={package_id}, compileSdk=35')
