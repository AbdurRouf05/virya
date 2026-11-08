import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:virya/core/constants/sport_category.dart';

enum CalendarView { year, month }

/// UI state of the KALENDER tab.
class CalendarState {
  final CalendarView view;

  /// null = SEMUA.
  final SportCategory? filter;

  /// First day of the month shown in the month grid; its year drives the
  /// heatmap.
  final DateTime month;

  /// Tapped day (local midnight), or null.
  final DateTime? selected;

  const CalendarState({
    required this.view,
    required this.filter,
    required this.month,
    required this.selected,
  });

  int get year => month.year;

  CalendarState copyWith({
    CalendarView? view,
    SportCategory? Function()? filter,
    DateTime? month,
    DateTime? Function()? selected,
  }) => CalendarState(
    view: view ?? this.view,
    filter: filter != null ? filter() : this.filter,
    month: month ?? this.month,
    selected: selected != null ? selected() : this.selected,
  );
}

class CalendarController extends AutoDisposeNotifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return CalendarState(
      view: CalendarView.month,
      filter: null,
      month: DateTime(now.year, now.month),
      selected: today,
    );
  }

  void setView(CalendarView v) => state = state.copyWith(view: v);

  void setFilter(SportCategory? f) => state = state.copyWith(filter: () => f);

  /// Moves the month grid by [delta] months.
  void shiftMonth(int delta) => state = state.copyWith(
    month: DateTime(state.month.year, state.month.month + delta),
  );

  /// Moves the heatmap by [delta] years (keeps the month number).
  void shiftYear(int delta) => state = state.copyWith(
    month: DateTime(state.month.year + delta, state.month.month),
  );

  /// Selects [day] (tap again to clear) and brings its month into view.
  void select(DateTime day) {
    final same = state.selected == day;
    state = state.copyWith(
      selected: () => same ? null : day,
      month: DateTime(day.year, day.month),
    );
  }
}

final calendarControllerProvider =
    NotifierProvider.autoDispose<CalendarController, CalendarState>(
      CalendarController.new,
    );
