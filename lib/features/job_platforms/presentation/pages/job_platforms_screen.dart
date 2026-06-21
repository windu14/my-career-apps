import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myjobs/core/widgets/empty_state_widget.dart';
import 'package:myjobs/core/widgets/global_loading_indicator.dart';
import 'package:myjobs/features/job_platforms/data/models/platform_model.dart';
import 'package:myjobs/features/job_platforms/data/repositories/platform_repository.dart';
import 'package:myjobs/features/job_platforms/presentation/pages/add_platform_screen.dart';

class JobPlatformsScreen extends StatefulWidget {
  const JobPlatformsScreen({super.key});

  @override
  State<JobPlatformsScreen> createState() => _JobPlatformsScreenState();
}

class _JobPlatformsScreenState extends State<JobPlatformsScreen> {
  final PlatformRepository _repository = PlatformRepository();

  IconData _getIconForPlatform(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('linkedin')) return Icons.business_center;
    if (lower.contains('github')) return Icons.code;
    if (lower.contains('instagram')) return Icons.camera_alt;
    if (lower.contains('dribbble') || lower.contains('behance')) return Icons.palette;
    if (lower.contains('web') || lower.contains('portfolio')) return Icons.language;
    return Icons.link;
  }

  Color _getColorForPlatform(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('linkedin')) return Colors.blue[800]!;
    if (lower.contains('github')) return Colors.black87;
    if (lower.contains('instagram')) return Colors.pink;
    if (lower.contains('dribbble')) return Colors.pinkAccent;
    return Colors.teal;
  }

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
            const Text('Job Platforms', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Koneksikan semua profil profesionalmu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<PlatformModel>>(
        stream: _repository.getPlatformsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const GlobalLoadingIndicator();
          }

          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: 'Gagal mengambil data. Detail: ${snapshot.error}',
            );
          }

          final platforms = snapshot.data;

          if (platforms == null || platforms.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.hub_outlined,
              title: 'Belum Ada Platform',
              subtitle: 'Tambahkan link ke LinkedIn, GitHub, atau Portfolio Anda di sini.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: platforms.length,
            itemBuilder: (context, index) {
              final platform = platforms[index];
              return LayeredPlatformCard(
                platformName: platform.platformName,
                username: platform.username,
                url: platform.url,
                icon: _getIconForPlatform(platform.platformName),
                color: _getColorForPlatform(platform.platformName),
                isConnected: platform.isConnected,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlatformScreen()),
          );
        },
        child: const Icon(Icons.add_link),
      ),
    );
  }
}

class LayeredPlatformCard extends StatefulWidget {
  final String platformName;
  final String username;
  final String url;
  final IconData icon;
  final Color color;
  final bool isConnected;

  const LayeredPlatformCard({
    super.key,
    required this.platformName,
    required this.username,
    required this.url,
    required this.icon,
    required this.color,
    required this.isConnected,
  });

  @override
  State<LayeredPlatformCard> createState() => _LayeredPlatformCardState();
}

class _LayeredPlatformCardState extends State<LayeredPlatformCard> {
  bool _isExpanded = false;

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          // Background Layer (Expansion Content)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(top: _isExpanded ? 60 : 0),
            padding: const EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            child: AnimatedOpacity(
              opacity: _isExpanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _isExpanded 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tautan Profil',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isConnected ? widget.username : 'Belum ditambahkan',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 16),
                        widget.isConnected
                            ? FilledButton.icon(
                                onPressed: _launchUrl,
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Buka Profil'),
                              )
                            : OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.link_rounded),
                                label: const Text('Hubungkan Sekarang'),
                              ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          
          // Foreground Layer (Main Card)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                boxShadow: _isExpanded
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: widget.color.withValues(alpha: 0.1),
                  foregroundColor: widget.color,
                  radius: 24,
                  child: Icon(widget.icon, size: 24),
                ),
                title: Text(
                  widget.platformName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  widget.isConnected ? 'Terhubung' : 'Tidak aktif',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.isConnected 
                            ? Colors.green 
                            : Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                trailing: AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
