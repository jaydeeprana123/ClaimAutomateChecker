import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../admin_controller.dart';
import '../package_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';

class UpdatePackageWeightsScreen extends StatefulWidget {
  final PackageModel package;
  const UpdatePackageWeightsScreen({super.key, required this.package});

  @override
  State<UpdatePackageWeightsScreen> createState() =>
      _UpdatePackageWeightsScreenState();
}

class _UpdatePackageWeightsScreenState
    extends State<UpdatePackageWeightsScreen> {
  final List<PackageWeight> _weights = [];
  final _agentNameController = TextEditingController();
  final _weightController = TextEditingController();

  void _addWeight() {
    if (_agentNameController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      setState(() {
        _weights.add(
          PackageWeight(
            agentName: _agentNameController.text,
            weight: double.parse(_weightController.text),
          ),
        );
        _agentNameController.clear();
        _weightController.clear();
      });
    }
  }

  void _removeWeight(int index) {
    setState(() {
      _weights.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Package Weights: ${widget.package.code}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Agent Weight',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _agentNameController,
                    decoration: InputDecoration(
                      labelText: 'Agent Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addWeight,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Current Weights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _weights.isEmpty
                  ? Center(
                      child: Text(
                        'No weights added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _weights.length,
                      itemBuilder: (context, index) {
                        final w = _weights[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              w.agentName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  w.weight.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _removeWeight(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value || _weights.isEmpty
                      ? null
                      : () {
                          final update = PackageWeightsUpdate(
                            weights: _weights,
                            updatedBy: StorageService.getRole() ?? 'admin',
                          );
                          controller.updatePackageWeights(
                            widget.package.code,
                            update,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update All Weights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
