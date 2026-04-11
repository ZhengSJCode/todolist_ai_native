# Flutter E2E 方案对比：Fluttium、Patrol、Honey

## 文档目的

这份文档不直接在仓库里同时落三套 E2E 框架，而是先用同一个业务目标来推演三种实现方式各自更合理的提交记录。

统一目标：

1. 启动 app
2. 进入首页
3. 添加一个 project
4. 添加一个 task
5. 在真机或模拟器上验证成功

这样做的目的是把差异放在同一个参照系里看清楚：

1. 每种方案会改哪些代码
2. 每种方案的 commit 边界应该怎样划
3. 哪种方案更适合 AI 驱动的 TDD 开发

---

## 基线前提

当前 Flutter 官方推荐的设备级集成测试基线是 `integration_test`：

1. `integration_test` 放在 `integration_test/` 目录
2. 使用 `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`
3. 用 `flutter test integration_test/app_test.dart` 在 Android/iOS 设备上执行

这意味着下面三种方案，本质上都在回答同一个问题：

`在 Flutter 官方 integration_test 基线之上，怎样把 E2E 测试写得更快、更稳、更适合持续演进。`

---

## 方案一：Fluttium

### 适合的思路

Fluttium 更像“用户流程脚本”方案。

核心特点：

1. 关注用户流而不是 Flutter 代码细节
2. 声明式、流程化
3. 更接近 QA/产品视角，而不是工程内联视角
4. 使用独立 flow 文件和 CLI 执行

如果用 Fluttium 做这次功能，比较合理的提交记录会是下面这样：

### 建议提交记录

1. `chore(test): add fluttium cli and base flow config`
   - 新增 `fluttium.yaml`
   - 引入 `fluttium_cli`
   - 配置目标设备、入口和测试运行方式

2. `refactor(test): expose stable semantics for project and task creation flow`
   - 为 `Add Project`、`Add Task` 相关控件补稳定语义标识
   - 修复设备高度下 `AddProjectPage` 的滚动和可达性问题
   - 这一步的目标不是“写测试”，而是让流程引擎能稳定识别节点

3. `test(e2e): add fluttium flow for creating project and task`
   - 新增类似 `flows/create_project_and_task.yaml`
   - 用流程步骤表达：
     - 打开 app
     - 点击 `Get Started`
     - 进入 `Projects`
     - 输入 project name
     - 点击 `Add`
     - 进入 `My Tasks`
     - 输入 task title
     - 点击 `Add`
     - 断言目标文本出现

4. `ci(test): run fluttium flow on android device`
   - 把 flow 测试接到本地脚本或 CI
   - 统一 `fluttium test ...` 的运行入口

### 对 AI 驱动 TDD 的影响

优点：

1. flow 文件很直观，AI 很容易生成首稿
2. 对非 Flutter 工程师也比较友好
3. 很适合“验收路径”描述

短板：

1. 它离 Flutter 代码层较远，不天然贴合“先写失败测试，再写最小实现”的工程闭环
2. 当页面结构变化时，flow 容易成为脆弱脚本
3. 改动往往会拆成“app 代码修语义 + flow 文件修步骤”两层上下文，AI 在多轮维护时成本更高

结论：

`Fluttium 更像验收流测试工具，不是最自然的 AI-first TDD 主力框架。`

---

## 方案二：Patrol

### 适合的思路

Patrol 是最接近 Flutter 工程日常开发语境的方案。

核心特点：

1. 基于 Flutter 的 `flutter_test` / `integration_test`
2. 仍然使用 Dart 写测试
3. 查找器更强，原生交互能力更强
4. 对 Android/iOS 权限弹窗、通知、原生页面更友好

如果用 Patrol 做这次功能，比较合理的提交记录会是下面这样：

### 建议提交记录

1. `chore(test): add patrol and patrol_cli bootstrap`
   - 引入 `patrol`
   - 安装 `patrol_cli`
   - 初始化 Patrol 目录结构和运行命令

