import ActivityKit
import Foundation

struct TemplateLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var title: String
        var subtitle: String
        var metricTitle: String
        var metricValue: String
        var status: String
        var updatedAt: Date
    }

    var name: String
}
