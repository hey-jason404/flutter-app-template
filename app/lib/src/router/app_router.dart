import 'package:app/src/pages/placeholder_pages.dart';
import 'package:app/src/router/session_refresh_listenable.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';
import 'package:session/session.dart';

/// 建立 app 的路由表:登入守衛 + refreshListenable(spec §5.3)。
///
/// 未登入且目標非 login → 導向 login;已登入且目標為 login → 導向 home;
/// 其餘不重導向。`refreshListenable` 讓 [SessionManager.states] 的每次事件
/// 觸發 go_router 重新評估 redirect(如 token 失效自動導回登入)。
GoRouter buildRouter(SessionManager session) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    refreshListenable: SessionRefreshListenable(session.states),
    redirect: (context, state) {
      final loggedIn = session.state is SessionAuthenticated;
      final goingToLogin = state.matchedLocation == RoutePaths.login;
      if (!loggedIn && !goingToLogin) {
        return RoutePaths.login;
      }
      if (loggedIn && goingToLogin) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const PlaceholderLoginPage(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const PlaceholderHomePage(),
      ),
      // {{feature-registry}}
    ],
  );
}
