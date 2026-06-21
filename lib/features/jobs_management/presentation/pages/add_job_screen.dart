import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myjobs/features/jobs_management/data/models/job_application_model.dart';
import 'package:myjobs/features/jobs_management/data/repositories/job_repository.dart';
import 'package:myjobs/core/widgets/global_loading_indicator.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = JobRepository();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _position1Controller = TextEditingController();
  final _position2Controller = TextEditingController();

  String _appliedVia = 'Online';
  String? _appliedViaDetail = 'LinkedIn';
  DateTime _appliedDate = DateTime.now();

  bool _isLoading = false;

  final List<String> _viaOptions = ['Online', 'Offline'];
  final List<String> _viaDetailOptions = ['LinkedIn', 'Web', 'Sosmed', 'Lainnya'];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _appliedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _appliedDate) {
      setState(() {
        _appliedDate = picked;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final job = JobApplication(
        id: '', // Firestore auto-generates ID
        title: _titleController.text.trim(),
        company: _companyController.text.trim(),
        appliedVia: _appliedVia,
        appliedViaDetail: _appliedVia == 'Online' ? _appliedViaDetail : null,
        position1: _position1Controller.text.trim().isNotEmpty ? _position1Controller.text.trim() : null,
        position2: _position2Controller.text.trim().isNotEmpty ? _position2Controller.text.trim() : null,
        appliedDate: _appliedDate,
        status: 'baru apply', // Default status as requested
      );

      try {
        await _repository.addJob(job);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil menambahkan lamaran pekerjaan!')),
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
    _titleController.dispose();
    _companyController.dispose();
    _position1Controller.dispose();
    _position2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Lamaran'),
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
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul (Role)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Judul harus diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Perusahaan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Perusahaan harus diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _appliedVia,
                      decoration: const InputDecoration(
                        labelText: 'Lewat Apa',
                        border: OutlineInputBorder(),
                      ),
                      items: _viaOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _appliedVia = newValue!;
                          if (_appliedVia == 'Online' && _appliedViaDetail == null) {
                            _appliedViaDetail = 'LinkedIn';
                          }
                        });
                      },
                    ),
                    if (_appliedVia == 'Online') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _appliedViaDetail,
                        decoration: const InputDecoration(
                          labelText: 'Detail Platform Online',
                          border: OutlineInputBorder(),
                        ),
                        items: _viaDetailOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _appliedViaDetail = newValue;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _position1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Posisi 1 (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _position2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Posisi 2 (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Apply',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(DateFormat('dd MMM yyyy').format(_appliedDate)),
                      ),
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
