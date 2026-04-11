# Todo 模块 TDD 实践复盘汇报大纲

## 文档目的

这份文档用于向管理层汇报本次 `todo` 模块开发的实践过程，重点说明三件事：

1. 我们为什么采用 `TDD + UI-first + 小步提交` 的组合策略
2. 这套方法在本次 Flutter/Dart 项目里是如何落地的
3. Flutter 测试机制为什么这样选型，以及它给交付质量带来的价值

---

## 第一部分：复盘汇报大纲

### 1. 项目背景与本次迭代目标

建议汇报内容：

1. 本次迭代的目标不是一次性做完全部功能，而是先完成一个可运行、可验证、可演进的第一阶段 `todo` 产品骨架
2. 当前阶段优先级是 `Flutter Client UI`，后端放在 UI 稳定之后推进
3. 第一阶段优先验证运行面是 `Flutter Web`，第二验证面是 `macOS`
4. 本次实践的核心目标除了交付功能，还包括验证一套可复制的研发方式

建议强调：

`这次不是单纯做一个页面集合，而是在验证一套面向持续交付的工程方法。`

### 2. 为什么采用基于 TDD 的开发方法

建议汇报内容：

1. TDD 的核心不是“多写测试”，而是用测试把需求提前转化为可验证行为
2. 先写失败测试，再写最小实现，再做重构，可以降低返工和失控开发的风险
3. 对于需求还在收敛中的产品，TDD 可以帮助团队更早发现理解偏差
4. 对于 UI 和后端并行演进的系统，TDD 可以形成稳定的回归保护

建议强调：

`测试在这套方法里不是验收的尾部动作，而是驱动设计和约束实现的前置动作。`

### 3. 本次采用的方法组合与总体策略

建议汇报内容：

本次实践采用的不是单一 TDD，而是以下方法组合：

1. `任务拆分`：把业务目标拆成明确、窄范围、可交付的任务
2. `UI-first`：先完成用户可见界面和交互骨架，再逐步接入 backend
3. `TDD`：先失败、再通过、再整理
4. `小步提交`：每个有意义进展都形成独立 commit
5. `运行验证`：不只看测试，还要求应用真实启动验证
6. `文档同步`：计划、设计和实现进度持续回写

建议强调：

`我们想验证的不是某一个技巧，而是一套从任务拆分到交付验证的完整方法链路。`

### 4. 方法背后的原理

建议汇报内容：

1. 任务拆分降低复杂度，让每一步都可解释、可验证、可回退
2. 测试先行让需求表达从“描述”变成“行为约束”
3. 小步提交让问题定位和责任边界更清晰
4. UI-first 让团队更早看到产品形态，缩短设计反馈周期
5. 后端后接可以避免在高不确定阶段过早投入复杂联调成本

建议强调：

`这套方法的本质，是把“大需求的不确定性”拆解成一系列“小行为的确定性”。`

### 5. 本次开发实践过程复盘

建议按阶段汇报，不按文件汇报。

#### 阶段一：建立规则、骨架与交付约束

关键动作：

1. 初始化 Flutter 模块和文档结构
2. 明确任务清单、架构约束、提交规则和运行验证要求
3. 把 pre-commit、golden、CI 等护栏逐步落到仓库

可引用提交：

1. `0400668` `chore: initialize todo module scaffold and planning docs`
2. `7cc4bc7` `chore: run flutter test in pre-commit hook`
3. `557ceeb` `docs: align planning rules and architecture constraints`
4. `e7d97d7` `docs: clarify figma design and asset references`
5. `6b9e00e` `test: add golden checks and pre-commit runtime rule`
6. `3d112dd` `Create dart.yml`

#### 阶段二：先完成 UI shell 和核心页面

关键动作：

1. 基于 Figma 拆解页面结构和组件
2. 先实现 `home`、`today tasks` 等核心页面骨架
3. 通过 widget test 和 golden test 固化 UI 行为与视觉基线

可引用提交：

