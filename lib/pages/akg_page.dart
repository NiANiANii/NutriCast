import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../features/akg_feature.dart';

class AKGPage extends StatelessWidget {
  final int? age;
  final String? gender;

  const AKGPage({super.key, this.age, this.gender});

  @override
  Widget build(BuildContext context) {
    if (age == null || gender == null) {
      return _buildMissingDataScreen(context);
    }

    final akgData =
        AKGFeature.getAKG(age!, gender!) ?? _getDefaultAKGData(gender!);

    _saveAKGData(akgData); // Simpan untuk RecapPage

    return Scaffold(
      appBar: AppBar(
        title: const Text("Angka Kecukupan Gizi (AKG)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfileCard(context, akgData),
            const SizedBox(height: 20),
            _buildNutritionGauge(
              context,
              "Energi",
              akgData["energy"],
              "kkal",
              akgData["energy"] * 1.2,
              Colors.deepOrange,
            ),
            _buildNutritionGauge(
              context,
              "Protein",
              akgData["protein"],
              "g",
              akgData["protein"] * 1.5,
              Colors.blue,
            ),
            _buildNutritionCard("Detail Kebutuhan Gizi", [
              _buildNutritionItem("Lemak", akgData["fat"], "g"),
              _buildNutritionItem("Karbohidrat", akgData["carbs"], "g"),
              _buildNutritionItem("Serat", akgData["fiber"], "g"),
              _buildNutritionItem("Air", akgData["water"], "ml"),
            ]),
            if (akgData["isDefault"] == true)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  "*Data standar digunakan karena data AKG spesifik tidak tersedia",
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAKGData(Map<String, dynamic> akgData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('akgEnergy', akgData["energy"]);
    await prefs.setInt('akgProtein', akgData["protein"]);
    await prefs.setInt('akgFat', akgData["fat"]);
    await prefs.setInt('akgCarbs', akgData["carbs"]);
    await prefs.setInt('akgFiber', akgData["fiber"]);
    await prefs.setInt('akgWater', akgData["water"]);
    await prefs.setString('akgAgeRange', akgData["ageRange"]);
  }

  Widget _buildMissingDataScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Angka Kecukupan Gizi (AKG)")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 50, color: Colors.orange[700]),
            const SizedBox(height: 16),
            const Text(
              "Data belum lengkap",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Silakan lengkapi data usia dan jenis kelamin pada halaman Home terlebih dahulu",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Ke Halaman Home",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getDefaultAKGData(String gender) {
    return {
      "ageRange": "Tidak tersedia",
      "gender": gender,
      "energy": 2000,
      "protein": 50,
      "fat": 65,
      "carbs": 300,
      "fiber": 25,
      "water": 2000,
      "isDefault": true,
    };
  }

  Widget _buildUserProfileCard(BuildContext context, Map<String, dynamic> akg) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  "Profil Gizi Anda",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            _buildProfileItem("Kelompok Umur", akg["ageRange"]),
            _buildProfileItem("Jenis Kelamin", akg["gender"]),
            if (age != null) _buildProfileItem("Usia", "$age tahun"),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildNutritionGauge(
    BuildContext context,
    String title,
    dynamic value,
    String unit,
    double max,
    Color color,
  ) {
    final numericValue = double.tryParse(value.toString()) ?? 0;
    final percentage = (numericValue / max).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: max,
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: 0,
                        endValue: max * 0.7,
                        color: Colors.grey[200],
                      ),
                      GaugeRange(
                        startValue: max * 0.7,
                        endValue: max * 0.9,
                        color: Colors.blue[100],
                      ),
                      GaugeRange(
                        startValue: max * 0.9,
                        endValue: max,
                        color: color.withOpacity(0.3),
                      ),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: numericValue,
                        needleColor: color,
                        knobStyle: KnobStyle(
                          color: color,
                          sizeUnit: GaugeSizeUnit.logicalPixel,
                          knobRadius: 5,
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          "$value $unit",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              color: percentage > 0.9 ? color : Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "0 $unit",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  "${max.toStringAsFixed(0)} $unit",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, dynamic value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            "$value $unit",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Informasi AKG"),
            content: const Text(
              "Angka Kecukupan Gizi (AKG) adalah rata-rata kebutuhan energi dan zat gizi "
              "yang dianjurkan untuk kelompok umur dan jenis kelamin tertentu.\n\n"
              "Data ini digunakan sebagai acuan untuk memenuhi kebutuhan gizi harian Anda.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("TUTUP"),
              ),
            ],
          ),
    );
  }
}
