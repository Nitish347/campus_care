import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/models/institute/institute_model.dart';
import 'package:campus_care/controllers/institute_controller.dart';
import 'package:campus_care/widgets/inputs/custom_text_field.dart';

class AddEditInstituteScreen extends StatefulWidget {
  const AddEditInstituteScreen({super.key});

  @override
  State<AddEditInstituteScreen> createState() => _AddEditInstituteScreenState();
}

class _AddEditInstituteScreenState extends State<AddEditInstituteScreen> {
  final InstituteController _controller = Get.find<InstituteController>();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _affiliationController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  String _selectedPlan = 'basic';
  String _selectedStatus = 'trial';
  DateTime? _establishedDate;
  DateTime _subscriptionStartDate = DateTime.now();
  DateTime _subscriptionEndDate = DateTime.now().add(const Duration(days: 30));

  Institute? _editingInstitute;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is Institute) {
      _editingInstitute = Get.arguments as Institute;
      _isEditing = true;
      _populateFields();
    }
  }

  void _populateFields() {
    if (_editingInstitute != null) {
      _nameController.text = _editingInstitute!.name;
      _codeController.text = _editingInstitute!.code;
      _emailController.text = _editingInstitute!.email;
      _phoneController.text = _editingInstitute!.phone;
      _addressController.text = _editingInstitute!.address;
      _websiteController.text = _editingInstitute!.website ?? '';
      _affiliationController.text = _editingInstitute!.affiliationNumber ?? '';
      _contactNameController.text = _editingInstitute!.contactPersonName;
      _contactEmailController.text = _editingInstitute!.contactPersonEmail;
      _contactPhoneController.text = _editingInstitute!.contactPersonPhone;
      _selectedPlan = _editingInstitute!.subscriptionPlan;
      _selectedStatus = _editingInstitute!.subscriptionStatus;
      _establishedDate = _editingInstitute!.establishedDate;
      _subscriptionStartDate = _editingInstitute!.subscriptionStartDate;
      _subscriptionEndDate = _editingInstitute!.subscriptionEndDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _affiliationController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _saveInstitute() {
    if (_formKey.currentState!.validate()) {
      final institute = Institute(
        id: _isEditing
            ? _editingInstitute!.id
            : 'inst_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        code: _codeController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        website:
            _websiteController.text.isEmpty ? null : _websiteController.text,
        establishedDate: _establishedDate,
        affiliationNumber: _affiliationController.text.isEmpty
            ? null
            : _affiliationController.text,
        subscriptionPlan: _selectedPlan,
        subscriptionStatus: _selectedStatus,
        subscriptionStartDate: _subscriptionStartDate,
        subscriptionEndDate: _subscriptionEndDate,
        totalStudents: _isEditing ? _editingInstitute!.totalStudents : 0,
        totalTeachers: _isEditing ? _editingInstitute!.totalTeachers : 0,
        totalClasses: _isEditing ? _editingInstitute!.totalClasses : 0,
        contactPersonName: _contactNameController.text,
        contactPersonEmail: _contactEmailController.text,
        contactPersonPhone: _contactPhoneController.text,
        isActive: _isEditing ? _editingInstitute!.isActive : true,
        isVerified: _isEditing ? _editingInstitute!.isVerified : false,
        createdAt: _isEditing ? _editingInstitute!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        _controller.updateInstitute(_editingInstitute!.id, institute);
      } else {
        _controller.addInstitute(institute);
      }

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Institute' : 'Add Institute'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Text('Basic Information',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        labelText: 'Institute Name',
                        hintText: 'Enter institute name',
                        prefixIcon: const Icon(Icons.business),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter institute name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _codeController,
                        labelText: 'Institute Code',
                        hintText: 'Enter unique code',
                        prefixIcon: const Icon(Icons.code),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter institute code'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Enter email address',
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter email';
                          if (!GetUtils.isEmail(value))
                            return 'Please enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Phone',
                        hintText: 'Enter phone number',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter phone number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _addressController,
                        labelText: 'Address',
                        hintText: 'Enter complete address',
                        prefixIcon: const Icon(Icons.location_on),
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter address'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _websiteController,
                        labelText: 'Website (Optional)',
                        hintText: 'Enter website URL',
                        prefixIcon: const Icon(Icons.language),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _affiliationController,
                        labelText: 'Affiliation Number (Optional)',
                        hintText: 'Enter affiliation number',
                        prefixIcon: const Icon(Icons.verified),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Contact Person
              Text('Contact Person',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _contactNameController,
                        labelText: 'Name',
                        hintText: 'Enter contact person name',
                        prefixIcon: const Icon(Icons.person),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter contact person name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _contactEmailController,
                        labelText: 'Email',
                        hintText: 'Enter contact email',
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter contact email';
                          if (!GetUtils.isEmail(value))
                            return 'Please enter valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _contactPhoneController,
                        labelText: 'Phone',
                        hintText: 'Enter contact phone',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter contact phone'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Subscription
              Text('Subscription',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedPlan,
                        decoration: const InputDecoration(
                            labelText: 'Subscription Plan',
                            border: OutlineInputBorder()),
                        items: ['basic', 'standard', 'premium', 'trial']
                            .map((plan) => DropdownMenuItem(
                                value: plan, child: Text(plan.toUpperCase())))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedPlan = value!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                            labelText: 'Status', border: OutlineInputBorder()),
                        items: ['active', 'trial', 'expired', 'suspended']
                            .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.toUpperCase())))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedStatus = value!),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveInstitute,
                  icon: const Icon(Icons.save),
                  label:
                      Text(_isEditing ? 'Update Institute' : 'Add Institute'),
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
