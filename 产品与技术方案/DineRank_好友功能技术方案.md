# DineRank（约饭）好友功能技术方案

> **版本**: V1.0  
> **目标**: 在不自建后端的前提下，为 DineRank 增加可正式上线的轻量好友系统  
> **定位**: 熟人约饭工具，不做重社交平台  
> **技术原则**: iOS 原生 + CloudKit，无自建服务器

---

## 一、一句话结论

好友功能值得做，而且会明显提升留存和复访。

但 DineRank 不应该做成“聊天社交 App”，而应该做成：

**好友关系 + 约饭协作 + 段位互看**

也就是说，先做能帮助用户“更方便约熟人”的那一层，不做动态、群聊、附近的人这种重社交。

---

## 二、为什么值得做

如果没有好友功能，DineRank 更像一次性工具：

- 发一个链接
- 约一次饭
- 用完就走

如果有轻量好友功能，产品会更像长期使用的熟人工具：

- 下次可以直接从好友里发起约饭
- 可以持续看到朋友的守约段位
- 战报分享更有对象，不只是“发链接”
- 段位和守约率会更有社交意义

### 对产品的直接提升

1. **留存更强**  
   用户不是只在“本次约饭”打开 App，而是会回来看朋友、段位和下次局。

2. **复用更高**  
   发起新约饭不用每次重新拉人。

3. **Pro 价值更清楚**  
   好友越稳定，圈子榜单、更多人数、更多分享样式这些付费权益越容易成立。

4. **更符合熟人产品定位**  
   DineRank 的核心不是陌生人社交，而是熟人协作和守约激励。

---

## 三、产品边界

### 3.1 V1 要做的

V1 好友功能只做这 5 件事：

1. 添加好友
2. 好友申请列表
3. 好友列表
4. 好友公开资料卡
5. 从好友中快速发起约饭

### 3.2 V1 不做的

这些功能先不要做：

- 聊天
- 动态流
- 附近的人
- 陌生人推荐
- 复杂群聊
- 举报申诉体系
- 大型社交排行榜

### 3.3 好友功能的产品定义

好友在 DineRank 里不是“社交关系资产”，而是：

**一组你未来可能继续约饭的人。**

所以好友关系只服务于 3 件事：

- 直接拉人组局
- 看对方守约情况
- 让战报和段位形成持续互动

---

## 四、正式上线的推荐方案

### 4.1 总体方案

采用：

**iOS App + CloudKit + Universal Link + 本地缓存**

不自建服务器，不单独买数据库。

### 4.2 为什么不是“完全本地”

好友关系一定涉及跨设备同步：

- 你发起好友申请
- 对方要能收到
- 对方同意后双方都要更新

所以：

- **完全本地**做不了好友系统
- **无自建后端**可以做好友系统

### 4.3 技术前提

这套方案默认依赖 Apple 生态能力：

- CloudKit
- iCloud 账号
- Universal Link
- App 内本地缓存

也就是说：

**用户如果设备上完全不可用 iCloud，好友关系和多人协作写入会受影响。**

这个前提需要在产品上接受。

---

## 五、数据结构设计

### 5.1 当前项目已有基础

当前工程已经有这些可复用基础：

- `AttendanceProfile`：本地用户档案
- `MealEvent / Participant`：约饭局与参与人模型
- `CloudMealEventService`：CloudKit 事件协作骨架

因此好友功能不是从零开始，而是在现有模型上往前扩。

### 5.2 新增核心实体

#### 1. UserProfilePublic

用于公开展示给其他好友看的资料。

```swift
struct UserProfilePublic {
    var userID: String              // CloudKit 用户唯一标识
    var userCode: String            // 可分享、可搜索的短码
    var nickname: String
    var avatarEmoji: String
    var currentRank: AttendanceRank
    var attendanceRate: Double?
    var currentStreak: Int
    var cityName: String?
    var isDiscoverable: Bool        // 是否允许被搜索/添加
    var updatedAt: Date
}
```

#### 2. FriendRequest

表示好友申请。

```swift
struct FriendRequest {
    var id: UUID
    var requesterID: String
    var recipientID: String
    var status: FriendRequestStatus   // pending / accepted / rejected / cancelled
    var message: String?
    var createdAt: Date
    var updatedAt: Date
}
```

#### 3. Friendship

表示双方已经成为好友。

```swift
struct Friendship {
    var id: UUID
    var userA: String
    var userB: String
    var createdAt: Date
    var source: FriendshipSource      // inviteLink / userCode / eventInvite
}
```

#### 4. UserPrivacySettings

表示用户的私密偏好。

```swift
struct UserPrivacySettings {
    var userID: String
    var allowFriendRequests: Bool
    var allowSearchByCode: Bool
    var allowRankPreview: Bool
    var blockedUserIDs: [String]
}
```

---

## 六、CloudKit 存储方案

### 6.1 推荐拆分

#### Public Database

适合放“公开、轻量、可搜索”的数据：

- `UserProfilePublic`
- `FriendRequest`
- `Friendship`

这里不要放敏感数据，只放：

- 昵称
- emoji 头像
- 段位摘要
- 公开守约率
- 好友关系状态

#### Private Database

适合放“只属于当前用户”的数据：

- `UserPrivacySettings`
- 本人的好友缓存
- 本人的本地偏好

#### 约饭协作数据

