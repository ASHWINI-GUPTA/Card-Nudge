import 'package:card_nudge/data/enums/amount_range.dart';
import 'package:card_nudge/data/enums/sort_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_strings.dart';
import '../providers/filter_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  final WidgetRef ref;

  const FilterBottomSheet({super.key, required this.ref});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late SortOrder _sort;
  late AmountRange _range;

  @override
  void initState() {
    super.initState();
    // Only lightweight state initialization here
    final filter = widget.ref.read(dueFilterProvider);
    _sort = filter.sort;
    _range = filter.range;
  }

  void _applyFilters() {
    widget.ref
        .read(dueFilterProvider.notifier)
        .updateFilter(sort: _sort, range: _range);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Sort by Amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Row(
                children: [
                  ChoiceChip(
                    label: const Text('ASC'),
                    selected: _sort == SortOrder.asc,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _sort = SortOrder.asc;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _sort == SortOrder.asc
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('DESC'),
                    selected: _sort == SortOrder.desc,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _sort = SortOrder.desc;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _sort == SortOrder.desc
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Amount Range',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              subtitle: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Any'),
                    selected: _range == AmountRange.all,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _range = AmountRange.all;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _range == AmountRange.all
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('< ₹5,000'),
                    selected: _range == AmountRange.low,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _range = AmountRange.low;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _range == AmountRange.low
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('₹5,000 - ₹10,000'),
                    selected: _range == AmountRange.medium,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _range = AmountRange.medium;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _range == AmountRange.medium
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('> ₹10,000'),
                    selected: _range == AmountRange.high,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _range = AmountRange.high;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _range == AmountRange.high
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.cancelButton,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 8),

                TextButton(
                  onPressed: () {
                    widget.ref.read(dueFilterProvider.notifier).resetFilter();
                  },
                  child: Text(
                    AppStrings.resetButton,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _applyFilters,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(AppStrings.applyButton),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
