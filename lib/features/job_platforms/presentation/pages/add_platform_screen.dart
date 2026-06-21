import 'package:flutter/material.dart';
import 'package:myjobs/core/widgets/global_loading_indicator.dart';
import 'package:myjobs/features/job_platforms/data/models/platform_model.dart';
import 'package:myjobs/features/job_platforms/data/repositories/platform_repository.dart';

class AddPlatformScreen extends StatefulWidget {
  const AddPlatformScreen({super.key});

  @override
  State<AddPlatformScreen> createState() => _AddPlatformScreenState();
}

class _AddPlatformScreenState extends State<AddPlatformScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = PlatformRepository();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _urlController = TextEditingController();

  bool _isLoading = false;
  bool _isConnected = true;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final platform = PlatformModel(
        id: '',
        platformName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        url: _urlController.text.trim(),
        isConnected: _isConnected,
      );

      try {
        await _repository.addPlatform(platform);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil menambahkan platform!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Job Platform'),
      ),
      body: _isLoading
          ? const GlobalLoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Platform (contoh: LinkedIn, Dribbble)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username / Profil URL (contoh: @johndoe)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Link URL Platform',
                        border: OutlineInputBorder(),
                        hintText: 'https://...',
                      ),
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Harus diisi';
                        if (!value.startsWith('http')) return 'Masukkan link yang valid (http/https)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Status Koneksi'),
                      subtitle: const Text('Apakah akun ini aktif dan terhubung?'),
                      value: _isConnected,
                      onChanged: (bool value) {
                        setState(() {
                          _isConnected = value;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
