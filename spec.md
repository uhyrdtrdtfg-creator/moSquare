# 墨方 MoSquare · 技术规格书 (Spec for AI Coding)

> 本文档用于直接喂给 AI（Claude / GPT / Cursor 等）作为实现指令。
> 每一节都有明确的输入输出、数据结构与验收标准。
> 产品定位：**面向零基础用户的练字 + 趣味游戏 App**。

---

## 0. 项目一览

| 项 | 值 |
|---|---|
| 产品名 | 墨方 MoSquare |
| 核心用户 | 零基础练字者（小学生、家长辅助、成年自学） |
| 核心价值 | 从握笔到成字的完整引导 · AI 笔迹评分 · 轻度游戏化 |
| 目标平台 | iOS / iPadOS / Android（一份代码） |
| 技术栈 | Flutter 3 + Dart · Node.js (NestJS) + PostgreSQL + Redis |
| MVP 范围 | L0-L2 学习路径 + 3 款小游戏 + 单机可用 |

---

## 1. 总体架构

```
┌───────────────────────────────────────────┐
│  Flutter 客户端 (iOS / Android)            │
│  ┌──────────┐  ┌────────────┐  ┌────────┐ │
│  │ 画布引擎 │  │ 学习路径   │  │ 游戏模块│ │
│  │ (Canvas) │  │  Engine    │  │         │ │
│  └────┬─────┘  └─────┬──────┘  └────┬────┘ │
│       │              │              │      │
│  ┌────┴──────────────┴──────────────┴────┐ │
│  │   端侧评分引擎 ScoringEngine (Dart)   │ │
│  └───────────────────────────────────────┘ │
│       │                                    │
│  ┌────┴────┐      ┌──────────────┐         │
│  │ SQLite  │      │ Riverpod 状态│         │
│  │ (本地)  │      └──────────────┘         │
│  └─────────┘                               │
└───────┬───────────────────────────────────┘
        │ HTTPS (optional, 离线优先)
        ▼
┌───────────────────────────────────────────┐
│  后端 NestJS                               │
│  - /auth  /characters  /attempts          │
│  - /mastery  /games  /leaderboard         │
│  - 云端深度评分(可选升级)                  │
│  PostgreSQL · Redis · 对象存储             │
└───────────────────────────────────────────┘
```

**离线优先**：MVP 阶段所有核心功能（写字、评分、游戏）必须可在**无网络**下完成，仅账号同步需要网络。

---

## 2. 数据模型

### 2.1 客户端本地数据库（SQLite via drift）

```sql
-- 用户(本地)
CREATE TABLE user_local (
  id TEXT PRIMARY KEY,                   -- uuid
  nickname TEXT NOT NULL DEFAULT '新同学',
  avatar_key TEXT DEFAULT 'default',
  current_level INTEGER NOT NULL DEFAULT 0,     -- 0..6
  current_stage_id TEXT,                         -- 当前关卡
  streak_days INTEGER NOT NULL DEFAULT 0,
  last_practice_at INTEGER,                      -- unix seconds
  onboarded INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

-- 字形库(内置,随 App 分发)
CREATE TABLE characters (
  id TEXT PRIMARY KEY,          -- "stroke:horizontal" / "radical:水" / "char:永"
  type TEXT NOT NULL,           -- "stroke" | "radical" | "char"
  glyph TEXT,                   -- 对应字符
  level INTEGER NOT NULL,       -- 0..6 属于哪一级
  structure TEXT,               -- "left-right" | "top-bottom" | "enclose" ... | null
  strokes_json TEXT NOT NULL,   -- 标准笔顺 SVG 路径数组
  std_bbox_json TEXT NOT NULL,  -- 标准占格信息
  tips_json TEXT                -- 书写要点(文字/图像key)
);

-- 尝试记录
CREATE TABLE attempts (
  id TEXT PRIMARY KEY,
  char_id TEXT NOT NULL,
  mode TEXT NOT NULL,           -- "trace" | "copy" | "blank" | "game"
  strokes_blob TEXT NOT NULL,   -- 用户笔迹 JSON 序列化
  score_shape INTEGER,
  score_order INTEGER,
  score_fluency INTEGER,
  score_layout INTEGER,
  score_total INTEGER,
  duration_ms INTEGER,
  created_at INTEGER NOT NULL,
  FOREIGN KEY(char_id) REFERENCES characters(id)
);

-- 掌握度(间隔重复)
CREATE TABLE mastery (
  char_id TEXT PRIMARY KEY,
  level INTEGER NOT NULL DEFAULT 0,     -- 0..5 Leitner 盒子
  ease REAL NOT NULL DEFAULT 2.5,
  next_review_at INTEGER NOT NULL,
  last_score INTEGER
);

-- 成就与打卡
CREATE TABLE achievements (
  key TEXT PRIMARY KEY,
  unlocked_at INTEGER
);
CREATE TABLE daily_checkins (
  date_key TEXT PRIMARY KEY,    -- "2026-04-17"
  minutes INTEGER NOT NULL DEFAULT 0,
  chars_done INTEGER NOT NULL DEFAULT 0
);

-- 游戏战绩
CREATE TABLE game_runs (
  id TEXT PRIMARY KEY,
  game_type TEXT NOT NULL,      -- "match3"/"bosh"/"speed"/...
  score INTEGER NOT NULL,
  duration_ms INTEGER,
  meta_json TEXT,
  created_at INTEGER NOT NULL
);
```

