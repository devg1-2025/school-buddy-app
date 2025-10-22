import 'package:flutter/material.dart';
import 'package:school_buddy_app/constants/app_colors.dart';
import './study_materials/study_materials.dart';
import './deadlines/deadlines.dart';
import 'home.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentIndex = 0;

  var pages = [
    Home(),
    StudyMaterials(),
    Deadlines()
  ];

  void _onItemSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.homeBgColor),
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      // borderRadius: BorderRadius.circular(20),
        child: BottomNavigationBar(
          items: [
            // Home
            BottomNavigationBarItem(icon: Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Icon(Icons.home_rounded)),
            label: ("Home")
            ),
            // Study Materials
            BottomNavigationBarItem(icon: Icon(Icons.book_rounded),
            label: ("Study Materials")
            ),
            // Deadlines
            BottomNavigationBarItem(icon: Icon(Icons.alarm_rounded),
            label: ("Deadlines")
            )
          ],
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: _onItemSelected,
        
          backgroundColor: Colors.white,
          selectedItemColor: Color(AppColors.primaryColor),
          ),
      ),
    );
  }
}