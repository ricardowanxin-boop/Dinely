# DineRank 提审准备

这份目录用于补齐 App Store Connect 与官网托管侧的审核材料。当前代码已经在 App 内提供：

- 首次使用说明
- 隐私政策入口
- 服务条款 / EULA 入口
- 免责声明入口
- 数据来源与地图说明入口
- 联系支持入口
- 一次性买断 Pro + 恢复购买入口

在正式提交审核前，还需要完成以下 App 外配置：

## 1. 官网托管页面

请至少托管以下两个公开页面，要求无需登录即可访问：

- `https://dinerank.app/privacy`
- `https://dinerank.app/support`

可直接参考：

- [PrivacyPolicy-Web-Copy.md](/Users/ricardo/文稿/创业/IOS原生AI应用/DineRank（约饭）/Deployment/AppReview/PrivacyPolicy-Web-Copy.md)
- [ReviewNotes-template.md](/Users/ricardo/文稿/创业/IOS原生AI应用/DineRank（约饭）/Deployment/AppReview/ReviewNotes-template.md)

## 2. App Store Connect 必填项

- `Privacy Policy URL`: `https://dinerank.app/privacy`
- `Support URL`: `https://dinerank.app/support`
- `Review Notes`: 使用本目录里的模板，并按当前版本实际入口微调

## 3. 当前对外只开放的 IAP

当前版本仅应对外提交并展示以下商品：

- `com.ricardo.dinerank.pro.lifetime`

月卡 / 年卡代码口子仍保留在工程中，但当前版本不应：

- 在 UI 中展示
- 在截图中出现
- 在 Review Notes 里提及
- 在本次 IAP 提交中一起送审

## 4. Universal Link

仍需确保以下文件已在线可访问：

- `https://dinerank.app/.well-known/apple-app-site-association`
- `https://www.dinerank.app/.well-known/apple-app-site-association`

本地模板位于：

- [apple-app-site-association](/Users/ricardo/文稿/创业/IOS原生AI应用/DineRank（约饭）/Deployment/UniversalLinks/apple-app-site-association)

