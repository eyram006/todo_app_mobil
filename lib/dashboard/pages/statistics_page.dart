import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/dashboard/models/statistics.dart';
import 'package:todo_app/dashboard/services/statistics_service.dart';
import 'package:todo_app/theme.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatisticsService _statisticsService = StatisticsService();
  Statistics? _statistics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final statistics = await _statisticsService.getUserStatistics(userId);
      setState(() {
        _statistics = statistics;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement statistiques: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_statistics == null) {
      return const Scaffold(
        body: Center(child: Text('Erreur de chargement des statistiques')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistiques & Analyses'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Métriques principales
            Row(
              children: [
                _buildMetricCard(
                  'Projets',
                  _statistics!.totalProjects.toString(),
                  Icons.folder,
                  AppColors.primary,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  'Tâches',
                  _statistics!.totalTasks.toString(),
                  Icons.task,
                  AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMetricCard(
                  'Complétées',
                  _statistics!.completedTasks.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  'Taux réussite',
                  '${_statistics!.completionRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Graphique des tâches par statut
            _buildStatusChart(),

            const SizedBox(height: 24),

            // Graphique des projets par mois
            _buildMonthlyChart(),

            const SizedBox(height: 24),

            // Métriques des membres
            Row(
              children: [
                _buildMetricCard(
                  'Membres',
                  _statistics!.totalMembers.toString(),
                  Icons.people,
                  AppColors.primary,
                ),
                const SizedBox(width: 16),
                _buildMetricCard(
                  'Actifs',
                  _statistics!.activeMembers.toString(),
                  Icons.person,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: AppColors.textGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tâches par statut',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: _statistics!.pendingTasks.toDouble(),
                    title: 'En attente\n${_statistics!.pendingTasks}',
                    color: Colors.orange,
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: _statistics!.inProgressTasks.toDouble(),
                    title: 'En cours\n${_statistics!.inProgressTasks}',
                    color: Colors.blue,
                    radius: 60,
                  ),
                  PieChartSectionData(
                    value: _statistics!.completedTasks.toDouble(),
                    title: 'Terminées\n${_statistics!.completedTasks}',
                    color: Colors.green,
                    radius: 60,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun'];
    final values = months
        .map((month) => _statistics!.projectsByMonth[month] ?? 0)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Projets créés par mois',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  months.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: values[index].toDouble(),
                        color: AppColors.primary,
                        width: 20,
                      ),
                    ],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          months[value.toInt()],
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
