import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavCard extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String> iconPaths; // List of icon paths
  final List<String> labels; // Optionally add labels for each nav item
  final double iconSize; // Icon size
  final Color activeColor; // Active icon color
  final Color inactiveColor; // Inactive icon color
  final Color backgroundColor; // Nav background color
  final double padding; // Padding for the nav card
  final Duration animationDuration; // Duration for the animation

  const NavCard({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.iconPaths,
    this.labels = const [],
    this.iconSize = 24.0,
    this.activeColor = const Color(0xFFD4A373),
    this.inactiveColor = Colors.white,
    this.backgroundColor = const Color(0xFF2E3A59),
    this.padding = 16.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(iconPaths.length, (index) {
          return _buildNavItem(
            iconPath: iconPaths[index],
            index: index,
            label: labels.isNotEmpty ? labels[index] : '',
            isActive: currentIndex == index,
          );
        }),
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required int index,
    required String label,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFD4A373).withOpacity(0.1) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedScale(
          duration: animationDuration,
          scale: isActive ? 1.15 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  iconPath,
                  width: isActive ? iconSize + 2 : iconSize,
                  height: isActive ? iconSize + 2 : iconSize,
                  colorFilter: ColorFilter.mode(
                    isActive ? activeColor : inactiveColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
