# DineRank UI设计方案 - 规范版

> 基于Figma设计规范的精确实现方案，所有尺寸、间距、对齐方式完全标准化

---

## 一、设计原则

### 核心理念
**实用工具 + 轻量游戏化 = 高留存 + 自传播**

### 核心价值
解决5大痛点：
1. **时间难协调** - 多选投票自动统计
2. **餐厅难决策** - 地图选点+投票
3. **位置难掌握** - 实时查看对方距离约饭地点多远
4. **AA难分摊** - 智能计算器
5. **爽约无约束** - 段位系统游戏化

### 视觉策略
- **工具页面**（首页/详情）：克制、高效、中性色
- **成就页面**（段位页）：游戏化、视觉冲击、段位色

---

## 二、App Icon设计

### 方案A：极简几何风格（推荐）
```
尺寸: 1024x1024pt
背景: 深海军蓝 #2C3E50

主图形:
- 三个圆点排列成三角形 (象征多人聚餐)
  - 圆点直径: 180pt
  - 颜色: 金色 #FFD700
  - 间距: 200pt
  - 位置: 居中偏上 y=400pt

- 底部横线 (象征餐桌)
  - 宽度: 600pt
  - 高度: 40pt
  - 颜色: 金色 #FFD700
  - 位置: y=700pt，居中
  - 圆角: 20pt

视觉特点:
- 极简克制，高级感强
- 抽象表达"多人聚餐"概念
- 深蓝+金色，专业且醒目
- 几何图形，现代感
```

### 方案B：文字图形化
```
尺寸: 1024x1024pt
背景: 深海军蓝 #2C3E50

主图形:
- "食否" 两字
  - 字体: 思源黑体 Heavy
  - 大小: 400pt
  - 颜色: 白色 #FFFFFF
  - 位置: 居中
  - 字间距: 80pt

- 顶部装饰线
  - 宽度: 500pt
  - 高度: 20pt
  - 颜色: 金色 #FFD700
  - 位置: y=250pt

视觉特点:
- 直接明了
- 文字图形化，记忆点强
- 克制现代
```

### 方案C：圆桌俯视图
```
尺寸: 1024x1024pt
背景: 深海军蓝 #2C3E50

主图形:
- 圆形餐桌 (俯视)
  - 直径: 600pt
  - 颜色: 金色 #FFD700 描边 60pt
  - 填充: 透明
  - 位置: 居中

- 4个小圆点 (座位)
  - 直径: 100pt
  - 颜色: 白色 #FFFFFF
  - 位置: 圆周均匀分布

视觉特点:
- 具象但克制
- 清晰传达"聚餐"概念
- 几何美感
```

### 推荐方案：A（极简几何风格）
理由：
1. 高级克制，符合"食否"定位
2. 抽象表达，不幼稚
3. 深蓝+金色，专业且有记忆点
4. 几何图形，适合90后审美

---

## 三、设计系统

### 画布设置
```
Frame: iPhone 14 Pro
Width: 393pt
Height: 852pt
Background: #F8F9FA

Safe Area:
- Top: 59pt (status bar + navigation bar)
- Bottom: 34pt (home indicator)
- Content Area: 759pt (852 - 59 - 34)

Grid System:
- Base Unit: 8pt
- Columns: 6
- Gutter: 16pt
- Margin: 16pt (left/right)
- Content Width: 361pt (393 - 16*2)
```

### 色彩系统

#### 主色调（工具部分）
```
Primary:
- Navy Blue #2C3E50（深海军蓝）
  用途：主按钮、标题、重要操作

Secondary:
- Slate Gray #64748B（石板灰）
  用途：次要文字、图标

Background:
- Light Gray #F8F9FA（浅灰）- 页面背景
- White #FFFFFF - 卡片背景

Text:
- Primary #1A1A1A（深灰黑）
- Secondary #6B7280（中灰）
- Tertiary #9CA3AF（浅灰）
```

#### 状态色
```
Success: #10B981（成功/确认/到场）
Warning: #F59E0B（警告/投票中）
Error: #EF4444（错误/爽约）
Info: #3B82F6（信息/提示）
```

#### 段位专属色
```
仅在段位相关页面使用：

Newcomer: #94A3B8（灰蓝）
Bronze: #CD7F32（青铜）
Silver: #C0C0C0（白银）
Gold: #FFD700（黄金）⭐ 也用于成就高光
Platinum: #E5E4E2（铂金）
Diamond: #B9F2FF（钻石蓝）
Legend: #A855F7（传奇紫）
```

