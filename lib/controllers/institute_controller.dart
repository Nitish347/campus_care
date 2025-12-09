import 'package:get/get.dart';
import 'package:campus_care/models/institute/institute_model.dart';

class InstituteController extends GetxController {
  // Observable lists
  final RxList<Institute> institutes = <Institute>[].obs;
  final RxList<Institute> filteredInstitutes = <Institute>[].obs;

  // Filters
  final RxString selectedStatusFilter = 'All'.obs;
  final RxString selectedPlanFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStaticData();
  }

  void _loadStaticData() {
    final now = DateTime.now();

    institutes.value = [
      Institute(
        id: 'inst_001',
        name: 'St. Mary\'s High School',
        code: 'SMHS001',
        email: 'admin@stmarys.edu',
        phone: '+91 98765 43210',
        address: '123 Main Street, Mumbai, Maharashtra 400001',
        website: 'https://www.stmarys.edu',
        establishedDate: DateTime(1995, 6, 15),
        affiliationNumber: 'CBSE/2024/001',
        subscriptionPlan: 'premium',
        subscriptionStatus: 'active',
        subscriptionStartDate: now.subtract(const Duration(days: 180)),
        subscriptionEndDate: now.add(const Duration(days: 185)),
        totalStudents: 1234,
        totalTeachers: 89,
        totalClasses: 24,
        contactPersonName: 'Dr. Rajesh Kumar',
        contactPersonEmail: 'rajesh.kumar@stmarys.edu',
        contactPersonPhone: '+91 98765 43211',
        isActive: true,
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Institute(
        id: 'inst_002',
        name: 'Delhi Public School',
        code: 'DPS002',
        email: 'contact@dps.edu.in',
        phone: '+91 98765 43220',
        address: '456 School Road, Delhi, Delhi 110001',
        website: 'https://www.dps.edu.in',
        establishedDate: DateTime(1988, 4, 10),
        affiliationNumber: 'CBSE/2024/002',
        subscriptionPlan: 'standard',
        subscriptionStatus: 'active',
        subscriptionStartDate: now.subtract(const Duration(days: 90)),
        subscriptionEndDate: now.add(const Duration(days: 275)),
        totalStudents: 2100,
        totalTeachers: 145,
        totalClasses: 36,
        contactPersonName: 'Mrs. Priya Sharma',
        contactPersonEmail: 'priya.sharma@dps.edu.in',
        contactPersonPhone: '+91 98765 43221',
        isActive: true,
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      Institute(
        id: 'inst_003',
        name: 'Greenwood International',
        code: 'GWI003',
        email: 'info@greenwood.edu',
        phone: '+91 98765 43230',
        address: '789 Education Lane, Bangalore, Karnataka 560001',
        website: 'https://www.greenwood.edu',
        establishedDate: DateTime(2005, 8, 20),
        affiliationNumber: 'ICSE/2024/003',
        subscriptionPlan: 'basic',
        subscriptionStatus: 'active',
        subscriptionStartDate: now.subtract(const Duration(days: 300)),
        subscriptionEndDate: now.add(const Duration(days: 65)),
        totalStudents: 856,
        totalTeachers: 62,
        totalClasses: 18,
        contactPersonName: 'Mr. Amit Patel',
        contactPersonEmail: 'amit.patel@greenwood.edu',
        contactPersonPhone: '+91 98765 43231',
        isActive: true,
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 450)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Institute(
        id: 'inst_004',
        name: 'Sunrise Academy',
        code: 'SRA004',
        email: 'admin@sunriseacademy.com',
        phone: '+91 98765 43240',
        address: '321 Knowledge Park, Pune, Maharashtra 411001',
        website: 'https://www.sunriseacademy.com',
        establishedDate: DateTime(2010, 1, 5),
        affiliationNumber: 'STATE/2024/004',
        subscriptionPlan: 'trial',
        subscriptionStatus: 'trial',
        subscriptionStartDate: now.subtract(const Duration(days: 15)),
        subscriptionEndDate: now.add(const Duration(days: 15)),
        totalStudents: 450,
        totalTeachers: 35,
        totalClasses: 12,
        contactPersonName: 'Ms. Sneha Reddy',
        contactPersonEmail: 'sneha.reddy@sunriseacademy.com',
        contactPersonPhone: '+91 98765 43241',
        isActive: true,
        isVerified: false,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      Institute(
        id: 'inst_005',
        name: 'Royal International School',
        code: 'RIS005',
        email: 'contact@royalschool.edu',
        phone: '+91 98765 43250',
        address: '555 Royal Avenue, Chennai, Tamil Nadu 600001',
        website: 'https://www.royalschool.edu',
        establishedDate: DateTime(2000, 3, 12),
        affiliationNumber: 'CBSE/2024/005',
        subscriptionPlan: 'premium',
        subscriptionStatus: 'expired',
        subscriptionStartDate: now.subtract(const Duration(days: 400)),
        subscriptionEndDate: now.subtract(const Duration(days: 35)),
        totalStudents: 1580,
        totalTeachers: 112,
        totalClasses: 28,
        contactPersonName: 'Dr. Venkat Raman',
        contactPersonEmail: 'venkat.raman@royalschool.edu',
        contactPersonPhone: '+91 98765 43251',
        isActive: false,
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 550)),
        updatedAt: now.subtract(const Duration(days: 35)),
      ),
      Institute(
        id: 'inst_006',
        name: 'Modern English School',
        code: 'MES006',
        email: 'admin@modernschool.edu',
        phone: '+91 98765 43260',
        address: '888 Modern Street, Hyderabad, Telangana 500001',
        website: 'https://www.modernschool.edu',
        establishedDate: DateTime(2015, 9, 1),
        affiliationNumber: 'CBSE/2024/006',
        subscriptionPlan: 'standard',
        subscriptionStatus: 'suspended',
        subscriptionStartDate: now.subtract(const Duration(days: 200)),
        subscriptionEndDate: now.add(const Duration(days: 165)),
        totalStudents: 720,
        totalTeachers: 58,
        totalClasses: 16,
        contactPersonName: 'Mrs. Kavita Mehta',
        contactPersonEmail: 'kavita.mehta@modernschool.edu',
        contactPersonPhone: '+91 98765 43261',
        isActive: false,
        isVerified: true,
        createdAt: now.subtract(const Duration(days: 250)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    filteredInstitutes.value = institutes;
  }

  // CRUD Operations
  void addInstitute(Institute institute) {
    institutes.add(institute);
    applyFilters();
    Get.snackbar(
      'Success',
      'Institute added successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void updateInstitute(String id, Institute updatedInstitute) {
    final index = institutes.indexWhere((inst) => inst.id == id);
    if (index != -1) {
      institutes[index] = updatedInstitute;
      applyFilters();
      Get.snackbar(
        'Success',
        'Institute updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void deleteInstitute(String id) {
    institutes.removeWhere((inst) => inst.id == id);
    applyFilters();
    Get.snackbar(
      'Success',
      'Institute deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleInstituteStatus(String id) {
    final index = institutes.indexWhere((inst) => inst.id == id);
    if (index != -1) {
      final institute = institutes[index];
      institutes[index] = institute.copyWith(
        isActive: !institute.isActive,
        updatedAt: DateTime.now(),
      );
      applyFilters();
    }
  }

  void verifyInstitute(String id) {
    final index = institutes.indexWhere((inst) => inst.id == id);
    if (index != -1) {
      final institute = institutes[index];
      institutes[index] = institute.copyWith(
        isVerified: true,
        updatedAt: DateTime.now(),
      );
      applyFilters();
      Get.snackbar(
        'Success',
        'Institute verified successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void renewSubscription(String id, DateTime newEndDate) {
    final index = institutes.indexWhere((inst) => inst.id == id);
    if (index != -1) {
      final institute = institutes[index];
      institutes[index] = institute.copyWith(
        subscriptionEndDate: newEndDate,
        subscriptionStatus: 'active',
        updatedAt: DateTime.now(),
      );
      applyFilters();
      Get.snackbar(
        'Success',
        'Subscription renewed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Filtering
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    applyFilters();
  }

  void setPlanFilter(String plan) {
    selectedPlanFilter.value = plan;
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void clearFilters() {
    selectedStatusFilter.value = 'All';
    selectedPlanFilter.value = 'All';
    searchQuery.value = '';
    applyFilters();
  }

  void applyFilters() {
    var filtered = institutes.toList();

    // Apply status filter
    if (selectedStatusFilter.value != 'All') {
      filtered = filtered.where((inst) {
        switch (selectedStatusFilter.value) {
          case 'Active':
            return inst.isActive && inst.subscriptionStatus == 'active';
          case 'Inactive':
            return !inst.isActive;
          case 'Pending':
            return !inst.isVerified;
          case 'Expired':
            return inst.subscriptionStatus == 'expired';
          default:
            return true;
        }
      }).toList();
    }

    // Apply plan filter
    if (selectedPlanFilter.value != 'All') {
      filtered = filtered
          .where((inst) =>
              inst.subscriptionPlan.toLowerCase() ==
              selectedPlanFilter.value.toLowerCase())
          .toList();
    }

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((inst) {
        return inst.name.toLowerCase().contains(query) ||
            inst.code.toLowerCase().contains(query) ||
            inst.email.toLowerCase().contains(query) ||
            inst.contactPersonName.toLowerCase().contains(query);
      }).toList();
    }

    filteredInstitutes.value = filtered;
  }

  // Statistics
  Map<String, dynamic> getInstituteStats() {
    return {
      'total': institutes.length,
      'active': institutes
          .where((i) => i.isActive && i.subscriptionStatus == 'active')
          .length,
      'inactive': institutes.where((i) => !i.isActive).length,
      'pending': institutes.where((i) => !i.isVerified).length,
      'expired':
          institutes.where((i) => i.subscriptionStatus == 'expired').length,
      'expiringSoon':
          institutes.where((i) => i.isSubscriptionExpiringSoon).length,
    };
  }

  Map<String, dynamic> getSubscriptionStats() {
    return {
      'basic': institutes.where((i) => i.subscriptionPlan == 'basic').length,
      'standard':
          institutes.where((i) => i.subscriptionPlan == 'standard').length,
      'premium':
          institutes.where((i) => i.subscriptionPlan == 'premium').length,
      'trial': institutes.where((i) => i.subscriptionPlan == 'trial').length,
    };
  }

  int getTotalStudents() {
    return institutes.fold(0, (sum, inst) => sum + inst.totalStudents);
  }

  int getTotalTeachers() {
    return institutes.fold(0, (sum, inst) => sum + inst.totalTeachers);
  }

  Institute? getInstituteById(String id) {
    try {
      return institutes.firstWhere((inst) => inst.id == id);
    } catch (e) {
      return null;
    }
  }
}