2. `refactor(test): centralize stable keys for creation flows`
   - 把 project/task 创建流程相关的 `Key` 抽成统一测试 key 定义
   - 补充设备上稳定的按钮 key
   - 修复 `AddProjectPage` 在真机高度下的 overflow

3. `test(e2e): add patrol test for project and task creation`
   - 新增 `patrol_test/create_project_and_task_test.dart`
   - 使用 `patrolTest(...)`
   - 直接在 Dart 里表达输入、点击、滚动和断言
   - 与现有 widget test / integration_test 的思维模型基本一致

4. `test(e2e): add native-aware assertions for dialogs and system surfaces`
   - 如果后续出现通知、权限、系统弹窗，再补 Patrol 的 native automation
   - 这一步是 Patrol 相比官方 `integration_test` 最有价值的扩展层

5. `ci(test): run patrol flows on emulator or device farm`
   - 接 Patrol 执行命令到 CI
   - 适配 device farm 或本地模拟器

### 对 AI 驱动 TDD 的影响

优点：

1. 仍然是 Dart 代码，AI 修改测试和修改产品代码时上下文一致
2. 和现有 widget test、integration_test 非常接近，迁移成本低
3. 对复杂移动端场景比官方 `integration_test` 更强
4. Patrol 生态活跃，版本更新和文档都明显更持续

短板：

1. 需要额外 CLI 和框架心智
2. 比官方 `integration_test` 多一层工具依赖
3. 如果团队只做非常简单的页面流程，可能显得略重

结论：

`如果目标是 AI 驱动的 TDD 开发，Patrol 是三者里最平衡、最像“工程主力方案”的。`

---

## 方案三：Honey

### 适合的思路

Honey 更像一门用于 E2E 的 DSL。

核心特点：

1. 使用 HoneyTalk 语言写测试
2. 依赖 accessibility tree
3. 可以通过 `HoneyWidgetsBinding` 注入到 app
4. 配套 VSCode extension，偏编辑器工作流

如果用 Honey 做这次功能，比较合理的提交记录会是下面这样：

### 建议提交记录

1. `chore(test): add honey and enable HoneyWidgetsBinding in test mode`
   - 引入 `honey`
   - 修改 `main.dart`
   - 使用 `--dart-define=HONEY=true` 之类的方式只在测试构建中开启 Honey

2. `refactor(test): improve accessibility labels for creation flow`
   - 因为 Honey 依赖 accessibility tree，这一步通常不可避免
   - 需要把 project/task 创建流程中的关键控件语义补齐
   - 同样要修复移动端布局可达性问题

3. `test(e2e): add HoneyTalk flow for project and task creation`
   - 新增类似 `e2e/create_project_and_task.honey`
   - 用 HoneyTalk 描述点击、输入、断言

4. `docs(test): add honey debug mode and vscode workflow`
   - 写明 VSCode 如何以 Honey 模式运行 app
   - 补充团队使用说明

### 对 AI 驱动 TDD 的影响

优点：

1. DSL 可读性高，测试脚本接近自然语言
2. 对产品或 QA 展示时比较直观
3. 强调 accessibility，本身会倒逼 UI 语义质量提升

短板：

1. 它不是 Dart 主线测试语言，AI 在“产品代码 <-> 测试代码”之间切换上下文更多
2. 需要改 `main.dart` 注入 `HoneyWidgetsBinding`
3. 依赖 VSCode workflow 的色彩更重
4. 从公开包信息看，版本和活跃度明显弱于 Patrol

结论：

`Honey 适合做面向流程表达的 E2E 脚本，但不如 Patrol 适合工程内的 AI-TDD 主链路。`

---

## 三种方案的提交记录对比

