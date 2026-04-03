import BackgroundTasks
import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

actor BackgroundRefreshService {
    static let shared = BackgroundRefreshService()
    static let minimumScheduleInterval: TimeInterval = 15 * 60

    private let repository: DemoContentRepository

    init(repository: DemoContentRepository = DemoContentRepository()) {
        self.repository = repository
    }

    func schedule(force: Bool = false) {
        guard AppRuntime.supportsBackgroundRefreshRegistration else {
            updateStatus {
                $0.lastScheduledAt = nil
                $0.lastErrorMessage = L10n.string("当前运行环境不支持后台刷新调度。")
                $0.outcome = .disabled
            }
            return
        }

        let settings = SharedDefaults.loadSettings()
        guard settings.backgroundRefreshEnabled else {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: AppConfig.backgroundRefreshTaskIdentifier)
            updateStatus {
                $0.lastScheduledAt = nil
                $0.lastErrorMessage = nil
                $0.outcome = .disabled
            }
            return
        }

        if force {
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: AppConfig.backgroundRefreshTaskIdentifier)
        }

        let nextRefresh = Date().addingTimeInterval(Self.minimumScheduleInterval)
        let request = BGAppRefreshTaskRequest(identifier: AppConfig.backgroundRefreshTaskIdentifier)
        request.earliestBeginDate = nextRefresh

        do {
            try BGTaskScheduler.shared.submit(request)
            updateStatus {
                $0.lastScheduledAt = nextRefresh
                $0.lastErrorMessage = nil
                $0.outcome = .scheduled
            }
        } catch {
            updateStatus {
                $0.lastScheduledAt = nil
                $0.lastErrorMessage = scheduleErrorMessage(for: error)
                $0.outcome = .failed
            }
        }
    }

    func handleAppRefresh() async {
        guard AppRuntime.supportsBackgroundRefreshRegistration else { return }

        updateStatus {
            $0.lastAttemptAt = Date()
            $0.lastErrorMessage = nil
            $0.outcome = .running
        }

        schedule(force: true)

        let snapshot = await repository.loadLatestSnapshot()

        #if canImport(WidgetKit)
        await MainActor.run {
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif

        if SharedDefaults.loadSettings().showBackgroundRefreshNotifications {
            await NotificationManager.shared.sendBackgroundRefreshNotification(snapshot: snapshot)
        }

        updateStatus {
            $0.lastSuccessAt = Date()
            $0.lastErrorMessage = snapshot.fallbackReason
            $0.outcome = .success
        }
    }

    private func updateStatus(_ mutate: (inout BackgroundRefreshStatus) -> Void) {
        var status = SharedDefaults.loadBackgroundRefreshStatus()
        mutate(&status)
        SharedDefaults.saveBackgroundRefreshStatus(status)
    }

    private func scheduleErrorMessage(for error: Error) -> String {
        let rawCode = (error as NSError).code
        guard let code = BGTaskScheduler.Error.Code(rawValue: rawCode) else {
            return error.localizedDescription
        }

        switch code {
        case .notPermitted:
            return L10n.string("系统当前不允许登记后台刷新，请检查“后台 App 刷新”与签名配置。")
        case .tooManyPendingTaskRequests:
            return L10n.string("系统当前挂起的后台请求过多。")
        case .unavailable:
            return L10n.string("当前运行环境不支持后台刷新调度。")
        case .immediateRunIneligible:
            return L10n.string("系统暂时不满足立即执行后台任务的条件。")
        @unknown default:
            return error.localizedDescription
        }
    }
}
