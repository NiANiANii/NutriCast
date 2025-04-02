import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/nutri_cast_feature.dart';

class NutriCastPage extends StatefulWidget {
  final Function(int age, String gender) onDataSubmitted;

  const NutriCastPage({super.key, required this.onDataSubmitted});

  @override
  _NutriCastPageState createState() => _NutriCastPageState();
}

class _NutriCastPageState extends State<NutriCastPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _gender = 'Laki-laki';
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _result = '';
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _gender = prefs.getString('userGender') ?? 'Laki-laki';
      _ageController.text = prefs.getInt('userAge')?.toString() ?? '';
      _heightController.text = prefs.getDouble('userHeight')?.toString() ?? '';
      _weightController.text = prefs.getDouble('userWeight')?.toString() ?? '';
      _isSubmitted = prefs.getBool('isSubmitted') ?? false;
    });
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userGender', _gender);
      await prefs.setInt('userAge', int.parse(_ageController.text));
      await prefs.setDouble('userHeight', double.parse(_heightController.text));
      await prefs.setDouble('userWeight', double.parse(_weightController.text));
      await prefs.setBool('isSubmitted', true);

      _calculateIMT();
      widget.onDataSubmitted(int.parse(_ageController.text), _gender);

      setState(() {
        _isSubmitted = true;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan!')));
    }
  }

  void _calculateIMT() {
    double height = double.parse(_heightController.text) / 100;
    double weight = double.parse(_weightController.text);
    double imt = weight / (height * height);
    String status = NutriCastFeature.getGiziStatus(imt);

    setState(() {
      _result = 'IMT: ${imt.toStringAsFixed(2)}\nStatus: $status';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input Data User',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Masukkan nama' : null,
              enabled: !_isSubmitted,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _gender,
              items:
                  ['Laki-laki', 'Perempuan']
                      .map(
                        (label) =>
                            DropdownMenuItem(value: label, child: Text(label)),
                      )
                      .toList(),
              decoration: const InputDecoration(
                labelText: 'Jenis Kelamin',
                border: OutlineInputBorder(),
              ),
              onChanged:
                  _isSubmitted
                      ? null
                      : (value) => setState(() => _gender = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Usia (tahun)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Masukkan usia';
                final age = int.tryParse(value);
                if (age == null) return 'Harus angka';
                if (age < 1 || age > 120) return '1-120 tahun';
                return null;
              },
              enabled: !_isSubmitted,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Tinggi Badan (cm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan tinggi badan';
                }
                final height = double.tryParse(value);
                if (height == null) return 'Harus angka';
                if (height < 50 || height > 250) return '50-250 cm';
                return null;
              },
              enabled: !_isSubmitted,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Berat Badan (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Masukkan berat badan';
                }
                final weight = double.tryParse(value);
                if (weight == null) return 'Harus angka';
                if (weight < 3 || weight > 300) return '3-300 kg';
                return null;
              },
              enabled: !_isSubmitted,
            ),
            const SizedBox(height: 24),
            if (!_isSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'SUBMIT DATA',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isSubmitted', false);
                    setState(() {
                      _isSubmitted = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.green),
                  ),
                  child: const Text(
                    'EDIT DATA',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
