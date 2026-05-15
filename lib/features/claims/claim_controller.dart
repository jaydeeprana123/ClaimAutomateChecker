import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../patients/patient_model.dart';
import '../patients/patient_repository.dart';
import '../patients/patient_controller.dart';
import '../../core/theme/app_colors.dart';

class ClaimController extends GetxController {
  final IPatientRepository patientRepository;

  ClaimController({required this.patientRepository});

  final formKey = GlobalKey<FormState>();

  // Patient Details
  final patientNameController = TextEditingController();
  final ageController = TextEditingController();
  final beneficiaryIdController = TextEditingController();
  final doctorNameController = TextEditingController();

  final mobileNumberController = TextEditingController();
  final selectedTitle = 'Mr'.obs;
  final gender = RxnString('Male');
  final dateOfBirth = Rxn<DateTime>();

  @override
  void onClose() {
    patientNameController.dispose();
    ageController.dispose();
    beneficiaryIdController.dispose();
    mobileNumberController.dispose();
    super.onClose();
  }

  void setTitle(String? value) {
    if (value != null) {
      selectedTitle.value = value;
      if (value == 'Mr') {
        gender.value = 'Male';
      } else if (value == 'Miss' || value == 'Mrs') {
        gender.value = 'Female';
      }
    }
  }

  void setGender(String? value) => gender.value = value;

  void setDateOfBirth(DateTime date) {
    dateOfBirth.value = date;
    calculateAge(date);
  }

  void calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    ageController.text = age.toString();
  }

  Future<void> savePatient() async {
    if (!formKey.currentState!.validate()) return;

    final patient = Patient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${selectedTitle.value}. ${patientNameController.text.trim().toUpperCase()}',
      age: ageController.text,
      gender: gender.value ?? 'Unknown',
      contact: mobileNumberController.text,
      email: '', // Not in form
      address: '', // Not in form
    );

    try {
      await patientRepository.addPatient(patient);

      // Update PatientController list if it exists
      if (Get.isRegistered<PatientController>()) {
        Get.find<PatientController>().patients.add(patient);
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Patient saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save patient',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void saveAndStartClaim() {
    if (!formKey.currentState!.validate()) return;

    // Just show snackbar as requested
    Get.snackbar(
      'Claim Started',
      'Patient details saved and claim process initiated.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );
  }
}
