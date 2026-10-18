# CashPaws Flutter starter (Supabase backend, free plan)

Built: Home (daily login, streak freeze, missions, weekly leaderboard), Walk (step counter),
Ads (rewarded), Spin, Wallet (withdrawal requests), Invite (referrals + share), Profile
(levels, avatars, delete account), onboarding, logo, icon and splash.

## 1. Supabase (free, no card)
1. supabase.com > New project (save the database password).
2. SQL Editor > New query > paste `supabase/schema.sql` > Run.
3. Authentication > Sign In / Providers > turn on "Allow anonymous sign-ins" (guest mode).
4. Project Settings > API: copy the Project URL and the anon public key into `lib/config.dart`.
   (Never put the service_role key in the app.)

## 2. Flutter project
`flutter create --org com.yourname --project-name cashpaws .` (keep existing lib/ and pubspec.yaml),
then `flutter pub get`. Put the same package name in `lib/config.dart`.

## 3. Android settings
- `android/app/build.gradle` (or .kts): minSdk 23.
- `AndroidManifest.xml`, outside <application>:
  `<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>`
- Inside <application> (Google test AdMob app ID):
  `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>`

## 4. Icon and splash
`dart run flutter_launcher_icons` then `dart run flutter_native_splash:create`

## 5. Run
Use a real phone (emulators don't count steps): `flutter run`. APK: `flutter build apk --release`.

## Continue with Google (later)
Needs a Google Cloud OAuth setup: a Web client ID (put it in `kGoogleWebClientId` and in
Supabase > Authentication > Providers > Google) plus an Android client ID with your package name
and SHA-1. Guest mode works without any of this.

## Paying withdrawals
Supabase > Table Editor > `withdrawals`. Send the money by hand (GCash, Maya or One),
then change `status` from pending to paid. Check for duplicate accounts first.

## Free plan notes
Free Supabase projects pause after about a week with no activity (you can resume them in the
dashboard). Upgrade before launch so the app never goes offline.

## Not included yet
- Daily reminder notifications (needs Firebase Cloud Messaging plus a scheduled job).
- Weekly reset uses UTC. Withdrawals are paid manually.
- Before release: replace the AdMob test IDs in `lib/services/ads_service.dart`, add AdMob
  server-side verification for rewarded ads, a privacy policy and ads disclosure.

## Withdrawal tiers and payout split (update 2)
- Run `supabase/migration_2_withdrawals.sql` in the SQL Editor (already merged into schema.sql for new projects).
- Tiers are fixed: $10, $20, $50, $100, $500, $1,000 face value. 1,000 coins = $1.00 face value.
- Users receive 10% of the face value. The app shows the exact payout before they confirm.
- Change rules in Supabase > Table Editor > `settings`: `coins_per_usd`, `payout_share_pct`,
  `usd_php` (update the exchange rate yourself), `min_account_days` (set to 0 while testing).
- When you pay a request, send the `payout` amount in the `currency` shown in the `withdrawals` row,
  then set `status` to paid. Rows with `needs_id` = true ($100+) should get an ID check first.
- Explain the payout share in your Play Store description and in-app terms. Google Play and consumer
  law expect earnings and payouts to be described accurately.

## Easiest build: GitHub builds the APK for you (no installs)
1. Create a free account at github.com and a new PRIVATE repository named cashpaws.
2. Unzip this project. In the repo click "uploading an existing file" and drag in everything
   (including the .github and tools folders). Commit to main.
3. Open the Actions tab > Build APK. It starts by itself (about 10 to 15 minutes).
4. When it turns green, open the run and download `cashpaws-apk` (a zip with app-release.apk).
5. Send the APK to your phone and install it (allow "Install unknown apps" when asked).
The default test package name is com.cashpaws.app. Choose your final name before publishing.

## Permanent signing key and package name
- The app id is com.cashpaws.cashpaws (org com.cashpaws + project cashpaws). Decide your final name before the Play Store.
- Builds are signed with the key stored in the GitHub secrets KEYSTORE_BASE64, KEYSTORE_PASSWORD,
  KEY_ALIAS and KEY_PASSWORD, so updates install over older versions and Google sign-in keeps working.
- Back up the signing secrets file. For Play Store release, use Play App Signing.