### 圆角规范
```
Large: 16pt - 大卡片、模态框
Medium: 12pt - 标准卡片、按钮
Small: 8pt - 标签、徽章
XSmall: 4pt - 进度条、分割线
```

### 阴影规范
```
Card Shadow: y=1pt, blur=3pt, #000000 10%
Elevated Shadow: y=4pt, blur=6pt, #000000 10%
Modal Shadow: y=10pt, blur=25pt, #000000 15%
Rank Glow: y=0, blur=20pt, rank-color 40%
```

### 间距系统
```
基于8pt网格：4pt / 8pt / 12pt / 16pt / 24pt / 32pt / 48pt
```

---

## 三、首页设计（工具风格）

### 导航栏
```
Height: 96pt (44pt bar + 52pt large title)
Background: #F8F9FA

Large Title "约饭":
- Font: SF Pro Display Bold 34pt
- Color: #2C3E50
- Position: x=16pt, y=59pt
- Line height: 41pt
```

### 约饭局卡片
```
Card Container:
- Width: 361pt (393 - 16*2)
- Height: auto (min 140pt)
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Shadow: y=1pt, blur=3pt, #000000 10%
- Padding: 16pt
- Margin bottom: 12pt

First card position:
- x: 16pt
- y: 155pt (96pt nav + 59pt from top)

Internal Layout (Auto Layout Vertical):
- Direction: Vertical
- Spacing: 12pt
- Padding: 16pt

Row 1 - Header (Horizontal):
├─ Emoji Icon
│  ├─ Size: 32x32pt
│  └─ Margin right: 8pt
├─ Title Text
│  ├─ Font: SF Pro Text Semibold 17pt
│  ├─ Color: #1A1A1A
│  └─ Flex: 1
└─ Status Badge
   ├─ Height: 24pt
   ├─ Padding: 4pt horizontal, 6pt vertical
   ├─ Corner radius: 8pt
   ├─ Background: #F59E0B (voting) / #10B981 (confirmed)
   └─ Text: SF Pro Text Medium 13pt, White

Row 2 - Date Info (Horizontal):
├─ Calendar Icon (16x16pt, #6B7280)
└─ Text "3个候选时间" (SF Pro Text Regular 15pt, #6B7280)

Row 3 - Participant Info (Horizontal):
├─ People Icon (16x16pt, #6B7280)
└─ Text "5/8人已投票" (SF Pro Text Regular 15pt, #6B7280)

Row 4 - Progress Bar:
├─ Track: 329pt x 4pt, #E5E7EB, radius 2pt
├─ Fill: 62% width, 4pt, #2C3E50, radius 2pt
└─ Percentage: SF Pro Text Regular 13pt, #6B7280, align right
```

### FAB按钮
```
Size: 56x56pt
Background: #2C3E50
Corner radius: 28pt (circle)
Shadow: y=4pt, blur=6pt, #000000 10%

Icon:
- SF Symbol "plus"
- Size: 24x24pt
- Color: #FFFFFF

Position:
- x: 321pt (393 - 56 - 16)
- y: 762pt (852 - 56 - 34)
- Fixed position
```

### 空状态
```
Container:
- Width: 361pt
- Height: 400pt
- Position: x=16pt, y=226pt (centered)

Illustration:
- Width: 200pt
- Height: 200pt
- Position: centered, y=0

Title "还没有约饭局":
- Font: SF Pro Text Semibold 20pt
- Color: #1A1A1A
- Position: centered, y=220pt

Subtitle "点击右下角创建第一个":
- Font: SF Pro Text Regular 15pt
- Color: #6B7280
- Position: centered, y=252pt
```

---

## 四、我的段位页设计（游戏化风格）

### Hero区域
```
Container:
- Width: 393pt
- Height: 400pt
- Background: Linear gradient (rank color → #FFFFFF, 180deg)

Rank Badge:
- Size: 120x120pt
- Position: x=136.5pt (centered), y=119pt

Badge Structure:
Outer Ring:
├─ Size: 120x120pt
├─ Stroke: 8pt, rank color gradient
├─ Fill: transparent
└─ Shadow: y=0, blur=20pt, rank-color 40%

Inner Circle:
├─ Size: 104x104pt (120 - 8*2)
├─ Fill: #FFFFFF
└─ Position: centered

Emoji Icon:
├─ Size: 64x64pt
└─ Position: centered

Progress Ring (optional):
├─ Size: 136x136pt
├─ Stroke: 10pt, rank color
├─ Cap: round
└─ Rotation: -90deg

Rank Name:
- Font: SF Pro Display Bold 28pt
- Color: #1A1A1A
- Position: centered, y=259pt

Attendance Rate:
- Font: SF Pro Rounded Bold 72pt
- Color: #1A1A1A
- Position: centered, y=299pt

Label "守约率":
- Font: SF Pro Text Regular 15pt
- Color: #6B7280
- Position: centered, y=383pt
```

