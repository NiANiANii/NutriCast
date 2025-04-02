import 'package:flutter/material.dart';
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
                "Silakan lengkapi data usia dan jenis kelamin pada halaman NutriCast terlebih dahulu",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Ke Halaman NutriCast"),
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
            Text(
              "Profil Gizi Anda",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Kelompok Umur: ${akg["ageRange"]}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Jenis Kelamin: ${akg["gender"]}",
              style: const TextStyle(fontSize: 16),
            ),
            if (age != null) ...[
              const SizedBox(height: 8),
              Text("Usia: $age tahun", style: const TextStyle(fontSize: 16)),
            ],
          ],
        ),
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
                    showLabels: true,
                    showTicks: true,
                    axisLabelStyle: const GaugeTextStyle(fontSize: 12),
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: numericValue,
                        needleColor: color,
                        knobStyle: KnobStyle(
                          color: color,
                          sizeUnit: GaugeSizeUnit.logicalPixel,
                          knobRadius: 8,
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Container(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            "$value $unit",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        angle: 90,
                        positionFactor:
                            0.8, // Mengatur posisi agar tidak overlap
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              color:
                  percentage > 0.9
                      ? Colors.red
                      : percentage > 0.7
                      ? Colors.orange
                      : color,
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
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            content: const Text("Angka Kecukupan Gizi (AKG) adalah ..."),
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
