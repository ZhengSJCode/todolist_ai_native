# 🎬 真实案发现场复盘：我是如何用 Claude Code 跑通完整 TDD 的

> 记录于：`7537d305-a78c-41a0-a34e-b5dcbcb35196` Session (语音看板需求开发)

如果你好奇“究竟该怎么向 AI 下达 TDD 指令，它才不会瞎写代码？”
那么，这份从我的终端里挖出来的历史记录，就是一份极佳的操作指南。

## 1. 核心破冰指令（只用了一句话）

在我完成需求拆解后，我在终端唤起了 Claude Code，然后敲下了这一句极其关键的命令：

```bash
> /Users/zhengshuaijie/.../docs/plan 帮我实现除3.1的功能吧 /using-superpowers
```

这句话看似简单，但暗藏了 3 个高级工程技巧：
1. **指定上下文边界**：`docs/plan` 目录。这是我在这之前让 AI 结合 PRD 拆解出的严密的 TDD 测试清单（比如 `client-voice-kanban-checklist.md`）。我直接告诉 AI：“别瞎猜，拿着这份需求和测试断言大纲来做”。
2. **划定作用域**：`帮我实现除3.1的功能吧`。明确这次迭代的 Scope，避免 AI 因为“太聪明”而去超纲开发。
3. **注入灵魂技能**：`/using-superpowers`。这是整个 TDD 得以成功执行的开关。它强制激活了项目配置中预设的开发纪律，最核心的约束就是：**“必须先写单元测试跑到报错（Red），再写业务代码（Green）”**。

---

## 2. Claude 是怎么执行这句指令的？

在接下来的半小时里，我的终端仿佛被一个严谨的高级测试工程师接管了。根据底层的执行日志，Claude 自动进行了以下疯狂但极其规范的闭环操作：

### Step 2.1: 疯狂建文件与写测试（红灯阶段：它懂金字塔！）
它并没有一股脑只写一种测试，而是严格遵循了我们前面提到的“测试金字塔”结构。
*它写出了如下文件，**注意，这时候它还完全没有写任何业务代码（如 API 或 Provider）的实现***：
*   **【底层】Unit Test（业务逻辑）**：`WRITE: voice_kanban_model_test.dart`
    *(测试：模型序列化、`fromJson`/`toJson` 的边界条件、默认值解析)*
*   **【底层】Unit Test（网络请求）**：`WRITE: voice_kanban_api_client_test.dart`
    *(测试：Mock Dio 请求，断言发出的 POST `/parse` 和 `rawText` 正不正确，能否正确捕获服务端的 400 报错)*
*   **【中层】Widget Test / Provider Test（状态流转）**：`WRITE: voice_kanban_provider_test.dart`
    *(测试：调用 API 接口后，Riverpod 状态是否能从 `AsyncLoading` 流转到 `AsyncData`，草稿列表数据有没有对上)*
*   **【中层】Widget Test（组件渲染交互）**：`WRITE: voice_kanban_page_test.dart`
    *(测试：在内存里把看版页面渲染出来，模拟点击筛选“全部/Task/Note”芯片，断言列表能正确过滤，同时用 `matchesGoldenFile` 顺手生成了 UI 基准图（**Golden Test**）防止样式退化)*

*至于顶层的 **Integration Test（集成/E2E 测试）**，Claude 在那次狂奔的半小时 Session 中并没有写。它非常聪明地止步于此（这是极其符合金字塔原理的：不要过早介入极其脆弱的 UI 全链路测试）。*
*直到后来所有的底层逻辑、网络层、页面都各自稳定（全绿）了，我才让它在 `integration_test/voice_kanban_test.dart` 里补齐了那条贯穿全局的主流程 E2E 测试。由于底层稳固，这个集成测试几乎是**一次性写完、一把跑通的**！*