### 2.2 笔迹数据结构（核心）

```dart
class Stroke {
  final List<StrokePoint> points; // 以时间为轴的点序列
  final int startMs;
  final int endMs;
  Stroke({required this.points, required this.startMs, required this.endMs});
}

class StrokePoint {
  final double x;         // 相对画布 0-1
  final double y;         // 相对画布 0-1
  final double pressure;  // 0-1，无压感时按速度反推
  final int tMs;          // 自笔画开始的毫秒
}

// 序列化时转 JSON，作为 attempts.strokes_blob 存储
```

### 2.3 标准字形数据格式（随 App 内置的 `assets/chars/*.json`）

```json
{
  "id": "char:永",
  "type": "char",
  "glyph": "永",
  "level": 3,
  "structure": "single",
  "strokes": [
    { "svg_path": "M 0.48 0.12 L 0.52 0.20", "direction": "dot" },
    { "svg_path": "M 0.30 0.35 L 0.70 0.35", "direction": "horizontal" }
  ],
  "std_bbox": { "cx": 0.5, "cy": 0.5, "w": 0.8, "h": 0.85 },
  "tips": [
    "永字八法是书法入门经典",
    "点要饱满、有力，位于米字格上半中心"
  ]
}
```

---

## 3. 画布引擎 CanvasEngine（最重要模块）

### 3.1 接口

```dart
class CanvasController {
  Stream<Stroke> onStrokeEnd;              // 一笔写完触发
  ValueNotifier<List<Stroke>> strokes;     // 当前所有笔画
  CanvasGrid grid;                         // 米字 / 田字 / 九宫 / 空白
  CanvasTheme theme;                       // 宣纸 / 仿古 / 毛边
  InkStyle ink;                            // 徽墨黑 / 朱砂 / 松烟

  void clear();
  void undoStroke();
  Uint8List exportPng({int size = 1024});
  String exportStrokesJson();
  void replayAt(double speed);             // 回放自己的笔迹
  void showStandardOverlay(CharacterDef c); // 描红底纹
}
```

### 3.2 绘制要求（验收标准）

1. 触控到渲染延迟 **≤ 16ms**（iPhone 12 及以上设备可达 8ms）
2. 笔画样条使用 **Catmull-Rom → 三阶贝塞尔** 平滑，采样间隔 ≤ 4ms
3. 支持 Apple Pencil 的 `pressure / altitudeAngle / azimuthAngle`
4. 无压感设备使用速度反推压感：`pressure = clamp(1 - speed/SPEED_MAX, 0.2, 1.0)`
5. 笔尖效果：毛笔（圆头变径）、硬笔（恒定宽度 ± 10%）
6. 画布尺寸必须始终 **正方形**，响应式缩放到父容器
7. 零基础模式下自动启用 **大格子**（比默认大 30%）

