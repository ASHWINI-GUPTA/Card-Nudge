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
  late String _sort;
  late String _range;

  @override
  void initState() {
    super.initState();
    final filter = widget.ref.read(filterProvider);
    _sort = filter['sort'] ?? 'asc';
    _range = filter['range'] ?? 'all';
  }

  void _applyFilters() {
    widget.ref
        .read(filterProvider.notifier)
        .update((state) => {...state, 'sort': _sort, 'range': _range});
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
                    selected: _sort == 'asc',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _sort = 'asc';
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _sort == 'asc'
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('DESC'),
                    selected: _sort == 'desc',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _sort = 'desc';
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _sort == 'desc'
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
                    selected: _range == 'all',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _range = 'all';
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _range == 'all'
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('< ₹5,000'),
                    selected: _range == 'low',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _range = 'low';
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _range == 'low'
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('₹5,000 - ₹10,000'),
                    selected: _range == 'medium',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _range = 'medium';
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _range == 'medium'
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('> ₹10,000'),
                    selected: _range == 'high',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _range = 'high';
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color:
                          _range == 'high'
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
