import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'patient_controller.dart';
import 'patient_model.dart';
import 'patient_repository.dart';
import '../claims/new_claim_screen.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PatientController(repository: PatientRepository()),
    );

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(context, controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.patients.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildPatientTable(context, controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PatientController controller) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patients', style: AppTextStyles.heading1),
              SizedBox(height: 4),
              Text(
                'Manage and view all registered patients.',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const NewClaimScreen()),
            icon: const Icon(Icons.add),
            label: const Text('New Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTable(
    BuildContext context,
    PatientController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32.0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DataTable(
              headingTextStyle: AppTextStyles.label.copyWith(
                color: AppColors.dark,
              ),
              dataTextStyle: AppTextStyles.bodyMedium,
              horizontalMargin: 0,
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Age')),
                DataColumn(label: Text('Gender')),
                DataColumn(label: Text('Contact')),
                DataColumn(label: Text('Actions')),
              ],
              rows: controller.patients.map((patient) {
                return DataRow(
                  cells: [
                    DataCell(Text(patient.id)),
                    DataCell(
                      Text(
                        patient.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(Text(patient.age)),
                    DataCell(Text(patient.gender)),
                    DataCell(Text(patient.contact)),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: AppColors.error,
                            ),
                            onPressed: () => _showDeleteConfirmation(
                              context,
                              controller,
                              patient,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    PatientController controller,
    Patient patient,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete patient "${patient.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.darkGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deletePatient(patient.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
