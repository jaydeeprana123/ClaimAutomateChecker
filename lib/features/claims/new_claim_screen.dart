import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'document_upload_screen.dart';

class NewClaimScreen extends StatefulWidget {
  const NewClaimScreen({super.key});

  @override
  State<NewClaimScreen> createState() => _NewClaimScreenState();
}

class _NewClaimScreenState extends State<NewClaimScreen> {
  final _formKey = GlobalKey<FormState>();

  // Patient Details Controllers
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _beneficiaryIdController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  String? _selectedGender;
  DateTime? _dateOfBirth;

  // Hospital Details Controllers
  final _hospitalNameController = TextEditingController();
  final _hospitalCodeController = TextEditingController();
  final _treatingDoctorController = TextEditingController();
  final _doctorRegController = TextEditingController();
  DateTime? _admissionDate;
  DateTime? _dischargeDate;

  // Package Selection
  String? _selectedPackage;
  
  final Map<String, String> _packages = {
    'Cataract Surgery': 'P19001',
    'Knee Replacement': 'P08012',
    'Angioplasty': 'P16003',
    'Appendectomy': 'P07002',
    'Delivery / C-section': 'P03001',
    'Dialysis': 'P14001',
    'Chemotherapy': 'P13002',
    'Hip Fracture': 'P08007',
  };

  @override
  void dispose() {
    _patientNameController.dispose();
    _ageController.dispose();
    _beneficiaryIdController.dispose();
    _mobileNumberController.dispose();
    _hospitalNameController.dispose();
    _hospitalCodeController.dispose();
    _treatingDoctorController.dispose();
    _doctorRegController.dispose();
    super.dispose();
  }

  void _submitClaim() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DocumentUploadScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate, Function(DateTime) onSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.dark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Claim Creation', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    title: 'Section 1 — Patient Details',
                    icon: Icons.person_outline,
                    child: Column(
                      children: [
                        _buildReadOnlyField('Claim ID', 'CLM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'),
                        const SizedBox(height: 16),
                        _buildTextField('Patient Name', _patientNameController),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Age', _ageController, isNumber: true)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                'Gender',
                                ['Male', 'Female', 'Other'],
                                _selectedGender,
                                (val) => setState(() => _selectedGender = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDatePicker(
                          'Date of Birth',
                          _dateOfBirth,
                          () => _selectDate(context, _dateOfBirth, (date) => setState(() => _dateOfBirth = date)),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('PMJAY Beneficiary ID', _beneficiaryIdController),
                        const SizedBox(height: 16),
                        _buildTextField('Mobile Number', _mobileNumberController, isNumber: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionCard(
                    title: 'Section 2 — Hospital Details',
                    icon: Icons.local_hospital_outlined,
                    child: Column(
                      children: [
                        _buildTextField('Hospital Name', _hospitalNameController),
                        const SizedBox(height: 16),
                        _buildTextField('Hospital Code', _hospitalCodeController),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePicker(
                                'Admission Date',
                                _admissionDate,
                                () => _selectDate(context, _admissionDate, (date) => setState(() => _admissionDate = date)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDatePicker(
                                'Discharge Date',
                                _dischargeDate,
                                () => _selectDate(context, _dischargeDate, (date) => setState(() => _dischargeDate = date)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Treating Doctor Name', _treatingDoctorController),
                        const SizedBox(height: 16),
                        _buildTextField('Doctor Registration Number', _doctorRegController),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionCard(
                    title: 'Section 3 — Package Selection',
                    icon: Icons.medical_services_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Package', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedPackage,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.lightGrey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.lightGrey),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                          items: _packages.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text('${entry.key} - ${entry.value}'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedPackage = value),
                          validator: (value) => value == null ? 'Please select a package' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submitClaim,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                      ),
                      child: const Text('Next — Document Upload', style: AppTextStyles.button),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4))],
        border: Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Text(title, style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark)),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          validator: (value) => value == null || value.isEmpty ? '$label is required' : null,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            filled: true,
            fillColor: AppColors.background, // visually indicate read-only
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: 'Select $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? '$label is required' : null,
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null ? 'Select Date' : '${value.day}/${value.month}/${value.year}',
                  style: value == null ? AppTextStyles.bodyMedium.copyWith(color: AppColors.darkGrey) : AppTextStyles.bodyMedium,
                ),
                const Icon(Icons.calendar_today_outlined, color: AppColors.darkGrey, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
