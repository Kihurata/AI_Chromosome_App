import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerState {
  final Widget? endDrawer;

  const DrawerState({this.endDrawer});
}

class DrawerNotifier extends Notifier<DrawerState> {
  @override
  DrawerState build() => const DrawerState();

  void update({Widget? endDrawer}) {
    if (state.endDrawer == endDrawer) {
      return;
    }
    state = DrawerState(endDrawer: endDrawer);
  }

  void clear() {
    if (state.endDrawer == null) return;
    state = const DrawerState();
  }
}

final drawerProvider = NotifierProvider<DrawerNotifier, DrawerState>(DrawerNotifier.new);
