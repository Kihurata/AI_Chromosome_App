import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderState {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool? showBackButton;

  const HeaderState({this.title, this.subtitle, this.actions, this.showBackButton});
}

class HeaderNotifier extends Notifier<HeaderState> {
  @override
  HeaderState build() => const HeaderState();

  void update({String? title, String? subtitle, List<Widget>? actions, bool? showBackButton}) {
    // Avoid unnecessary state updates
    if (state.title == title && 
        state.subtitle == subtitle && 
        state.actions == actions && 
        state.showBackButton == showBackButton) {
      return;
    }
        
    state = HeaderState(
      title: title, 
      subtitle: subtitle, 
      actions: actions,
      showBackButton: showBackButton,
    );
  }
  
  void clear() {
    if (state.title == null && state.subtitle == null && state.actions == null) {
      return;
    }
    state = const HeaderState();
  }
}

final headerProvider = NotifierProvider<HeaderNotifier, HeaderState>(HeaderNotifier.new);
