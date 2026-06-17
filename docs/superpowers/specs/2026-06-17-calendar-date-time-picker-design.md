# Calendar-First Date & Time Picker — Design Spec

**Date**: 2026-06-17
**Status**: Approved
**Topic**: Replace `omni_datetime_picker` with a custom calendar-first bottom sheet picker styled in the app's Warm Spa palette.

## 1. Motivation

The current `showOmniDateTimePicker` (from `omni_datetime_picker: ^2.3.2`) looks generic — it uses default Material 3 colors and lacks the app's distinctive warm spa character. The dialog feels foreign in an otherwise carefully designed booking flow.

### Goals
- Remove the `omni_datetime_picker` dependency entirely
- Deliver a calendar-first date + time slot picker that matches the app's Warm Spa aesthetic
- Keep the same API contract at the call site (a single `Future<DateTime?>` call)

### Non-goals
- No time-range selection (single point-in-time only)
- No recurring schedule support
- No backend availability integration (all slots shown as available for now)

## 2. Architecture

### File Structure

```
lib/presentation/widgets/date_time_picker_sheet.dart   # NEW — contains everything
lib/presentation/controllers/order_controller.dart       # MODIFIED — replace omni call
```

### Widget Tree

```
showModalBottomSheet
  └── DateTimePickerSheet (StatefulWidget)
        ├── Handle bar (drag indicator)
        ├── Header ("选择服务时间")
        ├── SelectedDateBanner (gradient card: 6月17日 星期二 · 09:00)
        ├── CalendarGrid
        │     ├── Month navigation (‹ 2026年6月 ›)
        │     ├── Weekday headers (一 二 三 四 五 六 日)
        │     ├── Day cells (grid)
        │     └── "今天" quick-jump pill
        ├── TimeSlotGrid
        │     ├── Section label ("选择时间")
        │     └── Time chips (flex-wrap grid)
        └── ConfirmButton (gradient CTA)
```

### Data Flow

```
OrderController.selectServiceDateTime(context)
  → showModalBottomSheet<DateTime>(context, builder: …)
    → DateTimePickerSheet manages internal state:
        - _selectedDate: DateTime
        - _selectedTime: TimeOfDay
        - _currentMonth: DateTime (for calendar navigation)
    → onConfirm: Navigator.pop(context, combinedDateTime)
  → controller updates _selectedDate & _selectedTime as before
```

No new controller needed — the sheet widget is self-contained. State lives in the widget's `State` class.

## 3. Visual Design

### Color Tokens (from AppTheme)

| Token | Usage |
|-------|-------|
| `gold #C4956A` | Selected date bg, time chip border, accents |
| `amber #B8860B` | Gradient end, weekend labels |
| `creamBg #F7F5F2` | Sheet background, disabled chips |
| `warmBorder #E8E2D8` | Unselected chip borders, dividers |
| `textPrimary #2D2A26` | Day numbers, labels |
| `textSecondary #6B5E53` | Subtitle text |
| `textMuted #B8A99A` | Weekday headers, disabled text |
| `danger #D4736A` | Saturday/Sunday labels |

### Component States

**Day cell:**
- *Default*: White circle, textPrimary text
- *Selected*: Gold→Amber gradient circle, white text, glow shadow
- *Today*: 1px gold border, textPrimary text (when not selected)
- *Past/disabled*: creamBg, textMuted, no tap
- *Weekend*: danger-colored text (red-tinted)

**Time chip:**
- *Default*: White bg, warmBorder border, textPrimary text
- *Selected*: Gold→Amber gradient, white text, glow shadow
- *Unavailable*: creamBg, warmBorder, textMuted, no tap (reserved for future backend integration)

**Confirm button:**
- *Enabled*: Gold→Amber gradient, white text, glow shadow
- *Disabled*: creamBg, textMuted, no shadow (when no date+time selected)

### Dimensions & Spacing

- Sheet border-radius: 20r (top-left, top-right)
- Calendar card border-radius: 20r
- Day cell size: 40×40
- Time chip: 10h padding, 10r border-radius
- Confirm button: 56h height, 14r border-radius
- Section spacing: 16–20h

## 4. Behavior

### Calendar

- **Range**: Today → Today + 90 days (matching current `lastDate`)
- **Month navigation**: ‹ › arrows, no horizontal swipe (keeps it simple)
- **Today pill**: Scrolls to current month + selects today if within range
- **Weekend labels**: Saturday & Sunday shown in danger color
- **Past dates**: Visually dimmed, non-interactive

### Time Slots

- **Range**: 08:00 → 20:00
- **Interval**: 30 minutes (hardcoded for now; matching current `minutesInterval: 5` is too granular for a chip grid — 30min feels right for service booking)
- **Selection**: Tap to select, chips wrap in a flex grid
- **Scroll**: If chips overflow, the entire sheet is scrollable via the bottom sheet's built-in scroll behavior

### Confirm Action

- Requires both date AND time selected to be enabled
- Returns combined `DateTime` via `Navigator.pop`
- The caller (`OrderController.selectServiceDateTime`) receives it and updates state exactly as before

## 5. API

```dart
/// Shows a calendar-first date & time picker as a modal bottom sheet.
///
/// [context] — BuildContext (required for showModalBottomSheet)
/// [initialDate] — Pre-selected date (defaults to now)
/// [initialTime] — Pre-selected time (defaults to 09:00)
/// [firstDate] — Earliest selectable date (defaults to today)
/// [lastDate] — Latest selectable date (defaults to today + 90 days)
///
/// Returns the selected [DateTime], or null if dismissed.
Future<DateTime?> showDateTimePickerSheet({
  required BuildContext context,
  DateTime? initialDate,
  TimeOfDay? initialTime,
  DateTime? firstDate,
  DateTime? lastDate,
});
```

### Migration (OrderController)

```dart
// BEFORE (omni_datetime_picker)
final picked = await showOmniDateTimePicker(
  context: context,
  initialDate: initialDate ?? now,
  firstDate: now,
  lastDate: now.add(const Duration(days: 90)),
  is24HourMode: true,
  isShowSeconds: false,
  minutesInterval: 5,
  borderRadius: BorderRadius.circular(16),
  title: const Text('选择服务时间'),
  theme: Theme.of(context).copyWith(...),
);

// AFTER (custom calendar picker)
final picked = await showDateTimePickerSheet(
  context: context,
  initialDate: initialDate ?? now,
  firstDate: now,
  lastDate: now.add(const Duration(days: 90)),
);
```

## 6. Dependency Impact

### Removed
- `omni_datetime_picker: ^2.3.2` — no longer needed (remove from `pubspec.yaml`, run `flutter pub get`)

### Added
- None — built entirely with Flutter Material widgets

## 7. Testing

- Unit: Verify date range clamping, time slot generation
- Widget: Verify day selection, time selection, confirm button enable/disable
- Integration: Verify the full flow from OrderCreateScreen tap → picker opens → select → returns to controller

## 8. Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Calendar grid layout bugs across screen sizes | Use `LayoutBuilder` + responsive sizing; test on small (360dp) and large (414dp) widths |
| 30-minute interval too coarse vs. old 5-minute | Acceptable for MVP; can add interval parameter later if needed |
| Bottom sheet height on small screens | Use `FractionallySizedBox` or `constrainedBox` to cap height; make content scrollable |
