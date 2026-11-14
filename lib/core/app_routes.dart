class AppRoutes {
  static const String home = '/';
  static const String groups = '/groups';
  static const String sessions = '/sessions';
  static const String sessionDetail = '/session-detail';
  static const String attendance = '/attendance';
  static const String participation = '/participation';
  static const String reports = '/reports';

  static String withParameters(String route, Map<String, String> parameters) {
    return Uri(path: route, queryParameters: parameters).toString();
  }
}
