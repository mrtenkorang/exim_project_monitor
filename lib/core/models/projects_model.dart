class Project {
  final int id;
  final String name;
  final String code;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double totalBudget;
  final int manager;
  final String managerName;
  final int totalFarmers;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalBudget,
    required this.manager,
    required this.managerName,
    required this.totalFarmers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String,
      totalBudget: double.parse(json['total_budget'] as String),
      manager: json['manager'] as int,
      managerName: json['manager_name'] as String,
      totalFarmers: json['total_farmers'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'total_budget': totalBudget.toString(),
      'manager': manager,
      'manager_name': managerName,
      'total_farmers': totalFarmers,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? totalBudget,
    int? manager,
    String? managerName,
    int? totalFarmers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      totalBudget: totalBudget ?? this.totalBudget,
      manager: manager ?? this.manager,
      managerName: managerName ?? this.managerName,
      totalFarmers: totalFarmers ?? this.totalFarmers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Project(id: $id, name: $name, code: $code, status: $status, totalFarmers: $totalFarmers)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.code == code &&
        other.description == description &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.status == status &&
        other.totalBudget == totalBudget &&
        other.manager == manager &&
        other.managerName == managerName &&
        other.totalFarmers == totalFarmers &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      code,
      description,
      startDate,
      endDate,
      status,
      totalBudget,
      manager,
      managerName,
      totalFarmers,
      createdAt,
      updatedAt,
    );
  }
}