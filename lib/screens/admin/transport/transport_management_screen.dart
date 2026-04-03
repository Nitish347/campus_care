import 'package:campus_care/controllers/transport_controller.dart';
import 'package:campus_care/models/transport/transport_assignment.dart';
import 'package:campus_care/models/transport/transport_driver.dart';
import 'package:campus_care/models/transport/transport_route.dart';
import 'package:campus_care/models/transport/transport_stop.dart';
import 'package:campus_care/models/transport/transport_vehicle.dart';
import 'package:campus_care/widgets/admin/admin_page_header.dart';
import 'package:campus_care/widgets/admin/confirm_dialog.dart';
import 'package:campus_care/widgets/common/empty_state.dart';
import 'package:campus_care/widgets/inputs/custom_dropdown.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';
import 'package:campus_care/widgets/responsive/responsive_padding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransportManagementScreen extends StatefulWidget {
  const TransportManagementScreen({super.key});

  @override
  State<TransportManagementScreen> createState() =>
      _TransportManagementScreenState();
}

class _TransportManagementScreenState extends State<TransportManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TransportController _controller;
  late final TabController _tabController;

  static const _tabLabels = [
    'Drivers',
    'Vehicles',
    'Routes',
    'Stops',
    'Assignments'
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<TransportController>()
        ? Get.find<TransportController>()
        : Get.put(TransportController());
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _controller.refreshAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime? date) =>
      date == null ? 'N/A' : DateFormat('dd MMM yyyy').format(date);

  Future<DateTime?> _pickDate(DateTime? initialDate) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _confirmDelete({
    required String title,
    required String message,
    required Future<void> Function() onDelete,
  }) async {
    final ok = await showConfirmDialog(
      context,
      title: title,
      message: message,
      confirmLabel: 'Delete',
      isDanger: true,
      icon: Icons.delete_forever_rounded,
    );
    if (ok) {
      await onDelete();
    }
  }

  Future<void> _showDriverForm({TransportDriver? existing}) async {
    final formKey = GlobalKey<FormState>();
    final firstName = TextEditingController(text: existing?.firstName ?? '');
    final lastName = TextEditingController(text: existing?.lastName ?? '');
    final phone = TextEditingController(text: existing?.phone ?? '');
    final alternatePhone =
        TextEditingController(text: existing?.alternatePhone ?? '');
    final licenseNo =
        TextEditingController(text: existing?.licenseNumber ?? '');
    final badgeNumber =
        TextEditingController(text: existing?.badgeNumber ?? '');
    final address = TextEditingController(text: existing?.address ?? '');
    final licenseExpiryCtrl = TextEditingController(
        text: existing?.licenseExpiry != null
            ? _fmtDate(existing!.licenseExpiry)
            : '');
    DateTime? licenseExpiry = existing?.licenseExpiry;
    bool isActive = existing?.isActive ?? true;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Driver' : 'Edit Driver'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: firstName,
                      labelText: 'First Name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: lastName,
                      labelText: 'Last Name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: phone,
                      labelText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: alternatePhone,
                      labelText: 'Alternate Phone (Optional)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: licenseNo,
                      labelText: 'License Number',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: licenseExpiryCtrl,
                      labelText: 'License Expiry (Optional)',
                      readOnly: true,
                      onTap: () async {
                        final picked = await _pickDate(licenseExpiry);
                        if (picked != null) {
                          setState(() {
                            licenseExpiry = picked;
                            licenseExpiryCtrl.text = _fmtDate(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: badgeNumber,
                      labelText: 'Badge Number (Optional)',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: address,
                      labelText: 'Address (Optional)',
                      maxLines: 2,
                    ),
                    SwitchListTile(
                      title: const Text('Active'),
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: isSubmitting
                          ? null
                          : (v) => setState(() => isActive = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSubmitting = true);
                      final payload = TransportDriver(
                        id: existing?.id ?? '',
                        firstName: firstName.text.trim(),
                        lastName: lastName.text.trim(),
                        phone: phone.text.trim(),
                        alternatePhone: alternatePhone.text.trim().isEmpty
                            ? null
                            : alternatePhone.text.trim(),
                        licenseNumber: licenseNo.text.trim(),
                        licenseExpiry: licenseExpiry,
                        badgeNumber: badgeNumber.text.trim().isEmpty
                            ? null
                            : badgeNumber.text.trim(),
                        address: address.text.trim().isEmpty
                            ? null
                            : address.text.trim(),
                        isActive: isActive,
                        instituteId: existing?.instituteId ?? '',
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final ok = existing == null
                          ? await _controller.addDriver(payload)
                          : await _controller.updateDriver(payload);
                      if (!ok) {
                        setState(() => isSubmitting = false);
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(existing == null ? 'Create' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showVehicleForm({TransportVehicle? existing}) async {
    final formKey = GlobalKey<FormState>();
    final vehicleNumber =
        TextEditingController(text: existing?.vehicleNumber ?? '');
    final capacity =
        TextEditingController(text: existing?.capacity.toString() ?? '');
    final model = TextEditingController(text: existing?.model ?? '');
    final manufacturer =
        TextEditingController(text: existing?.manufacturer ?? '');
    final gpsDeviceId =
        TextEditingController(text: existing?.gpsDeviceId ?? '');
    final registrationExpiryCtrl = TextEditingController(
      text: existing?.registrationExpiry != null
          ? _fmtDate(existing!.registrationExpiry)
          : '',
    );
    final insuranceExpiryCtrl = TextEditingController(
      text: existing?.insuranceExpiry != null
          ? _fmtDate(existing!.insuranceExpiry)
          : '',
    );
    final fitnessExpiryCtrl = TextEditingController(
      text: existing?.fitnessExpiry != null
          ? _fmtDate(existing!.fitnessExpiry)
          : '',
    );
    String vehicleType = existing?.vehicleType ?? 'van';
    bool isActive = existing?.isActive ?? true;
    DateTime? registrationExpiry = existing?.registrationExpiry;
    DateTime? insuranceExpiry = existing?.insuranceExpiry;
    DateTime? fitnessExpiry = existing?.fitnessExpiry;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Vehicle' : 'Edit Vehicle'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: vehicleNumber,
                      labelText: 'Vehicle Number',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown<String>(
                      labelText: 'Vehicle Type',
                      value: vehicleType,
                      onChanged: (v) =>
                          setState(() => vehicleType = v ?? 'van'),
                      items: const [
                        DropdownMenuItem(value: 'van', child: Text('Van')),
                        DropdownMenuItem(value: 'bus', child: Text('Bus')),
                        DropdownMenuItem(
                            value: 'mini_bus', child: Text('Mini Bus')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: capacity,
                      labelText: 'Capacity',
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null
                          ? 'Enter valid number'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: model,
                      labelText: 'Model (Optional)',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: manufacturer,
                      labelText: 'Manufacturer (Optional)',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: gpsDeviceId,
                      labelText: 'GPS Device ID (Optional)',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: registrationExpiryCtrl,
                      labelText: 'Registration Expiry (Optional)',
                      readOnly: true,
                      onTap: () async {
                        final picked = await _pickDate(registrationExpiry);
                        if (picked != null) {
                          setState(() {
                            registrationExpiry = picked;
                            registrationExpiryCtrl.text = _fmtDate(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: insuranceExpiryCtrl,
                      labelText: 'Insurance Expiry (Optional)',
                      readOnly: true,
                      onTap: () async {
                        final picked = await _pickDate(insuranceExpiry);
                        if (picked != null) {
                          setState(() {
                            insuranceExpiry = picked;
                            insuranceExpiryCtrl.text = _fmtDate(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: fitnessExpiryCtrl,
                      labelText: 'Fitness Expiry (Optional)',
                      readOnly: true,
                      onTap: () async {
                        final picked = await _pickDate(fitnessExpiry);
                        if (picked != null) {
                          setState(() {
                            fitnessExpiry = picked;
                            fitnessExpiryCtrl.text = _fmtDate(picked);
                          });
                        }
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Active'),
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: isSubmitting
                          ? null
                          : (v) => setState(() => isActive = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSubmitting = true);
                      final payload = TransportVehicle(
                        id: existing?.id ?? '',
                        vehicleNumber: vehicleNumber.text.trim(),
                        vehicleType: vehicleType,
                        capacity: int.parse(capacity.text.trim()),
                        model: model.text.trim().isEmpty
                            ? null
                            : model.text.trim(),
                        manufacturer: manufacturer.text.trim().isEmpty
                            ? null
                            : manufacturer.text.trim(),
                        registrationExpiry: registrationExpiry,
                        insuranceExpiry: insuranceExpiry,
                        fitnessExpiry: fitnessExpiry,
                        gpsDeviceId: gpsDeviceId.text.trim().isEmpty
                            ? null
                            : gpsDeviceId.text.trim(),
                        isActive: isActive,
                        instituteId: existing?.instituteId ?? '',
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final ok = existing == null
                          ? await _controller.addVehicle(payload)
                          : await _controller.updateVehicle(payload);
                      if (!ok) {
                        setState(() => isSubmitting = false);
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(existing == null ? 'Create' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showRouteForm({TransportRoute? existing}) async {
    final formKey = GlobalKey<FormState>();
    final routeNumber =
        TextEditingController(text: existing?.routeNumber ?? '');
    final routeName = TextEditingController(text: existing?.routeName ?? '');
    final start = TextEditingController(text: existing?.startLocation ?? '');
    final end = TextEditingController(text: existing?.endLocation ?? '');
    final morningStart =
        TextEditingController(text: existing?.morningStartTime ?? '');
    final morningEnd =
        TextEditingController(text: existing?.morningEndTime ?? '');
    final afternoonStart =
        TextEditingController(text: existing?.afternoonStartTime ?? '');
    final afternoonEnd =
        TextEditingController(text: existing?.afternoonEndTime ?? '');
    final distanceKm =
        TextEditingController(text: existing?.distanceKm?.toString() ?? '');
    final estimatedDuration = TextEditingController(
        text: existing?.estimatedDurationMinutes?.toString() ?? '');
    bool isActive = existing?.isActive ?? true;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Route' : 'Edit Route'),
          content: SizedBox(
            width: 550,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: routeNumber,
                      labelText: 'Route Number',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: routeName,
                      labelText: 'Route Name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: start,
                      labelText: 'Start Location',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: end,
                      labelText: 'End Location',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: morningStart,
                            labelText: 'Morning Start (HH:MM)',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: morningEnd,
                            labelText: 'Morning End (HH:MM)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: afternoonStart,
                            labelText: 'Afternoon Start (Optional HH:MM)',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: afternoonEnd,
                            labelText: 'Afternoon End (Optional HH:MM)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: distanceKm,
                            labelText: 'Distance KM (Optional)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: estimatedDuration,
                            labelText: 'Duration Mins (Optional)',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Active'),
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: isSubmitting
                          ? null
                          : (v) => setState(() => isActive = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSubmitting = true);
                      final payload = TransportRoute(
                        id: existing?.id ?? '',
                        routeNumber: routeNumber.text.trim(),
                        routeName: routeName.text.trim(),
                        startLocation: start.text.trim(),
                        endLocation: end.text.trim(),
                        morningStartTime: morningStart.text.trim().isEmpty
                            ? null
                            : morningStart.text.trim(),
                        morningEndTime: morningEnd.text.trim().isEmpty
                            ? null
                            : morningEnd.text.trim(),
                        afternoonStartTime: afternoonStart.text.trim().isEmpty
                            ? null
                            : afternoonStart.text.trim(),
                        afternoonEndTime: afternoonEnd.text.trim().isEmpty
                            ? null
                            : afternoonEnd.text.trim(),
                        distanceKm: distanceKm.text.trim().isEmpty
                            ? null
                            : double.tryParse(distanceKm.text.trim()),
                        estimatedDurationMinutes:
                            estimatedDuration.text.trim().isEmpty
                                ? null
                                : int.tryParse(estimatedDuration.text.trim()),
                        isActive: isActive,
                        instituteId: existing?.instituteId ?? '',
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final ok = existing == null
                          ? await _controller.addRoute(payload)
                          : await _controller.updateRoute(payload);
                      if (!ok) {
                        setState(() => isSubmitting = false);
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(existing == null ? 'Create' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showStopForm({TransportStop? existing}) async {
    if (_controller.routes.isEmpty) {
      Get.snackbar('Missing Route', 'Please create a route first.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    String routeId = existing?.routeId ??
        _controller.selectedRouteId.value ??
        _controller.routes.first.id;
    final stopName = TextEditingController(text: existing?.stopName ?? '');
    final sequence =
        TextEditingController(text: existing?.sequenceNumber.toString() ?? '');
    final pickup = TextEditingController(text: existing?.pickupTime ?? '');
    final drop = TextEditingController(text: existing?.dropTime ?? '');
    final stopAddress =
        TextEditingController(text: existing?.stopAddress ?? '');
    final latitude =
        TextEditingController(text: existing?.latitude?.toString() ?? '');
    final longitude =
        TextEditingController(text: existing?.longitude?.toString() ?? '');
    bool isActive = existing?.isActive ?? true;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Stop' : 'Edit Stop'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdown<String>(
                      labelText: 'Route',
                      value: routeId,
                      items: _controller.routes
                          .map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text('${r.routeNumber} - ${r.routeName}')))
                          .toList(),
                      onChanged: (v) => setState(() => routeId = v ?? routeId),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: stopName,
                      labelText: 'Stop Name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: stopAddress,
                      labelText: 'Stop Address (Optional)',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: sequence,
                      labelText: 'Sequence Number',
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null
                          ? 'Enter valid number'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: pickup,
                            labelText: 'Pickup Time (Optional HH:MM)',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: drop,
                            labelText: 'Drop Time (Optional HH:MM)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: latitude,
                            labelText: 'Latitude (Optional)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            controller: longitude,
                            labelText: 'Longitude (Optional)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('Active'),
                      contentPadding: EdgeInsets.zero,
                      value: isActive,
                      onChanged: isSubmitting
                          ? null
                          : (v) => setState(() => isActive = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSubmitting = true);
                      final payload = TransportStop(
                        id: existing?.id ?? '',
                        routeId: routeId,
                        stopName: stopName.text.trim(),
                        stopAddress: stopAddress.text.trim().isEmpty
                            ? null
                            : stopAddress.text.trim(),
                        sequenceNumber: int.parse(sequence.text.trim()),
                        pickupTime: pickup.text.trim().isEmpty
                            ? null
                            : pickup.text.trim(),
                        dropTime:
                            drop.text.trim().isEmpty ? null : drop.text.trim(),
                        latitude: latitude.text.trim().isEmpty
                            ? null
                            : double.tryParse(latitude.text.trim()),
                        longitude: longitude.text.trim().isEmpty
                            ? null
                            : double.tryParse(longitude.text.trim()),
                        isActive: isActive,
                        instituteId: existing?.instituteId ?? '',
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final ok = existing == null
                          ? await _controller.addStop(payload)
                          : await _controller.updateStop(payload);
                      if (ok) {
                        await _controller.changeSelectedRoute(routeId);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } else {
                        setState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(existing == null ? 'Create' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignmentForm({TransportAssignment? existing}) async {
    if (_controller.routes.isEmpty ||
        _controller.vehicles.isEmpty ||
        _controller.drivers.isEmpty) {
      Get.snackbar('Missing Data',
          'Create route, vehicle and driver before assignment.');
      return;
    }

    final formKey = GlobalKey<FormState>();
    String routeId = existing?.routeId ?? _controller.routes.first.id;
    String vehicleId = existing?.vehicleId ?? _controller.vehicles.first.id;
    String driverId = existing?.driverId ?? _controller.drivers.first.id;
    String shift = existing?.shift ?? 'both';
    String status = existing?.status ?? 'active';
    DateTime effectiveFrom = existing?.effectiveFrom ?? DateTime.now();
    DateTime? effectiveTo = existing?.effectiveTo;
    final attendantName =
        TextEditingController(text: existing?.attendantName ?? '');
    final attendantPhone =
        TextEditingController(text: existing?.attendantPhone ?? '');
    final effectiveCtrl = TextEditingController(text: _fmtDate(effectiveFrom));
    final effectiveToCtrl = TextEditingController(
      text:
          existing?.effectiveTo != null ? _fmtDate(existing!.effectiveTo) : '',
    );
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Add Assignment' : 'Edit Assignment'),
          content: SizedBox(
            width: 550,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdown<String>(
                      labelText: 'Route',
                      value: routeId,
                      items: _controller.routes
                          .map((r) => DropdownMenuItem(
                              value: r.id,
                              child: Text('${r.routeNumber} - ${r.routeName}')))
                          .toList(),
                      onChanged: (v) => setState(() => routeId = v ?? routeId),
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown<String>(
                      labelText: 'Vehicle',
                      value: vehicleId,
                      items: _controller.vehicles
                          .map((v) => DropdownMenuItem(
                              value: v.id, child: Text(v.vehicleNumber)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => vehicleId = v ?? vehicleId),
                    ),
                    const SizedBox(height: 10),
                    CustomDropdown<String>(
                      labelText: 'Driver',
                      value: driverId,
                      items: _controller.drivers
                          .map((d) => DropdownMenuItem(
                              value: d.id,
                              child: Text('${d.fullName} (${d.phone})')))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => driverId = v ?? driverId),
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: effectiveCtrl,
                      labelText: 'Effective From',
                      readOnly: true,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      onTap: () async {
                        final picked = await _pickDate(effectiveFrom);
                        if (picked != null) {
                          setState(() {
                            effectiveFrom = picked;
                            effectiveCtrl.text = _fmtDate(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: effectiveToCtrl,
                      labelText: 'Effective To (Optional)',
                      readOnly: true,
                      onTap: () async {
                        final picked =
                            await _pickDate(effectiveTo ?? effectiveFrom);
                        if (picked != null) {
                          setState(() {
                            effectiveTo = picked;
                            effectiveToCtrl.text = _fmtDate(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: attendantName,
                      labelText: 'Attendant Name (Optional)',
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(
                      controller: attendantPhone,
                      labelText: 'Attendant Phone (Optional)',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdown<String>(
                            labelText: 'Shift',
                            value: shift,
                            onChanged: (v) =>
                                setState(() => shift = v ?? 'both'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'morning', child: Text('Morning')),
                              DropdownMenuItem(
                                  value: 'afternoon', child: Text('Afternoon')),
                              DropdownMenuItem(
                                  value: 'both', child: Text('Both')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomDropdown<String>(
                            labelText: 'Status',
                            value: status,
                            onChanged: (v) =>
                                setState(() => status = v ?? 'active'),
                            items: const [
                              DropdownMenuItem(
                                  value: 'active', child: Text('Active')),
                              DropdownMenuItem(
                                  value: 'inactive', child: Text('Inactive')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: isSubmitting ? null : () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSubmitting = true);
                      final payload = TransportAssignment(
                        id: existing?.id ?? '',
                        routeId: routeId,
                        vehicleId: vehicleId,
                        driverId: driverId,
                        attendantName: attendantName.text.trim().isEmpty
                            ? null
                            : attendantName.text.trim(),
                        attendantPhone: attendantPhone.text.trim().isEmpty
                            ? null
                            : attendantPhone.text.trim(),
                        effectiveFrom: effectiveFrom,
                        effectiveTo: effectiveTo,
                        shift: shift,
                        status: status,
                        instituteId: existing?.instituteId ?? '',
                        routeNumber: existing?.routeNumber,
                        routeName: existing?.routeName,
                        vehicleNumber: existing?.vehicleNumber,
                        vehicleType: existing?.vehicleType,
                        driverFirstName: existing?.driverFirstName,
                        driverLastName: existing?.driverLastName,
                        driverPhone: existing?.driverPhone,
                        createdAt: existing?.createdAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      final ok = existing == null
                          ? await _controller.addAssignment(payload)
                          : await _controller.updateAssignment(payload);
                      if (!ok) {
                        setState(() => isSubmitting = false);
                        return;
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(existing == null ? 'Create' : 'Update'),
            )
          ],
        ),
      ),
    );
  }

  void _openAddFormForCurrentTab() {
    switch (_tabController.index) {
      case 0:
        _showDriverForm();
        break;
      case 1:
        _showVehicleForm();
        break;
      case 2:
        _showRouteForm();
        break;
      case 3:
        _showStopForm();
        break;
      case 4:
        _showAssignmentForm();
        break;
    }
  }

  Widget _buildListCard({
    required String title,
    required String subtitle,
    required String meta,
    required IconData icon,
    required Color color,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$subtitle\n$meta'),
        isThreeLine: true,
        trailing: SizedBox(
          width: 90,
          child: Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.edit_rounded), onPressed: onEdit),
              IconButton(
                  icon: const Icon(Icons.delete_rounded), onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          AdminPageHeader(
            title: 'Transport Management',
            subtitle:
                'Register drivers, manage vehicles, routes and van assignments',
            icon: Icons.directions_bus_rounded,
            showBackButton: true,
            showBreadcrumb: true,
            breadcrumbLabel: 'Transport',
            actions: [
              HeaderActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onPressed: _controller.refreshAll),
              const SizedBox(width: 8),
              HeaderActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add',
                  onPressed: _openAddFormForCurrentTab),
            ],
          ),
          Expanded(
            child: ResponsivePadding(
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Obx(
                    () => Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _metricChip(Icons.badge_rounded, 'Drivers',
                            _controller.drivers.length.toString()),
                        _metricChip(Icons.directions_bus_rounded, 'Vehicles',
                            _controller.vehicles.length.toString()),
                        _metricChip(Icons.alt_route_rounded, 'Routes',
                            _controller.routes.length.toString()),
                        _metricChip(Icons.assignment_rounded, 'Assignments',
                            _controller.assignments.length.toString()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabs: _tabLabels.map((e) => Tab(text: e)).toList()),
                  const SizedBox(height: 10),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Obx(() => _controller.drivers.isEmpty
                            ? EmptyState(
                                icon: Icons.badge_outlined,
                                title: 'No drivers',
                                message: 'Add a driver')
                            : ListView(
                                children: _controller.drivers
                                    .map((d) => _buildListCard(
                                          title: d.fullName,
                                          subtitle: d.phone,
                                          meta:
                                              'License: ${d.licenseNumber} | Expiry: ${_fmtDate(d.licenseExpiry)}',
                                          icon: Icons.badge_rounded,
                                          color: const Color(0xFF0891B2),
                                          onEdit: () =>
                                              _showDriverForm(existing: d),
                                          onDelete: () => _confirmDelete(
                                            title: 'Delete Driver',
                                            message: 'Delete ${d.fullName}?',
                                            onDelete: () =>
                                                _controller.deleteDriver(d.id),
                                          ),
                                        ))
                                    .toList(),
                              )),
                        Obx(() => _controller.vehicles.isEmpty
                            ? EmptyState(
                                icon: Icons.directions_bus_outlined,
                                title: 'No vehicles',
                                message: 'Add a vehicle')
                            : ListView(
                                children: _controller.vehicles
                                    .map((v) => _buildListCard(
                                          title: v.vehicleNumber,
                                          subtitle:
                                              '${v.vehicleType} | Capacity ${v.capacity}',
                                          meta:
                                              'Status: ${v.isActive ? 'Active' : 'Inactive'}',
                                          icon: Icons.directions_bus_rounded,
                                          color: const Color(0xFF4F46E5),
                                          onEdit: () =>
                                              _showVehicleForm(existing: v),
                                          onDelete: () => _confirmDelete(
                                            title: 'Delete Vehicle',
                                            message:
                                                'Delete ${v.vehicleNumber}?',
                                            onDelete: () =>
                                                _controller.deleteVehicle(v.id),
                                          ),
                                        ))
                                    .toList(),
                              )),
                        Obx(() => _controller.routes.isEmpty
                            ? EmptyState(
                                icon: Icons.alt_route_outlined,
                                title: 'No routes',
                                message: 'Add a route')
                            : ListView(
                                children: _controller.routes
                                    .map((r) => _buildListCard(
                                          title:
                                              '${r.routeNumber} - ${r.routeName}',
                                          subtitle:
                                              '${r.startLocation} -> ${r.endLocation}',
                                          meta:
                                              'Morning: ${r.morningStartTime ?? '-'} to ${r.morningEndTime ?? '-'}',
                                          icon: Icons.alt_route_rounded,
                                          color: const Color(0xFF059669),
                                          onEdit: () =>
                                              _showRouteForm(existing: r),
                                          onDelete: () => _confirmDelete(
                                            title: 'Delete Route',
                                            message: 'Delete ${r.routeNumber}?',
                                            onDelete: () =>
                                                _controller.deleteRoute(r.id),
                                          ),
                                        ))
                                    .toList(),
                              )),
                        Obx(() {
                          if (_controller.routes.isEmpty) {
                            return EmptyState(
                              icon: Icons.alt_route_outlined,
                              title: 'Routes required',
                              message: 'Create route first',
                            );
                          }
                          return Column(
                            children: [
                              CustomDropdown<String>(
                                labelText: 'Route',
                                value: _controller.selectedRouteId.value ??
                                    _controller.routes.first.id,
                                items: _controller.routes
                                    .map((r) => DropdownMenuItem(
                                        value: r.id,
                                        child: Text(
                                            '${r.routeNumber} - ${r.routeName}')))
                                    .toList(),
                                onChanged: (v) =>
                                    _controller.changeSelectedRoute(v),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: _controller.stops.isEmpty
                                    ? EmptyState(
                                        icon: Icons.place_outlined,
                                        title: 'No stops',
                                        message: 'Add route stops')
                                    : ListView(
                                        children: _controller.stops
                                            .map((s) => _buildListCard(
                                                  title:
                                                      '#${s.sequenceNumber} ${s.stopName}',
                                                  subtitle: s.stopAddress ??
                                                      'No address',
                                                  meta:
                                                      'Pickup: ${s.pickupTime ?? '-'}',
                                                  icon: Icons.place_rounded,
                                                  color:
                                                      const Color(0xFFDC2626),
                                                  onEdit: () => _showStopForm(
                                                      existing: s),
                                                  onDelete: () =>
                                                      _confirmDelete(
                                                    title: 'Delete Stop',
                                                    message:
                                                        'Delete ${s.stopName}?',
                                                    onDelete: () => _controller
                                                        .deleteStop(s.id),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                              )
                            ],
                          );
                        }),
                        Obx(() => _controller.assignments.isEmpty
                            ? EmptyState(
                                icon: Icons.assignment_outlined,
                                title: 'No assignments',
                                message: 'Assign route and van')
                            : ListView(
                                children: _controller.assignments
                                    .map((a) => _buildListCard(
                                          title:
                                              '${a.routeNumber ?? a.routeId} | ${a.vehicleNumber ?? a.vehicleId}',
                                          subtitle: a.driverName.isEmpty
                                              ? a.driverId
                                              : a.driverName,
                                          meta:
                                              'Shift: ${a.shift} | From: ${_fmtDate(a.effectiveFrom)}',
                                          icon: Icons.assignment_rounded,
                                          color: const Color(0xFFF59E0B),
                                          onEdit: () =>
                                              _showAssignmentForm(existing: a),
                                          onDelete: () => _confirmDelete(
                                            title: 'Delete Assignment',
                                            message: 'Delete this assignment?',
                                            onDelete: () => _controller
                                                .deleteAssignment(a.id),
                                          ),
                                        ))
                                    .toList(),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
          Text(value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
