import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final label;
  final hintText;
  final onChange;
  final validate;
  final formController;
  final color;
  final value;
  final prefixIcon;
  final suffixIcon;
  final obscureText;
  final maxLength;
  final keyboardType;
  final textCapitalization;
  final suffixText;
  final enabled;
  final margin;
  final padding;

  CustomTextInput(
      {Key key,
      @required this.label,
      @required this.onChange,
      this.hintText,
      this.validate,
      this.formController,
      this.color,
      this.value,
      this.prefixIcon,
      this.suffixIcon,
      this.obscureText,
      this.maxLength,
      this.keyboardType,
      this.textCapitalization,
      this.suffixText,
      this.enabled,
      this.margin,
      this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin != null ? margin : const EdgeInsets.all(1),
      padding: padding != null ? padding : const EdgeInsets.all(1),
      child: TextFormField(
        enabled: enabled,
        controller: formController,
        initialValue: value,
        onChanged: (String input) => onChange(input),
        validator: (String input) => validate(input),
        obscureText: obscureText ?? false,
        maxLength: maxLength,
        keyboardType: keyboardType ?? TextInputType.text,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          suffixText: suffixText,
        ),
      ),
    );
  }
}

// decoration: InputDecoration(
//   labelText: label,
//   enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.all(Radius.circular(12)),
//       borderSide: BorderSide(color: color)),
//   focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.all(Radius.circular(12)),
//     borderSide: BorderSide(color: Colors.orange),
//   ),
//   errorBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.all(Radius.circular(12)),
//       borderSide: BorderSide(width: 1, color: Colors.red)),
// )