### 统计卡片网格
```
Grid Container:
- Width: 361pt
- Position: x=16pt, y=420pt
- Layout: 2 columns
- Gap: 12pt

Stat Card:
- Width: 174.5pt ((361 - 12) / 2)
- Height: 100pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Shadow: y=1pt, blur=3pt, #000000 10%
- Padding: 16pt

Card Content:
├─ Icon (24x24pt, #6B7280, top-left)
├─ Value (SF Pro Display Bold 32pt, #1A1A1A, y=40pt)
└─ Label (SF Pro Text Regular 13pt, #6B7280, y=80pt)

Cards:
1. 总约饭次数
2. 守约次数
3. 爽约次数
4. 当前连胜
```

### 段位进度条
```
Container:
- Width: 361pt
- Position: x=16pt, y=644pt
- Padding: 16pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt

Content:
├─ Title "距离下一段位" (SF Pro Text Semibold 15pt, #1A1A1A)
├─ Progress Bar (y=36pt)
│  ├─ Track: 329pt x 8pt, #E5E7EB, radius 4pt
│  ├─ Fill: gradient (current → next rank color), radius 4pt
│  └─ Percentage: SF Pro Text Medium 13pt, #6B7280
└─ Subtitle "再守约3次升级" (SF Pro Text Regular 13pt, #6B7280, y=60pt)
```

### 战绩卡片（可分享）
```
Container:
- Width: 361pt
- Position: x=16pt, y=748pt
- Height: 280pt
- Background: Linear gradient (rank color → darker, 135deg)
- Corner radius: 16pt
- Shadow: y=4pt, blur=12pt, rank-color 30%
- Padding: 24pt

Content:
├─ Header "我的约饭战绩" (SF Pro Display Bold 24pt, White, y=0)
├─ Rank Badge (80x80pt, y=44pt, centered)
├─ Rank Name (SF Pro Display Bold 20pt, White, y=140pt)
├─ Stats Grid (y=172pt)
│  ├─ 守约率 92% (SF Pro Rounded Bold 32pt, White)
│  ├─ 总场次 48 (SF Pro Text Regular 15pt, White 80%)
│  └─ 连胜 12 (SF Pro Text Regular 15pt, White 80%)
└─ Footer "DineRank" (SF Pro Text Regular 13pt, White 60%, y=256pt)
```

### 分享按钮
```
Size: 361pt x 48pt
Position: x=16pt, y=1044pt
Background: #FFD700 (Gold)
Corner radius: 12pt
Shadow: y=2pt, blur=4pt, #000000 15%

Text: "分享我的战绩"
- Font: SF Pro Text Semibold 17pt
- Color: #1A1A1A
```

---

## 五、约饭详情页设计

### 顶部信息区
```
Container:
- Width: 393pt
- Height: 200pt
- Background: #FFFFFF
- Padding: 16pt

Content:
├─ Back Button (44x44pt, top-left)
├─ Title (SF Pro Display Bold 28pt, #1A1A1A, y=59pt)
├─ Status Badge (y=59pt, right-aligned)
├─ Creator Info (y=103pt)
│  ├─ Avatar (32x32pt, rank color border 2pt)
│  ├─ Name (SF Pro Text Regular 15pt, #6B7280)
│  └─ Rank Badge (24x24pt)
└─ Description (SF Pro Text Regular 15pt, #6B7280, y=147pt)
```

### 时间投票区
```
Section Header:
- Height: 44pt
- Background: #F8F9FA
- Padding: 0 16pt
- Text: "候选时间" (SF Pro Text Semibold 17pt, #1A1A1A)

Time Option Card:
- Width: 361pt
- Height: 80pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Padding: 16pt
- Margin: 12pt 16pt

Card Layout (Horizontal):
├─ Left Section
│  ├─ Date (SF Pro Text Semibold 17pt, #1A1A1A)
│  ├─ Time (SF Pro Text Regular 15pt, #6B7280)
│  └─ Weekday (SF Pro Text Regular 13pt, #9CA3AF)
├─ Middle Section
│  └─ Voter Avatars (24x24pt, overlap -8pt)
└─ Right Section
   └─ Checkbox (24x24pt, #2C3E50 when selected)
```

