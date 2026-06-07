import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';

Future<void> selectThemeDialog(
  BuildContext context, {
  String title = 'Theme',
}) =>
    showDialog<void>(
      useRootNavigator: true,
      barrierColor: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(124),
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: RadioGroup<ThemeMode>(
          groupValue: context.currentThemeMode,
          onChanged: (themeMode) {
            if (themeMode == null) return;
            context.changeAppThemeMode(themeMode);
            Navigator.of(context).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: context.supportedThemes
                .map((theme) => _AppThemeRadioButton(themeMode: theme))
                .toList(),
          ),
        ),
      ),
    );

class _AppThemeRadioButton extends StatelessWidget {
  const _AppThemeRadioButton({required this.themeMode});
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          themeMode.name,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        leading: Radio<ThemeMode>(
          activeColor: Theme.of(context).colorScheme.primary,
          value: themeMode,
        ),
        onTap: () => RadioGroup.maybeOf<ThemeMode>(context)?.onChanged(themeMode),
      );
}
