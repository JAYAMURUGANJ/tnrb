import 'package:flutter/material.dart';

import '../utils/constant.dart';

class KChoiceChip extends StatelessWidget {
  final String gate;
  final bool isSelected;
  final Function(bool) onSelected;

  const KChoiceChip({
    super.key,
    required this.gate,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onSelected(!isSelected),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //wrap the image with rectangular border
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey,
                    width: isSelected ? 4 : 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : Colors.grey.shade600,
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    isSelected ? Assets.open : Assets.close,
                    width: 80,
                    height: 80,
                  ),
                ),
              ),

              Text(
                "GATE - $gate",
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
