import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_repository.dart';
import 'user_model.dart';
import '../../core/theme/app_colors.dart';

import 'package:claim_automate_checker/features/admin/package_model.dart';

class AdminController extends GetxController {
  final IAdminRepository repository;

  AdminController({required this.repository});

  final RxList<AdminUser> users = <AdminUser>[].obs;
  final RxList<PackageModel> packages = <PackageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchPackages();
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
    if (index == 1 && users.isEmpty) fetchUsers();
    if (index == 2 && packages.isEmpty) fetchPackages();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      final data = await repository.getUsers();
      users.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPackages() async {
    isLoading.value = true;
    try {
      final data = await repository.getPackages();
      packages.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createUser(String username, String fullName, String email, String role, String password) async {
    isLoading.value = true;
    try {
      final user = AdminUser(username: username, fullName: fullName, email: email, role: role);
      final success = await repository.createUser(user, password);
      
      if (success) {
        await fetchUsers();
        Get.back(); // Navigate back from Create User screen
        Get.snackbar(
          'Success',
          'User created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to create user',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPackage(PackageModel package) async {
    isLoading.value = true;
    try {
      final success = await repository.createPackage(package);
      
      if (success) {
        await fetchPackages();
        Get.back(); // Navigate back from Create Package screen
        Get.snackbar(
          'Success',
          'Package created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to create package',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(String oldUsername, AdminUser user) async {
    isLoading.value = true;
    try {
      final success = await repository.updateUser(oldUsername, user);
      if (success) {
        await fetchUsers();
        Get.back();
        Get.snackbar('Success', 'User updated successfully',
            backgroundColor: AppColors.success, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to update user',
            backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePackage(String code, PackageModel package) async {
    isLoading.value = true;
    try {
      final success = await repository.updatePackage(code, package);
      if (success) {
        await fetchPackages();
        Get.back();
        Get.snackbar('Success', 'Package updated successfully',
            backgroundColor: AppColors.success, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to update package',
            backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePackageWeights(String code, PackageWeightsUpdate update) async {
    isLoading.value = true;
    try {
      final success = await repository.updatePackageWeights(code, update);
      if (success) {
        await fetchPackages();
        Get.back();
        Get.snackbar('Success', 'Package weights updated successfully',
            backgroundColor: AppColors.success, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to update package weights',
            backgroundColor: AppColors.error, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  final RxList<PackageDocument> packageDocuments = <PackageDocument>[].obs;
  final RxBool isLoadingDocuments = false.obs;

  Future<void> fetchPackageDocuments(String code) async {
    isLoadingDocuments.value = true;
    try {
      final data = await repository.getPackageDocuments(code);
      // Sort them by sortOrder ascending
      data.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      packageDocuments.assignAll(data);
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<bool> createPackageDocument(String code, PackageDocument doc) async {
    isLoadingDocuments.value = true;
    try {
      final newDoc = await repository.createPackageDocument(code, doc);
      if (newDoc != null) {
        await fetchPackageDocuments(code);
        Get.snackbar(
          'Success',
          'Package document created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to create package document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return false;
      }
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<bool> updatePackageDocument(String code, int docId, PackageDocument doc) async {
    isLoadingDocuments.value = true;
    try {
      final updatedDoc = await repository.updatePackageDocument(code, docId, doc);
      if (updatedDoc != null) {
        await fetchPackageDocuments(code);
        Get.snackbar(
          'Success',
          'Package document updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to update package document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return false;
      }
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  Future<bool> deletePackageDocument(String code, int docId) async {
    isLoadingDocuments.value = true;
    try {
      final success = await repository.deletePackageDocument(code, docId);
      if (success) {
        await fetchPackageDocuments(code);
        Get.snackbar(
          'Success',
          'Package document deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete package document',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
        return false;
      }
    } finally {
      isLoadingDocuments.value = false;
    }
  }
}
