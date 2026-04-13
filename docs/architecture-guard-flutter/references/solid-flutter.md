# Flutter/Dart 六大原则专项判断规则

## 1. 单一职责原则 (SRP)

**判断标准：一个类只有一个引起它变化的原因。**

### Flutter 专项检查

**Widget 层**
- ✅ Widget 只负责 UI 渲染和用户交互
- 🔴 Widget build() 内含网络请求、数据库操作、业务计算
- 🔴 `StatefulWidget` 的 `State` 同时管理 UI 状态 + 业务状态 + 网络请求
- 🟡 Widget 超过 200 行，承担多个 UI 区块职责

**Service/Repository 层**
- ✅ Repository 只负责数据获取和缓存策略
- ✅ Service 只负责业务逻辑编排
- 🔴 Repository 内含业务逻辑判断（如权限校验、数据转换业务规则）
- 🟡 Service 同时负责数据获取和业务处理

**Model 层**
- ✅ Model 只承载数据结构和简单转换（fromJson/toJson）
- 🟡 Model 内含复杂业务逻辑或 UI 格式化逻辑

### 评分锚点
| 分数 | 描述 |
|------|------|
| 9–10 | 所有类职责单一，变化原因唯一 |
| 7–8  | 轻微职责混合，但不影响主要功能 |
| 5–6  | UI/业务混写，但有一定分层意识 |
| 3–4  | Widget 承担多个不相关职责 |
| 0–2  | 典型"上帝类"，职责混乱 |

---

## 2. 里氏替换原则 (LSP)

**判断标准：子类必须能替换父类且不破坏程序正确性。**

### Flutter 专项检查

- ✅ 子类完整实现父类/接口的所有方法，且语义一致
- ✅ override 后的方法输入参数类型 ≥ 父类（更宽松），输出类型 ≤ 父类（更严格）
- 🔴 `override` 方法抛出 `UnimplementedError` 或 `UnsupportedError`
- 🔴 子类 override 方法改变了父类方法的核心语义（如：父类 `save()` 保存到本地，子类改为仅内存缓存不持久化，但调用方不知情）
- 🟡 子类新增前置条件比父类更严格（如父类允许 null，子类不允许）
- 🟡 Mixin 方法在某些子类中 override 为空实现

### 评分锚点
| 分数 | 描述 |
|------|------|
| 9–10 | 所有继承关系语义一致，可安全替换 |
| 7–8  | 存在轻微语义偏差，但不影响主流程 |
| 5–6  | 部分 override 改变语义，有隐患 |
| 0–4  | 存在 `UnimplementedError` 或明确违反替换关系 |

---

## 3. 依赖注入原则 (DIP)

**判断标准：高层模块不依赖低层模块，二者都依赖抽象。**

### Flutter 专项检查

**依赖方向**
- ✅ Widget/ViewModel/Bloc 依赖抽象 `abstract class` 或 `interface`
- ✅ 具体实现通过构造函数注入或 DI 框架（get_it、injectable）注入
- 🔴 Widget 内 `final repo = UserRepository()` 直接实例化具体类
- 🔴 Bloc/Provider 内 `http.Client()` 或 `Dio()` 直接创建网络客户端
- 🟡 使用全局单例但未抽象接口（`GetIt.instance<UserRepository>()`）

**可测试性指标**（DIP 的直接结果）
- ✅ 核心业务类可在不启动 Flutter 框架的情况下单元测试
- 🔴 测试需要真实网络 / 数据库，无法 mock

**Provider/Bloc 特殊规则**
- ✅ `Provider.of<UserRepository>(context)` — 依赖抽象接口
- 🟡 `Provider.of<UserRepositoryImpl>(context)` — 依赖具体实现
- 🔴 在 Widget 树深处直接 `context.read<XxxServiceImpl>()` 绕过抽象

### 评分锚点
| 分数 | 描述 |
|------|------|
| 9–10 | 全面面向接口，依赖可替换，易于测试 |
| 7–8  | 大部分依赖抽象，少量具体依赖 |
| 5–6  | 混合使用，部分关键路径直接依赖实现 |
| 0–4  | 大量直接实例化，无抽象层 |

