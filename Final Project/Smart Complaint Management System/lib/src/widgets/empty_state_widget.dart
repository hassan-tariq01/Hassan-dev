import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? customAction;
  final bool showAction;
  final Color? iconColor;
  final double iconSize;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onActionPressed,
    this.customAction,
    this.showAction = true,
    this.iconColor,
    this.iconSize = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              _buildSubtitle(),
            ],
            if (showAction && (actionText != null || customAction != null)) ...[
              const SizedBox(height: 32),
              _buildAction(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: (iconColor ?? const Color(AppConstants.primaryColor))
            .withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: iconSize * 0.5,
        color: iconColor ?? const Color(AppConstants.primaryColor),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle!,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600],
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAction() {
    if (customAction != null) {
      return customAction!;
    }

    if (actionText != null && onActionPressed != null) {
      return PrimaryButton(
        text: actionText!,
        onPressed: onActionPressed,
        isFullWidth: false,
      );
    }

    return const SizedBox.shrink();
  }
}

// Predefined empty state widgets for common scenarios
class NoComplaintsEmptyState extends StatelessWidget {
  final VoidCallback? onNewComplaint;

  const NoComplaintsEmptyState({
    Key? key,
    this.onNewComplaint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Complaints Found',
      subtitle: 'You haven\'t submitted any complaints yet. Start by creating your first complaint.',
      icon: Icons.report_problem_outlined,
      actionText: 'Submit Complaint',
      onActionPressed: onNewComplaint,
    );
  }
}

class NoAssignedComplaintsEmptyState extends StatelessWidget {
  const NoAssignedComplaintsEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Assigned Complaints',
      subtitle: 'You don\'t have any complaints assigned to you at the moment.',
      icon: Icons.assignment_outlined,
      showAction: false,
    );
  }
}

class NoEscalatedComplaintsEmptyState extends StatelessWidget {
  const NoEscalatedComplaintsEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Escalated Complaints',
      subtitle: 'There are no complaints that require your attention at this time.',
      icon: Icons.priority_high_outlined,
      showAction: false,
    );
  }
}

class NoStudentsEmptyState extends StatelessWidget {
  final VoidCallback? onUploadStudents;

  const NoStudentsEmptyState({
    Key? key,
    this.onUploadStudents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Students Found',
      subtitle: 'No students have been added to the system yet. Upload a batch file to add students.',
      icon: Icons.people_outline,
      actionText: 'Upload Students',
      onActionPressed: onUploadStudents,
    );
  }
}

class NoDepartmentsEmptyState extends StatelessWidget {
  final VoidCallback? onAddDepartment;

  const NoDepartmentsEmptyState({
    Key? key,
    this.onAddDepartment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Departments Found',
      subtitle: 'No departments have been created yet. Add departments to organize complaints.',
      icon: Icons.business_outlined,
      actionText: 'Add Department',
      onActionPressed: onAddDepartment,
    );
  }
}

class NoNotificationsEmptyState extends StatelessWidget {
  const NoNotificationsEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Notifications',
      subtitle: 'You\'re all caught up! No new notifications at the moment.',
      icon: Icons.notifications_none_outlined,
      showAction: false,
    );
  }
}

class SearchEmptyState extends StatelessWidget {
  final String searchQuery;

  const SearchEmptyState({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Results Found',
      subtitle: 'No complaints found matching "$searchQuery". Try adjusting your search terms.',
      icon: Icons.search_off_outlined,
      iconColor: Colors.grey,
      showAction: false,
    );
  }
}

class ErrorEmptyState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorEmptyState({
    Key? key,
    required this.error,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Something Went Wrong',
      subtitle: error,
      icon: Icons.error_outline,
      iconColor: const Color(AppConstants.errorColor),
      actionText: 'Try Again',
      onActionPressed: onRetry,
    );
  }
} 