### 3.3 米字格绘制

```
正方形画布：
- 外边框 1.5px
- 十字中线 1px
- 对角虚线 (dashed 4,4) 0.5px
- 颜色：墨主题 rgba(192,57,43,.5)
- 所有辅助线可在 settings 关闭
```

---

## 4. 端侧评分引擎 ScoringEngine

### 4.1 总体公式

```dart
int scoreTotal(UserGlyph user, StandardGlyph std) {
  final shape   = shapeSimilarity(user, std);       // 0-100
  final order   = strokeOrderMatch(user, std);      // 0-100
  final fluency = strokeFluency(user);              // 0-100
  final layout  = layoutAccuracy(user, std);        // 0-100
  return (0.45 * shape + 0.20 * order + 0.20 * fluency + 0.15 * layout).round();
}
```

### 4.2 各维度算法

#### 4.2.1 shapeSimilarity（形）

```
1. 将 user / std 字形栅格化成 128x128 灰度图
2. 先做 Procrustes 对齐（平移 + 缩放到相同 bbox）
3. 计算 IoU + 像素距离：
   iou = |user ∩ std| / |user ∪ std|
   chamfer = 平均最近邻距离（归一化）
4. score = clamp( 100 * (0.7*iou + 0.3*(1-chamfer)), 0, 100 )
```

#### 4.2.2 strokeOrderMatch（顺）

```
1. 对 user 的每一笔提取特征向量 (起点, 终点, 方向角, 长度)
2. 与 std 笔画序列做 DTW 匹配
3. 统计匹配错位数 e，笔画总数 n
4. score = clamp(100 - e/n * 100, 0, 100)
5. 多/少笔画的惩罚：|user.len - std.len| * 15 分
```

#### 4.2.3 strokeFluency（势）

```
1. 对每一笔：计算速度序列的变异系数 cv = std/mean
2. 起笔、收笔的速度应接近 0（加分）
3. 停顿检测：若某一笔中间停顿 > 500ms 扣分
4. score = clamp(100 - 80*cv_avg - 20*stall_ratio, 0, 100)
```

#### 4.2.4 layoutAccuracy（距）

```
1. 计算 user bbox 与 std_bbox 中心偏差 Δcx, Δcy
2. 计算尺寸偏差 Δw, Δh
3. score = 100 - (|Δcx| + |Δcy|) * 150 - (|Δw| + |Δh|) * 100
```

### 4.3 可执行反馈（比分数更重要）

```dart
class Feedback {
  final int totalScore;
  final List<Issue> issues;   // 最多 3 条
  final String encouragement; // 一句鼓励话
}

class Issue {
  final IssueType type;   // strokeOrder / tooShort / offCenter / tooFast / missStroke
  final String message;   // "横太短了，试着写到格子的 60%"
  final int? strokeIndex; // 高亮哪一笔
}
```

**话术模板库**（零基础温和风格）：

| 情况 | 输出 |
|---|---|
| 写得好 | "这一笔的力度刚刚好，继续～" |
| 笔顺错 | "记得先写上面的横，再写下面的竖哦" |
| 字偏左 | "字往右挪一点，米字格中间会更舒服" |
| 太快 | "慢一点，毛笔喜欢稳稳的呼吸" |
| 缺笔 | "好像少写了一画，我们再来一次？" |

---

## 5. 学习路径 Engine（零基础核心）

### 5.1 路径数据结构（内置 `assets/curriculum.json`）

