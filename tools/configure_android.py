"""Applies CashPaws Android settings after `flutter create` (min SDK, permissions, AdMob test app ID)."""
import re, pathlib

root = pathlib.Path('android/app')
for name in ['build.gradle.kts', 'build.gradle']:
    p = root / name
    if p.exists():
        s = p.read_text()
        s = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 23', s)
        s = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 23', s)
        p.write_text(s)
        print('patched', name, '->', 'minSdk 23' if '23' in s else 'CHECK minSdk')

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
