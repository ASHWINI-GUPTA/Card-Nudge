import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UtilizationSlider extends ConsumerStatefulWidget {
  const UtilizationSlider({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final int initialValue;
  final ValueChanged<int> onChanged;

  @override
  ConsumerState<UtilizationSlider> createState() => _UtilizationSliderState();
}

class _UtilizationSliderState extends ConsumerState<UtilizationSlider> {
  late int _sliderValue;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.initialValue;
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value.round();
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged(_sliderValue);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
            value: _sliderValue.toDouble(),
            min: 0,
            max: 100,
            divisions: 50,
            label: '${_sliderValue.round()}%',
            onChanged: _onSliderChanged,
          ),
        ),
        const SizedBox(width: 8),
        Text('${_sliderValue.round()}%'),
      ],
    );
  }
}
