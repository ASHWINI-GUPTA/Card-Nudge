import 'package:card_nudge/data/enums/sync_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sync_provider.dart';

class DataSynchronizationProgressBar extends ConsumerStatefulWidget {
  const DataSynchronizationProgressBar({super.key});

  @override
  ConsumerState<DataSynchronizationProgressBar> createState() =>
      _SyncProgressIndicatorState();
}

class _SyncProgressIndicatorState
    extends ConsumerState<DataSynchronizationProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  final List<Color> _dotColors = [
    Colors.blue[800]!,
    Colors.orange[800]!,
    Colors.red[700]!,
    Colors.green[700]!,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Create color sequence
    final colorTween = TweenSequence<Color?>(
      _dotColors.asMap().entries.map((entry) {
        final nextIndex = (entry.key + 1) % _dotColors.length;
        return TweenSequenceItem(
          weight: 1.0,
          tween: ColorTween(begin: entry.value, end: _dotColors[nextIndex]),
        );
      }).toList(),
    );

    _colorAnimation = colorTween.animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncStatus = ref.watch(syncStatusProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          syncStatus == SyncStatus.syncing
              ? AnimatedBuilder(
                animation: _colorAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    minHeight: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _colorAnimation.value!,
                    ),
                    backgroundColor: _colorAnimation.value!.withAlpha(51),
                  );
                },
              )
              : const SizedBox.shrink(),
    );
  }
}
