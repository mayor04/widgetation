import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Base class for any Widgetation state slice. Holds a single immutable
/// state object and emits new states through a [ValueListenable].
///
/// BLoC-shaped: read via [state], mutate by calling [emit] inside a method.
abstract class WidgetationStore<S> {
  final ValueNotifier<S> _state;

  WidgetationStore(S initial) : _state = ValueNotifier(initial);

  ValueListenable<S> get state => _state;

  S get value => _state.value;

  @protected
  void emit(S newState) {
    _state.value = newState;
  }

  @mustCallSuper
  void dispose() => _state.dispose();
}

/// Generic [InheritedWidget] exposing a [WidgetationStore] subclass to
/// descendants. Subscribers rebuild via [StoreBuilder] (or a manual
/// [ValueListenableBuilder] on `store.state`); the scope itself only
/// notifies when the store identity changes.
class StoreScope<T extends WidgetationStore> extends InheritedWidget {
  final T store;

  const StoreScope({super.key, required this.store, required super.child});

  static T of<T extends WidgetationStore>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope<T>>();
    assert(scope != null, 'No StoreScope<$T> found in context');
    return scope!.store;
  }

  static T? maybeOf<T extends WidgetationStore>(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope<T>>()?.store;

  @override
  bool updateShouldNotify(StoreScope<T> oldWidget) =>
      !identical(store, oldWidget.store);
}

extension WidgetationContextExt on BuildContext {
  T read<T extends WidgetationStore>() => StoreScope.of<T>(this);
}

/// Subscribes to a store's state. Thin wrapper over [ValueListenableBuilder]
/// so callers don't repeat the `StoreScope.of<X>(context).state` chain.
class StoreBuilder<T extends WidgetationStore<S>, S> extends StatelessWidget {
  final Widget Function(BuildContext context, S state) builder;

  const StoreBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of<T>(context);
    return ValueListenableBuilder<S>(
      valueListenable: store.state,
      builder: (ctx, s, _) => builder(ctx, s),
    );
  }
}