---

## 4. 接口分离原则 (ISP)

**判断标准：接口应小而精，不强迫实现类依赖它不需要的方法。**

### Flutter 专项检查

- ✅ `abstract class` 方法数量 ≤ 5，职责单一
- ✅ 不同使用方依赖不同的细粒度接口
- 🟡 `abstract class` 超过 8 个方法，且实现类中有多个方法体为空或 throw
- 🟡 Repository 接口同时包含读、写、缓存、统计方法，不同场景只用其中一部分
- 🔵 可将大接口拆分为 `ReadableRepository` + `WritableRepository`

**Dart 特殊语法**
- Dart 无 `interface` 关键字，用 `abstract class` 模拟接口
- Dart 3.0+ 有 `interface class`，优先使用以明确语义
- Mixin 是实现 ISP 的有效工具，但要避免 Mixin 方法过多

### 评分锚点
| 分数 | 描述 |
|------|------|
| 9–10 | 接口粒度合理，无冗余方法 |
| 7–8  | 接口略大，但实现类基本都用到 |
| 5–6  | 存在"胖接口"，有空实现或 throw |
| 0–4  | 接口臃肿，大量方法未被使用 |

---

## 5. 迪米特原则 (LoD)

**判断标准：一个对象应只与直接朋友通信，不与陌生人说话。**

### Flutter 专项检查

**直接朋友 = 当前类的成员变量、方法参数、方法返回值**

- ✅ `user.name` — 访问直接依赖对象的属性
- 🟡 `user.address.city` — 穿透一层，轻微违反
- 🔴 `order.user.address.city.zipCode` — 链式穿透，严重违反
- 🔴 Widget 通过 `context.read<AppState>().currentUser.profile.settings.theme` 获取数据

**Flutter 特殊场景**
- 🟡 在 Widget 深处直接访问全局 `AppState` 的深层属性
- 🟡 Service 直接访问另一个 Service 的内部数据结构
- ✅ 使用值对象（Value Object）封装常用组合属性

**解决方案提示**
- 为常用组合访问路径提供封装方法（Tell, Don't Ask）
- 使用 `extension` 在不修改原类的情况下添加快捷访问

### 评分锚点
| 分数 | 描述 |
|------|------|
| 9–10 | 无跨层访问，通信边界清晰 |
| 7–8  | 偶有两层访问，但未暴露内部结构 |
| 5–6  | 链式访问存在，有一定耦合 |
| 0–4  | 大量跨层访问，模块边界模糊 |

---

## 6. 开闭原则 (OCP)

**判断标准：对扩展开放，对修改关闭。新增功能通过扩展而非修改已有代码实现。**

### Flutter 专项检查

**典型腐化模式**
- 🔴 添加新支付方式需修改 `PaymentService` 内的 `if-else` / `switch`
- 🔴 添加新主题需修改 `ThemeManager` 的分支逻辑
- 🔴 添加新页面类型需修改路由 `switch` 语句
- 🟡 添加新功能需要修改已有类的多个方法

**符合 OCP 的模式**
- ✅ 策略模式：将变化行为抽象为接口，新增策略不修改已有代码
- ✅ 工厂模式：通过注册机制扩展，不修改工厂逻辑
- ✅ Flutter 路由：使用 `GoRouter` / `AutoRoute` 配置化路由，避免手写 switch

**注意：OCP 不意味着不能修改代码**
- 修复 bug → 允许修改
- 重构优化 → 允许修改
- **新增功能** → 应通过扩展，而非修改

### 评分锚点
| 分数 | 描述 |
|------|------|
| 9–10 | 新功能通过扩展接入，无需修改已有类 |
| 7–8  | 偶尔需要小改动，但影响范围可控 |
| 5–6  | 扩展时频繁修改已有类 |
| 0–4  | 核心类充满条件分支，无法不修改地扩展 |
