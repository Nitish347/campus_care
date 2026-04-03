import 'package:campus_care/models/transport/transport_assignment.dart';
import 'package:campus_care/models/transport/transport_driver.dart';
import 'package:campus_care/models/transport/transport_route.dart';
import 'package:campus_care/models/transport/transport_stop.dart';
import 'package:campus_care/models/transport/transport_vehicle.dart';
import 'package:campus_care/services/transport_service.dart';
import 'package:get/get.dart';

class TransportController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxList<TransportDriver> drivers = <TransportDriver>[].obs;
  final RxList<TransportVehicle> vehicles = <TransportVehicle>[].obs;
  final RxList<TransportRoute> routes = <TransportRoute>[].obs;
  final RxList<TransportStop> stops = <TransportStop>[].obs;
  final RxList<TransportAssignment> assignments = <TransportAssignment>[].obs;

  final RxnString selectedRouteId = RxnString();

  int get activeDriversCount => drivers.where((d) => d.isActive).length;
  int get activeVehiclesCount => vehicles.where((v) => v.isActive).length;
  int get activeRoutesCount => routes.where((r) => r.isActive).length;
  int get activeAssignmentsCount =>
      assignments.where((a) => a.status == 'active').length;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    await refreshAll();
  }

  Future<void> refreshAll() async {
    try {
      isLoading.value = true;
      error.value = '';

      await Future.wait([
        loadDrivers(showLoader: false),
        loadVehicles(showLoader: false),
        loadRoutes(showLoader: false),
        loadAssignments(showLoader: false),
      ]);

      if (routes.isNotEmpty) {
        selectedRouteId.value = selectedRouteId.value ?? routes.first.id;
        await loadStopsForSelectedRoute(showLoader: false);
      } else {
        selectedRouteId.value = null;
        stops.clear();
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load transport data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDrivers({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      drivers.assignAll(await TransportService.getDrivers());
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load drivers: $e');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> loadVehicles({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      vehicles.assignAll(await TransportService.getVehicles());
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load vehicles: $e');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> loadRoutes({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      routes.assignAll(await TransportService.getRoutes());
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load routes: $e');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> loadStopsForSelectedRoute({bool showLoader = true}) async {
    final routeId = selectedRouteId.value;
    if (routeId == null || routeId.isEmpty) {
      stops.clear();
      return;
    }
    await loadStops(routeId, showLoader: showLoader);
  }

  Future<void> loadStops(String routeId, {bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      stops.assignAll(await TransportService.getRouteStops(routeId));
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load route stops: $e');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> loadAssignments({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;
      assignments.assignAll(await TransportService.getAssignments());
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to load assignments: $e');
    } finally {
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> changeSelectedRoute(String? routeId) async {
    selectedRouteId.value = routeId;
    await loadStopsForSelectedRoute();
  }

  Future<bool> addDriver(TransportDriver driver) async {
    try {
      isLoading.value = true;
      await TransportService.createDriver(driver);
      await Future.wait(
          [loadDrivers(showLoader: false), loadAssignments(showLoader: false)]);
      Get.snackbar('Success', 'Driver added successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to add driver: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDriver(TransportDriver driver) async {
    try {
      isLoading.value = true;
      await TransportService.updateDriver(driver);
      await Future.wait(
          [loadDrivers(showLoader: false), loadAssignments(showLoader: false)]);
      Get.snackbar('Success', 'Driver updated successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to update driver: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDriver(String driverId) async {
    try {
      isLoading.value = true;
      await TransportService.deleteDriver(driverId);
      await Future.wait(
          [loadDrivers(showLoader: false), loadAssignments(showLoader: false)]);
      Get.snackbar('Success', 'Driver deleted successfully');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to delete driver: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addVehicle(TransportVehicle vehicle) async {
    try {
      isLoading.value = true;
      await TransportService.createVehicle(vehicle);
      await Future.wait([
        loadVehicles(showLoader: false),
        loadAssignments(showLoader: false)
      ]);
      Get.snackbar('Success', 'Vehicle added successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to add vehicle: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateVehicle(TransportVehicle vehicle) async {
    try {
      isLoading.value = true;
      await TransportService.updateVehicle(vehicle);
      await Future.wait([
        loadVehicles(showLoader: false),
        loadAssignments(showLoader: false)
      ]);
      Get.snackbar('Success', 'Vehicle updated successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to update vehicle: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      isLoading.value = true;
      await TransportService.deleteVehicle(vehicleId);
      await Future.wait([
        loadVehicles(showLoader: false),
        loadAssignments(showLoader: false)
      ]);
      Get.snackbar('Success', 'Vehicle deleted successfully');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to delete vehicle: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addRoute(TransportRoute route) async {
    try {
      isLoading.value = true;
      final createdRoute = await TransportService.createRoute(route);
      await Future.wait(
          [loadRoutes(showLoader: false), loadAssignments(showLoader: false)]);

      if (selectedRouteId.value == null || selectedRouteId.value!.isEmpty) {
        selectedRouteId.value = createdRoute.id;
        await loadStopsForSelectedRoute(showLoader: false);
      }

      Get.snackbar('Success', 'Route added successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to add route: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateRoute(TransportRoute route) async {
    try {
      isLoading.value = true;
      await TransportService.updateRoute(route);
      await Future.wait(
          [loadRoutes(showLoader: false), loadAssignments(showLoader: false)]);
      await loadStopsForSelectedRoute(showLoader: false);
      Get.snackbar('Success', 'Route updated successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to update route: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRoute(String routeId) async {
    try {
      isLoading.value = true;
      await TransportService.deleteRoute(routeId);
      await Future.wait(
          [loadRoutes(showLoader: false), loadAssignments(showLoader: false)]);

      if (selectedRouteId.value == routeId) {
        selectedRouteId.value = routes.isNotEmpty ? routes.first.id : null;
      }
      await loadStopsForSelectedRoute(showLoader: false);
      Get.snackbar('Success', 'Route deleted successfully');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to delete route: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addStop(TransportStop stop) async {
    try {
      isLoading.value = true;
      await TransportService.createRouteStop(stop);
      await loadStopsForSelectedRoute(showLoader: false);
      Get.snackbar('Success', 'Stop added successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to add stop: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateStop(TransportStop stop) async {
    try {
      isLoading.value = true;
      await TransportService.updateRouteStop(stop);
      await loadStopsForSelectedRoute(showLoader: false);
      Get.snackbar('Success', 'Stop updated successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to update stop: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStop(String stopId) async {
    try {
      isLoading.value = true;
      await TransportService.deleteRouteStop(stopId);
      await loadStopsForSelectedRoute(showLoader: false);
      Get.snackbar('Success', 'Stop deleted successfully');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to delete stop: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addAssignment(TransportAssignment assignment) async {
    try {
      isLoading.value = true;
      await TransportService.createAssignment(assignment);
      await loadAssignments(showLoader: false);
      Get.snackbar('Success', 'Assignment created successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to create assignment: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAssignment(TransportAssignment assignment) async {
    try {
      isLoading.value = true;
      await TransportService.updateAssignment(assignment);
      await loadAssignments(showLoader: false);
      Get.snackbar('Success', 'Assignment updated successfully');
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to update assignment: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    try {
      isLoading.value = true;
      await TransportService.deleteAssignment(assignmentId);
      await loadAssignments(showLoader: false);
      Get.snackbar('Success', 'Assignment deleted successfully');
    } catch (e) {
      error.value = e.toString();
      Get.snackbar('Error', 'Failed to delete assignment: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
