import 'dart:io';
import 'package:excel/excel.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';

class ExcelService {
  static final ExcelService _instance = ExcelService._internal();
  factory ExcelService() => _instance;
  ExcelService._internal();

  /// Parse Excel file and return structured data
  Future<List<Map<String, dynamic>>> parseExcelFile(List<int> bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]!.rows;

      if (rows.isEmpty) {
        throw 'Excel file is empty';
      }

      // Validate headers
      final headers = rows.first.map((cell) => cell?.value.toString().trim()).toList();
      if (!_validateHeaders(headers)) {
        throw 'Invalid Excel format. Please use the provided template with headers: ${AppConstants.excelHeaders.join(', ')}';
      }

      final data = <Map<String, dynamic>>[];
      
      // Process data rows (skip header row)
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || row.every((cell) => cell?.value == null)) {
          continue; // Skip empty rows
        }

        final rowData = {
          'student_name': row[0]?.value?.toString().trim() ?? '',
          'email': row[1]?.value?.toString().trim() ?? '',
          'batch_name': row[2]?.value?.toString().trim() ?? '',
          'department_name': row[3]?.value?.toString().trim() ?? '',
          'advisor_email': row[4]?.value?.toString().trim() ?? '',
        };

        // Validate row data
        final validationError = _validateRowData(rowData);
        if (validationError != null) {
          throw 'Row ${i + 1}: $validationError';
        }

        data.add(rowData);
      }

      return data;
    } catch (e) {
      throw 'Error parsing Excel file: $e';
    }
  }

  /// Upload parsed data to Supabase
  Future<Map<String, dynamic>> uploadExcelData(List<Map<String, dynamic>> data) async {
    try {
      final results = {
        'departments_created': 0,
        'batches_created': 0,
        'users_created': 0,
        'errors': <String>[],
      };

      for (final row in data) {
        try {
          // Create or get department
          String departmentId = await _getOrCreateDepartment(row['department_name']);
          if (departmentId.isNotEmpty) {
            results['departments_created'] = (results['departments_created'] as int) + 1;
          }

          // Create or get batch
          String batchId = await _getOrCreateBatch(row['batch_name'], departmentId);
          if (batchId.isNotEmpty) {
            results['batches_created'] = (results['batches_created'] as int) + 1;
          }

          // Create user
          await _createUser(row, batchId, departmentId);
          results['users_created'] = (results['users_created'] as int) + 1;

        } catch (e) {
          (results['errors'] as List<String>).add('Error processing ${row['student_name']}: $e');
        }
      }

      return results;
    } catch (e) {
      throw 'Error uploading data: $e';
    }
  }

  /// Validate Excel headers
  bool _validateHeaders(List<dynamic> headers) {
    if (headers.length < AppConstants.excelHeaders.length) {
      return false;
    }

    for (int i = 0; i < AppConstants.excelHeaders.length; i++) {
      if (headers[i] != AppConstants.excelHeaders[i]) {
        return false;
      }
    }

    return true;
  }

  /// Validate row data
  String? _validateRowData(Map<String, dynamic> rowData) {
    if (rowData['student_name'].isEmpty) {
      return 'Student name is required';
    }
    if (rowData['email'].isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(rowData['email'])) {
      return 'Invalid email format';
    }
    if (rowData['batch_name'].isEmpty) {
      return 'Batch name is required';
    }
    if (rowData['department_name'].isEmpty) {
      return 'Department name is required';
    }
    if (rowData['advisor_email'].isNotEmpty && !_isValidEmail(rowData['advisor_email'])) {
      return 'Invalid advisor email format';
    }
    return null;
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Get or create department
  Future<String> _getOrCreateDepartment(String departmentName) async {
    try {
      // Check if department exists
      final existingDepartments = await SupabaseService().getDepartments();
      final existingDepartment = existingDepartments.where(
        (d) => d['name'].toString().toLowerCase() == departmentName.toLowerCase(),
      ).firstOrNull;

      if (existingDepartment != null) {
        return existingDepartment['id'];
      }

      // Create new department
      final response = await SupabaseService().client
          .from(AppConstants.tableDepartments)
          .insert({'name': departmentName})
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw 'Error creating department: $e';
    }
  }

  /// Get or create batch
  Future<String> _getOrCreateBatch(String batchName, String departmentId) async {
    try {
      // Check if batch exists
      final existingBatches = await SupabaseService().getBatches();
      final existingBatch = existingBatches.where(
        (b) => b['name'].toString().toLowerCase() == batchName.toLowerCase(),
      ).firstOrNull;

      if (existingBatch != null) {
        return existingBatch['id'];
      }

      // Create new batch
      final response = await SupabaseService().client
          .from(AppConstants.tableBatches)
          .insert({
            'name': batchName,
            'department_id': departmentId,
          })
          .select()
          .single();

      return response['id'];
    } catch (e) {
      throw 'Error creating batch: $e';
    }
  }

  /// Create user
  Future<void> _createUser(Map<String, dynamic> rowData, String batchId, String departmentId) async {
    try {
      // Check if user already exists
      final existingUsers = await SupabaseService().getUsers();
      final existingUser = existingUsers.where(
        (u) => u['email'].toString().toLowerCase() == rowData['email'].toLowerCase(),
      ).firstOrNull;

      if (existingUser != null) {
        throw 'User with email ${rowData['email']} already exists';
      }

      // Create user
      await SupabaseService().client.from(AppConstants.tableUsers).insert({
        'name': rowData['student_name'],
        'email': rowData['email'],
        'role': AppConstants.roleStudent,
        'batch_id': batchId,
        'department_id': departmentId,
      });

      // If advisor email is provided, create advisor account
      if (rowData['advisor_email'].isNotEmpty) {
        final existingAdvisor = existingUsers.where(
          (u) => u['email'].toString().toLowerCase() == rowData['advisor_email'].toLowerCase(),
        ).firstOrNull;

        if (existingAdvisor == null) {
          await SupabaseService().client.from(AppConstants.tableUsers).insert({
            'name': 'Advisor for ${rowData['batch_name']}',
            'email': rowData['advisor_email'],
            'role': AppConstants.roleBatchAdvisor,
            'department_id': departmentId,
          });
        }
      }
    } catch (e) {
      throw 'Error creating user: $e';
    }
  }

  /// Generate Excel template
  List<int> generateTemplate() {
    final excel = Excel.createExcel();
    final sheet = excel['Template'];

    // Add headers
    for (int i = 0; i < AppConstants.excelHeaders.length; i++) {
      sheet!.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = AppConstants.excelHeaders[i]
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Add sample data
    final sampleData = [
      ['John Doe', 'john.doe@example.com', 'CS-2022', 'Computer Science', 'advisor@example.com'],
      ['Jane Smith', 'jane.smith@example.com', 'CS-2022', 'Computer Science', 'advisor@example.com'],
    ];

    for (int i = 0; i < sampleData.length; i++) {
      for (int j = 0; j < sampleData[i].length; j++) {
        sheet!.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1))
          ..value = sampleData[i][j];
      }
    }

    return excel.encode()!;
  }
} 