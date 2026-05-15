class Patient {
  final String id;
  final String name;
  final String age;
  final String gender;
  final String contact;
  final String email;
  final String address;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    this.email = '',
    this.address = '',
  });

  Patient copyWith({
    String? id,
    String? name,
    String? age,
    String? gender,
    String? contact,
    String? email,
    String? address,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}