### 餐厅投票区
```
Section Header:
- Height: 44pt
- Background: #F8F9FA
- Padding: 0 16pt
- Text: "候选餐厅" (SF Pro Text Semibold 17pt, #1A1A1A)

Restaurant Card:
- Width: 361pt
- Height: 120pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Padding: 16pt
- Margin: 12pt 16pt

Card Layout:
├─ Top Row (Horizontal)
│  ├─ Restaurant Name (SF Pro Text Semibold 17pt, #1A1A1A)
│  └─ Checkbox (24x24pt, #2C3E50 when selected)
├─ Middle Row
│  ├─ Cuisine Tag (SF Pro Text Regular 13pt, #6B7280, background #F8F9FA)
│  └─ Price "¥80/人" (SF Pro Text Regular 13pt, #6B7280)
├─ Address (SF Pro Text Regular 13pt, #9CA3AF)
└─ Voter Avatars (24x24pt, overlap -8pt)
```

### 参与者列表
```
Section Header:
- Height: 44pt
- Text: "参与者 (8人)" (SF Pro Text Semibold 17pt, #1A1A1A)

Participant Row:
- Width: 361pt
- Height: 64pt
- Background: #FFFFFF
- Padding: 12pt 16pt

Row Layout (Horizontal):
├─ Avatar (40x40pt, rank color border 2pt)
├─ Info Section
│  ├─ Name (SF Pro Text Semibold 15pt, #1A1A1A)
│  └─ Rank Badge (20x20pt) + Rank Name (SF Pro Text Regular 13pt, #6B7280)
└─ Status Icon (20x20pt)
   ├─ ✓ Voted (Green)
   ├─ ⏱ Pending (Amber)
   └─ ✗ Declined (Red)
```

### 底部操作栏
```
Container:
- Width: 393pt
- Height: 82pt (48pt button + 34pt safe area)
- Background: #FFFFFF
- Border top: 1pt solid #E5E7EB
- Padding: 16pt 16pt 34pt 16pt

Primary Button:
- Width: 361pt
- Height: 48pt
- Background: #2C3E50
- Corner radius: 12pt
- Text: "提交投票" (SF Pro Text Semibold 17pt, White)
```

---

## 六、约饭当天 - 位置共享页设计

### 地图视图
```
Container:
- Width: 393pt
- Height: 600pt
- Background: MapKit native map

Map Elements:
├─ Restaurant Annotation (餐厅标记)
│  ├─ Icon: 红色餐厅图标 48x48pt
│  ├─ Label: 餐厅名称 (SF Pro Text Semibold 15pt, White on #EF4444)
│  └─ Callout: 地址 + "导航" 按钮
│
└─ Participant Annotations (参与者位置)
   ├─ Avatar: Emoji 32x32pt on White circle 40x40pt
   ├─ Border: rank color 2pt
   ├─ Distance Label: "1.2km" (SF Pro Text Regular 11pt, White on semi-transparent black)
   └─ Animation: pulse effect when updating
```

### 位置共享控制卡片
```
Container:
- Width: 361pt
- Height: 120pt
- Position: x=16pt, y=620pt (overlay on map)
- Background: #FFFFFF with blur effect
- Corner radius: 16pt
- Shadow: y=4pt, blur=12pt, #000000 20%
- Padding: 16pt

Content:
├─ Header Row (Horizontal)
│  ├─ Icon: Location 24x24pt, #2C3E50
│  ├─ Title "实时位置共享" (SF Pro Text Semibold 17pt, #1A1A1A)
│  └─ Toggle Switch (51x31pt)
│
├─ Status Text
│  ├─ Enabled: "已开启，其他人可以看到你的位置" (SF Pro Text Regular 13pt, #10B981)
│  └─ Disabled: "开启后可查看所有人距离餐厅的距离" (SF Pro Text Regular 13pt, #6B7280)
│
└─ Privacy Note
   └─ "聚餐结束后自动停止共享" (SF Pro Text Regular 11pt, #9CA3AF)
```

