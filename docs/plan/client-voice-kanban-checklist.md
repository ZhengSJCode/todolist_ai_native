# 语音记录看板 — 客户端需求与测试清单

本文档与 `docs/prd.md`、`docs/server-voice-kanban-api-checklist.md` 对齐，描述 **Flutter 客户端**在本期（解析预览 + 写入 + 列表）下的需求、模块边界与 **TDD 测试要点**。服务端路径、JSON 字段以服务端清单为准，此处不重复定义，只列 **客户端必须遵守的契约**与 **交付物**。

---

## 1. 目标与范围（本期）

### 1.1 产品闭环（客户端视角）

1. 用户输入一段**文字**（语音转写本期可不做 UI，仅占位或隐藏入口）。  
2. 调 **`POST /parse`** 展示结构化预览（`ParsedDraft` 列表）。  
3. 用户确认后调 **`POST /entries`** 写入服务端。  
4. **看板首页**通过 **`GET /items`** 展示已持久化记录；支持 **全部 / task / metric / note** 筛选（查询参数 `type` 与服务端一致）。

### 1.2 非目标（本期不写进验收）

- 编辑 / 删除已持久化条目（无 `PATCH` / `DELETE` 时客户端不提供改删主流程）。  
- 登录、多端同步、提醒、图表（见 PRD 非目标）。  
- 真实语音采集与 ASR（可预留 `sourceType` 与 UI 占位）。

### 1.3 体验与视觉

- **与现有 todo 应用壳层一致**：沿用 `AppShell`、底部导航或侧栏路由模式、主题色与卡片密度；新页面在现有 `router` 中注册，不另起一套 Design Token。  
- 列表项需一眼区分 **类型**（`task` / `metric` / `note`）与 **时间**；`metric` 需展示 `value` + `unit`（若有）。

---

## 2. 依赖的 HTTP 契约（摘要）

| 客户端能力 | HTTP | 说明 |
|------------|------|------|
| 文字 → 预览 | `POST /parse` | body：`rawText`、`sourceType?`；响应：`{ items: ParsedDraft[] }` |
| 确认保存 | `POST /entries` | 同上 body；响应：`{ rawEntry, items: ParsedItem[] }` |
| 看板列表 | `GET /items` | 查询：`type` 可选 `all` \| `task` \| `metric` \| `note`；响应：`ParsedItem[]` |

错误体：`{ "error": string }`；状态码 **400** 展示 `error` 文案（可 Toast / 内联文案）。

---

## 3. 代码结构（建议，与仓库 `lib/src` 一致）

| 区域 | 路径建议 | 职责 |
|------|-----------|------|
| DTO / 领域模型 | `lib/src/api/` | `parsed_draft.dart`、`raw_entry_model.dart`、`parsed_item_model.dart`（或与现有命名统一）；`type` 建议 **枚举 + json 小写字符串** 映射 |
| HTTP 客户端 | `lib/src/api/` | 扩展现有 `TodoApiClient` **或** 新建 `VoiceKanbanApiClient`，封装上述三个方法；`baseUrl` 可注入，与现有一致 |
| 状态 | `lib/src/provider/` | 如 `VoiceKanbanController` / `AppDataProvider` 扩展：预览列表、列表、筛选、`loading`/`error` |
| 页面 | `lib/src/pages/` | 输入 + 预览页、看板列表页（或合并为一步式，以 PRD「输入页」为准） |
| 组件 | `lib/src/widgets/` | 单条预览卡片、单条看板卡片、类型 Chip、筛选栏 |

**原则**：解析预览与持久化列表 **共用** 同一套「行」视觉组件的字段子集（`type` / `content` / `value` / `unit`），减少分叉。

---

## 4. 功能需求明细

### 4.1 网络层

- **`parse(rawText)`**：`POST /parse`，返回 `List<ParsedDraft>`；`rawText` 在客户端先 `trim`，空串 **不调接口**，本地校验提示。  
- **`createEntry(rawText)`**：`POST /entries`，返回 `RawEntry` + `List<ParsedItem>`（或统一封装为「创建结果」模型）。  
- **`listItems({ParsedItemType? filter})`**：`GET /items`，`filter == null` 或 `all` 时不带 `type` 或显式 `type=all`（**与服务端实现保持一致**，并在单测中断言 URL）。  
- **错误处理**：非 2xx 时解析 `error` 字段；网络异常与超时单独文案（可选 Dio 拦截器）。  
- **不缓存违背服务端语义**：`/parse` 结果仅内存展示，除非产品明确要求离线草稿。

### 4.2 输入与预览页

