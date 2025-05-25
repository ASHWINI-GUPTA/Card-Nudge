import 'package:card_nudge/data/enums/amount_range.dart';
import 'package:card_nudge/data/enums/sort_order.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AmountFilter {
  final SortOrder sort;
  final AmountRange range;

  AmountFilter({this.sort = SortOrder.asc, this.range = AmountRange.all});

  AmountFilter copyWith({SortOrder? sort, AmountRange? range}) {
    return AmountFilter(sort: sort ?? this.sort, range: range ?? this.range);
  }
}

final dueFilterProvider = StateNotifierProvider<FilterNotifier, AmountFilter>(
  (ref) => FilterNotifier(),
);

class FilterNotifier extends StateNotifier<AmountFilter> {
  FilterNotifier() : super(AmountFilter());

  bool get isFilterApplied =>
      state.sort != SortOrder.asc || state.range != AmountRange.all;

  void updateFilter({SortOrder? sort, AmountRange? range}) {
    state = state.copyWith(sort: sort, range: range);
  }

  void resetFilter() {
    state = AmountFilter();
  }
}
