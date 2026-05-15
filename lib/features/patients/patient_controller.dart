import 'package:claim_automate_checker/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'patient_model.dart';
import 'patient_repository.dart';

class PatientController extends GetxController {
  final IPatientRepository repository;

  PatientController({required this.repository});

  final RxList<Patient> patients = <Patient>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    isLoading.value = true;
    try {
      final data = await repository.getPatients();
      patients.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPatient(Patient patient) async {
    isLoading.value = true;
    try {
      await repository.addPatient(patient);
      patients.add(patient);
      Get.back(); // Close dialog/screen
      Get.snackbar(
        'Success',
        'Patient added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePatient(String id) async {
    try {
      await repository.deletePatient(id);
      patients.removeWhere((p) => p.id == id);
      Get.snackbar(
        'Deleted',
        'Patient record removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete patient',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