### Step 2.2: 强行跑测试验证失败（见红）
在它写完这些测试代码后，它并没有“自作聪明”地马上补齐业务代码，而是非常老实地在后台自己执行了 `flutter test`，以便用报错来建立约束：
```bash
BASH TEST: flutter test test/voice_kanban_model_test.dart
BASH TEST: flutter test test/voice_kanban_api_client_test.dart
# （终端日志显示，这里抛出了一大堆类找不到的编译错误，因为实现类还没建，这完全符合 TDD 的 Red 阶段）
```

### Step 2.3: 补充最小实现与反复自愈（由红变绿）
确认了测试报错后，Claude 才开始去写对应的业务代码：
*   `WRITE: voice_kanban_model.dart`
*   `WRITE: voice_kanban_api_client.dart`
*   `WRITE: voice_kanban_provider.dart`

**最震撼的一幕出现了**：每写完一个类的初步实现，它就会自动在后台再去跑对应的 `flutter test`，用红绿状态来验证自己写的代码。
根据底层的 Bash 执行日志，在这个 Session 里，Claude 竟然**自主且密集地运行了三十多次 `flutter test`**，反复在“红 -> 绿”的泥潭里自我博弈和修复！

以下是我从历史记录里提取的一段极其真实的**“自我修复”死循环实录**（以 `voice_kanban_page_test.dart` 为例）：

1.  **第一次跑**：`BASH TEST: flutter test test/voice_kanban_page_test.dart`
    *   **结果**：挂了（Red）。
    *   **AI 的诊断与修复**：日志显示它捕获到了 Flutter Test 的报错：`No ProviderScope found`。因为写 Widget 测试时忘记在最外层包上 Riverpod 的环境了。于是它立刻去修改测试文件，把 `TaskCard` 包了起来。

2.  **第二次跑**：`BASH TEST: flutter test test/voice_kanban_page_test.dart`
    *   **结果**：又挂了（Red）。
    *   **AI 的诊断与修复**：这次报错变了：`Expected: exactly one matching node in the widget tree. Actual: _ZeroWidgetFinder`。它找不到测试代码里指定的那个包含“保存”文案的按钮！AI 去检查了一下自己刚才写的 UI 代码 `voice_kanban_page.dart`，发现里面没加 `Key('save_btn')`，导致测试脚本里的 `find.byKey` 扑了空。于是它马上打开业务代码补上了这行 Key。

3.  **第 N 次跑**：`BASH TEST: flutter test test/voice_kanban_page_test.dart`
    *   **结果**：依然挂（Red）。
    *   **AI 的诊断与修复**：这次是 Provider 里的状态流转问题：模拟发送语音请求后，页面应该先出 `CircularProgressIndicator`（Loading），然后再展示结果列表。但 AI 写的异步逻辑有问题，导致没等转圈结束测试就去断言列表了，抛出了 `PumpAndSettle timed out`。它耐心地调整了测试代码里的 `tester.pump(const Duration(milliseconds: 500))` 机制。

4.  **最后一次跑**：`BASH TEST: flutter test test/voice_kanban_page_test.dart`
    *   **结果**：终于，绿灯通过！（Green）✅
    *   **AI 的动作**：确认绿灯后，它才停下来，并在终端里非常优雅地向我汇报：“我已经完成了看版页面的开发和测试。”

---

## 3. 我的感受与结语

整个开发过程中，我除了敲下一开始的那句包含 `/using-superpowers` 的需求指令外，**仅仅是在它分批停下来询问时，敲了几次回车和 `继续`**。

剩下的所有体力活——设计测试断言、生成 Mock 数据、写出最初的业务代码、自己跑测试修复报错……全部由 Claude Code 根据 TDD 纪律全自动闭环完成了。

这就是在这个 AI 时代，作为一个开发者最极致的爽感：**用需求和契约（Plan/Checklist）作为紧箍咒，用 TDD 作为护城河，然后放手让 AI 在测试绿灯的保护下疯狂输出代码。**