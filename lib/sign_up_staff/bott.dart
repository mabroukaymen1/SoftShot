import 'package:baby/home/color.dart';
import 'package:flutter/material.dart';

class Shared_BottomAppBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  Shared_BottomAppBar(
      {required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFFF1F3F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildIconButton(context, Icons.home, 'Home', 0),
              _buildIconButton(context, Icons.list_alt, 'Activities', 1),
              SizedBox(width: 60),
              _buildIconButton(context, Icons.show_chart, 'Statistics', 2),
              _buildIconButton(context, Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(
      BuildContext context, IconData icon, String tooltip, int index) {
    return IconButton(
      icon: Icon(icon,
          color: selectedIndex == index
              ? AppColors.primary
              : AppColors.secondaryText),
      tooltip: tooltip,
      onPressed: () => onItemSelected(index),
    );
  }
}