1. `ea9ec49` `feat: add home and today tasks ui shell`
2. `3ad99ef` `feat: add let's start page and go_router routing`
3. `c1a7e02` `feat: implement all figma screens with full tdd coverage`
4. `1870311` `feat: complete remaining figma todo flows`

#### 阶段三：在 UI 稳定后补 backend 和联调

关键动作：

1. 新增 Dart REST backend
2. 通过 repository、server、API client 测试驱动接口行为
3. 用 `freezed + Riverpod` 组织模型和状态
4. 将 Flutter client 与 backend 连通，形成完整链路

可引用提交：

1. `27f752e` `feat: add dart rest backend with tdd`
2. `a8aa804` `feat: wire flutter client to rest backend with freezed + riverpod annotations`
3. `070ca4e` `docs: mark task 4/5/7 completed in plan document`

建议强调：

`整个过程遵循的是“先看得见，再跑得通，最后接得稳”的推进顺序。`

### 6. TDD 在本次开发中的具体落地方式

建议汇报内容：

1. 页面和交互优先用 `widget test` 驱动
2. 稳定页面用 `golden test` 固化视觉回归基线
3. API 通信用 `client test` 验证序列化、请求和错误处理
4. 后端用 `repository test` 和 `server test` 验证路由和业务规则
5. 关键链路用 `integration test` 做端到端烟雾验证

建议强调：

`我们不是“先把功能写完再补测试”，而是尽量让每一层实现都由最近的一层测试先约束起来。`

### 7. 这套方法带来的实际收益

建议汇报内容：

1. 阶段成果暴露更早，设计和产品反馈更快进入
2. 风险在局部阶段被提前发现，而不是压到最后联调时集中爆发
3. 提交历史更容易回溯，问题定位成本更低
4. UI、后端、联调可以形成层次推进，而不是一次性堆砌
5. 后续扩展 Android 或接入真实服务的成本更低

### 8. 本次实践中暴露的问题与不足

建议汇报内容：

1. 个别 commit message 还不够规范，信息密度不足
2. 后半段有部分提交粒度偏大，review 成本上升
3. 仓库规则中虽然定义了 worktree 策略，但本轮实践中还没有充分发挥
4. TDD 证据链存在于仓库中，但汇报材料中还需要进一步结构化呈现

建议强调：

`这轮实践已经验证了方法方向是对的，但在执行纪律上还有标准化空间。`

### 9. 下一步优化方向

建议汇报内容：

1. 统一 commit message 规范
2. 更严格按任务边界切分提交
3. 增强运行验证记录和发布前检查清单
4. 把 TDD 落地步骤模板化
5. 对高独立性任务更严格应用 worktree
6. 建立更适合管理汇报的测试与交付指标

### 10. 结论与管理建议

建议汇报内容：

1. 本次迭代交付的不只是功能，也验证了一套可持续交付的方法
2. `任务拆分 + UI-first + TDD + 小步提交 + 运行验证` 的组合是有效的
3. 建议后续在同类模块继续沿用，并把实践沉淀成团队工程规范

建议总结句：

`这次开发证明，面向持续交付的研发过程，可以通过更小的任务粒度、更前置的测试和更清晰的提交边界来获得稳定性。`

---

## 第二部分：Flutter Test 机制与选型

### 1. Flutter 的测试体系概览

Flutter 官方测试体系可以概括为四类：

| 类型 | 运行环境 | 核心目标 | 速度/成本 | 典型场景 |
| --- | --- | --- | --- | --- |
| `Unit Test` | Dart VM | 验证纯逻辑、状态计算、数据转换 | 最快，成本最低 | model、provider、filter、serializer |
| `Widget Test` | Flutter 测试环境 | 验证 UI 渲染、交互、状态变化 | 快，覆盖面高 | 页面、组件、路由、交互 |
| `Golden Test` | Widget Test 的视觉快照比对 | 防止 UI 视觉回归 | 中等 | 稳定页面、关键组件 |
| `Integration Test` | 真实运行环境或接近真实 target | 验证整条业务链路 | 最慢，成本最高 | 启动、联调、关键业务流程 |

