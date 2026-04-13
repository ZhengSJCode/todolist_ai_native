# Flutter 常用设计模式及适用场景

> **使用原则：只在代码已出现架构问题、且引入成本低于长期维护成本时才建议。**
> 如无明确腐化信号，注明"保持简单实现即可"。

---

## 创建型模式

### 工厂方法 (Factory Method)
**适用信号：**
- 存在根据类型创建不同对象的 `switch/if-else`
- 对象创建逻辑复杂，且在多处重复

**Flutter 典型场景：**
```dart
// 腐化代码：每次新增类型都要修改这里
Widget buildCard(String type) {
  if (type == 'video') return VideoCard();
  if (type == 'image') return ImageCard();
  // 新类型 → 修改此处 → 违反 OCP
}

// 引入工厂后：新增类型只需注册，不修改工厂
abstract class CardFactory {
  Widget create();
}
```
**不建议引入时机：** 只有 2-3 种类型且短期内不会扩展。

---

### 单例 (Singleton)
**适用信号：** 全局唯一的配置、缓存、日志管理器。

**Flutter 建议：** 优先用 `get_it` 管理单例，而非手写 `instance` 模式，便于测试时替换。

**不建议引入时机：** 滥用单例传递状态（应使用 Provider/Riverpod）。

---

## 结构型模式

### 装饰器 (Decorator)
**适用信号：**
- 需要在不修改原类的情况下增强行为（日志、缓存、重试）
- 行为组合多变

**Flutter 典型场景：**
```dart
// 为 Repository 添加缓存层，不修改原实现
class CachedUserRepository implements UserRepository {
  final UserRepository _inner;
  final Cache _cache;
  // ...
}
```
**不建议引入时机：** 只有一种行为增强，直接继承或修改更简单。

---

### 适配器 (Adapter)
**适用信号：**
- 接入第三方 SDK，需要隔离外部接口
- 旧接口与新接口不兼容

**不建议引入时机：** 仅为了"看起来更整洁"，实际无接口差异。

---

## 行为型模式

### 策略 (Strategy)
**适用信号：**
- 同一操作有多种算法/实现，且会继续增加
- 存在大量条件分支选择行为

**Flutter 典型场景：**
```dart
// 支付策略：新增支付方式不修改已有代码
abstract class PaymentStrategy {
  Future<void> pay(double amount);
}
class AlipayStrategy implements PaymentStrategy { ... }
class WechatPayStrategy implements PaymentStrategy { ... }
```
**不建议引入时机：** 只有固定的 2 种策略且不会增加。

---

### 观察者 (Observer)
**Flutter 中的替代：** Stream、ValueNotifier、Riverpod、BLoC 已是观察者模式的框架实现。
**建议：** 优先使用框架提供的响应式机制，不手写观察者。

---

### 命令 (Command)
**适用信号：**
- 需要操作历史、撤销/重做功能
- 操作需要排队或异步执行

**不建议引入时机：** 无撤销需求的普通业务操作。

---

### 模板方法 (Template Method)
**适用信号：**
- 多个流程步骤相同，只有部分步骤不同
- 避免子类之间重复相同的步骤逻辑

**Flutter 典型场景：**
```dart
// 列表页基类：加载→展示→错误处理流程相同，只有数据获取不同
abstract class BaseListPage<T> extends StatefulWidget {
  Future<List<T>> fetchData();
  Widget buildItem(T item);
  // 模板：loadData → setState → buildList 流程固定
}
```

---

## Flutter 特有架构模式

### Repository Pattern
**何时必须引入：** Widget 或 BLoC 直接调用网络/数据库（SRP + DIP 双违反）。
**结构：**
```
Widget/BLoC → Repository(abstract) → RemoteDataSource / LocalDataSource
```

### BLoC / Cubit
**何时建议引入：** 页面状态复杂（3+ 种状态），多个 Widget 共享状态。
**何时不需要：** 简单表单、单次请求的独立页面，`StatefulWidget` 足够。

### Clean Architecture 分层
**何时建议引入：** 项目规模中大型，多人协作，需要明确边界。
**何时不需要：** 小型功能模块、原型验证阶段，过早分层增加不必要复杂度。