### 参与者距离列表
```
Container:
- Width: 361pt
- Position: x=16pt, y=756pt
- Background: #FFFFFF
- Corner radius: 12pt
- Border: 1pt solid #E5E7EB
- Padding: 16pt

Header:
- Text: "所有人位置" (SF Pro Text Semibold 17pt, #1A1A1A)
- Subtitle: "5/8人已开启位置共享" (SF Pro Text Regular 13pt, #6B7280)

Participant Row:
- Height: 56pt
- Layout (Horizontal):
  ├─ Avatar (40x40pt, rank color border)
  ├─ Name (SF Pro Text Semibold 15pt, #1A1A1A)
  ├─ Distance Badge
  │  ├─ Background: #F8F9FA
  │  ├─ Corner radius: 8pt
  │  ├─ Padding: 4pt 8pt
  │  ├─ Text: "1.2km" (SF Pro Text Medium 13pt, #2C3E50)
  │  └─ Icon: Walking person 16x16pt
  └─ Status
     ├─ "已到达" (SF Pro Text Regular 13pt, #10B981) - if distance < 50m
     ├─ "5分钟" (SF Pro Text Regular 13pt, #F59E0B) - if distance < 1km
     └─ "未开启" (SF Pro Text Regular 13pt, #9CA3AF) - if not sharing

Sorting:
1. 已到达（距离<50m）
2. 按距离从近到远
3. 未开启位置共享的排最后
```

### 自动签到提示
```
Toast Notification:
- Width: 361pt
- Height: 80pt
- Position: centered, y=100pt
- Background: #10B981 gradient
- Corner radius: 16pt
- Shadow: y=4pt, blur=12pt, #10B981 30%
- Padding: 16pt
- Animation: slide down + fade in

Content:
├─ Icon: Checkmark circle 32x32pt, White
├─ Title "已自动签到" (SF Pro Text Semibold 17pt, White)
└─ Subtitle "你已到达餐厅附近" (SF Pro Text Regular 13pt, White 80%)

Auto dismiss: 3 seconds
```

---

## 七、创建约饭页设计

### 表单布局
```
Container:
- Width: 393pt
- Background: #F8F9FA
- Padding: 16pt

Navigation Bar:
- Height: 44pt
- Background: #FFFFFF
- Left: "取消" button
- Center: "创建约饭" (SF Pro Text Semibold 17pt, #1A1A1A)
- Right: "创建" button (#2C3E50)

Form Sections:
1. 基本信息（主题 + 菜系 + 预算）
2. 候选时间（2-3个）
3. 候选餐厅（地图选点，最多3家）
4. 参与人数限制（免费8人，Pro 20人）
```

### 地图选餐厅组件
```
Map Container:
- Width: 361pt
- Height: 300pt
- Background: MapKit native map
- Corner radius: 12pt
- Border: 1pt solid #E5E7EB
- Margin: 12pt 0

Map Controls:
├─ Search Bar (top overlay)
│  ├─ Width: 329pt (361 - 16*2)
│  ├─ Height: 44pt
│  ├─ Position: x=16pt, y=16pt
│  ├─ Background: #FFFFFF with blur
│  ├─ Corner radius: 12pt
│  ├─ Placeholder: "搜索餐厅" (SF Pro Text Regular 15pt, #9CA3AF)
│  └─ Icon: Search 20x20pt, #6B7280
│
├─ Restaurant Annotations
│  ├─ Unselected: Gray pin 24x24pt
│  ├─ Selected: Red pin 32x32pt with bounce animation
│  └─ Callout: Restaurant name + "选择" button
│
└─ My Location Button (bottom-right)
   ├─ Size: 44x44pt
   ├─ Position: x=301pt, y=240pt
   ├─ Background: #FFFFFF
   ├─ Corner radius: 22pt
   ├─ Icon: Location arrow 20x20pt, #2C3E50
   └─ Shadow: y=2pt, blur=4pt, #000000 15%

Selected Restaurant List (below map):
- Width: 361pt
- Background: #FFFFFF
- Corner radius: 12pt
- Border: 1pt solid #E5E7EB
- Padding: 12pt

Restaurant Chip:
├─ Height: 40pt
├─ Layout (Horizontal):
│  ├─ Restaurant Name (SF Pro Text Semibold 15pt, #1A1A1A)
│  ├─ Cuisine + Price (SF Pro Text Regular 13pt, #6B7280)
│  └─ Remove Icon (20x20pt, #EF4444)
└─ Margin: 8pt between chips

Add Restaurant Button:
- Width: 361pt
- Height: 48pt
- Background: transparent
- Border: 1pt dashed #2C3E50
- Corner radius: 12pt
- Text: "+ 在地图上选择餐厅" (SF Pro Text Regular 15pt, #2C3E50)
- Max: 3家餐厅
```

