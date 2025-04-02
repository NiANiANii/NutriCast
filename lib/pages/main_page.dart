import 'package:flutter/material.dart';
import 'nutri_cast_page.dart';
import 'questionnaire_page.dart';
import 'akg_page.dart';
import 'recap_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  int? _userAge;
  String? _userGender;

  // Method untuk membangun halaman yang aktif
  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return NutriCastPage(
          onDataSubmitted: (age, gender) {
            setState(() {
              _userAge = age;
              _userGender = gender;
            });
          },
        );
      case 1:
        return const QuestionnairePage();
      case 2:
        return AKGPage(age: _userAge, gender: _userGender);
      case 3:
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
            'Silakan lengkapi data diri di halaman NutriCast terlebih dahulu',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'NutriCast'),
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
