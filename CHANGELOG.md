# Changelog

## 0.0.2

- **Fixed**: stale `MediaQuery` shadowing the live root one. `VitalApp` wrapped the entire app in a one-shot `MediaQueryData.fromView` snapshot with no metrics listener; since Flutter 3.10 the root `View` owns the live `MediaQuery` and `WidgetsApp` installs none of its own, so the app's metrics froze at startup values (symptom: app rendered with frozen/halved screen metrics when the platform corrected the window size after launch).
- **Changed**: when environment configs are active, the app is no longer wrapped in `VitalApp` at all — the app is a complete `MaterialApp` and needs no shell. The debug banner is overlaid via a `Stack`; config-change remount semantics are preserved with `KeyedSubtree`. `VitalApp` remains as the minimal shell for splash/error content only and no longer inserts a `MediaQuery`.
- **Changed**: migrated to `MediaQuery.sizeOf`, `ColorScheme.surface`, and `RadioGroup` (Radio `groupValue`/`onChanged` deprecated since Flutter 3.32).
- **Dependencies**: `package_info_plus` `^9.0.0` → `^10.1.0`; SDK floor raised to `^3.10.0`.
- **Tests**: added regression coverage for MediaQuery liveness, banner visibility, and config switching.
- Note: appfuse is a pure Dart package (no native code), so the Swift Package Manager and Kotlin/AGP migrations do not apply; the updated plugin dependencies ship SPM support to consumers.

## 0.0.1

- Initial release.
