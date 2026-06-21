import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myjobs/core/widgets/empty_state_widget.dart';
import 'package:myjobs/features/jobs_management/data/models/job_application_model.dart';
import 'package:myjobs/features/jobs_management/data/repositories/job_repository.dart';
import 'package:myjobs/features/jobs_management/presentation/pages/add_job_screen.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  final JobRepository _repository = JobRepository();

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
            const Text('Manage Jobs', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.track_changes, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Pantau terus proses karirmu!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 8.0),
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<JobApplication>>(
        stream: _repository.getJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EmptyStateWidget(
              icon: Icons.hourglass_empty,
              title: 'Memuat Data...',
              subtitle: 'Harap tunggu sebentar.',
            );
          }

          if (snapshot.hasError) {
            return const EmptyStateWidget(
              icon: Icons.wifi_off_rounded,
              title: 'Koneksi Terputus',
              subtitle: 'Gagal mengambil data dari server. Periksa koneksi internet Anda.',
            );
          }

          final jobs = snapshot.data;

          if (jobs == null || jobs.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.work_off_outlined,
              title: 'Belum Ada Lamaran',
              subtitle: 'Ayo mulai apply pekerjaan dan catat progressmu di sini!',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _buildJobCard(context, job);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJobScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobApplication job) {
    Color statusColor;
    switch (job.status.toLowerCase()) {
      case 'diterima':
        statusColor = Colors.green;
        break;
      case 'interview hrd/user':
      case 'di lihat hrd':
        statusColor = Colors.orange;
        break;
      case 'gagal lolos':
        statusColor = Theme.of(context).colorScheme.error;
        break;
      case 'gada kejelasan':
      case 'lama tanpa kabar':
        statusColor = Colors.grey;
        break;
      case 'baru apply':
      default:
        statusColor = Theme.of(context).colorScheme.primary;
    }

    String appliedViaText = job.appliedVia;
    if (job.appliedVia == 'Online' && job.appliedViaDetail != null) {
      appliedViaText += ' (${job.appliedViaDetail})';
    }

    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  child: Text(job.company.isNotEmpty ? job.company[0].toUpperCase() : '?'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        job.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Applied: ${DateFormat('dd MMM yyyy').format(job.appliedDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Via: $appliedViaText',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  initialValue: job.status,
                  onSelected: (String newStatus) {
                    _repository.updateJobStatus(job.id, newStatus);
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      'baru apply',
                      'di lihat HRD',
                      'gada kejelasan',
                      'lama tanpa kabar',
                      'interview HRD/USER',
                      'diterima',
                      'gagal lolos'
                    ].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice.toUpperCase(), style: const TextStyle(fontSize: 12)),
                      );
                    }).toList();
                  },
                  child: Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          job.status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: statusColor, size: 16),
                      ],
                    ),
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
