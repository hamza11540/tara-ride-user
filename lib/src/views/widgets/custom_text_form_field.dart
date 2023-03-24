import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:driver_customer_app/src/repositories/setting_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_colors.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatefulWidget {
  final String hintText;
  final String labelText;
  final String? initialValue;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final int maxLines;
  final bool isPassword;
  final bool isCountryPicker;
  final bool isDateOfBirth;
  final bool isBorder;
  final bool isRequired;
  final Function? validator;
  final Function? onSave;
  final Function? onChange;
  final VoidCallback calendarTap;
  final AutovalidateMode validateMode;
  final List<TextInputFormatter> inputFormatters;
  TextEditingController? controller = TextEditingController();
  final Widget? prefixIcon;
  final BoxConstraints prefixIconConstraints;
  final Widget? suffixIcon;
  final BoxConstraints suffixIconConstraints;
  final bool enabled;
  final String errorText;
  final EdgeInsetsGeometry? contentPadding;
  final Color? color;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextStyle? style;
  final bool readOnly;
  final InputBorder? focusedErrorBorder;
  final InputBorder? errorBorder;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final void Function()? onTap;
  final TextCapitalization? textCapitalization;

  CustomTextFormField(
      {Key? key,
      this.hintText = '',
      this.labelText = '',
      this.initialValue,
      this.validator,
      this.onSave,
      this.onChange,
      this.focusNode,
      this.nextFocus,
      this.readOnly = false,
      this.validateMode = AutovalidateMode.onUserInteraction,
      this.inputType = TextInputType.text,
      this.inputAction = TextInputAction.next,
      this.maxLines = 1,
      VoidCallback? calendarTap,
      this.isDateOfBirth = false,
      this.isCountryPicker = false,
      this.isBorder = true,
      this.isRequired = false,
      this.isPassword = false,
      this.inputFormatters = const [],
      this.controller,
      this.prefixIcon,
      this.prefixIconConstraints =
          const BoxConstraints(minWidth: 0, minHeight: 0),
      this.suffixIcon,
      this.suffixIconConstraints =
          const BoxConstraints(minWidth: 0, minHeight: 0),
      this.errorText = "",
      this.contentPadding,
      this.color,
      this.enabled = true,
      this.hintStyle,
      this.labelStyle,
      this.floatingLabelBehavior,
      this.style,
      this.onTap,
      this.focusedErrorBorder,
      this.errorBorder,
      this.enabledBorder,
      this.focusedBorder,
      this.textCapitalization})
      : calendarTap = calendarTap ?? (() {}),
        super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: widget.onTap,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      focusNode: widget.focusNode ?? null,
      style: widget.style ??
          TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).primaryColor,
            fontSize: 18,
          ),
      textInputAction: widget.inputAction,
      keyboardType: widget.inputType,
      obscureText: widget.isPassword ? _obscureText : false,
      autovalidateMode: widget.validateMode,
      readOnly: widget.readOnly,
      onSaved: (newValue) =>
          widget.onSave != null ? widget.onSave!(newValue) : null,
      onChanged: (newValue) =>
          widget.onChange != null ? widget.onChange!(newValue) : null,
      inputFormatters: widget.inputFormatters,
      controller: widget.controller,
      initialValue: widget.initialValue,
      onFieldSubmitted: (v) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        }
      },
      textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
      decoration: InputDecoration(


        contentPadding: widget.contentPadding ?? const EdgeInsets.all(20),
        isDense: true,
        hintText: widget.hintText,
        fillColor: AppColors.lightBlue3,
        hintStyle: widget.hintStyle ??
            TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
            ),
        errorStyle: rubikBold,
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: widget.prefixIconConstraints,
        errorText: widget.errorText.isEmpty ? null : widget.errorText,
        errorMaxLines: 2,

        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 0.2, color:  AppColors.lightBlue3)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 0.6, color:  AppColors.lightBlue3)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(width: 0.2, color: AppColors.lightBlue3)),



        filled: true,
        suffixIcon: widget.isPassword || widget.isDateOfBirth
            ? widget.isPassword
            ? IconButton(
            icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withOpacity(.75)),
            onPressed: _toggle)
            : IconButton(
            icon: Icon(Icons.calendar_today,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withOpacity(.75)),
            onPressed: widget.calendarTap)
            : null,
      ),
      cursorColor: Theme.of(context).primaryColor,
      validator: (value) =>
          widget.validator != null ? widget.validator!(value) : null,
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