推荐理解方式：

`越靠近纯逻辑，越用 unit；越靠近页面交互，越用 widget；越靠近整条业务链路，越用 integration；越需要防视觉回归，越补 golden。`

### 2. 各类测试的原理

#### 2.1 Unit Test

原理：

1. 把逻辑从 UI 和平台环境中隔离出来
2. 只验证函数、类、状态对象和数据转换是否符合预期
3. 基于 Dart `package:test`，执行快、反馈短

适合：

1. DTO 或 domain model 规则
2. 过滤和排序逻辑
3. provider/state 的派生逻辑
4. API 数据转换和错误处理

#### 2.2 Widget Test

原理：

1. 在 Flutter 提供的测试环境中构建 widget tree
2. 使用 `WidgetTester` 驱动 `pumpWidget`、点击、输入、滚动和重绘
3. 不依赖真实设备，但能覆盖大部分 UI 行为

适合：

1. 页面首屏结构
2. 按钮点击和交互状态变化
3. 路由跳转
4. 表单校验
5. 局部页面状态渲染

#### 2.3 Golden Test

原理：

1. 把 widget 渲染结果与基准图片做像素级比较
2. 当后续修改导致界面样式偏移时，测试会直接失败
3. 适合作为 UI 回归的视觉护栏

适合：

1. 稳定页面壳层
2. 关键卡片组件
3. Figma 首轮还原后的核心视觉页面

注意：

1. `golden` 对字体、环境、平台差异较敏感
2. 不适合对高频变化页面过度使用，否则维护成本会升高

#### 2.4 Integration Test

原理：

1. 在更接近真实 target 的环境中启动 app
2. 验证多个页面、状态管理、网络层、backend、插件等是否协同工作
3. 用于覆盖真实链路上的系统级风险

适合：

1. 启动应用
2. 页面间完整跳转流程
3. 前后端联调
4. 关键 smoke test

注意：

1. 真实度最高，但执行最慢
2. 不应拿 `integration test` 代替大量 `unit/widget test`

### 3. 为什么 Flutter 推荐这种选型

原因主要有四个：

1. `Unit Test` 和 `Widget Test` 反馈足够快，适合高频执行
2. `Widget Test` 能覆盖大部分 Flutter UI 行为，性价比很高
3. `Golden Test` 能弥补“行为正确但视觉退化”的盲区
4. `Integration Test` 只保留关键路径，能把真实环境风险控制在可接受成本内

从管理视角可以把它理解为：

`用大量低成本测试覆盖大多数问题，用少量高成本测试兜住关键路径。`

### 4. 用测试金字塔理解这套策略

也可以把这套方法放到“测试金字塔”里理解：

1. 最底层是 `Unit Test`，数量应该最多，执行最快，成本最低，是测试体系的基础
2. 再往上一层可以理解为 `Functional Testing`，在 Flutter 项目里主要对应 `Widget Test`，必要时配合 `Golden Test` 去覆盖页面行为和稳定视觉
3. 再往上是 `Integration Testing`，用于验证页面、状态、网络、后端等多个模块是否协同工作
4. 更靠上的 `E2E` 只保留少量关键路径，用来确认真实使用链路没有断裂
5. 顶层是 `Manual Testing`，适合探索性验证、验收确认和补充自动化盲区，但不应承担大面积回归职责

这座金字塔越往上，通常越“慢、贵、难维护”；越往下，通常越“快、便宜、适合高频执行”。

结合当前项目，可以这样映射：

| 金字塔层级 | 本项目中的对应方式 |
| --- | --- |
| `Unit Testing` | model、provider、API 数据转换、过滤与派生逻辑 |
| `Functional Testing` | `Widget Test` 为主，`Golden Test` 作为稳定视觉补充 |
| `Integration Testing` | 页面跳转、状态联动、请求 backend 后的渲染链路 |
| `E2E` | 少量关键 smoke path，例如“启动应用 -> 进入首页 -> 拉取并展示 todo” |
| `Manual Testing` | Web 和 macOS 上的真实启动、交互体验、布局与视觉验收 |

