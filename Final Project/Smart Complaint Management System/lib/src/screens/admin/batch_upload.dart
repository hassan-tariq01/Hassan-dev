import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../utils/constants.dart';
import 'package:go_router/go_router.dart';

import '../../utils/routes.dart';

class BatchUpload extends StatefulWidget {
  const BatchUpload({Key? key}) : super(key: key);

  @override
  State<BatchUpload> createState() => _BatchUploadState();
}

class _BatchUploadState extends State<BatchUpload> {
  String? _fileName;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  String? _uploadResult;

  void _pickFile() async {
    setState(() {
      _uploadResult = null;
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _fileName = _selectedFile!.name;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;
    setState(() {
      _isUploading = true;
      _uploadResult = null;
    });
    try {
      final bytes = _selectedFile!.bytes ?? await File(_selectedFile!.path!).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;
      // Validate headers
      final headers = rows.first.map((cell) => cell?.value.toString().trim()).toList();
      if (!_validateHeaders(headers)) {
        setState(() {
          _uploadResult = 'Invalid Excel format. Please use the provided template.';
        });
        return;
      }
      // Insert users and batches
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final studentName = row[0]?.value?.toString().trim() ?? '';
        final email = row[1]?.value?.toString().trim() ?? '';
        final batchName = row[2]?.value?.toString().trim() ?? '';
        final departmentName = row[3]?.value?.toString().trim() ?? '';
        final advisorEmail = row[4]?.value?.toString().trim() ?? '';
        // TODO: Insert logic for department, batch, advisor, and user creation
        // This is a placeholder for actual Supabase insert logic
      }
      setState(() {
        _uploadResult = 'Upload successful!';
      });
    } catch (e) {
      setState(() {
        _uploadResult = 'Error uploading file: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  bool _validateHeaders(List<dynamic> headers) {
    final expected = AppConstants.excelHeaders;
    if (headers.length < expected.length) return false;
    for (int i = 0; i < expected.length; i++) {
      if (headers[i] != expected[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Upload'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload Excel File',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Excel File (.xlsx or .csv)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
              ),
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 12),
              Text('Selected file: $_fileName'),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_selectedFile != null && !_isUploading) ? _uploadFile : null,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload & Process'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
              ),
            ),
            if (_uploadResult != null) ...[
              const SizedBox(height: 16),
              Text(
                _uploadResult!,
                style: TextStyle(
                  color: _uploadResult!.startsWith('Error') ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 32),
            const Text(
              'Excel Format:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('| Student Name | Email | Batch | Department | Advisor Email |'),
          ],
        ),
      ),
    );
  }
} 