import 'package:flutter/material.dart';
import 'package:meetings_app/utils/constants/colors.dart';
import 'package:meetings_app/utils/helpers/helper_functions.dart';

class FilterChipsRow extends StatelessWidget {
  final int selectedFilterIndex; 
  final ValueChanged<int> onFilterSelected;

  const FilterChipsRow({
    super.key,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dark = LHelperFunctions.isDarkMode(context);

    // Los labels de los filtros, en orden
    final filters = ["Todos", "Esta semana", "Este mes", "Siguiente Mes", "Pasados"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          final label = filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8), // Espacio entre chips
            child: ChoiceChip(
              label: Text(label),
              selected: (index == selectedFilterIndex),
              selectedColor: dark ? LColors.accent2 : LColors.softGrey,
              backgroundColor: dark ? LColors.darkGrey : LColors.white,
              labelStyle: TextStyle(
                color: (index == selectedFilterIndex)
                    ? (dark ? LColors.white : LColors.dark)
                    : (dark ? LColors.textWhite : LColors.darkGrey),
              ),
              onSelected: (value) {
                if (value) {
                  onFilterSelected(index);
                }
              },
            ),
          );
        }),
      ),
    );
  }
}