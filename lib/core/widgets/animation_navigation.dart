part of 'app_animations.dart';

/// 导航动画组件
/// 企业级动画系统 - 页面导航和路由动画

/// 创建页面过渡动画
Route<T> createRoute<T>(Widget page, {RouteSettings? settings}) =>
    PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );

/// 显示底部弹窗动画
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  bool? showDragHandle,
  bool isScrollControlled = true,
}) =>
    showModalBottomSheet<T>(
      context: context,
      builder: builder,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: elevation ?? 8,
      shape: shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
      showDragHandle: showDragHandle ?? true,
      isScrollControlled: isScrollControlled,
    );
