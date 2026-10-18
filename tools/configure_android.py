"""Applies CashPaws Android settings after `flutter create`:
min SDK, permissions, AdMob test app ID, and newer Gradle / Android Gradle Plugin versions."""
import re, pathlib

root = pathlib.Path('android/app')
for name in ['build.gradle.kts', 'build.gradle']:
    p = root / name
    if p.exists():
        s = p.read_text()
        s = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 23', s)
        s = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 23', s)
        p.write_text(s)
        print('patched', name)

m = root / 'src/main/AndroidManifest.xml'
s = m.read_text()
perms = ('<uses-permission android:name="android.permission.INTERNET"/>\n'
         '    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>\n'
         '    <application')
s = s.replace('<application', perms, 1)
meta = ('<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" '
        'android:value="ca-app-pub-3940256099942544~3347511713"/>\n    </application>')
s = s.replace('</application>', meta, 1)
s = re.sub(r'android:label="[^"]*"', 'android:label="CashPaws"', s, count=1)
m.write_text(s)
print('manifest updated')


def sub_file(path, pattern, repl):
    p = pathlib.Path(path)
    if not p.exists():
        return
    text = p.read_text()
    new, count = re.subn(pattern, repl, text)
    if count:
        p.write_text(new)
    print(('patched ' if count else 'no match in ') + path)


AGP = r'''(com\.android\.application["')\s]*version\s*["'])[\d.]+'''
KOTLIN = r'''(org\.jetbrains\.kotlin\.android["')\s]*version\s*["'])[\d.]+'''
for f in ['android/settings.gradle', 'android/settings.gradle.kts']:
    sub_file(f, AGP, r'\g<1>8.6.0')       # Android Gradle Plugin
    sub_file(f, KOTLIN, r'\g<1>1.9.24')   # Kotlin plugin
sub_file('android/gradle/wrapper/gradle-wrapper.properties', r'gradle-[\d.]+-(all|bin)\.zip', 'gradle-8.7-all.zip')
