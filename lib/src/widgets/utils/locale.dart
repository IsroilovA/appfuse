import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';

Future<void> selectLocaleDialog(
  BuildContext context, {
  String title = 'Language',
}) =>
    showDialog<void>(
      useRootNavigator: true,
      barrierColor: Theme.of(context).textTheme.bodyLarge?.color?.withAlpha(124),
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: RadioGroup<Locale>(
          groupValue: context.currentLocale,
          onChanged: (locale) {
            if (locale == null) return;
            context.changeAppLocale(locale);
            Navigator.of(context).pop();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: context.supportedLanguages.keys
                .map(
                  (locale) => _AppLocaleRadioButton(
                    title: context.supportedLanguages[locale]!,
                    value: locale,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

class _AppLocaleRadioButton extends StatelessWidget {
  const _AppLocaleRadioButton({
    required this.title,
    required this.value,
  });
  final String title;
  final Locale value;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        leading: Radio<Locale>(
          activeColor: Theme.of(context).colorScheme.primary,
          value: value,
        ),
        onTap: () => RadioGroup.maybeOf<Locale>(context)?.onChanged(value),
      );
}
