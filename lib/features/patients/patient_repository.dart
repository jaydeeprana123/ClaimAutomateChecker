import 'patient_model.dart';

abstract class IPatientRepository {
  Future<List<Patient>> getPatients();
  Future<void> addPatient(Patient patient);
  Future<void> deletePatient(String id);
}

class PatientRepository implements IPatientRepository {
  // Mock data for initial list
  final List<Patient> _mockPatients = [
    Patient(
      id: '1',
      name: 'John Doe',
      age: '45',
      gender: 'Male',
      contact: '+91 9876543210',
      email: 'john@example.com',
      address: '123 Main St, Mumbai',
    ),
    Patient(
      id: '2',
      name: 'Jane Smith',
      age: '32',
      gender: 'Female',
      contact: '+91 8765432109',
      email: 'jane@example.com',
      address: '456 Park Rd, Delhi',
    ),
  ];

  @override
  Future<List<Patient>> getPatients() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate delay
    return _mockPatients;
  }

  @override
  Future<void> addPatient(Patient patient) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    _mockPatients.add(patient);
  }

  @override
  Future<void> deletePatient(String id) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate delay
    _mockPatients.removeWhere((p) => p.id == id);
  }
}