现有约饭局后续建议从“全靠 Public DB”逐步升级为：

**事件元数据 + 私有持有 + CKShare 协作**

这样正式版在权限和隐私上会更稳。

### 6.2 为什么不把所有好友数据都做在 Public DB

因为好友系统虽然不算特别敏感，但也不能把太多隐私暴露出去。

所以正式版策略是：

- 能公开的公开
- 需要私密的放 private
- 需要多人协作的再用 share

---

## 七、加好友方式

### 7.1 推荐方式

V1 只做三种方式：

1. `用户码添加`
2. `邀请链接添加`
3. `约饭局参与后快捷加好友`

### 7.2 为什么不做手机号/通讯录

因为这会立刻增加复杂度：

- 隐私弹窗更多
- 通讯录权限更敏感
- 匹配和纠错更复杂
- 审核和合规成本更高

对 DineRank 这种熟人约饭产品来说，用户码和邀请链接已经够用了。

### 7.3 用户流程

#### 场景 1：用户码加好友

```text
打开好友页
→ 输入对方用户码
→ 查看对方公开资料
→ 发送申请
→ 对方在“好友申请”里同意
→ 双方加入好友列表
```

#### 场景 2：邀请链接加好友

```text
用户生成自己的好友邀请链接
→ 发给朋友
→ 对方打开链接进入 App
→ 看到资料卡并确认申请
→ 双方成为好友
```

#### 场景 3：约饭后快捷加好友

```text
参加完一次约饭局
→ 在参与者列表中点击“加好友”
→ 发送申请
→ 对方确认
```

---

## 八、页面设计建议

### 8.1 V1 页面入口

不建议新开第 4 个 Tab。

推荐入口：

- 首页右上角增加“好友”入口
- 我的段位页增加“好友与圈子”入口
- 参与者列表中增加“加好友”按钮

### 8.2 页面清单

V1 需要新增这些页面：

1. 好友页
   - 好友列表
   - 搜索用户码
   - 创建邀请链接

2. 好友申请页
   - 收到的申请
   - 发出的申请

3. 好友资料页
   - 昵称
   - emoji
   - 当前段位
   - 守约率摘要
   - 连续守约天数
   - 发起约饭按钮

4. 从好友发起约饭页
   - 选择一个或多个好友
   - 进入已有创建约饭 3 步流

---

## 九、开发实现建议

### 9.1 新增模块

建议新增这些代码层：

#### Services

- `CloudIdentityService`
- `CloudFriendService`
- `FriendInviteService`

#### Models

- `UserProfilePublic`
- `FriendRequest`
- `Friendship`
- `UserPrivacySettings`

#### ViewModels

- `FriendsViewModel`
- `FriendRequestsViewModel`
- `FriendProfileViewModel`

#### Views

- `FriendsScreen`
- `FriendRequestsScreen`
- `FriendProfileScreen`
- `AddFriendSheet`

### 9.2 和当前项目的衔接方式

当前项目里，用户身份主要还是：

- `deviceId`
- 本地昵称
- 本地档案

正式好友系统上线前，建议这样升级：

1. 保留 `deviceId` 作为本地设备标识
2. 新增 `cloudUserID` 作为正式用户主键
3. 所有好友关系只认 `cloudUserID`
4. `MealEvent.participants` 里逐步兼容 `cloudUserID`

也就是说：

**设备 ID 继续存在，但不再当真正的好友身份主键。**

---

## 十、隐私与审核注意点

### 10.1 需要在隐私政策说明的内容

好友功能上线后，隐私政策里要新增说明：

- 会保存公开昵称与头像 emoji
- 会保存好友申请与好友关系
- 可选展示公开段位和守约率摘要
- 用户可以关闭被搜索、关闭好友申请、删除好友

### 10.2 App 审核上需要注意

这套方案比通讯录方案轻，审核更友好。

主要注意：

- 不要默认公开过多个人信息
- 不要误导用户“附近的人”
- 不要采集通讯录却不说明
- 不要把好友功能做成需要手机号验证但又没有完整说明

---

## 十一、开发排期建议

### 阶段 1：最小可用版（3-5 天）

目标：先做出能用的好友系统

包含：

- 用户公开资料
- 用户码
- 发送好友申请
- 同意 / 拒绝申请
- 好友列表
- 从好友页发起约饭入口

### 阶段 2：可上线版（7-12 天）

目标：达到正式 MVP 标准

增加：

- 删除好友
- 撤回申请
- 隐私开关
- 去重和异常处理
- 双设备真机联调
- 基础测试

### 阶段 3：增强版（2-4 周）

目标：提高长期留存

增加：

- 圈子排行榜
- 好友战报对比
- 更强的好友邀请链路
- 更细的权限和风控

---

## 十二、最终建议

### 12.1 值不值得做

值得做，而且会比“不做好友”更适合 DineRank。

### 12.2 应该怎么做

应该做成：

**轻量好友系统**

而不是：

**完整社交平台**

### 12.3 正式推荐路线

```text
V1
先做用户码 + 好友申请 + 好友列表 + 好友资料卡

V2
好友内快速发起约饭 + 圈子榜单

V3
更强的分享、战报、好友协作增强
```

### 12.4 一句话结论

**DineRank 做好友功能会更好，但要把它做成“更方便约熟人”的工具能力，而不是做成新的社交平台。**

