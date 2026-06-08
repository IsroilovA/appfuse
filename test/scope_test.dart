import 'package:appfuse/appfuse.dart';
import 'package:appfuse/src/widgets/foundation/banner.dart';
import 'package:appfuse/src/widgets/foundation/vital_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A minimal config for testing, requiring no assets or network.
class _TestConfig extends BaseConfig {
  const _TestConfig({super.name = 'TEST', super.showBanner = false}) : super(color: const Color(0xFFFF0000));

  @override
  Future<BaseConfig> init() async => this;

  @override
  T getConfigValue<T extends Object?>(String key) => throw UnsupportedError('no values in _TestConfig');
}

/// Reports the size it observes via [MediaQuery.sizeOf] on every build.
class _SizeProbe extends StatelessWidget {
  const _SizeProbe({required this.onSize});

  final ValueSetter<Size> onSize;

  @override
  Widget build(BuildContext context) {
    onSize(MediaQuery.sizeOf(context));
    return const SizedBox.expand();
  }
}

/// Counts how many times its state is (re)created, to observe remounts.
class _MountProbe extends StatefulWidget {
  const _MountProbe({required this.onMount});

  final VoidCallback onMount;

  @override
  State<_MountProbe> createState() => _MountProbeState();
}

class _MountProbeState extends State<_MountProbe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    PackageInfo.setMockInitialValues(
      appName: 'appfuse_test',
      packageName: 'dev.appfuse.test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Future<void> resizeView(WidgetTester tester, Size physicalSize, double devicePixelRatio) async {
    tester.view.physicalSize = physicalSize;
    tester.view.devicePixelRatio = devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pump();
  }

  group('MediaQuery liveness', () {
    testWidgets('config branch: app sees updated metrics after a view change', (tester) async {
      Size? seenSize;
      await tester.pumpWidget(AppFuseScope(
        configs: const [_TestConfig()],
        app: _SizeProbe(onSize: (size) => seenSize = size),
      ));
      await tester.pumpAndSettle();
      expect(seenSize, isNotNull, reason: 'initialization must complete and build the app');

      await resizeView(tester, const Size(400, 600), 1);
      expect(seenSize, const Size(400, 600), reason: 'app must observe live view metrics, not a startup snapshot');
    });

    testWidgets('no-configs branch: app sees updated metrics after a view change', (tester) async {
      Size? seenSize;
      await tester.pumpWidget(AppFuseScope(
        app: _SizeProbe(onSize: (size) => seenSize = size),
      ));
      await tester.pumpAndSettle();
      expect(seenSize, isNotNull);

      await resizeView(tester, const Size(400, 600), 1);
      expect(seenSize, const Size(400, 600));
    });

    testWidgets('VitalApp (splash/error shell): home sees updated metrics after a view change', (tester) async {
      Size? seenSize;
      await tester.pumpWidget(VitalApp(
        home: _SizeProbe(onSize: (size) => seenSize = size),
      ));
      expect(seenSize, isNotNull);

      await resizeView(tester, const Size(400, 600), 1);
      expect(seenSize, const Size(400, 600));
    });
  });

  group('config banner', () {
    testWidgets('shown when showBanner is true', (tester) async {
      await tester.pumpWidget(const AppFuseScope(
        configs: [_TestConfig(showBanner: true)],
        app: SizedBox.expand(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ConfigBanner), findsOneWidget);
    });

    testWidgets('absent when showBanner is false', (tester) async {
      await tester.pumpWidget(const AppFuseScope(
        configs: [_TestConfig()],
        app: SizedBox.expand(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ConfigBanner), findsNothing);
    });
  });

  group('config switching', () {
    testWidgets('changeConfig remounts the app subtree', (tester) async {
      const configA = _TestConfig(name: 'A');
      const configB = _TestConfig(name: 'B');
      var mounts = 0;
      late BuildContext appContext;

      await tester.pumpWidget(AppFuseScope(
        configs: const [configA, configB],
        app: Builder(builder: (context) {
          appContext = context;
          return _MountProbe(onMount: () => mounts++);
        }),
      ));
      await tester.pumpAndSettle();
      expect(mounts, 1);

      await appContext.fuse.activateConfig(configB);
      await tester.pumpAndSettle();
      expect(mounts, 2, reason: 'switching config must remount the whole app subtree');

      await appContext.fuse.activateConfig(configB);
      await tester.pumpAndSettle();
      expect(mounts, 2, reason: 're-activating the same config must not remount');
    });
  });
}
