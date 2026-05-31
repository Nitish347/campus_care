import 'package:campus_care/controllers/auth_controller.dart';
import 'package:campus_care/models/transport/transport_assignment.dart';
import 'package:campus_care/models/transport/transport_route.dart';
import 'package:campus_care/models/transport/transport_stop.dart';
import 'package:campus_care/services/api/transport_api_service.dart';
import 'package:campus_care/widgets/common/info_card.dart';
import 'package:campus_care/widgets/common/section_header.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:campus_care/widgets/student/student_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentTransportScreen extends StatefulWidget {
  const StudentTransportScreen({super.key});

  @override
  State<StudentTransportScreen> createState() => _StudentTransportScreenState();
}

class _StudentTransportScreenState extends State<StudentTransportScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TransportApiService _transportApi = TransportApiService();

  bool _isLoading = true;
  String? _error;
  TransportRoute? _route;
  List<TransportStop> _stops = const [];
  List<TransportAssignment> _assignments = const [];

  @override
  void initState() {
    super.initState();
    _loadTransportData();
  }

  Future<void> _loadTransportData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final student = _authController.currentStudent;
      if (student == null) {
        throw Exception('Student session not found');
      }

      final assignmentsRaw = await _transportApi.getAssignments(status: 'active');
      final assignments = assignmentsRaw
          .map((item) => TransportAssignment.fromJson(item as Map<String, dynamic>))
          .toList();

      final routesRaw = await _transportApi.getRoutes(isActive: true);
      final routes = routesRaw
          .map((item) => TransportRoute.fromJson(item as Map<String, dynamic>))
          .toList();

      String? routeId = student.routeId;
      if ((routeId == null || routeId.isEmpty) && assignments.isNotEmpty) {
        routeId = assignments.first.routeId;
      }

      TransportRoute? matchedRoute;
      if (routeId != null) {
        for (final route in routes) {
          if (route.id == routeId) {
            matchedRoute = route;
            break;
          }
        }
      }

      final visibleAssignments = routeId == null
          ? assignments
          : assignments.where((assignment) => assignment.routeId == routeId).toList();

      final stopsRaw =
          routeId == null ? const <dynamic>[] : await _transportApi.getRouteStops(routeId);
      final stops = stopsRaw
          .map((item) => TransportStop.fromJson(item as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _route = matchedRoute;
        _stops = stops;
        _assignments = visibleAssignments;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: StudentAppBar(
        title: 'Transport',
        extraActions: [
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _loadTransportData,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTransportData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ResponsivePadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Your Route',
                          subtitle: 'Pickup, drop, and assigned vehicle details',
                        ),
                        const SizedBox(height: 12),
                        if (_error != null)
                          InfoCard(
                            child: Text(
                              _error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          )
                        else if (_route == null)
                          const InfoCard(
                            child: ListTile(
                              leading: Icon(Icons.route_outlined),
                              title: Text('Transport route not assigned'),
                              subtitle: Text(
                                'Contact your school admin to assign your route.',
                              ),
                            ),
                          )
                        else ...[
                          InfoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_route!.routeNumber} • ${_route!.routeName}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_route!.startLocation} → ${_route!.endLocation}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _chip(
                                      context,
                                      Icons.wb_sunny_outlined,
                                      _route!.morningStartTime == null
                                          ? 'Morning: N/A'
                                          : 'Morning: ${_route!.morningStartTime}',
                                    ),
                                    _chip(
                                      context,
                                      Icons.nights_stay_outlined,
                                      _route!.afternoonStartTime == null
                                          ? 'Afternoon: N/A'
                                          : 'Afternoon: ${_route!.afternoonStartTime}',
                                    ),
                                    _chip(
                                      context,
                                      Icons.location_on_outlined,
                                      '${_stops.length} stops',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const SectionHeader(title: 'Assigned Team'),
                          const SizedBox(height: 10),
                          if (_assignments.isEmpty)
                            const InfoCard(
                              child: ListTile(
                                leading: Icon(Icons.directions_bus_outlined),
                                title: Text('No active assignment found'),
                                subtitle: Text('Vehicle and driver details are not available.'),
                              ),
                            )
                          else
                            ..._assignments.map((assignment) => InfoCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        assignment.vehicleNumber ?? 'Vehicle',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Driver: ${assignment.driverName.isEmpty ? 'N/A' : assignment.driverName}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      if ((assignment.driverPhone ?? '').isNotEmpty)
                                        Text(
                                          'Driver Phone: ${assignment.driverPhone}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      if ((assignment.attendantName ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Attendant: ${assignment.attendantName}',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ],
                                  ),
                                )),
                          const SizedBox(height: 20),
                          const SectionHeader(title: 'Stops'),
                          const SizedBox(height: 10),
                          if (_stops.isEmpty)
                            const InfoCard(
                              child: ListTile(
                                leading: Icon(Icons.pin_drop_outlined),
                                title: Text('No stops configured'),
                              ),
                            )
                          else
                            ..._stops.map(
                              (stop) => InfoCard(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 16,
                                    child: Text(stop.sequenceNumber.toString()),
                                  ),
                                  title: Text(stop.stopName),
                                  subtitle: Text(
                                    [
                                      if ((stop.pickupTime ?? '').isNotEmpty)
                                        'Pickup: ${stop.pickupTime}',
                                      if ((stop.dropTime ?? '').isNotEmpty)
                                        'Drop: ${stop.dropTime}',
                                    ].join('  •  '),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _chip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
