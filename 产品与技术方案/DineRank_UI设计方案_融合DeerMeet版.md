# DineRank UI设计方案 - 融合DeerMeet版

> 基于DeerMeet的视觉优点 + 飞书的协作清晰度 + 微信读书的成就系统

---

## 一、DeerMeet设计分析

### ✅ 值得借鉴的优点

1. **暖色调氛围**
   - 红棕色(#8B4513) + 橙黄渐变(#FF8C42)
   - 营造"美食+温暖聚会"的情感联结
   - 比冷色调更有食欲和社交感

2. **大卡片视觉冲击**
   - 图片+信息叠加的设计吸引注意力
   - 适合"展示重点内容"的场景

3. **圆形主操作按钮**
   - 中间大红色圆形按钮，操作明确
   - 符合"快速发起"的心智模型

4. **简洁顶部导航**
   - 不过度设计，保持克制

### ❌ 不适合DineRank的部分

1. **过于社交化** - 大头像展示适合陌生人，不适合熟人工具
2. **信息密度低** - 一屏一人效率低，需要列表视图
3. **娱乐化过重** - 约会风格不适合团队/朋友聚餐

---

## 二、融合设计策略

### 核心定位
**"有温度的协作工具"**
- 工具属性：飞书的清晰高效（70%）
- 情感温度：DeerMeet的暖色调（20%）
- 成就激励：微信读书的游戏化（10%）

### 视觉风格关键词
- 温暖但不浮夸
- 清晰但不冰冷
- 有趣但不幼稚
- 专业但不严肃

---

## 三、完整UI设计提示词

### 3.1 APP图标设计（融合版）

```
Design an iOS app icon for "DineRank", a warm and efficient group dining coordination tool.

Core concept: Dining + Achievement + Warmth

Visual elements:
- A minimalist bowl or plate silhouette (top view)
- Chopsticks crossed forming an "X" or arranged elegantly
- A subtle rank badge/star integrated into the design
- Geometric simplicity with organic warmth

Color palette (inspired by DeerMeet):
- Primary: Warm terracotta #C1694F (earthy, food-related)
- Accent: Sunset orange #FF8C42 (energy, achievement)
- Highlight: Gold #FFB84D (rank, premium)
- Background: Cream gradient #FFF5E6 to #FFE4C4

Style:
- Flat design with subtle gradient (not too glossy)
- Rounded, friendly shapes
- Recognizable at 60x60px
- iOS design guidelines compliant

Mood: Warm dinner gathering + organized efficiency

Reference style:
- DeerMeet's warm color palette
- Notion's geometric simplicity
- Airbnb's friendly professionalism

Avoid:
- Generic food emojis
- Overly complex illustrations
- Cold tech colors (blue/gray)
- Childish cartoon style

Output: 1024x1024px, ready for iOS export
```

---

### 3.2 整体UI风格系统

```
Design a complete UI system for "DineRank" iOS app - a group dining coordination tool with gamified attendance ranking.

Brand personality: Warm, trustworthy, efficient, achievement-oriented

DESIGN SYSTEM:

1. COLOR PALETTE (inspired by DeerMeet + refined)

Primary colors:
- Terracotta #C1694F (main brand, headers, active states)
- Sunset Orange #FF8C42 (CTA buttons, highlights)
- Warm Cream #FFF5E6 (backgrounds, cards)

Secondary colors:
- Deep Brown #3E2723 (primary text)
- Soft Beige #F5E6D3 (secondary backgrounds)
- Success Green #4CAF50 (attendance confirmed)
- Alert Coral #FF6B6B (no-show warnings)

Rank-specific colors (warmer tones):
- Newcomer: #A8DADC (soft teal)
- Bronze: #CD7F32 (classic bronze)
- Silver: #C0C0C0 (classic silver)
- Gold: #FFD700 (classic gold)
- Platinum: #E5E4E2 (warm platinum)
- Diamond: #B9F2FF (light diamond blue)
- Legend: #DDA0DD (warm purple)

2. TYPOGRAPHY
- Headings: SF Pro Display Semibold (not too heavy)
- Body: SF Pro Text Regular
- Numbers: SF Pro Rounded Medium (for stats)
- Hierarchy: 28pt / 20pt / 17pt / 15pt / 13pt

3. CARD DESIGN (key differentiator)

Event cards:
- Background: White with warm shadow (0 4px 12px rgba(193,105,79,0.08))
- Border radius: 20px (softer than standard 16px)
- Padding: 20px
- Left accent bar: 4px terracotta for active events
- Hover/press: subtle scale (0.98) + deeper shadow

Participant cards:
- Horizontal layout with emoji avatar
- Rank badge on top-right corner (small, 24x24px)
- Warm background gradient based on rank color

Restaurant cards:
- Image with rounded corners (16px)
- Overlay gradient: transparent to rgba(0,0,0,0.3)
- Info on bottom with white text

4. BUTTONS

Primary (inspired by DeerMeet's center button):
- Large circular FAB for "Create Event" (64x64px)
- Terracotta to orange gradient
- Subtle shadow + scale animation on press
- Position: bottom-right floating

Secondary:
- Rounded rectangle (12px radius)
- Sunset orange fill
- Height: 48px
- Bold text, white color

Tertiary:
- Text only, terracotta color
- Underline on press

5. NAVIGATION

Tab bar (3 items):
- Icons: SF Symbols, outlined when inactive
- Active: terracotta fill + label
- Inactive: gray + no label
- Background: white with top border

Top navigation:
- Large title style (iOS native)
- Terracotta color for title
- Minimal, no heavy backgrounds

6. RANK BADGES

Design style:
- Circular badge with rank icon (emoji)
- Outer ring: rank color gradient
- Inner: white background
- Size: 80x80px (profile), 40x40px (list), 24x24px (mini)
- Subtle glow effect (outer-shadow with rank color)

7. DATA VISUALIZATION

Progress rings (like Apple Health):
- Stroke width: 12px
- Rank color gradient
- Animated fill on load
- Center: percentage in SF Pro Rounded

Stats cards:
- 2x2 grid layout
- Each card: icon + number + label
- Warm cream background
- Terracotta icons

8. MICRO-INTERACTIONS

- Rank up: confetti particles (warm colors) + badge scale bounce
- Vote submitted: checkmark with elastic bounce
- Pull to refresh: custom spinner (rotating chopsticks icon)
- Card press: scale 0.98 + shadow increase
- Haptic feedback on all important actions

9. LAYOUT PRINCIPLES

- Generous whitespace (24px margins, 16px between cards)
- Card-based content (not flat lists)
- Bottom sheet modals (iOS native style)
- Sticky headers with blur effect
- Safe area aware

10. EMPTY STATES

- Warm illustrations (hand-drawn style, not 3D)
- Terracotta accent color
- Friendly copy with emoji
- Clear CTA button

REFERENCE APPS FOR SPECIFIC ELEMENTS:
- DeerMeet: Color palette, warmth, main action button
- Lark/Feishu: Event cards, voting interface, collaboration clarity
- WeChat Reading: Achievement page, data visualization, rank display
- Airbnb: Card layouts, image treatment, professional warmth
- Apple Health: Progress rings, stats grid

SCREENS TO DESIGN (priority order):
1. Home (event list with warm cards)
2. Create Event (3-step with progress)
3. Event Detail (voting + participants)
4. My Rank (achievement showcase)
5. Post-Event (attendance + AA)

Design for iOS 17+, light mode first
Use SF Symbols where possible
Maintain 8pt grid system
Warm > Cold, Clear > Fancy, Efficient > Decorative
```

---

### 3.3 关键页面设计（融合版）

#### 首页 - 约饭局列表

```
Design the home screen for DineRank with warm, card-based layout.

Layout:
- Large title "约饭" (terracotta color #C1694F)
- Subtitle: "让每次聚餐都值得期待" (soft brown)
- Event cards in vertical list with generous spacing (16px between)
- Floating circular FAB (bottom-right, 64x64px, terracotta-orange gradient)

Event Card design (inspired by DeerMeet warmth + Feishu clarity):
- White background, 20px rounded corners
- Warm shadow: 0 4px 12px rgba(193,105,79,0.08)
- Left accent bar: 4px terracotta (for active), gold (for confirmed)
- Top section:
  - Event emoji icon (large, 40x40px) + Title (bold, 20pt)
  - Status badge (top-right): pill shape, colored background
- Middle section:
  - Date range with calendar icon
  - Participant count with people icon
  - Mini emoji avatars (overlapping, max 5 visible + "+3")
- Bottom section:
  - Progress indicator: "5/8人已投票" with mini progress bar
  - Right arrow icon (subtle)

Status badges:
- Voting: Orange background, "投票中"
- Confirmed: Green background, "已确定"
- Completed: Gray background, "已结束"

Empty state:
- Warm illustration: table with empty chairs (hand-drawn style)
- Text: "还没有约饭局\n快来发起第一次聚餐吧"
- CTA button below

Visual hierarchy: Cards are hero, FAB is obvious, clean whitespace
Reference: DeerMeet's warmth + Feishu's information density
```

#### 创建约饭局 - 3步流程

```
Design a 3-step event creation flow with warm, guided experience.

Progress indicator (top):
- 3 circles connected by lines
- Active: terracotta filled circle with white number
- Completed: gold filled with checkmark
- Upcoming: cream outline
- Connecting lines: gradient from completed to upcoming

Step 1 - Basic Info:
- Large emoji picker (grid, 6x4, warm background)
- Text field: "给这次聚餐起个名字" (placeholder with emoji)
- Time slot selector:
  - Cards with date + time period
  - Selectable (max 3), terracotta border when selected
  - Add button: dashed border, "+" icon
- Cuisine tags: horizontal scroll, pill-shaped chips
  - Unselected: cream background
  - Selected: terracotta background, white text
- Budget slider: warm gradient track, circular thumb

Step 2 - Restaurant Search (optional):
- Search bar: rounded, warm shadow, map pin icon
- "跳过此步" text button (top-right)
- Results: cards with:
  - Restaurant image (if available) or cuisine emoji
  - Name (bold) + cuisine type
  - Distance + price per person
  - Checkbox (terracotta when selected)
- Max 3 selections indicator at bottom

Step 3 - Ready to Share:
- Large preview card of created event (same style as home)
- Celebration illustration (confetti, warm colors)
- Text: "约饭局已创建！"
- Primary button: "复制链接并分享" (gradient, large)
- Secondary button: "稍后分享" (text only)

Visual style: Warm, encouraging, clear progress
Reference: Airbnb booking flow + DeerMeet's warmth
```

#### 我的段位页 - 成就展示

```
Design a gamified profile page with warm achievement showcase.

Hero section (inspired by WeChat Reading + DeerMeet warmth):
- Gradient background: cream to light terracotta
- Large rank badge (120x120px):
  - Circular with rank icon (emoji)
  - Outer glow effect (rank color)
  - Subtle animation: gentle pulse
- Rank name below badge (bold, 24pt)
- Attendance rate: large number (72pt, SF Pro Rounded) + "守约率"
- Circular progress ring around badge (rank color gradient)

Stats grid (2x2, below hero):
- Each card: warm cream background, rounded 16px
- Icon (terracotta) + Number (bold) + Label
  - Total events: 🍜 icon
  - Current streak: 🔥 icon
  - Longest streak: 🏆 icon
  - Rank progress: ⬆️ icon with progress bar

Achievement section:
- Title: "我的成就" with count badge
- Horizontal scrollable cards:
  - Unlocked: full color, rank icon + title + date
  - Locked: grayscale, lock icon overlay
- Card size: 120x140px, rounded 12px

History timeline:
- Title: "守约记录"
- Vertical timeline with dots:
  - Green dot: attended
  - Red dot: missed
  - Gray dot: pending
- Each entry: date, event name, status icon
- Connecting line: gradient based on status

Share button (bottom):
- "分享我的战绩" 
- Gradient button, full width
- Generates shareable card image

Visual hierarchy: Badge is focal point, stats support, history is detail
Reference: WeChat Reading achievements + Strava profile + DeerMeet warmth
```

#### 约饭局详情页 - 协作中心

```
Design the event detail page with clear collaboration interface.

Header card:
- Warm gradient background (cream to light orange)
- Event emoji (large) + title (bold, 24pt)
- Creator info: small avatar + "由 [name] 发起"
- Status banner: pill shape, colored, with icon
- Share button: top-right, terracotta icon

Time Voting Section:
- Section title: "选择时间" + vote count badge
- Time option cards (vertical stack, 12px spacing):
  - White background, rounded 16px, warm shadow
  - Left: Date (large) + time period
  - Center: Voter emoji avatars (overlapping, max 5 + count)
  - Right: Vote button (outline when not voted, filled when voted)
  - Winning option: gold left border + crown icon
- Real-time update indicator: subtle pulse animation

Restaurant Voting Section:
- Section title: "选择餐厅" + vote count badge
- Restaurant cards (vertical stack):
  - Image or cuisine emoji background
  - Overlay gradient for text readability
  - Name (bold) + cuisine + price
  - Distance with map pin icon
  - Vote count + vote button
  - Winning: gold border + crown

Participants Section:
- Section title: "参与者 (4/8人)"
- Horizontal scrollable:
  - Each: circular emoji avatar (48x48px)
  - Rank badge overlay (top-right, 20x20px)
  - Name below
  - Vote status: checkmark or pending dot
  - Tap to see profile

Bottom Actions (sticky):
- Primary: "确认约饭局" (creator only, gradient button)
- Secondary: "退出约饭局" (text button, coral color)

Visual style: Clear sections, warm colors, real-time feel
Reference: Feishu collaboration + Doodle voting + DeerMeet warmth
```

---

## 四、设计资产清单

### 必须交付

1. **App Icon**
   - 1024x1024px master
   - All iOS sizes exported

2. **7个段位徽章**
   - 每个3个尺寸：80px / 40px / 24px
   - 包含发光效果的版本

3. **核心页面设计**
   - 首页（iPhone 14 Pro: 393x852pt）
   - 创建流程（3个页面）
   - 约饭局详情
   - 我的段位页
   - AA计算器

4. **组件库**
   - Buttons (primary/secondary/tertiary)
   - Cards (event/restaurant/participant)
   - Input fields
   - Progress indicators
   - Status badges

5. **配色方案文档**
   - 完整色板
   - 使用场景说明

### 可选交付

- 空状态插画（3个）
- 引导页设计（3页）
- 动画效果说明
- Dark mode适配

---

## 五、Figma实施步骤

### Step 1: 设置设计系统（30分钟）
```
1. 创建新Figma文件
2. 设置frame: iPhone 14 Pro (393x852pt)
3. 创建color styles:
   - Primary/Terracotta: #C1694F
   - Accent/Orange: #FF8C42
   - Background/Cream: #FFF5E6
   - Text/Brown: #3E2723
   - 7个段位颜色
4. 创建text styles:
   - Heading/28pt/Semibold
   - Title/20pt/Semibold
   - Body/17pt/Regular
   - Caption/15pt/Regular
5. 设置8pt grid
```

### Step 2: 设计App Icon（1小时）
```
1. 使用"APP图标设计提示词"
2. 在Figma创建1024x1024画板
3. 设计3个方案
4. 选择最佳方案细化
5. 导出所有尺寸
```

### Step 3: 设计组件库（2小时）
```
1. Buttons (3种状态: default/pressed/disabled)
2. Cards (event/restaurant/participant)
3. Badges (rank/status)
4. Input fields
5. 设置为components，添加variants
```

### Step 4: 设计核心页面（4小时）
```
按优先级：
1. 首页（1小时）
2. 我的段位页（1小时）
3. 创建流程（1.5小时）
4. 约饭局详情（1.5小时）
```

### Step 5: 原型连接（30分钟）
```
1. 连接主要页面跳转
2. 添加简单交互（按钮点击、页面切换）
3. 测试流程完整性
```

---

## 六、与原方案的核心差异

| 维度 | 原方案 | 融合DeerMeet版 |
|------|--------|---------------|
| 主色调 | 珊瑚橙（偏冷） | 陶土橙（偏暖） |
| 情感定位 | 工具感强 | 温暖+高效平衡 |
| 卡片设计 | 标准圆角 | 更大圆角+暖阴影 |
| 主操作按钮 | 标准矩形 | 圆形FAB（DeerMeet风格） |
| 段位展示 | 简单徽章 | 发光效果+更强视觉 |
| 整体氛围 | 专业克制 | 专业但有温度 |

---

## 七、设计验证清单

### 视觉一致性
- [ ] 所有页面使用统一色板
- [ ] 圆角尺寸一致（20px/16px/12px）
- [ ] 阴影效果统一
- [ ] 间距符合8pt网格

### 可用性
- [ ] 按钮最小尺寸44x44pt
- [ ] 文字对比度符合WCAG AA标准
- [ ] 重要信息不依赖颜色区分
- [ ] 操作反馈明确

### 品牌一致性
- [ ] 暖色调贯穿始终
- [ ] 温暖但不失专业
- [ ] 段位系统视觉突出
- [ ] 与竞品有明显差异

---

## 八、总结

### 核心设计理念
**"温暖的效率工具"** - 让协作不冰冷，让成就有温度

### 关键设计决策
1. **借鉴DeerMeet的暖色调**，但降低娱乐化程度
2. **保持飞书的信息密度**，但增加情感温度
3. **强化段位系统视觉**，用发光效果+渐变提升荣誉感
4. **圆形FAB主按钮**，降低创建门槛

### 与竞品的差异化
- Splitwise：冷色调工具 vs 我们的暖色调
- Doodle：纯功能 vs 我们的游戏化
- DeerMeet：陌生人社交 vs 我们的熟人协作

**一句话总结：用DeerMeet的温暖包裹飞书的效率，打造有温度的约饭协作工具。**
