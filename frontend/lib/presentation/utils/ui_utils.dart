import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UIUtils {
  /// Lấy chữ cái đại diện từ tên (Initials)
  static String getInitials(String name) {
    if (name.isEmpty) return '??';
    List<String> parts = name.trim().split(' ');
    if (parts.length >= 2) return (parts[0][0] + parts.last[0]).toUpperCase();
    return parts[0][0].toUpperCase();
  }

  /// Lấy màu nền Avatar dựa trên mã hash của tên
  static Color getAvatarColor(String name) {
    final colors = [
      Colors.blue[50]!,
      Colors.teal[50]!,
      Colors.green[50]!,
      Colors.orange[50]!,
      Colors.red[50]!,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  /// Lấy màu chữ tương ứng với màu nền Avatar
  static Color getAvatarTextColor(String name) {
    final colors = [
      Colors.blue[800]!,
      Colors.teal[800]!,
      Colors.green[800]!,
      Colors.orange[800]!,
      Colors.red[800]!,
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  /// Ẩn một phần số CCCD để bảo mật
  static String maskIdentityCard(String id) {
    if (id.length <= 4) return id;
    return '${id.substring(0, 4)}${'*' * (id.length - 4)}';
  }

  /// Định dạng ngày tháng chuẩn Việt Nam
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