这也是为什么我们不主张把大量验证压力推到 `integration` 或人工测试上，而是优先把问题压在更靠近底层、反馈更快的测试里解决。

### 5. 结合本项目的推荐测试选型

对于当前 `todo` 模块，建议采用以下组合：

| 测试类型 | 本项目推荐用途 |
| --- | --- |
| `Unit Test` | `todo_api_client`、数据模型、过滤逻辑、provider 派生逻辑 |
| `Widget Test` | `home`、`today tasks`、`let's start`、`task details`、`add project` 等页面和核心组件 |
| `Golden Test` | `home shell`、`today tasks shell` 等视觉稳定页面 |
| `Integration Test` | `启动 app -> 路由进入页面 -> 请求 backend -> 渲染结果` 的关键 smoke path |

推荐执行顺序：

1. 先用 `Unit Test` 或 `Widget Test` 驱动最小行为
2. 再用 `Golden Test` 固化稳定视觉结果
3. 最后用少量 `Integration Test` 兜底整链路风险

### 6. 这套选型如何支撑 TDD

在本项目里，TDD 并不是单一层级上的实践，而是分层推进：

1. 逻辑层通过 `Unit Test` 保证正确性
2. 界面层通过 `Widget Test` 保证可交互和可渲染
3. 视觉层通过 `Golden Test` 保证 UI 回归可发现
4. 系统层通过 `Integration Test` 保证链路可用

这意味着 TDD 在项目中的作用不是“补测试”，而是：

1. 把需求转化成分层的可验证行为
2. 在不同粒度上持续缩小回归风险
3. 让实现顺序自然服从“先最小正确，再整体可用”的交付逻辑

### 7. 使用时需要注意的边界

1. `Widget Test` 并不等同于真实设备测试，宿主平台和插件能力仍需要额外验证
2. `Golden Test` 的价值很高，但要控制数量，优先覆盖稳定且关键的页面
3. `Integration Test` 应控制在关键链路，不宜泛化为所有场景的默认测试方式
4. 如果一个能力可以在 `Unit Test` 或 `Widget Test` 层面被更快验证，就不应直接推到 `Integration Test`

---

## 第三部分：可直接用于汇报的总结口径

可以在汇报中直接使用以下表达：

1. `我们这次不是单纯交付一个 todo 功能，而是在验证一套可持续交付的方法。`
2. `这套方法的核心是把需求拆成小任务，用测试把行为前置固化，再通过小步提交和运行验证把风险控制在每一步。`
3. `Flutter 的测试体系天然支持这种方法：逻辑用 unit，界面用 widget，视觉用 golden，整链路用 integration。`
4. `这让我们既能快速推进 UI-first 的研发节奏，又能保证后续接 backend 和扩展平台时不失控。`

---

## 第四部分：官方参考资料

以下为整理本节时参考的 Flutter 官方资料：

1. [Flutter testing overview](https://docs.flutter.dev/testing/overview)
2. [Widget testing introduction](https://docs.flutter.dev/cookbook/testing/widget/introduction)
3. [Integration testing introduction](https://docs.flutter.dev/cookbook/testing/integration/introduction)
4. [Check app functionality with an integration test](https://docs.flutter.dev/testing/integration-tests)
5. [flutter_test library](https://api.flutter.dev/flutter/flutter_test/)
6. [WidgetTester](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)
7. [testWidgets](https://api.flutter.dev/flutter/flutter_test/testWidgets.html)
8. [matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)
9. [goldenFileComparator](https://api.flutter.dev/flutter/flutter_test/goldenFileComparator.html)
10. [Plugins in Flutter tests](https://docs.flutter.dev/testing/plugins-in-tests)
