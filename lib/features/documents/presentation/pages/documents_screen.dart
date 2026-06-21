import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myjobs/core/widgets/empty_state_widget.dart';
import 'package:myjobs/core/widgets/global_loading_indicator.dart';
import 'package:myjobs/features/documents/data/models/document_model.dart';
import 'package:myjobs/features/documents/data/repositories/document_repository.dart';
import 'package:myjobs/features/documents/presentation/pages/add_document_screen.dart';
import 'package:myjobs/features/documents/presentation/pages/document_detail_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentRepository _repository = DocumentRepository();
  final ScrollController _scrollController = ScrollController();
  
  String _searchQuery = '';
  bool _isSearching = false;
  Timer? _debounceTimer;
  
  int _documentLimit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
      // Reached the bottom, load more
      setState(() {
        _documentLimit += 10;
      });
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'cv':
        return Icons.person;
      case 'portfolio':
        return Icons.folder_special;
      case 'dokumen lamaran':
        return Icons.description;
      case 'dokumen kerja':
        return Icons.work;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
        _isSearching = false;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
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
            const Text('My Documents', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.folder, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Koleksi dokumen karirmu',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari berdasarkan judul dokumen...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isSearching
                ? const GlobalLoadingIndicator()
                : StreamBuilder<List<DocumentModel>>(
                    stream: _repository.getDocumentsStream(limit: _documentLimit),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const GlobalLoadingIndicator();
                      }

                      if (snapshot.hasError) {
                        return EmptyStateWidget(
                          icon: Icons.error_outline,
                          title: 'Koneksi Terputus / Error',
                          subtitle: 'Gagal mengambil data. Detail: ${snapshot.error}',
                        );
                      }

                      final allDocs = snapshot.data;

                      if (allDocs == null || allDocs.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Icons.folder_off_outlined,
                          title: 'Belum Ada Dokumen',
                          subtitle: 'Ayo simpan CV, Portfolio, dan dokumen penting lainnya di sini.',
                        );
                      }

                      // Apply search filter strictly by title
                      final filteredDocs = allDocs.where((doc) {
                        final query = _searchQuery.toLowerCase();
                        return doc.title.toLowerCase().contains(query);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Icons.search_off,
                          title: 'Tidak Ditemukan',
                          subtitle: 'Dokumen yang Anda cari tidak ada.',
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          itemCount: filteredDocs.length + (allDocs.length >= _documentLimit ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filteredDocs.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: GlobalLoadingIndicator(),
                              );
                            }
                            final doc = filteredDocs[index];
                            return _buildModernCard(context, doc);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDocumentScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context, DocumentModel doc) {
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (doc.link.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentDetailScreen(document: doc),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dokumen ini tidak memiliki tautan (link).')),
            );
          }
        },
        child: Stack(
          children: [
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                _getIconForType(doc.type),
                size: 140,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doc.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doc.type,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(doc.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
