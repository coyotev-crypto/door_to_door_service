# 我的钱包 — UI 设计文档

**日期**: 2026-06-21
**状态**: 已确认（仅 UI 设计，不含后端实现）

---

## 1. 概述

为服务人员端新增"我的钱包"功能，提供余额查看、交易流水、提现申请、提现记录等界面。

### 后端 API（已就绪）

| 方法 | 路径 | 用途 |
|------|------|------|
| GET | `/api/v1/wallet` | 获取钱包信息（余额/冻结/累计） |
| GET | `/api/v1/wallet/transactions` | 交易流水列表 |
| POST | `/api/v1/wallet/withdraw` | 申请提现 |
| GET | `/api/v1/wallet/withdrawals` | 提现记录列表 |
| GET | `/api/v1/wallet/withdrawals/:id` | 提现详情 |

---

## 2. 页面架构

```
个人中心 (ProfileScreen)
  └─ 「我的钱包」菜单项 → /wallet
       ├─ 余额卡片（可用/冻结/累计 + 提现按钮）
       ├─ 交易流水列表（最近 N 条 + "查看全部"）
       ├─ 点击流水条目 → /wallet/transactions
       └─ 提现按钮 → /wallet/withdraw
            ├─ 提现表单（金额/账户/到账金额）
            └─ 提现记录列表
                 └─ 点击条目 → /wallet/withdrawals/:id
```

### 新增路由

```dart
// route_names.dart
static const String wallet = '/wallet';
static const String walletWithdraw = '/wallet/withdraw';
static const String walletTransactions = '/wallet/transactions';
static const String walletWithdrawalDetail = '/wallet/withdrawals/:id';
```

### 入口

ProfileScreen 中添加"我的钱包"菜单项，使用现有 `_menuItem` 模式。

---

## 3. 钱包首页 — WalletScreen

### 3.1 布局结构

```
┌──────────────────────────┐
│  AppBar: 我的钱包         │
├──────────────────────────┤
│  ┌── 余额卡片 ──────────┐│
│  │  可用余额              ││
│  │  ¥ 12,580.00         ││  ← 金色渐变背景，白色文字
│  │  ─────────────────    ││
│  │  冻结 ¥200  累计 ¥86K││  ← 分割线下方两列数据
│  │  [      提现      ]  ││  ← 半透明白色按钮
│  └──────────────────────┘│
│                          │
│  交易流水        查看全部 →│
│  ┌── 流水列表 ──────────┐│
│  │ 订单收入    +¥580.00 ││
│  │ 06-21 14:30          ││
│  │ ──────────────────── ││
│  │ 提现       -¥1,000.00││
│  │ 06-20 09:15          ││
│  │ ──────────────────── ││
│  │ 订单收入    +¥320.00 ││
│  │ 06-19 16:45          ││
│  └──────────────────────┘│
└──────────────────────────┘
```

### 3.2 设计要点

- **背景色**: `AppTheme.creamBg`
- **余额卡片**: `LinearGradient(colors: [AppTheme.gold, AppTheme.amber])`，圆角 16.r
- **金额字体**: 36.sp，FontWeight.w800，白色
- **冻结/累计**: 11.sp 标签，16.sp 数值
- **提现按钮**: 半透明白色 `rgba(255,255,255,0.2)`，圆角 10.r
- **交易列表**: 白色卡片 `BorderRadius.circular(14.r)`，分割线 `AppTheme.warmBorder`
- **收入**: `#4CAF50`（绿色），**支出**: `#E57373`（红色）
- **列表项**: 标题 14.sp w600 + 时间 11.sp muted

### 3.3 交互行为

| 操作 | 行为 |
|------|------|
| 点击"提现"按钮 | `Get.toNamed(RouteNames.walletWithdraw)` |
| 点击"查看全部" | `Get.toNamed(RouteNames.walletTransactions)` |
| 点击流水条目 | 暂无交互（仅展示），或跳转对应订单详情 |
| 下拉 | EasyRefresh 下拉刷新 |

---

## 4. 提现页面 — WalletWithdrawScreen

### 4.1 布局结构

```
┌──────────────────────────┐
│  ← 申请提现               │
├──────────────────────────┤
│  🔒 提现将在1-3个工作日  │  ← 提示 Banner
│     内到账...             │
├──────────────────────────┤
│  可提现余额               │
│  ¥ 12,580.00             │  ← 金色大字体
├──────────────────────────┤
│  ┌── 提现表单 ──────────┐│
│  │ 提现金额              ││
│  │ [¥ 请输入提现金额   ] ││  ← 输入框
│  │ 最低提现金额 ¥10.00   ││
│  │                       ││
│  │ 到账账户              ││
│  │ [💳 中国银行 尾号3829]││  ← 可切换
│  │                       ││
│  │ 到账金额              ││
│  │ ¥ 0.00               ││
│  │ 手续费 ¥0.00          ││
│  │                       ││
│  │ [    确认提现        ]││  ← 金色渐变按钮
│  └──────────────────────┘│
│                          │
│  提现记录                 │
│  ┌── 记录列表 ──────────┐│
│  │ 提现¥1,000 [处理中]   ││
│  │ 中国银行·3829·06-20  ││
│  │ ──────────────────── ││
│  │ 提现¥500   [已完成]   ││
│  │ 中国银行·3829·06-15  ││
│  │ ──────────────────── ││
│  │ 提现¥2,000 [已完成]   ││
│  │ 中国银行·3829·06-10  ││
│  └──────────────────────┘│
└──────────────────────────┘
```

