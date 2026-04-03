import ActivityKit
import Foundation

@MainActor
final class LiveActivityManager: ObservableObject {
    @Published private(set) var isSupported = false
    @Published private(set) var hasActiveActivity = false

    init() {}

    func refreshStatus() {
        isSupported = ActivityAuthorizationInfo().areActivitiesEnabled
        hasActiveActivity = !Activity<TemplateLiveActivityAttributes>.activities.isEmpty
    }

    func start(snapshot: TemplateSnapshot) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            refreshStatus()
            return
        }

        if !Activity<TemplateLiveActivityAttributes>.activities.isEmpty {
            await update(snapshot: snapshot)
            return
        }

        do {
            _ = try Activity.request(
                attributes: TemplateLiveActivityAttributes(name: AppConfig.localizedBrandName(locale: Locale(identifier: "en_US"))),
                content: makeContent(snapshot: snapshot),
                pushType: nil
            )
        } catch {
            #if DEBUG
            print("Live Activity request failed: \(error.localizedDescription)")
            #endif
        }

        refreshStatus()
    }

    func update(snapshot: TemplateSnapshot) async {
        let content = makeContent(snapshot: snapshot)
        for activity in Activity<TemplateLiveActivityAttributes>.activities {
            await activity.update(content)
        }
        refreshStatus()
    }

    func sync(snapshot: TemplateSnapshot, isEnabled: Bool) async {
        if !isEnabled {
            await stopAll(using: snapshot)
            return
        }

        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            refreshStatus()
            return
        }

        if Activity<TemplateLiveActivityAttributes>.activities.isEmpty {
            await start(snapshot: snapshot)
        } else {
            await update(snapshot: snapshot)
        }
    }

    func stopAll(using snapshot: TemplateSnapshot = SampleData.snapshot) async {
        let content = makeContent(snapshot: snapshot)
        for activity in Activity<TemplateLiveActivityAttributes>.activities {
            await activity.end(content, dismissalPolicy: .immediate)
        }
        refreshStatus()
    }

    private func makeContent(snapshot: TemplateSnapshot) -> ActivityContent<TemplateLiveActivityAttributes.ContentState> {
        ActivityContent(
            state: TemplateLiveActivityAttributes.ContentState(
                title: snapshot.title,
                subtitle: snapshot.subtitle,
                metricTitle: snapshot.metricTitle,
                metricValue: snapshot.metricValue,
                status: snapshot.status.title,
                updatedAt: snapshot.fetchedAt
            ),
            staleDate: Calendar.current.date(byAdding: .minute, value: 30, to: Date())
        )
    }
}
