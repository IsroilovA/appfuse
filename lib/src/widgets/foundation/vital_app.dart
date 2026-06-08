import 'package:flutter/widgets.dart';

/// Bare Minimum [Widget] to be used as a root widget for `runApp()` function
@immutable
class VitalApp extends StatelessWidget {
  /// creates [VitalApp]
  const VitalApp({required this.home, super.key});

  /// [Widget] to be displayed
  final Widget home;

  // Intentionally provides no MediaQuery: the root [View] already exposes a
  // live one that tracks metrics changes. Inserting a one-shot
  // `MediaQueryData.fromView` snapshot here would shadow it and freeze the
  // app's metrics at startup values.
  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Color(0x00000000),
            fontFamily: 'Roboto',
            fontSize: 14,
          ),
          child: home,
        ),
      );
}
