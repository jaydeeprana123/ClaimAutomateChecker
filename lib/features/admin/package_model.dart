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
