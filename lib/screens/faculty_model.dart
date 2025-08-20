// lib/models/faculty_model.dart

class Faculty {
  final String name;
  final String department;
  final String phone;

  Faculty({
    required this.name,
    required this.department,
    required this.phone,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      name: json['name']?.toString() ?? 'No Name',
      department: json['department']?.toString() ?? 'No Department',
      phone: json['phone']?.toString() ?? 'No Phone',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'department': department,
      'phone': phone,
    };
  }
}
