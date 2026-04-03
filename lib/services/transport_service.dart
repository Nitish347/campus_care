import 'package:campus_care/models/transport/transport_assignment.dart';
import 'package:campus_care/models/transport/transport_driver.dart';
import 'package:campus_care/models/transport/transport_route.dart';
import 'package:campus_care/models/transport/transport_stop.dart';
import 'package:campus_care/models/transport/transport_vehicle.dart';
import 'package:campus_care/services/api/transport_api_service.dart';

class TransportService {
  static final TransportApiService _apiService = TransportApiService();

  static Future<List<TransportDriver>> getDrivers() async {
    final data = await _apiService.getDrivers();
    return data
        .map((item) => TransportDriver.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<TransportDriver> createDriver(TransportDriver driver) async {
    final data = await _apiService.createDriver(driver.toJson());
    return TransportDriver.fromJson(data);
  }

  static Future<TransportDriver> updateDriver(TransportDriver driver) async {
    final data = await _apiService.updateDriver(driver.id, driver.toJson());
    return TransportDriver.fromJson(data);
  }

  static Future<void> deleteDriver(String driverId) async {
    await _apiService.deleteDriver(driverId);
  }

  static Future<List<TransportVehicle>> getVehicles() async {
    final data = await _apiService.getVehicles();
    return data
        .map((item) => TransportVehicle.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<TransportVehicle> createVehicle(
      TransportVehicle vehicle) async {
    final data = await _apiService.createVehicle(vehicle.toJson());
    return TransportVehicle.fromJson(data);
  }

  static Future<TransportVehicle> updateVehicle(
      TransportVehicle vehicle) async {
    final data = await _apiService.updateVehicle(vehicle.id, vehicle.toJson());
    return TransportVehicle.fromJson(data);
  }

  static Future<void> deleteVehicle(String vehicleId) async {
    await _apiService.deleteVehicle(vehicleId);
  }

  static Future<List<TransportRoute>> getRoutes() async {
    final data = await _apiService.getRoutes();
    return data
        .map((item) => TransportRoute.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<TransportRoute> createRoute(TransportRoute route) async {
    final data = await _apiService.createRoute(route.toJson());
    return TransportRoute.fromJson(data);
  }

  static Future<TransportRoute> updateRoute(TransportRoute route) async {
    final data = await _apiService.updateRoute(route.id, route.toJson());
    return TransportRoute.fromJson(data);
  }

  static Future<void> deleteRoute(String routeId) async {
    await _apiService.deleteRoute(routeId);
  }

  static Future<List<TransportStop>> getRouteStops(String routeId) async {
    final data = await _apiService.getRouteStops(routeId);
    return data
        .map((item) => TransportStop.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<TransportStop> createRouteStop(TransportStop stop) async {
    final data = await _apiService.createRouteStop(stop.routeId, stop.toJson());
    return TransportStop.fromJson(data);
  }

  static Future<TransportStop> updateRouteStop(TransportStop stop) async {
    final data = await _apiService.updateRouteStop(stop.id, stop.toJson());
    return TransportStop.fromJson(data);
  }

  static Future<void> deleteRouteStop(String stopId) async {
    await _apiService.deleteRouteStop(stopId);
  }

  static Future<List<TransportAssignment>> getAssignments() async {
    final data = await _apiService.getAssignments();
    return data
        .map((item) =>
            TransportAssignment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<TransportAssignment> createAssignment(
      TransportAssignment assignment) async {
    final data = await _apiService.createAssignment(assignment.toJson());
    return TransportAssignment.fromJson(data);
  }

  static Future<TransportAssignment> updateAssignment(
      TransportAssignment assignment) async {
    final data =
        await _apiService.updateAssignment(assignment.id, assignment.toJson());
    return TransportAssignment.fromJson(data);
  }

  static Future<void> deleteAssignment(String assignmentId) async {
    await _apiService.deleteAssignment(assignmentId);
  }
}
