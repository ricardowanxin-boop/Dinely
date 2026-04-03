# Universal Links Deployment

Host the file below at both of these URLs with `Content-Type: application/json` and no file extension redirects:

- `https://dinerank.app/.well-known/apple-app-site-association`
- `https://www.dinerank.app/.well-known/apple-app-site-association`

Source file in this repo:

- [apple-app-site-association](/Users/ricardo/文稿/创业/IOS原生AI应用/DineRank（约饭）/Deployment/UniversalLinks/apple-app-site-association)

App-side configuration already expects these associated domains:

- `applinks:dinerank.app`
- `applinks:www.dinerank.app`

The current app identifier wired into the AASA file is:

- `2HZLQ4V556.com.ricardo.dinerank`

Verification checklist:

1. Serve the file over HTTPS without a `.json` suffix.
2. Confirm the response body matches the file in this repo exactly.
3. Reinstall the app on device after the domain file is live.
4. Test a link such as `https://dinerank.app/join/00000000-0000-0000-0000-000000000000`.
