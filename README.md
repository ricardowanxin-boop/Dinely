# 食否 / Dinely

基于当前确认的 Figma 与产品方案搭建的 食否 / Dinely iOS MVP 工程，面向 iOS 17+，默认使用 SwiftUI。

当前工程已经不是空模版，而是带业务骨架的首版实现，核心方向是「熟人聚餐协同工具 + 守约段位游戏」：

- 首页 / 我的段位 / 设置 三个主 Tab
- 创建约饭、详情、地图、签到、AA、战报 主流程页面
- 暖橙品牌主题、约饭卡片、状态徽标、段位卡与分享卡基础组件
- 本地样例数据、状态层与后续 CloudKit / StoreKit / Widget 接入骨架
- App Group、Widget 与 Live Activity / 灵动岛基础设施
- 后台刷新调度与本地通知能力
- UI Test 烟雾测试骨架

## 目录结构

```text
DineRank/
  App/
  Models/
  Services/
  Support/
  ViewModels/
  Views/
  Resources/
DineRankWidgetsExtension/
DineRankUITests/
scripts/
```

## 当前构建

```bash
xcodebuild -project DineRank.xcodeproj \
  -scheme DineRank \
  -destination 'generic/platform=iOS Simulator' \
  build
```

## 当前实现范围

1. 首页约饭局列表与暖色 Hero 区
2. 创建约饭 3 步流：基础信息 / 候选时间 / 地图选餐厅
3. 约饭详情：时间投票、餐厅投票、参与者、流程入口
4. 约饭当天地图、位置共享、签到确认、AA 分摊、守约战报
5. 我的段位：段位 Hero、战绩分享卡、排行榜
6. 设置：市场名称、主题、Pro 商品与配置展示

## 模版默认约定

- iOS 17.0+
- SwiftUI
- WidgetKit
- ActivityKit
- StoreKit 2
- App Group 共享存储
- 后台刷新任务标识：`com.ricardo.dinerank.refresh`

## 说明

- 当前仍以 `SampleData` 为主，CloudKit、地图搜索、Universal Link、内购校验还没接入真实线上服务。
- Live Activity、Widget、后台刷新、通知与定位权限需要真机和正确签名后再做最终联调。
- 如果后续继续基于这个工程扩展，请优先收口真实 bundle id、App Group、IAP 商品、CloudKit schema 与定位策略。
