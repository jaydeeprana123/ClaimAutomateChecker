import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/logger.dart';
import 'user_model.dart';
import 'package:claim_automate_checker/features/admin/package_model.dart';

abstract class IAdminRepository {
  Future<List<AdminUser>> getUsers();
  Future<bool> createUser(AdminUser user, String password);
  Future<List<PackageModel>> getPackages();
  Future<bool> createPackage(PackageModel package);
  Future<bool> updateUser(String username, AdminUser user);
  Future<bool> updatePackage(String code, PackageModel package);
  Future<bool> updatePackageWeights(String code, PackageWeightsUpdate update);
}

class AdminRepository implements IAdminRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Options _getOptions() {
    final token = StorageService.getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<List<AdminUser>> getUsers() async {
    try {
      final response = await _dio.get(
        '/api/v1/admin/users',
        options: _getOptions(),
      );

      AppLogger.printData("getUsers status", response.statusCode.toString());

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => AdminUser.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.printData("getUsers error", e.toString());
      return [];
    }
  }

  @override
  Future<bool> createUser(AdminUser user, String password) async {
    try {
      final response = await _dio.post(
        '/api/v1/admin/users',
        data: {
          'username': user.username,
          'email': user.email,
          'full_name': user.fullName,
          'role': user.role,
          'password': password,
          'is_active': true,
        },
        options: _getOptions(),
      );

      AppLogger.printData("createUser status", response.statusCode.toString());

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      AppLogger.printData("createUser error", e.toString());
      return false;
    }
  }

  @override
  Future<List<PackageModel>> getPackages() async {
    try {
      final response = await _dio.get(
        '/api/v1/admin/packages',
        options: _getOptions(),
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => PackageModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      AppLogger.printData("getPackages error", e.toString());
      return [];
    }
  }

  @override
  Future<bool> createPackage(PackageModel package) async {
    try {
      final response = await _dio.post(
        '/api/v1/admin/packages',
        data: package.toJson(),
        options: _getOptions(),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      AppLogger.printData("createPackage error", e.toString());
      return false;
    }
  }

  @override
  Future<bool> updateUser(String username, AdminUser user) async {
    try {
      final response = await _dio.put(
        '/api/v1/admin/users/$username',
        data: user.toJson(),
        options: _getOptions(),
      );
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.printData("updateUser error", e.toString());
      return false;
    }
  }

  @override
  Future<bool> updatePackage(String code, PackageModel package) async {
    try {
      final response = await _dio.put(
        '/api/v1/admin/packages/$code',
        data: package.toJson(),
        options: _getOptions(),
      );
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.printData("updatePackage error", e.toString());
      return false;
    }
  }

  @override
  Future<bool> updatePackageWeights(String code, PackageWeightsUpdate update) async {
    try {
      final response = await _dio.put(
        '/api/v1/admin/packages/$code/weights',
        data: update.toJson(),
        options: _getOptions(),
      );
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.printData("updatePackageWeights error", e.toString());
      return false;
    }
  }
}
