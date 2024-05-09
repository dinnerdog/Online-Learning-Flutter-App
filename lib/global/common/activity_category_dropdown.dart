import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:test1/data/model/activity_model.dart';
import 'package:test1/main.dart';

class ActivityCategoryDropdown extends StatefulWidget {
  final Function(ActivityCategory) onCategorySelected;
  final ActivityCategory? selectedCategory;
  ActivityCategoryDropdown({Key? key, required this.onCategorySelected,  this.selectedCategory})
      : super(key: key);

  @override
  _ActivityCategoryDropdownState createState() =>
      _ActivityCategoryDropdownState();
}

class _ActivityCategoryDropdownState extends State<ActivityCategoryDropdown> {

  ActivityCategory _selectedCategory = ActivityCategory.general;
  @override
  Widget build(BuildContext context) {
    List<String> dropdownItems =
        ActivityCategory.values.map((e) => e.name).toList();

    return CustomDropdown<String>(

  
      initialItem: widget.selectedCategory?.name,
      decoration: CustomDropdownDecoration(
        listItemStyle: TextStyle(color: AppColors.accentColor, fontSize: 16),
        headerStyle: TextStyle(color: AppColors.mainColor, fontSize: 16),
        hintStyle: TextStyle(color: AppColors.mainColor, fontSize: 16),
        expandedBorderRadius: BorderRadius.circular(5),
        expandedFillColor: AppColors.secondaryColor,
        closedFillColor: AppColors.secondaryColor,
        closedBorder: Border.all(color: AppColors.mainColor, width: 1),
        closedBorderRadius: BorderRadius.circular(5),
      ),
      hintText: 'Select a category for the activity',
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = ActivityCategory.values
              .firstWhere((element) => element.name == newValue);
        });
        widget.onCategorySelected(ActivityCategory.values
            .firstWhere((element) => element.name == newValue));
      },
      items: dropdownItems,
    );
  }
}