```json
{
  "levels": [
    {
      "id": "L0",
      "title": "开蒙",
      "description": "学会握笔，感受墨迹",
      "stages": [
        { "id": "L0-1", "title": "握笔姿势", "type": "video", "asset": "v/hold_pen.mp4" },
        { "id": "L0-2", "title": "横向拖动", "type": "drag_test" },
        { "id": "L0-3", "title": "纵向拖动", "type": "drag_test" }
      ]
    },
    {
      "id": "L1",
      "title": "八画",
      "description": "掌握 8 种基本笔画",
      "stages": [
        { "id": "L1-1", "title": "横", "type": "stroke",  "char_id": "stroke:horizontal" },
        { "id": "L1-2", "title": "竖", "type": "stroke",  "char_id": "stroke:vertical" },
        { "id": "L1-3", "title": "撇", "type": "stroke",  "char_id": "stroke:pie" },
        { "id": "L1-4", "title": "捺", "type": "stroke",  "char_id": "stroke:na" },
        { "id": "L1-5", "title": "点", "type": "stroke",  "char_id": "stroke:dot" },
        { "id": "L1-6", "title": "提", "type": "stroke",  "char_id": "stroke:ti" },
        { "id": "L1-7", "title": "折", "type": "stroke",  "char_id": "stroke:zhe" },
        { "id": "L1-8", "title": "钩", "type": "stroke",  "char_id": "stroke:gou" }
      ]
    },
    {
      "id": "L2",
      "title": "偏旁",
      "stages": ["radical:水", "radical:人(亻)", "radical:言(讠)", "radical:手(扌)", "..."]
    },
    { "id": "L3", "title": "独体字", "stages": ["char:人", "char:口", "char:日", "..."] },
    { "id": "L4", "title": "结构",   "stages": ["struct:left-right", "struct:top-bottom", "..."] },
    { "id": "L5", "title": "成字",   "stages": ["grade:1", "grade:2", "grade:3", "..."] },
    { "id": "L6", "title": "成篇",   "stages": ["poem:静夜思", "..."] }
  ]
}
```

### 5.2 通关规则

```dart
bool isStagePassed(StageRun run) {
  switch (run.stage.type) {
    case 'video':    return run.videoWatched;
    case 'drag_test': return run.dragCount >= 5;
    case 'stroke':
    case 'radical':
    case 'char':
      // 连续 3 次评分 ≥ 85 即通关
      return run.recentScores.length >= 3
          && run.recentScores.take(3).every((s) => s >= 85);
  }
}
```

### 5.3 三阶段训练（每关必须走完）

1. **观（Watch）**：2–3 秒标准字笔顺动画，可点"慢速重播"
2. **描（Trace）**：灰色底纹覆写，允许偏差 20px，**不评分**只看笔顺
3. **临（Copy）**：旁边有范字，米字格里独立写，**开始评分**
4. **背（Blank）**：空白米字格，评分更严格（+5 扣分）

首次进入某关默认走完观+描+临，连续 3 次通过"临"才解锁"背"。

### 5.4 间隔重复（Mastery）

使用简化版 SM-2 算法：

```
after each practice:
  q = score / 20  // 0-5
  if q < 3: box = 0, next = now + 10min
  else:
    box = min(box + 1, 5)
    ease = max(1.3, ease + (0.1 - (5-q)*(0.08 + (5-q)*0.02)))
    next_interval = {1d, 2d, 4d, 7d, 14d, 30d}[box]
    next_review_at = now + next_interval
```

主页"今日复习"从 `mastery` 中拉 `next_review_at <= now` 的字。

---

## 6. 游戏模块（MVP 3 款）

所有游戏共享一个接口：

```dart
abstract class MiniGame {
  String get id;
  String get title;
  Duration get estimatedDuration;
  Widget build(BuildContext ctx, GameSession session);
  Future<GameResult> onFinish();
}
```

### 6.1 速写达人 SpeedWriter（首先实现，最简单）

```
配置：
- 时长 60 秒
- 给定 10 个字（从用户掌握度池中抽，保证他会）
- 每写完一个字评分：≥70 得 1 分；≥85 得 2 分；≥95 得 3 分
- 连续 3 个 ≥85 触发 "连击" x1.5 加成
- 结束展示：总得分 + 最好作品 + 最薄弱笔画

数据:
game_runs.meta_json = {
  chars: ["人","口","日",...],
  per_char: [{char, score, duration_ms}...],
  combo: 3
}
```

### 6.2 笔顺警察 StrokeCop