### 输入框样式
```
Text Input:
- Width: 361pt
- Height: 48pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Padding: 12pt 16pt
- Font: SF Pro Text Regular 17pt
- Placeholder color: #9CA3AF

Focus State:
- Border: 2pt solid #2C3E50
- Shadow: 0 0 0 4pt rgba(44,62,80,0.1)
```

### 时间选择器
```
Time Picker Card:
- Width: 361pt
- Height: 120pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Padding: 16pt

Content:
├─ Date Picker (SF Pro Text Regular 17pt)
├─ Period Picker: "午餐" / "晚餐" (Segmented Control)
└─ Delete Button (20x20pt, #EF4444, top-right)

Add Time Button:
- Width: 361pt
- Height: 48pt
- Background: transparent
- Border: 1pt dashed #2C3E50
- Corner radius: 12pt
- Text: "+ 添加候选时间" (SF Pro Text Regular 15pt, #2C3E50)
- Max: 3个时间段
```

### 参与人数设置
```
Participant Limit Card:
- Width: 361pt
- Height: 80pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Padding: 16pt

Layout (Horizontal):
├─ Left Section
│  ├─ Title "参与人数上限" (SF Pro Text Semibold 15pt, #1A1A1A)
│  └─ Subtitle "免费版最多8人" (SF Pro Text Regular 13pt, #6B7280)
│
└─ Right Section
   └─ Stepper (- / 8 / +)
      ├─ Button: 32x32pt, #F8F9FA
      ├─ Number: SF Pro Text Semibold 17pt, #1A1A1A
      └─ Range: 2-8 (免费) / 2-20 (Pro)

Pro Upgrade Prompt (if > 8):
- Width: 361pt
- Height: 60pt
- Background: Linear gradient (#FFD700 → #FFA500)
- Corner radius: 12pt
- Padding: 12pt
- Text: "升级Pro版支持最多20人" (SF Pro Text Semibold 15pt, #1A1A1A)
- Action: "立即升级" button
```

---

## 八、聚餐后流程设计

### 标记到场页面
```
Container:
- Width: 393pt
- Background: #F8F9FA

Navigation Bar:
- Title: "标记到场人员" (SF Pro Text Semibold 17pt, #1A1A1A)
- Left: "取消" button
- Right: "完成" button (#2C3E50)

Participant List:
- Width: 361pt
- Position: x=16pt, y=103pt

Participant Row:
- Height: 72pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Padding: 16pt
- Margin bottom: 12pt

Row Layout (Horizontal):
├─ Avatar (48x48pt, rank color border 2pt)
├─ Info Section
│  ├─ Name (SF Pro Text Semibold 17pt, #1A1A1A)
│  └─ Rank Badge + Rate (SF Pro Text Regular 13pt, #6B7280)
└─ Checkbox (32x32pt)
   ├─ Unchecked: Border 2pt #E5E7EB
   ├─ Checked: Background #10B981, White checkmark
   └─ Animation: Scale + Spring bounce

Summary Bar (bottom):
- Width: 393pt
- Height: 82pt
- Background: #FFFFFF
- Border top: 1pt solid #E5E7EB
- Padding: 16pt

Content:
├─ Text: "已到场 5/8人" (SF Pro Text Semibold 17pt, #1A1A1A)
└─ Button: "确认并结算" (Primary button, 361pt x 48pt)
```

### AA计算器页面
```
Container:
- Width: 393pt
- Background: #F8F9FA

Navigation Bar:
- Title: "AA分摊" (SF Pro Text Semibold 17pt, #1A1A1A)
- Left: "返回" button
- Right: "完成" button

Total Amount Card:
- Width: 361pt
- Height: 120pt
- Position: x=16pt, y=103pt
- Background: Linear gradient (#2C3E50 → #1A1A1A)
- Corner radius: 16pt
- Padding: 24pt

Content:
├─ Label "总金额" (SF Pro Text Regular 15pt, White 80%)
├─ Amount Input
│  ├─ Font: SF Pro Display Bold 48pt, White
│  ├─ Placeholder: "¥0"
│  └─ Keyboard: Decimal pad
└─ Subtitle "共8人参与" (SF Pro Text Regular 13pt, White 60%)

Split Result Card:
- Width: 361pt
- Height: 100pt
- Position: x=16pt, y=235pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Padding: 20pt

Content:
├─ Label "每人应付" (SF Pro Text Regular 15pt, #6B7280)
├─ Amount "¥125.50" (SF Pro Display Bold 40pt, #2C3E50)
└─ Note "已自动四舍五入" (SF Pro Text Regular 11pt, #9CA3AF)

Participant List:
- Width: 361pt
- Position: x=16pt, y=347pt

Participant Row:
- Height: 64pt
- Background: #FFFFFF
- Border: 1pt solid #E5E7EB
- Corner radius: 12pt
- Padding: 16pt
- Margin bottom: 8pt

Row Layout (Horizontal):
├─ Avatar (40x40pt)
├─ Name (SF Pro Text Semibold 15pt, #1A1A1A)
└─ Amount "¥125.50" (SF Pro Text Semibold 17pt, #2C3E50)

Action Buttons:
- Width: 361pt
- Position: x=16pt, bottom area

Buttons:
├─ "复制分摊明细" (Secondary button, 48pt height)
└─ "完成结算" (Primary button, 48pt height)
```

