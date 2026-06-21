import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// iOS-style slide from right + parallax on the page underneath.
CustomTransitionPage<void> iosCupertinoPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, page) {
      return CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: false,
        child: page,
      );
    },
  );
}