```
玩法：
- 屏幕播放一个字的笔顺动画，有 50% 概率顺序错乱
- 选项：✓ 正确 / ✗ 有错 / 🎯 指出第几笔错
- 10 题，每题 10 秒限时
- 每答对一题 10 分，指出正确错误位置 +5 分

字库：常见易错字表（如 "必、万、我、成、及、火" 等）
```

### 6.3 部首拼图 RadicalPuzzle（零基础友好）

```
玩法：
- 给一个米字格 + 目标字图片
- 下方 4-6 个偏旁/部件碎片
- 拖拽 + 旋转/缩放放入格子
- 位置误差 < 10%、尺寸误差 < 15% 算对
- 10 关一局，难度渐进（从"明 = 日+月"到"德"）

用途：建立"字是拼起来的"这个直觉，非常适合 L2-L4
```

### 6.4 后续游戏（P2/P3 实现，接口预留）

match3 · bossBattle · typoDetective · evolution · duel · poemQuest · zenWrite

---

## 7. UI / UX 规格

### 7.1 信息架构

```
[首次打开] → Onboarding (L0 开蒙)
     │
     ▼
[主页 Home] ─┬─ 今日学习 (next stage)
             ├─ 今日复习 (mastery due)
             ├─ 小游戏 (3 款卡片)
             └─ 书房 (个人主页)
                  ├─ 作品墙
                  ├─ 勋章
                  └─ 段位
```

### 7.2 主要页面

| 页面 | 路由 | 关键组件 |
|---|---|---|
| Onboarding | `/onboard` | 全屏动画、握笔视频、首笔写字 |
| Home | `/home` | 今日学习大卡片 + 游戏横滑 + 连签日历 |
| Practice | `/practice/:stageId` | 画布、范字、笔顺按钮、评分弹窗 |
| Game | `/game/:type` | 因游戏而异 |
| Study Room | `/room` | 作品展示、勋章、段位、设置 |
| Report | `/report/weekly` | 家长报告（PDF 导出） |

### 7.3 设计语言

- 主色：墨黑 `#1a1a1a` · 宣纸 `#faf7f0` · 朱砂 `#c0392b` · 深青 `#2c3e50`
- 字体：PingFang SC（正文）· Noto Serif SC（标题）· STKaiti（字帖范字）
- 圆角：`6px` 小组件 · `16px` 大卡片
- 阴影：柔和、低对比；不用 Material 重投影
- 动画：慢速淡入、无弹跳；尊重用户专注

### 7.4 无障碍

- 所有交互元素 hit area ≥ 44×44
- 颜色不单独承载信息（朱砂红同时伴随"错"字/震动）
- 支持系统字号放大
- 毛笔音效可关闭（耳机场景）

---

## 8. 状态管理 & 导航

- 状态：**Riverpod 2.x**（`StateNotifierProvider` / `AsyncNotifier`）
- 路由：**go_router**
- 持久化：**drift**（SQLite）+ **shared_preferences**（轻量偏好）
- 依赖注入：Riverpod 自身 + `get_it`（仅用于 Platform Channel 级别）

---

## 9. 文件结构（推荐）

```
lib/
  main.dart
  app.dart
  router.dart
  theme/
    colors.dart  typography.dart  theme.dart
  data/
    db/  drift_database.dart  dao/
    repo/  character_repo.dart  attempt_repo.dart  mastery_repo.dart
    models/
  features/
    onboarding/   (L0 三步引导)
    home/
    practice/
      canvas/     canvas_controller.dart  canvas_widget.dart  grid_painter.dart
      scoring/    scoring_engine.dart  shape.dart  order.dart  fluency.dart  layout.dart
      feedback/   feedback_sheet.dart  message_builder.dart
    curriculum/   curriculum_engine.dart  stage_page.dart
    games/
      shared/     mini_game.dart  game_session.dart
      speed_writer/  stroke_cop/  radical_puzzle/
    room/         作品墙、勋章、段位
    report/       weekly_report_pdf.dart
  shared/
    widgets/      primary_button.dart  ink_audio.dart  rice_grid.dart
    utils/        math_utils.dart  stroke_utils.dart
assets/
  chars/         # 字形 JSON
  audio/         # 毛笔音、磨墨音、木鱼音
  video/         # 握笔教学
  fonts/
  curriculum.json
```