| 维度 | Fluttium | Patrol | Honey |
| --- | --- | --- | --- |
| 测试表达 | Flow/YAML 风格 | Dart 测试代码 | HoneyTalk DSL |
| 与 Flutter 现有测试体系距离 | 远 | 最近 | 中等偏远 |
| 与 widget test / integration_test 协同 | 一般 | 很好 | 一般 |
| 对 AI 修改代码和测试的一致性 | 中 | 高 | 中 |
| 对原生弹窗/通知/系统交互支持 | 弱到中 | 强 | 取决于框架能力与语义 |
| 对语义/可访问性依赖 | 中 | 中 | 高 |
| 适合 QA/产品直接读流程 | 高 | 中 | 高 |
| 适合作为工程主力 TDD 工具 | 中低 | 高 | 中低 |
| 活跃度和生态稳定性 | 偏弱 | 强 | 偏弱 |

---

## 哪个更适合 AI 驱动的 TDD 开发

我的判断是：

### 第一选择：Patrol

原因：

1. 仍然使用 Dart，最贴近 AI 修改 Flutter 工程代码的主上下文
2. 能和现有 `widget test`、官方 `integration_test` 组成连续测试金字塔
3. 当页面结构调整时，AI 可以同时改 production code、test key、Patrol test，闭环最短
4. 如果未来要测权限、通知、原生弹窗，这条路不需要换框架

### 第二选择：官方 `integration_test`

如果场景还比较简单，其实最稳的主线依然是先用官方 `integration_test` 打底，再决定是否往 Patrol 升级。

原因：

1. 官方支持
2. 团队门槛最低
3. 很适合当前这种先把基础设备集成测试跑起来的阶段

### 第三选择：Fluttium

适合：

1. 你想把测试表达做得更像验收流
2. 希望产品、QA、开发都能快速读懂流程

但它更适合作为补充层，不适合替代工程主线测试。

### 第四选择：Honey

Honey 的自然语言/DSL 思路有吸引力，但从当前公开信息看：

1. 活跃度偏弱
2. 与现有 Flutter Dart 测试主链路耦合不够紧
3. 更像一个有特色的实验型 E2E 方案，而不是当前团队最稳的主力选择

---

## 最终建议

如果目标是：

### 1. 先把当前项目做稳

建议：

1. 继续以官方 `integration_test` 为基线
2. 保持 `widget test + integration_test` 的分层
3. 用稳定 `Key` 和可滚动/可访问布局提升设备测试可靠性

### 2. 再引入更强的移动端 E2E 能力

建议优先尝试：

1. Patrol

原因：

1. 最适合 AI 在单一语言上下文中持续迭代
2. 最贴近 TDD 的“写失败测试 -> 改代码 -> 立刻重跑”循环
3. 对移动端复杂场景有长期扩展价值

### 3. 如果你要做给产品/QA 演示的流程脚本

可以再考虑：

1. Fluttium
2. Honey

但我不建议把它们作为当前项目 AI 驱动 TDD 的主链路。

---

## 如果要继续落地

下一步有两种继续方式：

1. 我直接给你生成三套“真实分支方案”
   - `codex/poc-fluttium`
   - `codex/poc-patrol`
   - `codex/poc-honey`

2. 我只选一套继续实现
   - 如果目标是最适合 AI 驱动 TDD，我建议直接做 `Patrol POC`

---

## 参考资料

1. Flutter 官方 `integration_test`：[Check app functionality with an integration test](https://docs.flutter.dev/testing/integration-tests)
2. Flutter 官方测试概览：[Testing Flutter apps](https://docs.flutter.dev/testing/overview)
3. Flutter 官方集成测试概念：[Integration testing concepts](https://docs.flutter.dev/cookbook/testing/integration/introduction)
4. Patrol 官网：[Patrol](https://patrol.leancode.co/)
5. Patrol 文档：[Write your first test](https://patrol.leancode.co/write-your-first-test)
6. Patrol 包信息：[patrol on pub.dev](https://pub.dev/packages/patrol)
7. Fluttium 官网：[Fluttium](https://fluttium.dev/)
8. Fluttium 流程测试文档：[Testing A Flow Test](https://fluttium.dev/docs/getting-started/testing-a-first-flow-test/)
9. Fluttium 包信息：[fluttium on pub.dev](https://pub.dev/packages/fluttium)
10. Honey 包信息：[honey on pub.dev](https://pub.dev/packages/honey)
