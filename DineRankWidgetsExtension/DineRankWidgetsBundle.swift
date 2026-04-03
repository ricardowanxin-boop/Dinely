import ActivityKit
import SwiftUI
import WidgetKit

private enum WidgetPalette {
    static let backgroundTop = Color(red: 0.12, green: 0.24, blue: 0.35)
    static let backgroundBottom = Color(red: 0.05, green: 0.10, blue: 0.16)
    static let textPrimary = Color(red: 0.95, green: 0.98, blue: 0.99)
    static let textSecondary = Color(red: 0.95, green: 0.98, blue: 0.99).opacity(0.72)
    static let accent = Color(red: 0.98, green: 0.71, blue: 0.42)
    static let accentSoft = Color(red: 0.45, green: 0.83, blue: 0.82)
    static let border = Color.white.opacity(0.08)
}

private struct TemplateEntry: TimelineEntry {
    let date: Date
    let snapshot: TemplateSnapshot
}

private struct TemplateProvider: TimelineProvider {
    func placeholder(in context: Context) -> TemplateEntry {
        TemplateEntry(date: Date(), snapshot: SampleData.snapshot)
    }

    func getSnapshot(in context: Context, completion: @escaping (TemplateEntry) -> Void) {
        completion(
            TemplateEntry(
                date: Date(),
                snapshot: SharedDefaults.loadLatestSnapshot() ?? SampleData.snapshot
            )
        )
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TemplateEntry>) -> Void) {
        let snapshot = SharedDefaults.loadLatestSnapshot() ?? SampleData.snapshot
        let entry = TemplateEntry(date: Date(), snapshot: snapshot)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

private struct TemplateWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TemplateEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .accessoryRectangular:
            accessoryRectangular
        case .accessoryInline:
            accessoryInline
        default:
            mediumWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("模板状态")
                .font(.caption.weight(.bold))
                .foregroundStyle(WidgetPalette.textSecondary)

            Text(entry.snapshot.metricValue)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(WidgetPalette.accent)

            Text(entry.snapshot.metricTitle)
                .font(.caption)
                .foregroundStyle(WidgetPalette.textSecondary)

            Spacer(minLength: 0)

            Text(DisplayFormatters.time(entry.snapshot.fetchedAt))
                .font(.caption2)
                .foregroundStyle(WidgetPalette.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(16)
        .containerBackground(backgroundGradient, for: .widget)
    }

    private var mediumWidget: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.snapshot.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(WidgetPalette.textPrimary)
                    .lineLimit(2)

                Text(entry.snapshot.subtitle)
                    .font(.caption)
                    .foregroundStyle(WidgetPalette.textSecondary)
                    .lineLimit(2)

                Spacer(minLength: 0)

                Text(entry.snapshot.sourceLabel)
                    .font(.caption2)
                    .foregroundStyle(WidgetPalette.textSecondary)
                    .lineLimit(1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(entry.snapshot.metricTitle)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(WidgetPalette.textSecondary)

                Text(entry.snapshot.metricValue)
                    .font(.title2.weight(.black))
                    .foregroundStyle(WidgetPalette.accent)

                Text(entry.snapshot.status.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(WidgetPalette.accentSoft)

                Text(DisplayFormatters.time(entry.snapshot.fetchedAt))
                    .font(.caption2)
                    .foregroundStyle(WidgetPalette.textSecondary)
            }
            .frame(width: 92, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(WidgetPalette.border, lineWidth: 1)
            )
        }
        .padding(16)
        .containerBackground(backgroundGradient, for: .widget)
    }

    private var accessoryRectangular: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.snapshot.title)
                .font(.caption.weight(.bold))
                .lineLimit(1)

            Text("\(entry.snapshot.metricTitle)：\(entry.snapshot.metricValue)")
                .font(.caption2)
                .lineLimit(1)

            Text(DisplayFormatters.time(entry.snapshot.fetchedAt))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var accessoryInline: some View {
        Text("\(entry.snapshot.metricTitle) \(entry.snapshot.metricValue)")
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [WidgetPalette.backgroundTop, WidgetPalette.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct TemplateSummaryWidget: Widget {
    let kind = "TemplateSummaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TemplateProvider()) { entry in
            TemplateWidgetView(entry: entry)
        }
        .configurationDisplayName(L10n.string("模板摘要"))
        .description(L10n.string("展示共享快照的最新状态。"))
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

struct TemplateLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TemplateLiveActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 10) {
                Text(context.state.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(WidgetPalette.textPrimary)

                Text(context.state.subtitle)
                    .font(.caption)
                    .foregroundStyle(WidgetPalette.textSecondary)

                HStack {
                    Text(context.state.metricTitle)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(WidgetPalette.textSecondary)

                    Spacer(minLength: 8)

                    Text(context.state.metricValue)
                        .font(.title3.weight(.black))
                        .foregroundStyle(WidgetPalette.accent)
                }
            }
            .padding(16)
            .activityBackgroundTint(Color(red: 0.08, green: 0.14, blue: 0.21))
            .activitySystemActionForegroundColor(WidgetPalette.accent)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.metricTitle)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(WidgetPalette.textSecondary)
                        Text(context.state.metricValue)
                            .font(.headline.weight(.black))
                            .foregroundStyle(WidgetPalette.accent)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.state.status)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(WidgetPalette.accentSoft)
                        Text(DisplayFormatters.time(context.state.updatedAt))
                            .font(.caption2)
                            .foregroundStyle(WidgetPalette.textSecondary)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.title)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(WidgetPalette.textPrimary)
                        .lineLimit(1)
                }
            } compactLeading: {
                Text(context.state.metricValue)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(WidgetPalette.accent)
            } compactTrailing: {
                Text(context.state.status.prefix(1))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(WidgetPalette.accentSoft)
            } minimal: {
                Text(context.state.metricValue)
                    .font(.caption2.weight(.bold))
            }
        }
    }
}

@main
struct DineRankWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TemplateSummaryWidget()
        TemplateLiveActivityWidget()
    }
}
