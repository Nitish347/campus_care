import 'package:flutter/material.dart';

import '../responsive/responsive_padding.dart';
import 'custom_dropdown.dart';

class ClassSectionDropDown extends StatelessWidget {
  final  double? padding;
  const ClassSectionDropDown({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return   Padding(
      padding: EdgeInsets.all(padding ??16),
      child: Row(
        children: [
          Expanded(child: CustomDropdown(
              hintText: "Select Class",
              labelText: "Class",
              items: [])),
          SizedBox(
            width: 10,
          ),
          Expanded(

              child: CustomDropdown(
                  hintText: "Select Section",
                  labelText: "Section",
                  items: [])),
        ],
      ),
    );
  }
}
