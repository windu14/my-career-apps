import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myjobs/core/widgets/global_loading_indicator.dart';
import 'package:myjobs/features/jobs_management/data/models/job_application_model.dart';
import 'package:myjobs/features/jobs_management/data/repositories/job_repository.dart';
import 'package:myjobs/features/documents/data/models/document_model.dart';
import 'package:myjobs/features/documents/data/repositories/document_repository.dart';
import 'package:myjobs/features/goals/presentation/pages/career_goals_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JobRepository _jobRepository = JobRepository();
  final DocumentRepository _documentRepository = DocumentRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MyJobs Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.waving_hand, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Hello, Future Leader!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCareerRoadmapBanner(context),
            const SizedBox(height: 32),
            Text(
              'Recent Documents',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecentDocumentsSection(context),
            const SizedBox(height: 32),
            Text(
              'Career Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAnalyticsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDocumentsSection(BuildContext context) {
    return StreamBuilder<List<DocumentModel>>(
      stream: _documentRepository.getDocumentsStream(limit: 5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140,
            child: Center(child: GlobalLoadingIndicator(size: 32)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Card.outlined(
            color: Theme.of(context).colorScheme.surface,
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('Belum ada dokumen.')),
            ),
          );
        }
        final docs = snapshot.data!;
        return SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final doc = docs[index];
              return SizedBox(
                width: 200,
                child: Card.outlined(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -15,
                        bottom: -15,
                        child: Icon(
                          Icons.insert_drive_file,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                doc.type,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('dd MMM yyyy').format(doc.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCareerRoadmapBanner(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CareerGoalsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Career Roadmap',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bangun masa depanmu selangkah demi selangkah. Tetapkan dan capai target karirmu sekarang!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alt_route,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return StreamBuilder<List<JobApplication>>(
      stream: _jobRepository.getJobsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GlobalLoadingIndicator();
        }

        if (snapshot.hasError) {
          return Center(child: Text('Gagal memuat statistik: ${snapshot.error}'));
        }

        final jobs = snapshot.data ?? [];

        if (jobs.isEmpty) {
          return Card.filled(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text('Belum ada lamaran. Ayo mulai melamar pekerjaan untuk melihat statistikmu!'),
              ),
            ),
          );
        }

        // Calculate statistics
        int diterima = 0;
        int ditolak = 0;
        int interview = 0;
        int belumAdaKabar = 0;

        for (var job in jobs) {
          final s = job.status.toLowerCase();
          if (s.contains('diterima')) {
            diterima++;
          } else if (s.contains('gagal') || s.contains('ditolak')) {
            ditolak++;
          } else if (s.contains('interview')) {
            interview++;
          } else {
            belumAdaKabar++;
          }
        }

        // Generate Insight
        String insight = '';
        if (interview > 0) {
          insight = 'Wow! Kamu punya $interview panggilan interview. Persiapkan dirimu sebaik mungkin!';
        } else if (diterima > 0) {
          insight = 'Luar biasa! $diterima lamaranmu diterima. Selamat menempuh karir baru!';
        } else if (ditolak > 5) {
          insight = 'Jangan menyerah! Penolakan adalah hal biasa. Coba perbaiki CV dan portfolio-mu.';
        } else {
          insight = 'Tetap semangat! Ada $belumAdaKabar lamaran yang sedang menunggu kabar. Terus berdoa dan apply lagi.';
        }

        return Card.outlined(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                      sections: [
                        if (diterima > 0)
                          PieChartSectionData(
                            color: Colors.green[400],
                            value: diterima.toDouble(),
                            title: '$diterima',
                            radius: 40,
                            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        if (interview > 0)
                          PieChartSectionData(
                            color: Colors.blue[400],
                            value: interview.toDouble(),
                            title: '$interview',
                            radius: 45,
                            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        if (ditolak > 0)
                          PieChartSectionData(
                            color: Colors.red[400],
                            value: ditolak.toDouble(),
                            title: '$ditolak',
                            radius: 35,
                            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        if (belumAdaKabar > 0)
                          PieChartSectionData(
                            color: Colors.grey[400],
                            value: belumAdaKabar.toDouble(),
                            title: '$belumAdaKabar',
                            radius: 30,
                            titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendItem(context, 'Diterima', Colors.green[400]!),
                    _buildLegendItem(context, 'Interview', Colors.blue[400]!),
                    _buildLegendItem(context, 'Gagal', Colors.red[400]!),
                    _buildLegendItem(context, 'Menunggu', Colors.grey[400]!),
                  ],
                ),
                const Divider(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(BuildContext context, String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
