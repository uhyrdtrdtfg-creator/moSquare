# 墨方 · MoSquare

> 一款好玩的练字 App · 面向零基础小朋友（4-5 岁）和初学者
> iPad · SwiftUI + PencilKit · 纯离线（无网络、无后端）

---

## 快速开始

### 在 iPad 上跑（推荐）
1. 在 iPad 上装 Swift Playgrounds（App Store 免费）
2. 把整个 `墨方.swiftpm/` 文件夹用 AirDrop 发到 iPad
3. Swift Playgrounds 打开 → 右上角 ▶️ 运行
4. 支持 Apple Pencil · 手指书写也可

### 在 Mac 上跑
```bash
open 墨方.swiftpm/Package.swift
```
Xcode 打开后选 iPad 模拟器 → Cmd+R

---

## 体系结构（44 个 Swift 文件 · ~16,600 行）

### 数据层
```
Models/
├─ AppState.swift              ~700 行 · 全局状态（UserDefaults 持久化）
├─ StrokeData.swift            ~540 行 · StrokeSpec / CharacterDef / 笔画路径数学
├─ KidsCharacters.swift        ~480 行 · L0 幼儿第一批字
├─ KidsCharactersExtra.swift   ~990 行 · L0 幼儿扩展字
├─ KidsCharactersPack3.swift         · L0 幼儿第三批（家居/动作/颜色/食物）
├─ Fables.swift                      · 30 篇寓言绘本剧本 + 场景标签
└─ Encouragements.swift         ~60 行 · 60 条鼓励话术
```

### 引擎层
```
Engine/
├─ ScoringEngine.swift         ~250 行 · 形/顺/势/距 四维评分
├─ StrokeMatcher.swift         ~120 行 · 逐笔匹配（跟写模式）
└─ Speaker.swift                ~60 行 · TTS + 系统音效
```

### 画布层
```
Canvas/
└─ InkCanvas.swift             ~470 行 · PencilKit 封装 + 米字格 + 描红底纹
```

### 界面层（成人）
```
Views/
├─ App.swift + RootView.swift  · 入口 + 顶栏 + Tab
├─ OnboardingView.swift        · 身份选择 + 第一笔体验
├─ HomeView.swift       ~920 行 · 首页（双模式分支）
├─ PracticeView.swift   ~600 行 · 练字 Tab（成人八画偏旁 + 幼儿字库）
├─ RoomView.swift              · 书房（段位/勋章/贴纸/设置）
├─ ParentReportView.swift      · 家长周报（含家长锁）
└─ Games/
   ├─ SpeedWriterView.swift    · 速写达人
   ├─ StrokeCopView.swift      · 笔顺警察
   ├─ RadicalPuzzleView.swift  · 部首拼图
   ├─ ZenWriteView.swift       · 静心禅写
   └─ CompositeLearnView.swift · 组字学习
```

### 界面层（幼儿专属）
```
Views/
├─ KidPracticeView.swift ~720 行 · 三幕式练字（预览+逐笔描摹+贴纸奖励）
├─ VirtualPetView.swift ~410 行 · 🐣 虚拟宠物 6 阶段成长
├─ GrowthTreeView.swift ~290 行 · 🌳 成长树 5 阶段
├─ WeeklyMissionView.swift     · 🏅 本周 3 项挑战
├─ CertificateView.swift       · 🎓 毕业证书（卷轴 + 分享）
├─ StoryView.swift             · 📖 30 篇寓言绘本（翻页阅读 · 卡通背景 · 点字听读）
├─ ColorCharView.swift         · 🎨 填色描字
└─ Games/
   ├─ KidListenTapGame.swift   · 🔊 听音找字
   ├─ KidMemoryMatchGame.swift · 🃏 翻翻配对
   ├─ KidBubblePopGame.swift   · 🫧 蹦字泡
   └─ FindCharView.swift       · 🔍 字卡找找看
```

---

## 两种模式

### 🧒 小朋友模式（4-5/6 岁）
首次打开选择"小朋友"即进入，所有界面切为暖色系（橙/红/金）。

**核心路径：**
1. **首页**：今天要练什么 → 4+4 工具格子 → 每日任务 → 小游戏 → 字库
2. **练字**：先看 → 逐笔描摹 → 写完得贴纸
3. **陪伴**：宠物每日喂食 / 树每字长叶 / 周挑战 / 毕业证书
4. **拓展**：故事 / 填色 / 找找看 / 组字 / 听音 / 翻翻配对 / 蹦字泡

**49 个字分级：**
- L0-A 原 19 字：数字 · 人物 · 象形 · 天地
- L0-B 扩展 30 字：数字续 · 自然 · 身体 · 动物 · 方位

### 🙋 成人零基础模式
六级成长体系：
- **L1 八画**：横 竖 撇 捺 点 提 折 钩
- **L2 偏旁**：亻 氵 扌 讠 宀 艹
- **L3-L5**：独体字 / 结构 / 成字（规划中）

**四种练字模式：**
- **跟** 逐笔严格校验（默认）
- **观** 看笔顺动画
- **描** 自由描红
- **临** 独立临摹（半透明参考）
- **背** 空白默写

---

## 家长使用指南

