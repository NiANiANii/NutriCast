import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecapPage extends StatefulWidget {
  const RecapPage({super.key});

  @override
  _RecapPageState createState() => _RecapPageState();
}

class _RecapPageState extends State<RecapPage> {
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _akgData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userData = {
        'name': prefs.getString('userName') ?? 'Tidak ada data',
        'age': prefs.getInt('userAge')?.toString() ?? '0',
        'gender': prefs.getString('userGender') ?? 'Tidak ada data',
        'height': prefs.getDouble('userHeight')?.toString() ?? '0',
        'weight': prefs.getDouble('userWeight')?.toString() ?? '0',
        'imt': _calculateIMT(
          double.parse(prefs.getDouble('userHeight')?.toString() ?? '0'),
          double.parse(prefs.getDouble('userWeight')?.toString() ?? '0'),
        ),
        'status': _getIMTStatus(
          _calculateIMT(
            double.parse(prefs.getDouble('userHeight')?.toString() ?? '0'),
            double.parse(prefs.getDouble('userWeight')?.toString() ?? '0'),
          ),
        ),
      };

      _akgData = {
        'energy': prefs.getInt('akgEnergy')?.toString() ?? '0',
        'protein': prefs.getInt('akgProtein')?.toString() ?? '0',
        'fat': prefs.getInt('akgFat')?.toString() ?? '0',
        'carbs': prefs.getInt('akgCarbs')?.toString() ?? '0',
        'fiber': prefs.getInt('akgFiber')?.toString() ?? '0',
        'water': prefs.getInt('akgWater')?.toString() ?? '0',
      };

      _isLoading = false;
    });
  }

  double _calculateIMT(double height, double weight) {
    if (height == 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  String _getIMTStatus(double imt) {
    if (imt < 18.5) return 'Kurus';
    if (imt >= 18.5 && imt < 25) return 'Normal';
    if (imt >= 25 && imt < 30) return 'Gemuk';
    return 'Obesitas';
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            '$value $unit',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Data Nutrisi'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Diri',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                _buildInfoCard('Nama', _userData['name']),
                _buildInfoCard('Usia', '${_userData['age']} tahun'),
                _buildInfoCard('Jenis Kelamin', _userData['gender']),
                _buildInfoCard('Tinggi Badan', '${_userData['height']} cm'),
                _buildInfoCard('Berat Badan', '${_userData['weight']} kg'),
                _buildInfoCard(
                  'Indeks Massa Tubuh',
                  '${_userData['imt'].toStringAsFixed(1)} (${_userData['status']})',
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Kebutuhan Gizi Harian (AKG)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildNutritionItem('Energi', _akgData['energy'], 'kkal'),
                    _buildNutritionItem('Protein', _akgData['protein'], 'g'),
                    _buildNutritionItem('Lemak', _akgData['fat'], 'g'),
                    _buildNutritionItem('Karbohidrat', _akgData['carbs'], 'g'),
                    _buildNutritionItem('Serat', _akgData['fiber'], 'g'),
                    _buildNutritionItem('Air', _akgData['water'], 'ml'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi untuk berbagi data
                },
                child: const Text('Bagikan Data Rekap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
