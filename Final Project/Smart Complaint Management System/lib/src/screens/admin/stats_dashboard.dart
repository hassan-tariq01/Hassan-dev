import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import 'package:go_router/go_router.dart';

import '../../utils/routes.dart';

class StatsDashboard extends StatefulWidget {
  const StatsDashboard({Key? key}) : super(key: key);

  @override
  State<StatsDashboard> createState() => _StatsDashboardState();
}

class _StatsDashboardState extends State<StatsDashboard> {
  bool _isLoading = true;
  Map<String, int> _statusCounts = {};
  int _totalComplaints = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final complaints = await SupabaseService().getComplaints();
      _totalComplaints = complaints.length;
      _statusCounts = {
        AppConstants.statusSubmitted: complaints.where((c) => c['status'] == AppConstants.statusSubmitted).length,
        AppConstants.statusInProgress: complaints.where((c) => c['status'] == AppConstants.statusInProgress).length,
        AppConstants.statusEscalatedToHOD: complaints.where((c) => c['status'] == AppConstants.statusEscalatedToHOD).length,
        AppConstants.statusResolved: complaints.where((c) => c['status'] == AppConstants.statusResolved).length,
        AppConstants.statusRejected: complaints.where((c) => c['status'] == AppConstants.statusRejected).length,
      };
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading statistics: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<PieChartSectionData> _buildPieSections() {
    final colors = [
      AppConstants.submittedColor,
      AppConstants.inProgressColor,
      AppConstants.escalatedColor,
      AppConstants.resolvedColor,
      AppConstants.rejectedColor,
    ];
    final statuses = [
      AppConstants.statusSubmitted,
      AppConstants.statusInProgress,
      AppConstants.statusEscalatedToHOD,
      AppConstants.statusResolved,
      AppConstants.statusRejected,
    ];
    return List.generate(statuses.length, (i) {
      final count = _statusCounts[statuses[i]] ?? 0;
      final percent = _totalComplaints == 0 ? 0.0 : (count / _totalComplaints) * 100;
      return PieChartSectionData(
        color: Color(colors[i]),
        value: count.toDouble(),
        title: '${percent.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Statistics'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Complaint Status Distribution',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildStatusSummary(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusSummary() {
    final statuses = [
      AppConstants.statusSubmitted,
      AppConstants.statusInProgress,
      AppConstants.statusEscalatedToHOD,
      AppConstants.statusResolved,
      AppConstants.statusRejected,
    ];
    final colors = [
      AppConstants.submittedColor,
      AppConstants.inProgressColor,
      AppConstants.escalatedColor,
      AppConstants.resolvedColor,
      AppConstants.rejectedColor,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(statuses.length, (i) {
        final count = _statusCounts[statuses[i]] ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: Color(colors[i]),
              ),
              const SizedBox(width: 8),
              Text(
                statuses[i],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text('($count)'),
            ],
          ),
        );
      }),
    );
  }
} 