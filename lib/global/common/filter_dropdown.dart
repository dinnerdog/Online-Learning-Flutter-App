import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:test1/main.dart';

class FilterDropdown extends StatefulWidget {
  final Function(String) onFilterApplied;
  final List<String> filterConditions;
  final String currentFilterCondition;

  FilterDropdown(
      {Key? key, required this.onFilterApplied, required this.filterConditions, required this.currentFilterCondition})
      : super(key: key);

  @override
  _FilterDropdownState createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  @override
  Widget build(BuildContext context) {


    return CustomDropdown<String>(
    
      listItemBuilder: (context, item, isSelected, onItemSelect) {
        return ListTile(
          textColor: AppColors.accentColor,
          dense: true,
          
          minLeadingWidth: 0,
          minVerticalPadding: 0,
          horizontalTitleGap: 0,
          title: Text(item),
          onTap: onItemSelect,
          selected: isSelected,
        );
      },
      initialItem: widget.currentFilterCondition,
      decoration: CustomDropdownDecoration(
        expandedSuffixIcon: Icon(
          Icons.arrow_drop_up,
          color: AppColors.accentColor,
        ),
        closedSuffixIcon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.accentColor,
        ),
        listItemStyle: TextStyle(color: AppColors.accentColor, fontSize: 16),
        headerStyle: TextStyle(color: AppColors.mainColor, fontSize: 16),
        hintStyle: TextStyle(color: AppColors.mainColor, fontSize: 16),
        expandedBorderRadius: BorderRadius.circular(20),
        expandedFillColor: AppColors.secondaryColor,
        closedFillColor: AppColors.secondaryColor,
        closedBorder: Border.all(color: AppColors.mainColor, width: 1),
        closedBorderRadius: BorderRadius.circular(20),
      ),
      hintText: 'Filter by category',
      onChanged: (String? newValue) {
        setState(() {
          
            widget.onFilterApplied(newValue!);
         
        });
      },
      items: widget.filterConditions,
    );
  }
}
