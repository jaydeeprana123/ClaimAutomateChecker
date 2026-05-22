class PackageModel {
  final int? id;
  final String name;
  final String code;
  final String specialty;
  final bool isActive;

  PackageModel({
    this.id,
    required this.name,
    required this.code,
    required this.specialty,
    this.isActive = true,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      specialty: json['specialty'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'code': code,
      'specialty': specialty,
      'is_active': isActive,
    };
  }
}

class PackageWeight {
  final String agentName;
  final double weight;

  PackageWeight({
    required this.agentName,
    required this.weight,
  });

  factory PackageWeight.fromJson(Map<String, dynamic> json) {
    return PackageWeight(
      agentName: json['agent_name'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent_name': agentName,
      'weight': weight,
    };
  }
}

class PackageWeightsUpdate {
  final List<PackageWeight> weights;
  final String updatedBy;

  PackageWeightsUpdate({
    required this.weights,
    required this.updatedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'weights': weights.map((w) => w.toJson()).toList(),
      'updated_by': updatedBy,
    };
  }
}

class PackageDocument {
  final int? id;
  final int? packageId;
  final int? fieldKeyId;
  final String fieldKey;
  final String label;
  final int? fieldGroupId;
  final String fieldGroup; // 'text', 'ot_notes', 'pathology', 'radiology', 'others'
  final String dataType;   // 'string' or 'array'
  final bool mandatory;
  final int sortOrder;
  final String? notes;

  PackageDocument({
    this.id,
    this.packageId,
    this.fieldKeyId,
    required this.fieldKey,
    required this.label,
    this.fieldGroupId,
    required this.fieldGroup,
    required this.dataType,
    this.mandatory = true,
    this.sortOrder = 0,
    this.notes,
  });

  factory PackageDocument.fromJson(Map<String, dynamic> json) {
    return PackageDocument(
      id: json['id'],
      packageId: json['package_id'],
      fieldKeyId: json['field_key_id'],
      fieldKey: json['field_key'] ?? '',
      label: json['label'] ?? '',
      fieldGroupId: json['field_group_id'],
      fieldGroup: json['field_group'] ?? '',
      dataType: json['data_type'] ?? '',
      mandatory: json['mandatory'] ?? true,
      sortOrder: json['sort_order'] ?? 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (packageId != null) 'package_id': packageId,
      if (fieldKeyId != null) 'field_key_id': fieldKeyId,
      'field_key': fieldKey,
      'label': label,
      if (fieldGroupId != null) 'field_group_id': fieldGroupId,
      'field_group': fieldGroup,
      'data_type': dataType,
      'mandatory': mandatory,
      'sort_order': sortOrder,
      'notes': notes,
    };
  }
}