### 守约战报页面
```
Container:
- Width: 393pt
- Background: #F8F9FA

Navigation Bar:
- Title: "守约战报" (SF Pro Text Semibold 17pt, #1A1A1A)
- Right: "分享" button (#FFD700)

Report Card:
- Width: 361pt
- Height: 500pt
- Position: x=16pt, y=103pt
- Background: #FFFFFF
- Corner radius: 16pt
- Shadow: y=4pt, blur=12pt, #000000 15%
- Padding: 24pt

Content:
├─ Header
│  ├─ Title "约饭战报" (SF Pro Display Bold 28pt, #1A1A1A)
│  ├─ Event Name (SF Pro Text Semibold 17pt, #6B7280)
│  └─ Date (SF Pro Text Regular 15pt, #9CA3AF)
│
├─ Stats Grid (2x2)
│  ├─ 应到人数: 8 (SF Pro Display Bold 32pt, #2C3E50)
│  ├─ 实到人数: 5 (SF Pro Display Bold 32pt, #10B981)
│  ├─ 守约率: 62.5% (SF Pro Display Bold 32pt, #F59E0B)
│  └─ 人均消费: ¥125 (SF Pro Display Bold 32pt, #2C3E50)
│
├─ Divider (1pt, #E5E7EB)
│
├─ Attendance List
│  ├─ Section "守约英雄 ✓" (SF Pro Text Semibold 15pt, #10B981)
│  ├─ Participant rows with rank badges
│  ├─ Section "爽约名单 ✗" (SF Pro Text Semibold 15pt, #EF4444)
│  └─ Participant rows (rank decreased indicator)
│
└─ Footer
   └─ "DineRank" logo + "记录每一次守约" (SF Pro Text Regular 11pt, #9CA3AF)

Share Button:
- Width: 361pt
- Height: 48pt
- Position: x=16pt, y=619pt
- Background: #FFD700 gradient
- Corner radius: 12pt
- Text: "分享战报" (SF Pro Text Semibold 17pt, #1A1A1A)
- Icon: Share icon 20x20pt
```

---

## 九、组件库

### 按钮系统
```
Primary Button:
- Background: #2C3E50
- Text: White, SF Pro Text Semibold 17pt
- Height: 48pt
- Corner radius: 12pt
- Active: opacity 0.8

Secondary Button:
- Background: transparent
- Border: 1pt solid #2C3E50
- Text: #2C3E50, SF Pro Text Semibold 17pt
- Height: 48pt
- Corner radius: 12pt

Achievement Button:
- Background: #FFD700 gradient
- Text: #1A1A1A, SF Pro Text Semibold 17pt
- Height: 48pt
- Corner radius: 12pt
- 仅用于段位页分享

FAB:
- Size: 56x56pt
- Background: #2C3E50
- Icon: White "+" 24x24pt
- Corner radius: 28pt
- Shadow: Elevated
- Position: fixed, bottom-right (16pt margin)
```

### 段位徽章
```
Large Badge (个人页):
- Size: 120x120pt
- Outer ring: 8pt stroke, rank color gradient
- Inner circle: 104x104pt, White fill
- Icon: 64x64pt emoji
- Glow: rank color 40%
- Animation: scale 0.8→1.0, 0.5s

Medium Badge (列表):
- Size: 40x40pt
- Outer ring: 3pt stroke, rank color
- Icon: 24x24pt emoji

Mini Badge (角标):
- Size: 24x24pt
- Background: rank color
- Icon: 16x16pt emoji
```

