# 首次设置密码 — 设计文档

**日期**: 2026-06-19  
**状态**: 已确认

---

## 1. 概述

验证码登录的新用户可能从未设置过登录密码。后端在登录响应中返回 `hasSetPassword` 标记，前端据此判断是否需要引导用户完成首次密码设置。

### 用户故事

- 用户通过验证码登录后，若 `hasSetPassword == false`，强制跳转设置密码页
- 设置密码页不可返回，用户必须完成密码设置才能进入首页
- 设置成功后 Toast 提示并跳转首页
- 已设置密码的用户不受影响，直接进入首页

---

## 2. 数据模型变更

### 2.1 LoginResponseModel

新增字段 `hasSetPassword`，字段名与后端保持一致：

```dart
class LoginResponseModel {
  // ... 现有字段 ...
  final bool? hasSetPassword; // 新增

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      // ... 现有映射 ...
      hasSetPassword: json['hasSetPassword'] as bool?,
    );
  }
}
```

---

## 3. 登录拦截流程

`LoginController.handleLogin()` 成功分支中增加判断：

```
登录成功 → 保存 Token → 获取用户信息
  → hasSetPassword == false ?
      是 → Get.offAllNamed(RouteNames.setPassword)  // 清空导航栈，不可返回
      否 → Get.offAllNamed(RouteNames.home)
```

关键约束：
- 使用 `Get.offAllNamed`，清除登录页栈，设置密码页成为新的根
- 设置密码页**不显示返回箭头**，用户必须完成设置
- 设置成功后同样使用 `Get.offAllNamed(RouteNames.home)` 进首页

---

## 4. 设置密码页面

### 4.1 路由

- 路由名：`RouteNames.setPassword = '/account/set-password'`
- 路由注册：`GetPage(name: RouteNames.setPassword, page: () => const SetPasswordScreen())`
- 绑定控制器：复用 `AccountSecurityController`

### 4.2 UI 结构

全屏页面，温润质感风格，与 `ChangePasswordScreen` 一致：

```
┌─────────────────────────────┐
│       设置登录密码           │  ← AppBar，无 leading 返回按钮
├─────────────────────────────┤
│  ┌─ 提示 Banner ──────────┐ │
│  │ 🔒 首次使用，请设置     │ │
│  │   登录密码以保护账户安全│ │
│  └─────────────────────────┘ │
│                             │
│  新密码                      │
│  ┌─────────────────────────┐ │
│  │ 请输入新密码     👁     │ │  ← TextFormField, obscure
│  └─────────────────────────┘ │
│                             │
│  确认密码                    │
│  ┌─────────────────────────┐ │
│  │ 请再次输入新密码 👁     │ │  ← TextFormField, obscure
│  └─────────────────────────┘ │
│                             │
│  ┌─────────────────────────┐ │
│  │      ✨ 确认设置         │ │  ← 金色渐变按钮 / loading
│  └─────────────────────────┘ │
└─────────────────────────────┘
```

### 4.3 验证规则

| 字段 | 规则 |
|------|------|
| 新密码 | 非空，长度 ≥ 6 位 |
| 确认密码 | 非空，必须与新密码一致 |

### 4.4 交互状态

- **正常**：按钮显示"确认设置"
- **加载中**：按钮显示 CircularProgressIndicator
- **成功**：Toast "密码设置成功" → `Get.offAllNamed(RouteNames.home)`
- **失败**：Toast 显示后端错误信息，留在当前页

---

## 5. API 层

### 5.1 端点

复用 `PUT /user/pwd/set`（`ApiEndpoints.changePassword`）。

请求体：
```json
{
  "newPassword": "用户输入的新密码"
}
```

注意：此请求**不传 `oldPassword`**。后端根据用户是否已有密码来区分"设置"（首次）和"修改"（已有密码）。

### 5.2 Repository

`AccountSecurityRepository` 新增方法：

```dart
/// 设置登录密码（首次，无需旧密码）
Future<BaseResponse<void>> setPassword({
  required String newPassword,
}) async {
  final response = await _dioClient.put(
    ApiEndpoints.changePassword,
    data: { 'newPassword': newPassword },
  );
  final baseResponse = BaseResponse<void>.fromJson(response.data);
  if (!baseResponse.isSuccess) throw Exception(baseResponse.message);
  return baseResponse;
}
```

### 5.3 Controller

`AccountSecurityController` 新增：

```dart
final GlobalKey<FormState> setPasswordFormKey = GlobalKey<FormState>();
final TextEditingController setNewPasswordController = TextEditingController();
final TextEditingController setConfirmPasswordController = TextEditingController();
final RxBool isSettingPassword = false.obs;

Future<bool> setPassword() async {
  // 1. 表单验证
  // 2. 调用 repository.setPassword(newPassword: ...)
  // 3. 成功 → Toast + Get.offAllNamed(RouteNames.home)
  // 4. 失败 → Toast + 留在当前页
}
```

---

## 6. 影响范围

| 文件 | 变更 |
|------|------|
| `lib/data/models/login_response_model.dart` | 新增 `hasSetPassword` 字段 |
| `lib/presentation/controllers/login_controller.dart` | `handleLogin()` 增加拦截判断 |
| `lib/routes/route_names.dart` | 新增 `setPassword` 路由常量 |
| `lib/routes/app_pages.dart` | 注册新路由 |
| `lib/presentation/screens/account/set_password_screen.dart` | **新文件**：设置密码页面 |
| `lib/data/repositories/account_security_repository.dart` | 新增 `setPassword()` 方法 |
| `lib/presentation/controllers/account_security_controller.dart` | 新增设置密码相关状态与方法 |

---

## 7. 边界情况

| 场景 | 处理 |
|------|------|
| 设置密码时网络异常 | Toast 提示错误，留在当前页 |
| 设置密码时 Token 过期 | 后端返回错误，前端提示重新登录 |
| 用户强制关闭 App 再打开 | App 启动时 Token 有效则直接进首页（登录成功后 Token 已保存），若后端再次返回 hasSetPassword=false 则再次拦截 |

---

## 8. 与现有功能的区别

| | 设置密码（新） | 修改密码（已有） | 忘记密码（已有） |
|------|-------------|----------------|----------------|
| 入口 | 登录后拦截 | 账户安全 > 登录密码 | 登录页底部弹窗 |
| 是否需要旧密码 | ❌ 不需要 | ✅ 需要 | ❌ 不需要 |
| 是否需要验证码 | ❌ 不需要 | ❌ 不需要 | ✅ 需要 |
| 可返回 | ❌ 不可返回 | ✅ 可返回 | ✅ 关闭弹窗 |
| API | PUT /user/pwd/set | PUT /user/pwd/set | POST /user/pwd/reset-with-code |
