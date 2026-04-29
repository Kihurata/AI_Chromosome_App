import 'package:equatable/equatable.dart';

class LayoutState extends Equatable {
  final bool isSidebarCollapsed;

  const LayoutState({
    this.isSidebarCollapsed = false,
  });

  LayoutState copyWith({
    bool? isSidebarCollapsed,
  }) {
    return LayoutState(
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
    );
  }

  @override
  List<Object> get props => [isSidebarCollapsed];
}