### 进度条
```
Horizontal Progress:
- Track: height 4pt, #E5E7EB, radius 2pt
- Fill: height 4pt, #2C3E50, radius 2pt
- Animation: width transition 0.3s ease

Circular Progress (段位):
- Size: 136x136pt
- Stroke: 10pt, rank color
- Track: #E5E7EB
- Cap: round
- Rotation: -90deg (start from top)
```

### 状态标签
```
Badge:
- Height: 24pt
- Padding: 4pt 8pt
- Corner radius: 8pt
- Font: SF Pro Text Medium 13pt

States:
- Voting: #F59E0B bg, White text, "投票中"
- Confirmed: #10B981 bg, White text, "已确定"
- Completed: #6B7280 bg, White text, "已结束"
- Cancelled: #EF4444 bg, White text, "已取消"
```

---

## 十、交互规范

### 动画时长
```
Fast: 0.2s - 按钮点击、开关切换
Normal: 0.3s - 页面元素淡入、卡片展开
Slow: 0.5s - 页面转场、模态框弹出
```

### 缓动函数
```
Ease Out: 元素进入
Ease In: 元素退出
Ease In Out: 状态变化
Spring: 游戏化元素（段位徽章、成就动画）
```

### 触觉反馈
```
Light: 按钮点击、开关切换
Medium: 选择时间、添加参与者、开启位置共享
Heavy: 提交投票、创建约饭成功
Success: 升级段位、完成成就、自动签到
Warning: 即将爽约提醒
Error: 操作失败
```

### 页面转场
```
Push: 进入详情页、进入位置共享页
Modal: 创建约饭、选择餐厅地图
Sheet: 时间选择器、设置面板
Fade: Tab切换
```

### 位置更新动画
```
Participant Annotation Update:
- Animation: Scale 0.8→1.0 + Fade in
- Duration: 0.3s
- Easing: Ease out

Distance Label Update:
- Animation: Number counter with fade
- Duration: 0.5s
- Trigger: Every 5 seconds when location updates

Arrival Notification:
- Animation: Slide down from top + Spring bounce
- Duration: 0.5s
- Auto dismiss: 3s with fade out
```

---

## 十一、设计检查清单

### 视觉一致性
- [ ] 所有尺寸符合8pt网格
- [ ] 圆角使用规范值（4/8/12/16pt）
- [ ] 阴影统一使用规范值
- [ ] 色彩仅使用色彩系统中的颜色
- [ ] 字体大小符合规范（13/15/17/20/24/28/34/72pt）

### 可用性
- [ ] 按钮最小尺寸44x44pt
- [ ] 文字对比度符合WCAG AA标准
- [ ] 状态用色块+文字双重标识
- [ ] 操作反馈明确（视觉+触觉）

### 品牌一致性
- [ ] 工具感强，不误导为社交App
- [ ] 段位系统视觉冲击力强
- [ ] 战绩卡片可炫耀、易分享
- [ ] 与竞品有明显差异

---

## 十二、总结

### 核心设计理念
**"可靠的工具 + 可炫耀的成就"**

### 关键设计决策

1. **双重视觉语言**
   - 工具页面：中性色 + 克制设计 = 专业可靠
   - 成就页面：段位色 + 游戏化 = 视觉冲击

2. **色彩克制**
   - 主色调用海军蓝#2C3E50，不是暖橙色
   - 段位色仅在相关页面使用
   - 避免色彩打架和视觉疲劳

3. **强化游戏化**
   - 段位徽章120pt，带发光效果
   - 战绩卡片设计为核心增长引擎
   - 进度可视化（进度条、进度环）

4. **位置共享体验**
   - 地图原生MapKit，流畅无缝
   - 实时距离显示，降低等待焦虑
   - 自动签到，减少操作摩擦
   - 隐私优先，默认关闭位置共享

5. **精确规范**
   - 所有尺寸基于8pt网格
   - 间距、圆角、阴影完全标准化
   - 便于开发实现和设计一致性

### 与竞品的差异化

- **Splitwise/AA记账**：纯工具，无游戏化 → 我们有段位系统
- **Doodle/投票工具**：纯功能，无留存 → 我们有成就激励
- **DeerMeet/陌生人社交**：暖色调约会风 → 我们是专业协作风
- **飞书/企业协作**：过于严肃 → 我们有游戏化点缀
- **传统约饭工具**：无位置共享 → 我们实时显示距离，降低等待焦虑

**一句话总结：实用工具 + 轻量游戏化 = 高留存 + 自传播。用克制的设计包裹段位系统，用位置共享解决等待焦虑，打造专业但有成就感的约饭协同工具。**
