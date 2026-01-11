import 'package:campus_care/controllers/class_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../responsive/responsive_padding.dart';
import 'custom_dropdown.dart';

class ClassSectionDropDown extends StatefulWidget {
  final double? padding;
  final Function(String classId) onChangedClass;
  final Function(
    String classId,
  ) onChangedSection;
  const ClassSectionDropDown(
      {super.key,
      this.padding,
      required this.onChangedClass,
      required this.onChangedSection});

  @override
  State<ClassSectionDropDown> createState() => _ClassSectionDropDownState();
}

class _ClassSectionDropDownState extends State<ClassSectionDropDown> {
  final controller = Get.find<ClassController>();
  String? selectedClass;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(widget.padding ?? 16),
      child: Row(
        children: [
          Expanded(
              child: CustomDropdown(
                  hintText: "Select Class",
                  labelText: "Class",
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() {
                      selectedClass = val;
                    });
                    widget.onChangedClass(val);
                  },
                  items: List.generate(controller.classes.length, (index) {
                    return DropdownMenuItem(
                        value: controller.classes[index].id,
                        child: Text(controller.classes[index].name));
                  }))),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: CustomDropdown(
                  hintText: "Select Section",
                  labelText: "Section",
                  onChanged: (val) {
                    if (val == null) return;
                    widget.onChangedSection(val as String);
                  },
                  items: selectedClass == null
                      ? []
                      : List.generate(
                          controller.classes
                              .firstWhere((e) => e.id == selectedClass)
                              .sections
                              .length, (index) {
                          return DropdownMenuItem(
                              value: controller.classes
                                  .firstWhere((e) => e.id == selectedClass)
                                  .sections[index],
                              child: Text(controller.classes
                                  .firstWhere((e) => e.id == selectedClass)
                                  .sections[index]));
                        }))),
        ],
      ),
    );
  }
}
