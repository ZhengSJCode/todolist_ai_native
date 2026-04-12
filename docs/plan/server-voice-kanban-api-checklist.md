# 语音记录看板 — 服务端接口与测试用例清单

本文档与 `docs/prd.md` 对齐，**当前范围包含**：

- **文字转结构化（不落库）**：`POST /parse` — 仅把 `rawText` 解析为结构化草稿，**不写** `RawEntry` / `ParsedItem`
- **增**：`POST /entries` — 持久化 `RawEntry` + 解析得到的若干 `ParsedItem`
- **查**：`GET /items` — 列表、类型筛选、按 `createdAt` 降序

**不包含**：`PATCH` / `DELETE`；后续可追加章节或新文档。

实现时测试可落在 `server/test/`，风格参考现有 `server_test.dart`、`todo_repository_test.dart`。

**约定**：JSON 字段 **camelCase**；持久化实体的时间为 **ISO 8601** 字符串。解析预览无 `createdAt` 字段（见 1.3）。

---

## 1. 数据模型（JSON 形状）

### 1.1 `RawEntry`（原始输入，仅 `POST /entries` 响应与存储）

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 服务端生成，非空 |
| `sourceType` | string | 本期仅接受 `text`；其它值 `400`（与 `POST /entries` 的 P6 一致） |
| `rawText` | string | 用户原始输入 |
| `createdAt` | string | ISO 8601 |

### 1.2 `ParsedItem`（解析条目，已持久化）

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 服务端生成 |
| `rawEntryId` | string | 关联的 `RawEntry.id` |
| `type` | string | `task` \| `metric` \| `note` |
| `content` | string | 主展示文案 |
| `title` | string? | 可选 |
| `value` | num? | `metric` 时使用 |
| `unit` | string? | 如 `kg`、`km` |
| `createdAt` | string | ISO 8601；`GET /items` 排序用 |

### 1.3 `ParsedDraft`（解析预览，**仅** `POST /parse` 响应）

不落库、无服务端 id；与 `ParsedItem` 的语义字段对齐，便于客户端「预览 → 确认 → 再 `POST /entries`」复用 UI。

| 字段 | 类型 | 说明 |
|------|------|------|
| `type` | string | `task` \| `metric` \| `note` |
| `content` | string | 主展示文案 |
| `title` | string? | 可选 |
| `value` | num? | `metric` 时使用 |
| `unit` | string? | 可选 |

**说明**：不包含 `id`、`rawEntryId`、`createdAt`。

### 1.4 错误体

非 `2xx` 且需要 body 时统一：

```json
{ "error": "人类可读说明" }
```

---

## 2. HTTP 接口一览（本期）

| 方法 | 路径 | 说明 |
|------|------|------|
| `POST` | `/parse` | 文字 → 结构化草稿（`ParsedDraft[]`），**不写入**存储 |
| `POST` | `/entries` | 提交原始文本 → 持久化 `RawEntry` + `ParsedItem[]` |
| `GET` | `/items` | 已持久化条目列表；筛选；按 `createdAt` 降序 |

与 `/todos`、`/projects` 共存。

---

## 3. 接口详规与测试用例

以下每条 **「测试」** 对应一个 `test('...')` 或 `group` 子用例。

---

### 3.1 `POST /parse`（文字转结构化，不落库）

**请求体**

| 字段 | 类型 | 必填 |
|------|------|------|
| `rawText` | string | 是（trim 后非空） |
| `sourceType` | string | 否；缺省为 `text`；非法值 `400`（与持久化接口对齐） |

**成功：`200 OK`**

响应体 JSON 对象：

| 字段 | 类型 |
|------|------|
| `items` | `ParsedDraft[]`（条数由解析规则决定；合法非空输入下通常 ≥1） |

**建议测试用例**

| # | 用例名 | 请求 | 断言要点 |
|---|--------|------|----------|
| S1 | 合法文本返回草稿列表 | `POST /parse`，有效 `rawText` | `200`；`items` 为非空数组；每项含 `type`、`content`；**无** `id` / `rawEntryId` / `createdAt` |
| S2 | PRD 示例句 | 同 `POST /entries` P2 的 `rawText` | `200`；`items.length >= 3`；含 `metric`（体重）、`task`（鸡胸肉）、`note` |
| S3 | `rawText` 仅空白 | 同 P4 | `400`；`error` 非空 |
| S4 | 缺少 `rawText` | 同 P5 | `400` |
| S5 | 非法 `sourceType` | 同 P6 | `400` |
| S6 | 无副作用 | 先 `GET /items` 记条数 / id 集合 → `POST /parse` → 再 `GET /items` | 两次 `GET` 结果一致（解析不改变存储） |

