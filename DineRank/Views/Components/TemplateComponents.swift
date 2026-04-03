import SwiftUI

enum TemplateLayoutMetrics {
    static let controlHeight: CGFloat = 52
    static let segmentedControlHeight: CGFloat = 44
    static let tabBarClearance: CGFloat = 120
    static let compactBottomActionBarClearance: CGFloat = 148
    static let fullBottomActionBarClearance: CGFloat = 176
}

struct RootChromeVisibilityPreferenceKey: PreferenceKey {
    static let defaultValue = true

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value && nextValue()
    }
}

extension View {
    func rootChromeVisible(_ isVisible: Bool) -> some View {
        preference(key: RootChromeVisibilityPreferenceKey.self, value: isVisible)
    }
}

struct TemplateSectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StatusBadge: View {
    let status: SnapshotStatus

    var body: some View {
        Label {
            Text(status.title)
                .font(.caption.weight(.semibold))
        } icon: {
            Circle()
                .fill(AppTheme.statusTint(for: status))
                .frame(width: 8, height: 8)
        }
        .foregroundStyle(AppTheme.statusTint(for: status))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.statusTint(for: status).opacity(0.12), in: Capsule())
    }
}

struct EventStatusBadge: View {
    let status: EventStatus

    var body: some View {
        Text(status.title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(status.accentColor, in: Capsule())
    }
}

struct FeatureBadge: View {
    let title: String
    let systemImage: String
    var tint: Color = AppTheme.copper

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(minHeight: 36)
        .background(tint.opacity(0.12), in: Capsule())
    }
}

struct TemplateMetricPill: View {
    let title: String
    let value: String
    var tint: Color = AppTheme.copper

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.title3.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.surfaceWarm, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
    }
}

struct KeyValueRow: View {
    let title: String
    let value: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 12) {
                titleView
                    .layoutPriority(1)

                Spacer(minLength: 16)

                valueView(multilineAlignment: .trailing)
            }

            VStack(alignment: .leading, spacing: 6) {
                titleView
                valueView(multilineAlignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var titleView: some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func valueView(multilineAlignment: TextAlignment) -> some View {
        Text(value)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(AppTheme.textPrimary)
            .multilineTextAlignment(multilineAlignment)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct TemplateSettingsRow: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(AppTheme.copper)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

struct TemplateEmptyStateView: View {
    let title: String
    let detail: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(AppTheme.copper)

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(detail)
                .font(.footnote)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .padding(.horizontal, 18)
        .background(AppTheme.surfaceWarm, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
    }
}

struct ProgressBarView: View {
    let progress: Double
    var fillColor: Color = AppTheme.aqua

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.divider)
                    .frame(height: 4)

                Capsule()
                    .fill(fillColor)
                    .frame(width: max(geometry.size.width * progress, 10), height: 4)
            }
        }
        .frame(height: 4)
    }
}

struct ParticipantAvatarView: View {
    let participant: Participant
    var size: CGFloat = 44

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(AppTheme.surfaceWarm)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(participant.rank.accentColor, lineWidth: 2)
                )

            Text(participant.avatarEmoji)
                .font(.system(size: size * 0.45))

            Circle()
                .fill((participant.attended ?? participant.hasVotedTime) ? AppTheme.mint : AppTheme.divider)
                .frame(width: size * 0.2, height: size * 0.2)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 2)
                )
        }
    }
}

struct RankBadgeView: View {
    let rank: AttendanceRank
    var rateText: String?
    var size: CGFloat = 120

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(rank.accentColor, lineWidth: 8)
                    .frame(width: size, height: size)
                    .shadow(color: rank.accentColor.opacity(0.28), radius: 18)

                Circle()
                    .fill(.white)
                    .frame(width: size - 16, height: size - 16)

                Text(rank.emoji)
                    .font(.system(size: size * 0.34))
            }

            if let rateText {
                Text(rateText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

struct EventCardView: View {
    let event: MealEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(event.status.accentColor)
                .frame(width: 2)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Text(event.categoryEmoji)
                        .font(.system(size: 22))
                        .frame(width: 32, height: 32)
                        .background(AppTheme.surfaceWarm, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(1)

                        Text("由 \(event.creatorName) 发起")
                            .font(.system(size: 13))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer(minLength: 8)
                    EventStatusBadge(status: event.status)
                }

                Label(event.votingSummary, systemImage: "calendar")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 8) {
                    HStack(spacing: -8) {
                        ForEach(event.participants.prefix(4)) { participant in
                            Circle()
                                .fill(AppTheme.surface)
                                .frame(width: 28, height: 28)
                                .overlay(ParticipantAvatarView(participant: participant, size: 24))
                        }
                    }

                    Spacer(minLength: 8)
                    Text(event.participantSummary)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                HStack(spacing: 12) {
                    ProgressBarView(progress: event.progress)
                    Text(DisplayFormatters.percentage(event.progress))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 2)
        .accessibilityIdentifier("event-card-\(event.title)")
    }
}

struct MetricCardView: View {
    let icon: String
    let value: String
    let label: String
    var accent: Color = AppTheme.copper

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(accent)

            Text(value)
                .font(.title2.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(AppTheme.textPrimary)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 6, x: 0, y: 2)
    }
}

struct TemplateSegmentedControl<Option: Hashable & Sendable>: View {
    let options: [Option]
    @Binding var selection: Option
    var title: (Option) -> String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection

                Button {
                    selection = option
                } label: {
                    Text(title(option))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? AppTheme.textPrimary : AppTheme.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, minHeight: TemplateLayoutMetrics.segmentedControlHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? AppTheme.surfaceWarm : .clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(isSelected ? AppTheme.copper.opacity(0.28) : .clear, lineWidth: 1)
                        )
                        .shadow(
                            color: isSelected ? AppTheme.shadow.opacity(0.32) : .clear,
                            radius: 4,
                            x: 0,
                            y: 1
                        )
                }
                .buttonStyle(.plain)
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.surfaceTint)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.18), value: selection)
    }
}

struct TemplatePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: TemplateLayoutMetrics.controlHeight)
            .background(
                LinearGradient(
                    colors: [AppTheme.copper, AppTheme.copperDark],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct TemplateSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(AppTheme.copper)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: TemplateLayoutMetrics.controlHeight)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.copper.opacity(configuration.isPressed ? 0.5 : 1), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct BottomActionBar<PrimaryAction: View, SecondaryAction: View>: View {
    @ViewBuilder var primaryAction: PrimaryAction
    @ViewBuilder var secondaryAction: SecondaryAction

    var body: some View {
        VStack(spacing: 8) {
            primaryAction
            secondaryAction
        }
        .accessibilityElement(children: .contain)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(
            AppTheme.surface
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(AppTheme.divider)
                        .frame(height: 1)
                }
                .shadow(color: AppTheme.shadow.opacity(0.7), radius: 8, x: 0, y: -2)
        )
    }
}

struct AdaptiveButtonGroup<Primary: View, Secondary: View>: View {
    @ViewBuilder var primary: Primary
    @ViewBuilder var secondary: Secondary

    init(
        @ViewBuilder primary: () -> Primary,
        @ViewBuilder secondary: () -> Secondary
    ) {
        self.primary = primary()
        self.secondary = secondary()
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 12) {
                primary
                    .frame(maxWidth: .infinity)
                secondary
                    .frame(maxWidth: .infinity)
            }

            VStack(spacing: 12) {
                primary
                secondary
            }
        }
    }
}
