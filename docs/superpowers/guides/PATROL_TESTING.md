# Patrol Test 运行方式

## 简介

Patrol 是一个用于 Flutter 应用的端到端测试框架，它扩展了 Flutter 的测试能力，提供了更强大的原生交互支持。

## 运行 Patrol 测试

### 基本命令

运行 Patrol 测试的基本命令：

```bash
patrol test --target patrol_test/测试文件名.dart
```

### 开发模式

在开发过程中，可以使用开发模式来支持热重启：

```bash
patrol develop --target patrol_test/测试文件名.dart
```

在开发模式下，可以在终端中输入 "r" 来重新运行测试而无需重新构建应用。

## 测试结构

Patrol 测试文件通常位于 `patrol_test/` 目录下，具有以下结构：

```dart
void main() {
  patrolTest('测试描述', ($) async {
    // 测试代码
    await $.pumpWidgetAndSettle(你的应用根组件());
    
    // 执行操作和断言
    await $('元素标识').tap();
    expect($('预期文本'), findsOneWidget);
  });
}
```

## 原生交互

Patrol 提供了对原生操作的支持，例如处理权限弹窗：

```dart
if (await $.platform.mobile.isPermissionDialogVisible()) {
  await $.platform.mobile.grantPermissionWhenInUse();
}
```

## 控件定位

建议使用 Key 来定位控件，可以在单独的文件中集中定义：

```dart
class LoginPageKeys {
  final emailTextField = const Key('emailTextField');
  final passwordTextField = const Key('passwordTextField');
  final signInButton = const Key('signInButton');
}
```

在测试中使用：
```dart
await $(keys.signInPage.emailTextField).enterText('test@example.com');
```

## 项目中的 Patrol 测试

在当前项目中，Patrol 测试文件位于：
- `patrol_test/create_project_and_background_test.dart`

可以通过以下命令运行：
```bash
patrol test --target patrol_test/create_project_and_background_test.dart
```