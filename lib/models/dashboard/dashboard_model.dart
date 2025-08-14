// lib/models/dashboard/dashboard_model.dart

class DashboardStat {
  final String title;
  final dynamic value;
  final String icon;
  DashboardStat({required this.title, required this.value, required this.icon});
  factory DashboardStat.fromJson(Map<String, dynamic> json) {
    return DashboardStat(
      title: json['title'] ?? 'N/A',
      value: json['value'] ?? 0,
      icon: json['icon'] ?? 'default',
    );
  }
}

class DashboardData {
  final String role;
  final List<DashboardStat> stats;
  DashboardData({required this.role, required this.stats});
  factory DashboardData.fromJson(Map<String, dynamic> json) {
    var statsList = json['stats'] as List? ?? [];
    List<DashboardStat> parsedStats = statsList.map((i) => DashboardStat.fromJson(i)).toList();
    return DashboardData(role: json['role'] ?? 'User', stats: parsedStats);
  }
}
