import 'package:flutter/material.dart';

class MyDropDownButton extends StatefulWidget {
  String? dropdownValue;
  final List<String> items;
  final Color? textColor;
  final Color? iconColor;
  final Color? backgroundColor;
  final Function(String v) function;
  final String hintText;
  final Map<String,Color> colorsMap;

  MyDropDownButton({Key? key, required this.dropdownValue, required this.items, this.textColor, this.iconColor, this.backgroundColor, required this.function, required this.hintText, this.colorsMap =const {}}) : super(key: key);

  @override
  State<MyDropDownButton> createState() => _MyDropDownButtonState();
}

class _MyDropDownButtonState extends State<MyDropDownButton> {
  // String dropdownValue = widget.dropdownValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withOpacity(0.2),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButton<String>(
        hint: Text(widget.hintText),
        isExpanded: true,
        value: widget.dropdownValue,
        isDense: false,
        alignment: Alignment.centerRight,
        dropdownColor: widget.backgroundColor,

        // focusColor: Colors.green,
        icon: Icon(
          Icons.arrow_drop_down,
          color: widget.iconColor,
          size: 30,
        ),
        // elevation: 16,
        style: const TextStyle(color: Colors.deepPurple),
        underline: const SizedBox(
          height: 0,
          width: 0,
        ),
        onChanged: (String? newValue) {
          setState(() {
            widget.dropdownValue = newValue!;
          });
          if(newValue!=null){
            widget.function(newValue);
          }
        },
        items: widget.items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                value,
                style:  TextStyle(color: widget.colorsMap[value] ?? ((value == 'cash') ? Colors.green : value == 'card' ? Colors.blue : Colors.black)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

