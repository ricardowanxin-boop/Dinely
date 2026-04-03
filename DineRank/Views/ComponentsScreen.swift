import SwiftUI

struct RankScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var storeEntitlementStore: StoreEntitlementStore

    private var metrics: [(icon: String, value: String, label: String, tint: Color)] {
        [
            ("calendar", "\(viewModel.profile.totalInvited)", "总局数", AppTheme.aqua),
            ("flame.fill", "\(viewModel.profile.currentStreak)", "连续守约", AppTheme.warning),
            ("sparkles", "\(viewModel.profile.longestStreak)", "最长连胜", AppTheme.copper),
            ("chart.line.uptrend.xyaxis", DisplayFormatters.percentage(viewModel.profile.attendanceRate), "守约率", AppTheme.mint)
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                heroSection
                metricsSection
                shareSection
                leaderboardSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, TemplateLayoutMetrics.tabBarClearance)
        }
        .background(AppBackgroundView())
        .accessibilityIdentifier("rank-screen")
        .navigationTitle("我的段位")
        .navigationBarTitleDisplayMode(.large)
        .rootChromeVisible(true)
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            RankBadgeView(
                rank: viewModel.profile.currentRank,
                rateText: "Gold Tier",
                size: 120
            )
            .padding(.top, 8)

            Text("守约食神")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)

            Text(DisplayFormatters.percentage(viewModel.profile.attendanceRate))
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .foregroundStyle(AppTheme.textPrimary)

            Text("守约率")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [AppTheme.surfaceWarm, AppTheme.surface],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 10, x: 0, y: 4)
    }

    private var metricsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ForEach(Array(metrics.enumerated()), id: \.offset) { item in
                let metric = item.element
                MetricCardView(icon: metric.icon, value: metric.value, label: metric.label, accent: metric.tint)
            }
        }
    }

    private var shareSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            TemplateSectionHeader(
                title: "我的约饭战绩",
                subtitle: "暖橙高光的分享卡会成为产品最重要的自传播入口。"
            )

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.copper, Color(hex: "#FFC935")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 220)

                VStack(alignment: .leading, spacing: 16) {
                    Text("我的约饭战绩")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    HStack(alignment: .center, spacing: 18) {
                        Circle()
                            .fill(.white)
                            .frame(width: 84, height: 84)
                            .overlay(
                                Text(viewModel.profile.currentRank.emoji)
                                    .font(.system(size: 34))
                            )

                        VStack(alignment: .leading, spacing: 6) {
                            Text(viewModel.profile.currentRank.title)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("总场次 \(viewModel.profile.totalInvited)")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.82))
                            Text("连续守约 \(viewModel.profile.currentStreak)")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.82))
                        }
                    }

                    ViewThatFits(in: .horizontal) {
                        HStack {
                            shareStat(value: DisplayFormatters.percentage(viewModel.profile.attendanceRate), label: "守约率")
                            Spacer()
                            shareStat(value: "\(viewModel.profile.totalAttended)", label: "实到次数")
                            Spacer()
                            shareStat(value: "\(viewModel.profile.currentStreak)", label: "连胜")
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                shareStat(value: DisplayFormatters.percentage(viewModel.profile.attendanceRate), label: "守约率")
                                Spacer()
                                shareStat(value: "\(viewModel.profile.totalAttended)", label: "实到次数")
                            }

                            shareStat(value: "\(viewModel.profile.currentStreak)", label: "连胜")
                        }
                    }
                }
                .padding(20)
            }

            ShareLink(item: shareText) {
                Text("分享我的战绩")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TemplatePrimaryButtonStyle())
            .accessibilityIdentifier("rank-share-button")
        }
        .templateSurface()
    }

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TemplateSectionHeader(
                title: "圈子排行榜",
                subtitle: "后续接入 Pro 权益后，这一块可以成为留存与复访入口。"
            )

            if storeEntitlementStore.hasProAccess {
                ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { item in
                    let index = item.offset
                    let entry = item.element
                    HStack(spacing: 12) {
                        Text("#\(index + 1)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(width: 28)

                        Circle()
                            .fill(AppTheme.surfaceWarm)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(entry.rank.emoji)
                                    .font(.system(size: 18))
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.nickname)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("\(entry.rank.title) · \(DisplayFormatters.percentage(entry.attendanceRate))")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        Text("\(entry.currentStreak) 连")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppTheme.copper)
                    }
                    .padding(14)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.divider, lineWidth: 1)
                    )
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Pro 专属", systemImage: "lock.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.copper)

                    Text("圈子排行榜已经接好数据结构，升级 Pro 后即可查看完整排名、连续上榜和圈内对比。")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppTheme.surfaceWarm, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )
            }
        }
        .templateSurface()
    }

    private func shareStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(.white)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private var shareText: String {
        """
        我的约饭战绩
        当前段位：\(viewModel.profile.currentRank.title) \(viewModel.profile.currentRank.emoji)
        守约率：\(DisplayFormatters.percentage(viewModel.profile.attendanceRate))
        总场次：\(viewModel.profile.totalInvited)
        连续守约：\(viewModel.profile.currentStreak)
        """
    }
}
