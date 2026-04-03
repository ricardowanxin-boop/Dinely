import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let foregroundDelegate = ForegroundNotificationDelegate()
    private var hasCheckedAuthorization = false

    private init() {}

    func requestAuthorization() async {
        configureForegroundPresentation()
        guard !AppRuntime.isUITesting else { return }
        guard !hasCheckedAuthorization else { return }
        hasCheckedAuthorization = true

        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
    }

    func configureForegroundPresentation() {
        UNUserNotificationCenter.current().delegate = foregroundDelegate
    }

    func sendManualUpdateNotification(snapshot: TemplateSnapshot) async {
        await sendNotification(
            title: L10n.string("模板数据已更新"),
            body: L10n.format("%@ · %@：%@", snapshot.title, snapshot.metricTitle, snapshot.metricValue)
        )
    }

    func sendBackgroundRefreshNotification(snapshot: TemplateSnapshot) async {
        await sendNotification(
            title: L10n.string("后台刷新完成"),
            body: L10n.format("%@ · 更新时间 %@", snapshot.title, DisplayFormatters.time(snapshot.fetchedAt))
        )
    }

    private func sendNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }
}

private final class ForegroundNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }
}
