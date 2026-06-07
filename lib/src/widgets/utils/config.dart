import 'package:appfuse/appfuse.dart';
import 'package:flutter/material.dart';

Future<void> selectConfigDialog(
  BuildContext context, {
  String title = 'Config',
}) async {
  final configs = context.fuse.state.configs;
  final selectedConfig = context.fuse.state.config;
  if (configs == null) return;
  if (selectedConfig is EmptyConfig) return;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      content: RadioGroup<String>(
        groupValue: selectedConfig.name,
        onChanged: (name) {
          final config = configs.where((config) => config.name == name).firstOrNull;
          if (config != null) context.changeConfig(config);
          Navigator.of(context).pop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: configs.map((config) => _ConfigRadioButton(config: config)).toList(),
        ),
      ),
    ),
  );
}

@immutable
class _ConfigRadioButton extends StatelessWidget {
  const _ConfigRadioButton({required this.config});
  final BaseConfig config;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(config.name),
        leading: Radio<String>(
          activeColor: config.color,
          value: config.name,
        ),
        onTap: () => RadioGroup.maybeOf<String>(context)?.onChanged(config.name),
      );
}