### 进入家长专区
- 小朋友模式首页 → 右下「家长专区 ↓」按钮
- 或书房 → 设置

### 家长锁验证
1. 长按按钮 **2 秒**
2. 答对随机两位数乘法题（如 7 × 8 = ?）

### 家长可以看到
- 本周练字分钟数 / 掌握字 / 贴纸 / 连签
- 近 7 天练字柱状图
- 已掌握字网格 + 最好分
- **薄弱字**（< 70 分，重点提醒）
- 累计数据

### 家长可以设置
- 每日时长限制（10 / 15 / 20 / 30 / 45 分钟）
- 默认 20 分钟；到点后所有练字入口显示温柔弹窗「今天练得够多啦~」

---

## 核心创新

### 🎯 逐笔描摹模式（跟写）
小朋友写完当前笔才会出现下一笔底纹。严格判断：
- 起笔距离 ≤ 0.28（归一化）
- 终笔距离 ≤ 0.28
- 方向向量余弦 ≥ 0.40

写错：画布抖动 + 温和提示 + 自动擦除 + 宽容重试。
**失败 2 次**：自动演示正确写法 + 语音"看老师写一遍"。

### 🎯 四维评分（成人）
```
总分 = 形 45% + 顺 20% + 势 20% + 距 15%
```
封顶机制：位置严重偏移时总分强制 ≤ 55，避免"写错得高分"。

### 🎯 三幕式练字（幼儿）
```
Phase 1 预览 → Phase 2 逐笔描摹 → Phase 3 贴纸奖励
```

### 🎯 成长循环闭环
```
练字 → 喂宠物 → 宠物升级 → 解锁装扮
     → 长树叶   → 树升级     → 视觉奖励
     → 贴纸册   → 填满毕业   → 金色横幅 → 证书可打印
     → 每日任务 → 周挑战     → 徽章奖励
```

### 🎯 30 篇寓言绘本（识字闭环最后一步）
写过的字在绘本里会自动加亮、点一下能听发音。30 篇 4–5 页的寓言小故事：
- 改编经典：守株待兔 · 龟兔赛跑 · 两只小羊 · 乌鸦喝水 · 小马过河 · 井底之鱼 …
- 家常温情：一家人 · 爸爸的手 · 妈妈的心 · 奶奶的花 · 哥哥和妹妹 …
- 自然小诗：日出 · 下雨 · 下雪 · 风吹云 · 月下的小兔 …

每页一张卡通背景（CC0 扁平插画 4 张 + SwiftUI 自绘 6 场景：夜 / 雨 / 雪 / 屋内 / 池塘 / 日出），文字浮在下方卡片里。滑动翻页。

---

## 技术栈

| 层 | 选择 | 理由 |
|---|---|---|
| UI | SwiftUI | iPad 原生最优 |
| 书写 | PencilKit | Apple Pencil 压感原生 |
| TTS | AVSpeechSynthesizer | 完全离线 zh-CN |
| 音效 | AudioServicesPlaySystemSound | 无需资源文件 |
| 存储 | UserDefaults + JSON | 无数据库依赖 |
| 证书导出 | ImageRenderer | iOS 16+ 原生 |
| 网络 | 无 | 完全离线 |

**最低系统版本**：iOS / iPadOS 17.0

---

## 常见问答

**Q: 为什么是 iPad only？**
A: 练字需要大屏、PencilKit 压感、Apple Pencil 体验。iPhone 屏太小写不好字。

**Q: 为什么不联网？**
A: 数据隐私、家长放心、功能无依赖、任何场景可用。

**Q: 数据在哪里？**
A: 全部 UserDefaults。卸载 App 数据清空；iCloud 备份 App 可恢复。

**Q: 评分不准怎么办？**
A: 零基础用户评分刻意"宽容 + 封顶"：85+ 认为掌握。如果需要精确评分，可以在 `Engine/ScoringEngine.swift` 调整四维权重。

**Q: 想加新字？**
A: 
1. 参照 `Models/KidsCharacters.swift` 的格式添加 `CharacterDef` + 笔顺数据
2. 在 `KidsCharactersExtra.groups` 加分组
3. 在 `KidsCharactersExtra.meta` 加拼音/emoji/含义/贴纸
4. 新字会自动出现在所有相关界面

**Q: 想改家长锁密码题？**
A: 编辑 `Views/ParentReportView.swift` 里的 `ParentLockGate.question` 生成逻辑。

---

## 项目状态

- ✅ **44 个 Swift 文件 · ~16,600 行**
- ✅ xcodebuild 验证：**BUILD SUCCEEDED** · 零警告零错误
- ✅ iPad Pro 13-inch (M4) 模拟器验证通过
- ✅ 所有界面交互路径闭环

开发版本 v1.0（2026-04）

---

## 许可与声明

本 app 为教育原型项目。字形数据、笔顺、UI 配图均为独立制作。

### 第三方素材

- 绘本卡通背景图 · `墨方.swiftpm/Resources/backgrounds/scene_*.png`
  - 来源：[Kenney Background Elements](https://kenney.nl/assets/background-elements)
  - 许可：[CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/)（公共领域）
  - 详见 `Resources/backgrounds/LICENSE.txt`
