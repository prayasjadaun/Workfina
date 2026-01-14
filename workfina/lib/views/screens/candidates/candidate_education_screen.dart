// lib/screens/profile/add_education_screen.dart  (adjust path as needed)

import 'package:flutter/material.dart';
// import your AppTheme if needed

class AddEducationScreen extends StatefulWidget {
  const AddEducationScreen({super.key});

  @override
  State<AddEducationScreen> createState() => _AddEducationScreenState();
}

class _AddEducationScreenState extends State<AddEducationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _schoolController = TextEditingController();
  final _degreeController = TextEditingController();
  final _fieldController = TextEditingController();
  final _gradeController = TextEditingController();
  final _locationController = TextEditingController();

  String? _startMonth = 'January';
  String? _startYear;
  String? _endMonth = 'January';
  String? _endYear;

  final _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late final List<String> _years;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _years = List.generate(50, (i) => (currentYear - i).toString());

    // sensible defaults
    _startYear = (currentYear - 4).toString(); // e.g. 4 years ago for recent grad
    _endYear = currentYear.toString();
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _degreeController.dispose();
    _fieldController.dispose();
    _gradeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  int _getMonthIndex(String month) {
    return _months.indexOf(month) + 1; // 1-based for DateTime
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Education'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
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
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(
                  labelText: 'School / University *',
                  hintText: 'e.g., Delhi University, IIT Delhi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g., Delhi, India',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _degreeController,
                decoration: InputDecoration(
                  labelText: 'Degree *',
                  hintText: "e.g., Bachelor's in Computer Science, MBA",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _fieldController,
                decoration: InputDecoration(
                  labelText: 'Field of Study',
                  hintText: 'e.g., Computer Science, Mechanical Engineering',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 28),

              const Text('Start Date *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _startMonth,
                      decoration: _dropdownDecoration('Month'),
                      items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() => _startMonth = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _startYear,
                      decoration: _dropdownDecoration('Year'),
                      items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (v) => setState(() => _startYear = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text('End Date (or Expected) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _endMonth,
                      decoration: _dropdownDecoration('Month'),
                      items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() => _endMonth = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _endYear,
                      decoration: _dropdownDecoration('Year'),
                      items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (v) => setState(() => _endYear = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: _gradeController,
                decoration: InputDecoration(
                  labelText: 'Grade / Percentage / CGPA',
                  hintText: 'e.g., 8.5 CGPA, 85%, First Division',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

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
          onPressed: _saveEducation,
          child: const Text('Save Education', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  void _saveEducation() {
  if (!_formKey.currentState!.validate()) return;

  // Safe parsing with fallback to 0
  final startYearInt = int.tryParse(_startYear ?? '0') ?? 0;
  final endYearInt   = int.tryParse(_endYear ?? '0') ?? 0;

  // Year level validation
  if (endYearInt < startYearInt) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('End year cannot be before start year'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // Same year → check months
  if (endYearInt == startYearInt) {
    final startMonthIndex = _months.indexOf(_startMonth ?? '');
    final endMonthIndex   = _months.indexOf(_endMonth ?? '');

    // Handle invalid month (indexOf returns -1 if not found)
    if (startMonthIndex == -1 || endMonthIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid start and end months')),
      );
      return;
    }

    if (endMonthIndex < startMonthIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End month cannot be before start month in the same year'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prevent same month + same year (zero duration)
    if (endMonthIndex == startMonthIndex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Start and end cannot be the exact same month and year.\n'
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
  }


  // All validations passed → create and return the education entry
  final newEducation = {
    'school': _schoolController.text.trim(),
    'degree': _degreeController.text.trim(),
    'field': _fieldController.text.trim(),
    'location': _locationController.text.trim(),
    'start_month': _startMonth,
    'start_year': _startYear,
    'end_month': _endMonth,
    'end_year': _endYear,
    'grade': _gradeController.text.trim(),
  };

  Navigator.pop(context, newEducation);
}

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}