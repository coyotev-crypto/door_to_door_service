import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';
import '../../core/utils/screen_adapter.dart';

Future<DateTime?> showDateTimePickerSheet({
  required BuildContext context,
  DateTime? initialDate,
  TimeOfDay? initialTime,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final now = DateTime.now();
  final resolvedFirstDate = _dateOnly(firstDate ?? now);
  final resolvedLastDate =
      _dateOnly(lastDate ?? now.add(const Duration(days: 90)));
  final resolvedInitialDate = _clampDate(
    _dateOnly(initialDate ?? now),
    resolvedFirstDate,
    resolvedLastDate,
  );
  final resolvedInitialTime = initialTime ??
      (initialDate != null
          ? TimeOfDay.fromDateTime(initialDate)
          : const TimeOfDay(hour: 9, minute: 0));

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: DateTimePickerSheet(
          initialDate: resolvedInitialDate,
          initialTime: resolvedInitialTime,
          firstDate: resolvedFirstDate,
          lastDate: resolvedLastDate,
        ),
      );
    },
  );
}

class DateTimePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final DateTime firstDate;
  final DateTime lastDate;

  const DateTimePickerSheet({
    super.key,
    required this.initialDate,
    required this.initialTime,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<DateTimePickerSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(widget.initialDate);
    _selectedTime = widget.initialTime;
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: Material(
        color: AppTheme.creamBg,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHandle(),
                      SizedBox(height: 14.h),
                      _buildHeader(),
                      SizedBox(height: 16.h),
                      _buildSelectedBanner(),
                      SizedBox(height: 16.h),
                      _buildCalendarCard(),
                      SizedBox(height: 18.h),
                      _buildTimeSlots(),
                    ],
                  ),
                ),
              ),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 44.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppTheme.warmBorder,
          borderRadius: BorderRadius.circular(99.r),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '选择服务时间',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon:
              Icon(Icons.close_rounded, size: 22.sp, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildSelectedBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_rounded, size: 24.sp, color: Colors.white),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '${_selectedDate.month}月${_selectedDate.day}日 ${_weekdayLabel(_selectedDate)} · ${_formatTime(_selectedTime)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    final canGoPrevious =
        _monthStart(_currentMonth).isAfter(_monthStart(widget.firstDate));
    final canGoNext =
        _monthStart(_currentMonth).isBefore(_monthStart(widget.lastDate));

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.warmBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _monthButton(
                  Icons.chevron_left_rounded, canGoPrevious, _goPreviousMonth),
              Expanded(
                child: Text(
                  '${_currentMonth.year}年${_currentMonth.month}月',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              _monthButton(
                  Icons.chevron_right_rounded, canGoNext, _goNextMonth),
            ],
          ),
          SizedBox(height: 14.h),
          _buildWeekdays(),
          SizedBox(height: 8.h),
          _buildCalendarGrid(),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _selectToday,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(99.r),
                  border:
                      Border.all(color: AppTheme.gold.withValues(alpha: 0.25)),
                ),
                child: Text(
                  '今天',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthButton(IconData icon, bool enabled, VoidCallback onTap) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(
        icon,
        size: 24.sp,
        color:
            enabled ? AppTheme.gold : AppTheme.textMuted.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildWeekdays() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Row(
      children: List.generate(weekdays.length, (index) {
        final isWeekend = index >= 5;
        return Expanded(
          child: Center(
            child: Text(
              weekdays[index],
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isWeekend ? AppTheme.danger : AppTheme.textMuted,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCalendarGrid() {
    final days = _monthDaysWithPadding();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 6.w,
      ),
      itemBuilder: (context, index) {
        final day = days[index];
        if (day == null) return const SizedBox.shrink();
        return _DayCell(
          date: day,
          selected: _isSameDate(day, _selectedDate),
          today: _isSameDate(day, DateTime.now()),
          disabled: _isBeforeDate(day, widget.firstDate) ||
              _isAfterDate(day, widget.lastDate),
          weekend: day.weekday == DateTime.saturday ||
              day.weekday == DateTime.sunday,
          onTap: () {
            setState(() {
              _selectedDate = day;
            });
          },
        );
      },
    );
  }

  Widget _buildTimeSlots() {
    final slots = _timeSlots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择时间',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: slots.map((time) {
            return _TimeChip(
              time: time,
              selected: _sameTime(time, _selectedTime),
              onTap: () {
                setState(() {
                  _selectedTime = time;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 16.h),
      decoration: const BoxDecoration(color: AppTheme.creamBg),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop(DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ));
        },
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            gradient:
                const LinearGradient(colors: [AppTheme.gold, AppTheme.amber]),
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '确认时间',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DateTime?> _monthDaysWithPadding() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final leadingEmptyCells = firstDay.weekday - 1;
    return [
      ...List<DateTime?>.filled(leadingEmptyCells, null),
      ...List.generate(
          daysInMonth,
          (index) =>
              DateTime(_currentMonth.year, _currentMonth.month, index + 1)),
    ];
  }

  List<TimeOfDay> _timeSlots() {
    final slots = <TimeOfDay>[];
    for (var hour = 8; hour <= 20; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
      if (hour < 20) {
        slots.add(TimeOfDay(hour: hour, minute: 30));
      }
    }
    return slots;
  }

  void _goPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _goNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectToday() {
    final today = _clampDate(
        _dateOnly(DateTime.now()), widget.firstDate, widget.lastDate);
    setState(() {
      _selectedDate = today;
      _currentMonth = DateTime(today.year, today.month);
    });
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final bool today;
  final bool disabled;
  final bool weekend;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.selected,
    required this.today,
    required this.disabled,
    required this.weekend,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? Colors.white
        : disabled
            ? AppTheme.textMuted
            : weekend
                ? AppTheme.danger
                : AppTheme.textPrimary;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? null
              : disabled
                  ? AppTheme.creamBg
                  : Colors.white,
          gradient: selected
              ? const LinearGradient(colors: [AppTheme.gold, AppTheme.amber])
              : null,
          border: today && !selected
              ? Border.all(color: AppTheme.gold, width: 1)
              : null,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final TimeOfDay time;
  final bool selected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.time,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? null : Colors.white,
          gradient: selected
              ? const LinearGradient(colors: [AppTheme.gold, AppTheme.amber])
              : null,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
              color: selected ? Colors.transparent : AppTheme.warmBorder),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          _formatTime(time),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _monthStart(DateTime date) => DateTime(date.year, date.month);

DateTime _clampDate(DateTime date, DateTime firstDate, DateTime lastDate) {
  if (_isBeforeDate(date, firstDate)) return firstDate;
  if (_isAfterDate(date, lastDate)) return lastDate;
  return date;
}

bool _isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isBeforeDate(DateTime a, DateTime b) =>
    _dateOnly(a).isBefore(_dateOnly(b));

bool _isAfterDate(DateTime a, DateTime b) => _dateOnly(a).isAfter(_dateOnly(b));

bool _sameTime(TimeOfDay a, TimeOfDay b) =>
    a.hour == b.hour && a.minute == b.minute;

String _formatTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

String _weekdayLabel(DateTime date) {
  const labels = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  return labels[date.weekday - 1];
}
