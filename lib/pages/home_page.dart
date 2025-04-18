import 'package:flutter/material.dart';
import 'akg_page.dart';
import 'recap_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/nutri_cast_feature.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int? _userAge;
  String? _userGender;

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

      final savedIMT = prefs.getDouble('userIMT');
      if (savedIMT != null) {
        _result =
            'IMT: ${savedIMT.toStringAsFixed(2)}\nStatus: ${NutriCastFeature.getGiziStatus(savedIMT)}';
      }

      _userAge = prefs.getInt('userAge');
      _userGender = prefs.getString('userGender');
    });
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();

      final age = int.parse(_ageController.text);
      final height = double.parse(_heightController.text);
      final weight = double.parse(_weightController.text);
      final imt = _calculateIMT(height, weight);
      final status = NutriCastFeature.getGiziStatus(imt);

      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userGender', _gender);
      await prefs.setInt('userAge', age);
      await prefs.setDouble('userHeight', height);
      await prefs.setDouble('userWeight', weight);
      await prefs.setDouble('userIMT', imt);
      await prefs.setBool('isSubmitted', true);

      setState(() {
        _result = 'IMT: ${imt.toStringAsFixed(2)}\nStatus: $status';
        _isSubmitted = true;
        _userAge = age;
        _userGender = _gender;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  double _calculateIMT(double height, double weight) {
    if (height == 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  Widget _buildHomePage() {
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
                filled: true,
                fillColor: Colors.white,
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
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged:
                  _isSubmitted
                      ? null
                      : (value) => setState(() => _gender = value!),
              validator:
                  (value) => value == null ? 'Pilih jenis kelamin' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Usia (tahun)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
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
                filled: true,
                fillColor: Colors.white,
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
                filled: true,
                fillColor: Colors.white,
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
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'SIMPAN DATA',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
                    style: TextStyle(fontSize: 16, color: Colors.green),
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

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage(); // Home = NutriCast + fitur tambahan (bisa nanti)
      case 1:
        return AKGPage(age: _userAge, gender: _userGender);
      case 2:
        return const RecapPage();
      default:
        return const Center(child: Text('Halaman tidak ditemukan'));
    }
  }

  void _onItemTapped(int index) {
    if ((index == 2 || index == 3) &&
        (_userAge == null || _userGender == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan lengkapi data diri terlebih dahulu di halaman Home',
          ),
        ),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
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
    return Scaffold(
      appBar: AppBar(title: const Text('NutriCast App')),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Kuesioner',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'AKG'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Rekap',
          ),
        ],
      ),
    );
  }
}