- 多行文本输入；**解析**按钮或提交时触发 `POST /parse`。  
- 展示 `items` 列表：类型、`content`、若有 `value`/`unit` 则展示。  
- **保存**按钮：调用 `POST /entries`（使用当前输入框中的 `rawText`，与服务端再次解析一致）；成功后 **清空预览或跳转看板**，并刷新列表。  
- 加载中：禁用重复提交；失败：展示 `error`。

### 4.3 看板列表页

- 进入页或从保存返回时 **`GET /items`**。  
- 筛选：`全部`、`Task`、`Metric`、`Note` 映射到服务端 `type`（见服务端清单 G3–G6）。  
- 排序：**信任服务端**倒序；若客户端二次排序，须与 `createdAt` 降序一致。  
- 每条展示：`type`、`content`、`value`+`unit`（若有）、格式化后的 `createdAt`（本地时区展示即可）。

### 4.4 路由与入口

- 在 `router` / `bottom_nav` 增加「看板」或替换某一 Tab 的占位，**不破坏**现有能启动的应用结构。  
- Deep link 本期非必须。

---

## 5. 测试需求（TDD / 验收）

### 5.1 API 模型与客户端单测

| # | 用例 | 断言要点 |
|---|------|----------|
| M1 | `ParsedDraft.fromJson` | 缺省 `title`/`value`/`unit` 不崩溃；`type`、`content` 必填 |
| M2 | `ParsedItem.fromJson` | 含 `id`、`rawEntryId`、`createdAt`；时间与字符串互转 |
| M3 | `CreateEntryResponse.fromJson` | `rawEntry` + `items` 嵌套解析正确 |

### 5.2 HTTP 客户端单测（Mock Dio / `HttpClientAdapter`）

| # | 用例 | 断言要点 |
|---|------|----------|
| C1 | `parse` | `POST` 到 `.../parse`，body 含 `rawText`；200 时返回 drafts 条数与首项 `type` |
| C2 | `createEntry` | `POST` 到 `.../entries`；201 时含 `rawEntry.id` |
| C3 | `listItems` 无筛选 | `GET .../items` 无 `type` 或 `type=all`（与实现选定一致） |
| C4 | `listItems(type: metric)` | URL 含 `type=metric` |
| C5 | 400 响应 | 抛出或返回 `Result` 中含服务端 `error` 字符串 |

### 5.3 Provider / 状态单测

| # | 用例 | 断言要点 |
|---|------|----------|
| T1 | 初始状态 | 列表空、无错误 |
| T2 | `loadItems` 成功 | 列表长度与 fake 数据一致 |
| T3 | 切换筛选 | 再次请求或本地过滤策略与产品一致；若每次请求服务端，断言调用参数变化 |
| T4 | `parse` 成功再 `save` | 保存成功后列表条数增加（可 fake client 计数） |

### 5.4 Widget 测试

| # | 用例 | 断言要点 |
|---|------|----------|
| W1 | 看板页 | `pump` 后可见筛选 chip；给定 fake 数据可见某条 `content` |
| W2 | 输入页 | 输入文字 → mock `parse` → 可见预览行数 |
| W3 | 错误展示 | mock 400 → 可见错误文案 |

### 5.5 集成 / 黄金路径（可选）

- 在 CI 允许的前提下：`FakeVoiceKanbanApiClient` 注入全应用，走「输入 → 预览 → 保存 → 看板」一步流程（见 `test/app_interactive_flow_test.dart` 风格）。

---

## 6. 实现检查清单（客户端）

- [ ] 三个 API 方法与契约、错误体对齐  
- [ ] 模型 `fromJson` / 枚举映射单测绿  
- [ ] 输入 + 预览 + 保存流程可手动跑通（Web 或 macOS 其一）  
- [ ] 看板列表 + 筛选 + 时间 / metric 展示  
- [ ] UI 与现有 shell / 主题无明显割裂  
- [ ] 上述 C / T / W 类测试覆盖核心路径  

---

## 7. 脚注

1. **服务端未就绪时**：使用 `FakeVoiceKanbanApiClient`（或现有 `fake_todo_api_client` 模式）保证 UI 与测试可并行开发。  
2. **`POST /parse` 与 `POST /entries`**：保存时应以用户最终确认的 **同一段 `rawText`** 提交 `entries`，避免预览后改字未同步（若产品允许改字，保存前须重新 `parse` 或一并提交修订结构——**本期建议**：保存前以输入框文本为准并文档化）。  
3. 服务端清单变更时，**先改契约与 server test，再同步本清单与客户端模型**。

---

文档版本：客户端「解析预览 + 增 + 查」需求与测试清单。
