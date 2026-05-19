import 'package:claim_automate_checker/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'patient_model.dart';
import 'patient_repository.dart';
import '../claims/ai_analysis_result_screen.dart';

class PatientController extends GetxController {
  final IPatientRepository repository;

  PatientController({required this.repository});

  final RxList<Patient> patients = <Patient>[].obs;
  final RxBool isLoading = false.obs;

  // Search text controller
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPatients();

    // Setup debounce for search query
    debounce(searchQuery, (query) {
      fetchPatients(search: query);
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchPatients({String? search}) async {
    isLoading.value = true;
    try {
      final data = await repository.getPatients(search: search);
      patients.assignAll(data);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch patients from server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPatient(Patient patient) async {
    isLoading.value = true;
    try {
      final newPatient = await repository.addPatient(patient);
      if (newPatient != null) {
        patients.add(newPatient);
      }
      Get.back(); // Close dialog/screen
      Get.snackbar(
        'Success',
        'Patient added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add patient to server: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
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

  Future<void> getPatientById(String id) async {
    isLoading.value = true;
    try {
      final patient = await repository.getPatientById(id);
      if (patient != null) {
        List<dynamic> claims = [];
        final patientIdInt = int.tryParse(patient.id);
        if (patientIdInt != null) {
          try {
            final fetchedClaims = await repository.getPatientClaims(patientIdInt);
            if (fetchedClaims != null) {
              claims = fetchedClaims;
            }
          } catch (e) {
            debugPrint("Failed to fetch claims for patient: $e");
          }
        }
        _showPatientDetailsDialog(patient, claims: claims);
      } else {
        Get.snackbar(
          'Error',
          'Patient not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch patient details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showPatientDetails(Patient patient) async {
    isLoading.value = true;
    List<dynamic> claims = [];
    final patientIdInt = int.tryParse(patient.id);
    if (patientIdInt != null) {
      try {
        final fetchedClaims = await repository.getPatientClaims(patientIdInt);
        if (fetchedClaims != null) {
          claims = fetchedClaims;
        }
      } catch (e) {
        debugPrint("Failed to fetch claims for patient: $e");
      }
    }
    isLoading.value = false;
    _showPatientDetailsDialog(patient, claims: claims);
  }

  void _showPatientDetailsDialog(Patient patient, {List<dynamic> claims = const []}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.badge_outlined, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Patient Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.darkGrey),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1),
                const SizedBox(height: 8),
                _buildDetailRow('Patient ID', patient.id),
                _buildDetailRow('PMJAY Beneficiary ID', patient.pmjayNumber),
                _buildDetailRow('Full Name', patient.name),
                _buildDetailRow('Date of Birth', patient.dob),
                _buildDetailRow('Age', '${patient.age} years'),
                _buildDetailRow('Gender', patient.gender),
                _buildDetailRow('Contact Number', patient.contact.isEmpty ? '-' : patient.contact),
                if (patient.createdAt.isNotEmpty)
                  _buildDetailRow('Registered On', patient.createdAt.substring(0, 10)),
                const Divider(height: 24, thickness: 1),
                const SizedBox(height: 8),
                const Text(
                  'Claims History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                if (claims.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No claims found for this patient.',
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: claims.length,
                      itemBuilder: (context, index) {
                        final claim = claims[index];
                        final claimId = claim['claim_id'] ?? claim['id'];
                        final claimRef = claim['claim_ref'] ?? 'Ref: $claimId';
                        final packageCode = claim['package_code'] ?? 'Unknown Pkg';
                        final verdict = claim['verdict'] ?? 'UNKNOWN';
                        final score = claim['total_score'] != null ? '${(claim['total_score'] as num).round()}%' : '-';
                        
                        Color verdictColor;
                        if (verdict == 'PASS') {
                          verdictColor = AppColors.success;
                        } else if (verdict == 'FAIL') {
                          verdictColor = AppColors.error;
                        } else {
                          verdictColor = AppColors.warning;
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 1,
                          child: ListTile(
                            dense: true,
                            title: Text(
                              '$packageCode ($claimRef)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                const Text('Verdict: '),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: verdictColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    verdict,
                                    style: TextStyle(
                                      color: verdictColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('Score: $score'),
                              ],
                            ),
                            trailing: claimId != null
                                ? IconButton(
                                    icon: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 20),
                                    onPressed: () {
                                      Get.back(); // Close details dialog
                                      final idInt = claimId is int ? claimId : int.tryParse(claimId.toString());
                                      if (idInt != null) {
                                        Get.to(() => AiAnalysisResultScreen(claimId: idInt));
                                      }
                                    },
                                    tooltip: 'View AI Analysis Result',
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }
}