**与解析器关系**：应与 `POST /entries` 使用**同一套**解析实现，仅差「是否持久化」；可抽共享函数，用 S2 与 P2 对齐断言。

---

### 3.2 `POST /entries`（增）

**请求体**

| 字段 | 类型 | 必填 |
|------|------|------|
| `rawText` | string | 是（trim 后非空） |
| `sourceType` | string | 否；缺省为 `text` |

**成功：`201 Created`**

响应体 JSON 对象：

| 字段 | 类型 |
|------|------|
| `rawEntry` | `RawEntry` |
| `items` | `ParsedItem[]` |

**建议测试用例**

| # | 用例名（描述） | 请求 | 断言要点 |
|---|----------------|------|----------|
| P1 | 合法文本创建成功 | `POST`，body 含有效 `rawText` | `201`；`rawEntry`、`items` 字段完整；每条 `rawEntryId` 等于 `rawEntry.id` |
| P2 | PRD 示例句拆多条 | 同 S2 | `201`；条数与类型与 S2 一致（持久化形态多 `id`、`rawEntryId`、`createdAt`） |
| P3 | 缺省 `sourceType` | 不传 `sourceType` | `201`；`rawEntry.sourceType == text` |
| P4 | `rawText` 仅空白 | `rawText`: `"   \n\t  "` | `400` |
| P5 | 缺少 `rawText` | body `{}` 或 `rawText: null` | `400` |
| P6 | 非法 `sourceType` | 非 `text` | `400` |

**仓储层单测（推荐）**

| # | 用例名 | 断言要点 |
|---|--------|----------|
| R1 | 创建后可 `listItems` | 能查到对应 `rawEntryId` |
| R2 | 同次 `items` 共享 `rawEntryId` | 与 P1 呼应 |

---

### 3.3 `GET /items`（查）

**查询参数**

| 参数 | 取值 | 说明 |
|------|------|------|
| `type` | 省略、`all`、`task`、`metric`、`note` | 省略与 `all` 等价 |

**成功：`200 OK`**

响应体：`ParsedItem[]`。排序：按 `createdAt` **降序**。

**建议测试用例**

| # | 用例名 | 请求 | 断言要点 |
|---|--------|------|----------|
| G1 | 空库 | 无 `POST /entries` 前置 | `200`；`[]` |
| G2 | 多条按时间倒序 | 连续两次 `POST /entries` 再 `GET` | `200`；第一条 `createdAt` ≥ 第二条 |
| G3 | `type=task` | 库中含多类型 | `200`；每条 `type == task` |
| G4 | `type=metric` / `type=note` | 同上 | 分别只含对应类型 |
| G5 | `type=all` 与省略一致 | 对比两种 `GET` | 条数与 id 集合一致 |
| G6 | 非法 `type` | `type=foo` | `400` |

**仓储层单测**

| # | 用例名 | 断言要点 |
|---|--------|----------|
| L1 | 列表默认倒序 | `createdAt` 降序 |
| L2 | 按 `type` 筛选 | 类型与条数正确 |

---

## 4. 解析行为与单元测试（支撑 `POST /parse` 与 `POST /entries`）

解析放在独立类（如 `RuleBasedEntryParser`），返回 **`ParsedDraft` 列表**（或内部等价结构）；`POST /entries` 在持久化时再分配 `id`、`rawEntryId`、`createdAt`。

| # | 用例名 | 输入 | 期望（要点） |
|---|--------|------|----------------|
| X1 | 空串 | `""` | HTTP 层 `400`（S3/S4、P4/P5） |
| X2 | 单句 note | 无明确数值与待办模式 | 至少一条 `note` |
| X3 | metric | 含体重类数值 | `metric`，`value`/`unit` 或 `content` 可辨认 |
| X4 | PRD 整句 | 与 S2/P2 相同 | 条数与类型集合一致 |

---

## 5. 实现检查清单（本期）

- [ ] `POST /parse`：S1–S6 相关测试绿
- [ ] `POST /entries`：P1–P6 相关测试绿
- [ ] `GET /items`：G1–G6 相关测试绿
- [ ] 仓储：R1–R2、L1–L2 绿（若分层）
- [ ] 解析单测：X1–X4 绿；**与 `/parse`、`/entries` 共用实现**
- [ ] 与 `/todos`、`/projects` 共存无冲突
- [ ] JSON `Content-Type` 与 `_json` / `_error` 一致

---

## 6. 脚注

1. **`POST /parse` 与 `POST /entries`**：字段校验（`rawText`、`sourceType`）应一致，避免「能预览却不能保存」的割裂。  
2. **`sourceType`**：本期仅 `text`；`voice` 可在下一版与转写链路一并放开。  
3. **后续**：`PATCH` / `DELETE` 另开章节或新文档。

---

文档版本：含「解析预览 + 增 + 查」契约与测试清单。