### 4.2 设计要点

- **提示 Banner**: 金色半透明渐变 + 金色边框，12.r 圆角，信息图标前置
- **可提现余额**: 12.sp 标签 muted，32.sp 数值 gold
- **表单卡片**: 白色背景，16.r 圆角，输入框 creamBg 填充
- **到账账户行**: 银行图标 + 银行名 + 尾号 + 切换箭头
- **到账金额**: 20.sp w800，手续费 11.sp muted
- **提现按钮**: 金色渐变，14.r 圆角，14.r 阴影，16.sp 白色 w700
- **状态标签**: "处理中"=橙底橙字，"已完成"=绿底绿字，"已拒绝"=红底红字

### 4.3 交互行为

| 操作 | 行为 |
|------|------|
| 输入金额 | 实时计算到账金额（金额 - 手续费） |
| 点击"切换"账户 | Bottom Sheet 选择其他银行卡 |
| 点击"确认提现" | 表单验证 → POST /withdraw → Toast + 返回 |
| 点击提现记录条目 | `Get.toNamed('/wallet/withdrawals/:id')` |

---

## 5. 交易流水页 — WalletTransactionsScreen

### 5.1 布局

全屏列表页面，标题"交易流水"，支持 EasyRefresh 上拉加载更多。

每个列表项：
```
┌──────────────────────────────┐
│ 订单收入              +¥580  │  ← 标题 + 金额（绿/红）
│ 订单 #202606211430          │  ← 订单号/备注
│ 2026-06-21 14:30:00         │  ← 时间
└──────────────────────────────┘
```

- 列表项样式与首页流水一致，带分割线
- 无数据时显示空状态占位

---

## 6. 提现详情页 — WalletWithdrawalDetailScreen

### 6.1 布局

全屏页面，标题"提现详情"，展示提现单的完整信息：

```
┌──────────────────────────┐
│  ← 提现详情               │
├──────────────────────────┤
│  ┌── 状态卡片 ──────────┐│
│  │    ✅ 已完成          ││  ← 大图标 + 状态文案
│  │    提现金额已到账     ││
│  └──────────────────────┘│
│                          │
│  ┌── 详情卡片 ──────────┐│
│  │ 提现金额     ¥1,000  ││
│  │ 手续费        ¥0.00  ││
│  │ 到账金额     ¥1,000  ││
│  │ 到账银行     中国银行 ││
│  │ 银行卡尾号   3829     ││
│  │ 申请时间     06-20   ││
│  │ 到账时间     06-22   ││
│  └──────────────────────┘│
└──────────────────────────┘
```

---

## 7. 数据模型（前端使用）

```dart
// 钱包信息
class WalletModel {
  final double availableBalance;  // 可用余额
  final double frozenBalance;     // 冻结金额
  final double totalIncome;       // 累计收入
}

// 交易流水条目
class WalletTransactionModel {
  final int id;
  final String type;       // income / withdraw
  final String description;
  final double amount;
  final String orderNo;
  final DateTime createdAt;
}

// 提现记录
class WithdrawalModel {
  final int id;
  final double amount;
  final double fee;
  final String status;     // pending / completed / rejected
  final String bankName;
  final String bankCardTail;
  final DateTime createdAt;
  final DateTime? completedAt;
}
```

---

## 8. 文件清单

| 文件 | 类型 | 说明 |
|------|------|------|
| `lib/presentation/screens/wallet/wallet_screen.dart` | 新增 | 钱包首页 |
| `lib/presentation/screens/wallet/wallet_withdraw_screen.dart` | 新增 | 提现页面 |
| `lib/presentation/screens/wallet/wallet_transactions_screen.dart` | 新增 | 交易流水列表 |
| `lib/presentation/screens/wallet/wallet_withdrawal_detail_screen.dart` | 新增 | 提现详情 |
| `lib/presentation/controllers/wallet_controller.dart` | 新增 | 钱包控制器 |
| `lib/data/models/wallet_model.dart` | 新增 | 数据模型 |
| `lib/routes/route_names.dart` | 修改 | 新增 4 个路由常量 |
| `lib/routes/app_pages.dart` | 修改 | 注册新路由 |
| `lib/presentation/screens/account/profile_screen.dart` | 修改 | 添加"我的钱包"入口 |
| `lib/core/network/api_endpoints.dart` | 修改 | 新增钱包 API 端点 |

**总计**: 6 个新文件 + 4 个修改文件，纯 UI 层。
