import 'package:flutter/material.dart';
import 'package:mpac_app/core/data/models/country_model.dart';
import 'package:mpac_app/core/data/models/state_model.dart' as state_model;
import 'package:mpac_app/core/utils/constants/colors.dart';
import 'package:sizer/sizer.dart';

class CustomDropDownWidget<T> extends StatelessWidget {
  final String? hint;
  final List<T>? options;
  final Function(T)? onChange;
  final bool? showError;
  final String? messageError;
  final String? title;
  final bool? isLoading;
  final bool? showRetryIcon;
  final Function? onRetry;
  final double? hintWidth;
  final bool? disabled;
  final Function? onDisableClicked;
  final T? selectedOption;
  final Color? borderColor;
  final Color? backgroundColor;
  final Widget? icon;
  final bool showFlags;

  const CustomDropDownWidget({
    Key? key,
    this.hint,
    this.title,
    this.icon,
    this.backgroundColor,
    required this.options,
    required this.onChange,
    this.showError = false,
    this.showFlags = false,
    this.messageError = '',
    this.isLoading = false,
    this.borderColor = const Color(0xFFBBBBBB),
    this.showRetryIcon = false,
    this.disabled = false,
    this.onRetry,
    this.hintWidth,
    this.onDisableClicked,
    this.selectedOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null
            ? Text(
                title!,
                style: TextStyle(
                  color: AppColors.primaryFontColor,
                  fontSize: 14.sp,
                ),
              )
            : Container(),
        GestureDetector(
          onTap: () {
            if (disabled!) {
              onDisableClicked!();
            }
          },
          child: Container(
            width: double.infinity,
            // height: MediaQuery.of(context).size.height * 0.075,
            margin: const EdgeInsets.only(top: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: backgroundColor == null ? Colors.white : backgroundColor!,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              // border: Border.all(
              //     color: showError! ? Colors.red : Colors.grey, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  hint: Text(
                    hint!,
                    style: const TextStyle(
                      color: Color(0xFFBBBBBB),
                    ),
                  ),
                  iconSize: 20.0,
                  icon: icon == null
                      ? isLoading!
                          ? const SizedBox(
                              width: 16.0,
                              height: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                              ),
                            )
                          : Transform(
                              alignment: FractionalOffset.center,
                              transform: Matrix4.identity()
                                ..rotateZ(90 * 3.1415927 / 180),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 2.h,
                                color: AppColors.hintTextFieldColor,
                              ),
                            )
                      : icon!,
                  value: selectedOption,
                  items: options!.map<DropdownMenuItem<T>>((T option) {
                    return DropdownMenuItem<T>(
                      value: option,
                      child: Row(
                        children: [
                          // if (showFlags && option is CountryModel) Flag.fromString(
                          //   "USA",
                          //   height: 20,
                          //   width: 20,
                          //   fit: BoxFit.fill,
                          //   replacement: Text('ACC'),
                          // ) else Container(),

                          Text(
                            T.toString() == "Map<String, dynamic>"
                                ? (option as Map)['name']
                                : getTitle(option).toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: !disabled! ? (val) => onChange!(val as T) : null,
                ),
              ),
            ),
          ),
        ),
        showError!
            ? const SizedBox(
                height: 3.0,
              )
            : Container(),
        showError!
            ? Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    onRetry!();
                  },
                  child: Row(
                    children: [
                      Text(
                        messageError!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12.0),
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      showRetryIcon!
                          ? const Icon(
                              Icons.refresh,
                              color: Colors.red,
                              size: 16.0,
                            )
                          : Container()
                    ],
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  String getTitle(T item) {
    // if (kIsWeb) {
    //   if (item is CountryModel) return item.name;
    //   if (item is stateModel.State) return item.name;

    //   return '$item';
    // } else
    {
      if (item is CountryModel) {
        return "${item.emoji.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'), (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397))}   ${item.name}";
      }
      if (item is state_model.State) return item.name;

      return '$item';
    }
  }
}

// CustomDropDownWidget<ProductTypeEntity>(
// options: state.productsTypes,
// onChange: (ProductTypeEntity productType) {
// _bloc.onChangingProductType(productType);
// setState(() {});
// },
// hint: localizations!.productType,
// isLoading: state.isLoadingProductsTypes,
// messageError: localizations!.requiredField,
// showError: state.errorProductTypeValidation,
// selectedOption: state.submitProductParams
//     .productTypeEntity!.id ==
// -1
// ? null
// : state
//     .submitProductParams.productTypeEntity,
// );
