// lib/screens/profile/add_experience_screen.dart  (or wherever your screens live)

import 'package:flutter/material.dart';
// import your theme / models if needed
// import 'package:your_app/theme/app_theme.dart';  

class AddExperienceScreen extends StatefulWidget {
  const AddExperienceScreen({super.key});

  @override
  State<AddExperienceScreen> createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ctcController = TextEditingController();

  String? _startMonth;
  String? _startYear;
  String? _endMonth;
  String? _endYear;
  bool _isCurrentlyWorking = false;

  final _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late final List<String> _years;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List.generate(40, (i) => (currentYear - 39 + i).toString());

    // sensible defaults
    _startMonth = 'January';
    _startYear = (currentYear - 1).toString();
    _endMonth = 'January';
    _endYear = currentYear.toString();
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _ctcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Work Experience'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildTextFormField(
                controller: _companyController,
                label: 'Company Name',
                isRequired: true,
                icon: Icons.business,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _roleController,
                label: 'Job Title / Role',
                isRequired: true,
                icon: Icons.work_outline,
                
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Key Responsibilities & Achievements',
                icon: Icons.description_outlined,
                maxLines: 5,
                minLines: 3,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _ctcController,
                label: 'Annual CTC (₹)',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                hint: 'e.g. 1200000  or  12 LPA',
              ),
              const SizedBox(height: 32),

              const Text('Start Date *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Month', _startMonth, _months, (v) => _startMonth = v)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdown('Year', _startYear, _years, (v) => _startYear = v)),
                ],
              ),

              const SizedBox(height: 28),

              CheckboxListTile(
                value: _isCurrentlyWorking,
                onChanged: (v) {
                  setState(() {
                    _isCurrentlyWorking = v ?? false;
                    if (_isCurrentlyWorking) {
                      _endMonth = null;
                      _endYear = null;
                    }
                  });
                },
                title: const Text('I currently work here'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),

              if (!_isCurrentlyWorking) ...[
                const SizedBox(height: 28),
                const Text('End Date *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDropdown('Month', _endMonth, _months, (v) => _endMonth = v)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDropdown('Year', _endYear, _years, (v) => _endYear = v)),
                  ],
                ),
              ],

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24),
        child: FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _saveExperience,
          child: const Text('Save Experience', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    IconData? icon,
    int? maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    String? hint,
    
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines ?? maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: isRequired
          ? (v) => (v?.trim().isEmpty ?? true) ? 'Required' : null
          : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  void _saveExperience() {
  if (!_formKey.currentState!.validate()) return;

  // Parse with safe defaults
  final startYearStr = _startYear ?? '0';
  final endYearStr   = _isCurrentlyWorking ? null : (_endYear ?? '0');

  final startYearInt = int.tryParse(startYearStr) ?? 0;
  final endYearInt   = endYearStr != null ? (int.tryParse(endYearStr) ?? 0) : null;

  final startMonthIndex = _months.indexOf(_startMonth ?? 'January');
  final endMonthIndex   = _isCurrentlyWorking 
      ? -1 
      : _months.indexOf(_endMonth ?? 'January');

  if (!_isCurrentlyWorking && endYearInt != null) {
    // Year comparison
    if (endYearInt < startYearInt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End year cannot be before start year')),
      );
      return;
    }

    // Same year → check months
    if (endYearInt == startYearInt) {
      if (endMonthIndex < startMonthIndex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End month cannot be before start month in same year')),
        );
        return;
      }

      // Prevent zero-duration (same month same year)
      if (endMonthIndex == startMonthIndex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start and end cannot be the same month and year.\n'
                'Use a longer duration or mark as current if this is ongoing.'),
          ),
        );
        return;
      }
    }
  }

  // All good → proceed to create and pop
  final newExperience = {
    'company_name': _companyController.text.trim(),
    'role_title': _roleController.text.trim(),
    'location': _locationController.text.trim(),
    'description': _descriptionController.text.trim(),
    'ctc': _ctcController.text.trim(),
    'start_month': _startMonth,
    'start_year': _startYear,
    'end_month': _isCurrentlyWorking ? null : _endMonth,
    'end_year': _isCurrentlyWorking ? null : _endYear,
    'is_current': _isCurrentlyWorking,
  };

  Navigator.pop(context, newExperience);
}
}