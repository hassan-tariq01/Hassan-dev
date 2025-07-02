import 'constants.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.emailRequired;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppConstants.emailInvalid;
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequired;
    }
    
    if (value.length < 6) {
      return AppConstants.passwordMinLength;
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  static String? validateTitle(String? value) {
    return validateRequired(value, 'Title');
  }

  static String? validateDescription(String? value) {
    return validateRequired(value, 'Description');
  }

  static String? validateName(String? value) {
    return validateRequired(value, 'Name');
  }

  static String? validateBatchName(String? value) {
    return validateRequired(value, 'Batch name');
  }

  static String? validateDepartmentName(String? value) {
    return validateRequired(value, 'Department name');
  }

  static String? validateComment(String? value) {
    return validateRequired(value, 'Comment');
  }

  static String? validateMediaUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Media URL is optional
    }
    
    // Check if it's a valid URL (Google Drive or other)
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  static String? validateExcelFile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an Excel file';
    }
    
    final fileExtension = value.split('.').last.toLowerCase();
    if (fileExtension != 'xlsx' && fileExtension != 'csv') {
      return 'Please select a valid Excel file (.xlsx or .csv)';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Student ID is required';
    }
    
    if (value.length < 3) {
      return 'Student ID must be at least 3 characters';
    }
    
    // Check for valid format: CS + Year + 3-digit number (e.g., CS2024001)
    final studentIdRegex = RegExp(r'^[A-Z]{2,4}\d{4}\d{3}$');
    if (!studentIdRegex.hasMatch(value)) {
      return 'Student ID format: CS2024001 (Department + Year + 3-digit number)';
    }
    
    return null;
  }

  static String? validateBatchCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Batch code is required';
    }
    
    // Batch code format: CS-2022, CS-2023, etc.
    final batchRegex = RegExp(r'^[A-Z]{2,4}-\d{4}$');
    if (!batchRegex.hasMatch(value)) {
      return 'Batch code must be in format: CS-2022';
    }
    
    return null;
  }

  static String? validateFileSize(int? sizeInBytes) {
    if (sizeInBytes == null) {
      return null;
    }
    
    const maxSizeInMB = 10; // 10MB limit
    const maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    
    if (sizeInBytes > maxSizeInBytes) {
      return 'File size must be less than $maxSizeInMB MB';
    }
    
    return null;
  }

  static String? validateFileType(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return null;
    }
    
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi'];
    final fileExtension = fileName.split('.').last.toLowerCase();
    
    if (!allowedExtensions.contains(fileExtension)) {
      return 'File type not supported. Please use: ${allowedExtensions.join(', ')}';
    }
    
    return null;
  }
} 