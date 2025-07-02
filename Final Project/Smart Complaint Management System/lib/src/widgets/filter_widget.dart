import 'package:flutter/material.dart';
import '../utils/constants.dart';

class FilterWidget extends StatefulWidget {
  final String? selectedStatus;
  final String? selectedBatch;
  final String? selectedAdvisor;
  final String? selectedStudent;
  final String searchQuery;
  final List<String> statusOptions;
  final List<Map<String, String>> batchOptions;
  final List<Map<String, String>> advisorOptions;
  final List<Map<String, String>> studentOptions;
  final Function(String?) onStatusChanged;
  final Function(String?) onBatchChanged;
  final Function(String?) onAdvisorChanged;
  final Function(String?) onStudentChanged;
  final Function(String) onSearchChanged;
  final VoidCallback onClearFilters;
  final bool showSearch;
  final bool showStatus;
  final bool showBatch;
  final bool showAdvisor;
  final bool showStudent;

  const FilterWidget({
    Key? key,
    this.selectedStatus,
    this.selectedBatch,
    this.selectedAdvisor,
    this.selectedStudent,
    this.searchQuery = '',
    this.statusOptions = const [],
    this.batchOptions = const [],
    this.advisorOptions = const [],
    this.studentOptions = const [],
    required this.onStatusChanged,
    required this.onBatchChanged,
    required this.onAdvisorChanged,
    required this.onStudentChanged,
    required this.onSearchChanged,
    required this.onClearFilters,
    this.showSearch = true,
    this.showStatus = true,
    this.showBatch = false,
    this.showAdvisor = false,
    this.showStudent = false,
  }) : super(key: key);

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showSearch) ...[
            _buildSearchField(),
            const SizedBox(height: 12),
          ],
          if (widget.showStatus || widget.showBatch || widget.showAdvisor || widget.showStudent) ...[
            _buildFilterRow(),
            const SizedBox(height: 8),
            _buildClearButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search complaints',
        hintText: 'Search by title, description, or student name',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  widget.onSearchChanged('');
                },
              )
            : null,
      ),
      onChanged: widget.onSearchChanged,
    );
  }

  Widget _buildFilterRow() {
    final filters = <Widget>[];

    if (widget.showStatus) {
      filters.add(Expanded(
        child: _buildDropdown(
          label: 'Status',
          value: widget.selectedStatus,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Statuses')),
            ...widget.statusOptions.map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            )).toList(),
          ],
          onChanged: widget.onStatusChanged,
        ),
      ));
    }

    if (widget.showBatch) {
      filters.add(Expanded(
        child: _buildDropdown(
          label: 'Batch',
          value: widget.selectedBatch,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Batches')),
            ...widget.batchOptions.map((batch) => DropdownMenuItem(
              value: batch['id'],
              child: Text(batch['name'] ?? ''),
            )).toList(),
          ],
          onChanged: widget.onBatchChanged,
        ),
      ));
    }

    if (widget.showAdvisor) {
      filters.add(Expanded(
        child: _buildDropdown(
          label: 'Advisor',
          value: widget.selectedAdvisor,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Advisors')),
            ...widget.advisorOptions.map((advisor) => DropdownMenuItem(
              value: advisor['id'],
              child: Text(advisor['name'] ?? ''),
            )).toList(),
          ],
          onChanged: widget.onAdvisorChanged,
        ),
      ));
    }

    if (widget.showStudent) {
      filters.add(Expanded(
        child: _buildDropdown(
          label: 'Student',
          value: widget.selectedStudent,
          items: [
            const DropdownMenuItem(value: null, child: Text('All Students')),
            ...widget.studentOptions.map((student) => DropdownMenuItem(
              value: student['id'],
              child: Text(student['name'] ?? ''),
            )).toList(),
          ],
          onChanged: widget.onStudentChanged,
        ),
      ));
    }

    return Row(
      children: filters,
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String?>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String?>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildClearButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: widget.onClearFilters,
          icon: const Icon(Icons.clear, size: 16),
          label: const Text('Clear Filters'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(AppConstants.primaryColor),
          ),
        ),
      ],
    );
  }
} 