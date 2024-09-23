import 'package:flutter/material.dart';
import 'package:baby/home/color.dart';

class SharedBottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  SharedBottomAppBar(
      {required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF1F3F6), Color(0xFFEFEFEF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          notchMargin: 8,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildIconButton(context, Icons.home, 'Home', 0),
              _buildIconButton(context, Icons.list_alt, 'Activities', 1),
              _buildIconButton(context, Icons.person, 'Profile', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
      BuildContext context, IconData icon, String tooltip, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: IconButton(
        icon: Icon(
          icon,
          color: selectedIndex == index
              ? AppColors.primary
              : AppColors.secondaryText,
          size: selectedIndex == index ? 30 : 24,
        ),
        tooltip: tooltip,
        onPressed: () => onItemSelected(index),
      ),
    );
  }
}