---

## 10. API（P2 云端，MVP 可全跳过）

```
POST /auth/anon            → 匿名账号
POST /auth/login           → 手机号 + 验证码
GET  /me                   → 用户信息

GET  /characters?level=2   → 字形库增量同步
POST /attempts             → 上传练习记录 (可批量)
GET  /mastery              → 掌握度同步

GET  /games/leaderboard?type=speed&range=week
POST /games/runs           → 上传战绩

POST /scoring/deep         → body: {strokes, char_id} → 云端深度评分(P3)

GET  /report/weekly        → 家长周报(HTML/PDF)
```

所有请求 Bearer Token · 所有写操作幂等（`Idempotency-Key` 头）。

---

## 11. 非功能需求

| 项 | 指标 |
|---|---|
| 冷启动 | < 2s（首次 < 4s） |
| 画布 FPS | ≥ 60（iPad Pro ≥ 120） |
| 离线可用 | MVP 100% 功能离线可用 |
| 包体 | < 60MB（不含高清视频），视频按需下载 |
| 崩溃率 | < 0.1% |
| 电池 | 30min 画布持续使用 ≤ 8% 电量（iPhone 13） |

---

## 12. MVP 交付清单（4 周可完成）

**Week 1 · 画布 + 字库**
- [ ] Flutter 项目骨架，Riverpod + go_router + drift
- [ ] 画布引擎基本版：绘制、撤销、清除、米字格
- [ ] 内置 8 个基本笔画 + 20 个高频字的字形 JSON
- [ ] 观/描/临 三阶段页面

**Week 2 · 评分 + 学习路径**
- [ ] ScoringEngine 四维度基础版
- [ ] Feedback 话术库 + 弹窗 UI
- [ ] Curriculum Engine + L0/L1 全部内容
- [ ] 连签、主页卡片

**Week 3 · 游戏 + 养成**
- [ ] 速写达人、笔顺警察、部首拼图三款
- [ ] 勋章 / 段位 / 作品墙雏形
- [ ] 设置、主题（墨黑/朱砂两套）

**Week 4 · 抛光 + 打包**
- [ ] Onboarding 动画 + 握笔视频
- [ ] 音效、震动反馈
- [ ] 性能打磨到目标帧率
- [ ] iOS TestFlight / Android 内测包

---

## 13. 给 AI 的编码指令（贴进 Cursor / Claude Code 即用）

> 你是一名资深 Flutter 工程师。请基于 `spec.md`（本文件）实现「墨方」练字 App。约束：
>
> 1. 严格遵守文件结构与命名规范，不随意增加顶层目录。
> 2. 先跑通 `lib/features/practice/canvas` 模块并在 `example/` 写一个独立 demo 页，展示画布 + 米字格 + 清除/撤销。
> 3. 所有核心类要有单元测试（`test/` 目录），评分引擎测试覆盖率 ≥ 70%。
> 4. 评分公式完全按 §4.2 实现，不要"自由发挥"。
> 5. 零基础相关 UI（L0 引导、大格子、温和话术）按 §5 / §7 执行。
> 6. 遇到数据结构冲突以本文件 §2 为准。
> 7. 提交前运行 `flutter analyze` 零警告。
> 8. 每完成一个模块输出：【模块名】【核心文件列表】【如何验证】，不要大段解释。

---

## 14. 开放问题（需要产品/设计敲定）

1. L0 握笔姿势检测是否真实做 ML，还是只播视频 + 用户自认？（MVP 建议后者）
2. 字体版权：范字是否使用思源宋体 / 叶根友 / 自研？
3. 是否做"毛笔"音效（可能惊到办公室用户，默认关闭？）
4. 家长报告 PDF 渲染走客户端还是服务端？
5. 小游戏是否支持离线排行榜（本地最高分）？建议 MVP 是。

---

**文档版本**：v1.0 · 2026-04-17 · 零基础主线  
**配套文件**：`insight.html`（产品洞察）· `prototype.html`（可跑体感 Demo）
