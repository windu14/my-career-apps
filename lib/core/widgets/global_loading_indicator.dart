import 'package:flutter/material.dart';
import 'package:m3_expressive/m3_expressive.dart';

class GlobalLoadingIndicator extends StatelessWidget {
  final double size;
  final Duration morphDuration;

  const GlobalLoadingIndicator({
    super.key,
    this.size = 64.0,
    this.morphDuration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: M3LoadingIndicator(
        size: size,
        morphDuration: morphDuration,
      ),
    );
  }
}
