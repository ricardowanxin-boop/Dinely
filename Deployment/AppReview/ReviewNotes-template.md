# App Review Notes 模板

可直接复制到 App Store Connect，并按当前提交版本微调。

---

This build is for **DineRank / 食否**, a social meal-planning app for friends to create a meal event, vote on time and restaurant, share live location on the day of the meetup, check in, split the bill, and generate an attendance report.

Main review path:

1. Launch the app and review the first-use compliance notice.
2. Home tab: view existing meal events or tap the `+` create button in the top-right corner to create a new event.
3. Event detail: vote on time and restaurant, then confirm the event.
4. Live Map: review location sharing, restaurant navigation, and check-in flow.
5. Attendance / AA / Battle Report: mark attendance, enter the total bill, and generate the report.
6. Settings: review `Privacy Policy`, `Terms / EULA`, `Disclaimer`, `Data Source & Map Notes`, `Contact Support`, `Restore Purchases`, and the one-time `DineRank Pro` buyout entry.

In-App Purchase:

- This version only offers a **one-time non-consumable purchase**:
  - `com.ricardo.dinerank.pro.lifetime`
- It unlocks larger party size, circle leaderboard, and high-resolution battle report export.
- There is **no monthly or yearly subscription exposed in this build**.

Maps:

- The app uses Apple MapKit.
- In mainland China, map attribution may display AMap / GaoDe as part of Apple Maps data attribution.

Cloud sync:

- Shared meal-event collaboration uses Apple CloudKit.

If any clarification is needed, please contact:

- `support@dinerank.app`

---
