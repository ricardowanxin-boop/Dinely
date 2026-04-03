# 食否 App Icon - Figma制作步骤

## 方案A：极简几何风格（推荐）

### 1. 创建画布
```
Frame: 1024 x 1024px
Name: "食否-Icon-方案A"
```

### 2. 背景
```
- 选中Frame
- Fill: #2C3E50 (深海军蓝)
```

### 3. 三个圆点（象征多人）
```
第一个圆点:
- 工具: Ellipse (O)
- 尺寸: 180 x 180px
- Fill: #FFD700 (金色)
- 位置: X=422, Y=340

第二个圆点:
- 复制第一个圆点
- 位置: X=272, Y=540

第三个圆点:
- 复制第一个圆点
- 位置: X=572, Y=540

形成等边三角形排列
```

### 4. 底部横线（象征餐桌）
```
- 工具: Rectangle (R)
- 尺寸: 600 x 40px
- Fill: #FFD700 (金色)
- 位置: X=212, Y=700 (居中)
- Corner radius: 20px
```

### 5. 导出
```
- 选中Frame
- Export settings:
  - Format: PNG
  - Scale: 1x, 2x, 3x
  - iOS App Icon sizes: 1024x1024
```

---

## 方案B：文字图形化

### 1. 创建画布
```
Frame: 1024 x 1024px
Name: "食否-Icon-方案B"
```

### 2. 背景
```
- Fill: #2C3E50
```

### 3. 顶部装饰线
```
- Rectangle: 500 x 20px
- Fill: #FFD700
- 位置: X=262, Y=250 (居中)
- Corner radius: 10px
```

### 4. "食否"文字
```
- 工具: Text (T)
- 内容: "食否"
- 字体: Source Han Sans CN Heavy (思源黑体)
  - 如果没有，用 Noto Sans SC Bold
- 字号: 400px
- 颜色: #FFFFFF
- 字间距: 80 (Letter spacing)
- 位置: 居中对齐
- 垂直位置: Y=312 (视觉居中)
```

### 5. 导出
```
同方案A
```

---

## 方案C：圆桌俯视图

### 1. 创建画布
```
Frame: 1024 x 1024px
Name: "食否-Icon-方案C"
```

### 2. 背景
```
- Fill: #2C3E50
```

### 3. 圆形餐桌
```
- 工具: Ellipse (O)
- 尺寸: 600 x 600px
- Fill: 无
- Stroke: #FFD700, 60px
- 位置: X=212, Y=212 (居中)
```

### 4. 四个座位点
```
座位1 (上):
- Ellipse: 100 x 100px
- Fill: #FFFFFF
- 位置: X=462, Y=152

座位2 (右):
- 位置: X=762, Y=462

座位3 (下):
- 位置: X=462, Y=772

座位4 (左):
- 位置: X=162, Y=462

均匀分布在圆周上
```

### 5. 导出
```
同方案A
```

---

## 快速技巧

### 精确居中对齐
```
1. 选中所有元素
2. 右侧面板 → Align
3. 点击 "Horizontal centers" 和 "Vertical centers"
```

### 批量导出iOS所需尺寸
```
Export settings:
- 1024x1024 (App Store)
- 180x180 (iPhone App iOS 14+)
- 120x120 (iPhone App iOS 7-13)
- 167x167 (iPad Pro)
```

### 颜色变量设置
```
在 Local styles 中创建:
- Primary/Navy: #2C3E50
- Accent/Gold: #FFD700
- Text/White: #FFFFFF

方便后续调整
```

---

## 推荐方案A的理由

1. **极简克制** - 符合"食否"高级定位
2. **抽象表达** - 不幼稚，适合90后
3. **识别度高** - 三角形构图稳定，金色醒目
4. **可扩展** - 圆点数量可调整（3人/4人/5人）

制作时间：约5分钟
