import 'package:auto_size_text/auto_size_text.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:place_picker/entities/localization_item.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';

import '../../../app_colors.dart';
import '../../controllers/ride_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/create_ride_address.dart';
import '../../models/selected_payment_method.dart';
import '../../models/user.dart';
import '../../models/vehicle_type.dart';
import '../../repositories/setting_repository.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/menu.dart';
import 'home_map.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

ValueNotifier<User> currentUser = ValueNotifier(User());

class AdvanceBookingScreen extends StatefulWidget {
  const AdvanceBookingScreen({Key? key}) : super(key: key);

  @override
  State<AdvanceBookingScreen> createState() => _AdvanceBookingScreenState();
}

class _AdvanceBookingScreenState extends State<AdvanceBookingScreen> {
  GlobalKey<HomeMapScreenState> homeMapKey = GlobalKey();
  LocationData? _currentLocation;
  VehicleType? vehicleTypeSelected = setting.value.vehicleTypes
          .where((element) => element.isDefault)
          .isNotEmpty
      ? setting.value.vehicleTypes.where((element) => element.isDefault).first
      : null;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  late RideController _con;
  CreateRideAddress? pickup;
  CreateRideAddress? destination;
  String? observation;
  SelectedPaymentMethod? selectedPaymentMethod;

  void showPlacePicker(Function onSelected, {LatLng? defaultLocation}) async {
    LocationResult? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          'AIzaSyAwCB8cIQR5n18C70tD-DpzOvnQqsFLIJI',
          displayLocation: defaultLocation,
          localizationItem: LocalizationItem(
            languageCode: setting.value.locale.languageCode,
            nearBy: AppLocalizations.of(context)!.nearbyPlaces,
            findingPlace: AppLocalizations.of(context)!.findingPlace,
            noResultsFound: AppLocalizations.of(context)!.noResultsFound,
            unnamedLocation: AppLocalizations.of(context)!.unnamedLocation,
            tapToSelectLocation:
                AppLocalizations.of(context)!.tapSelectThisLocation,
          ),
        ),
      ),
    );
    onSelected(result);
  }

  DateTime? picked;
  void _openDateTimePicker(BuildContext context) {
    BottomPicker.dateTime(
      title: 'Set the event exact time and date',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.black,
      ),
      onSubmit: (date) {
        picked = date;
        print(picked);
      },
      onClose: () {
        print('Picker closed');
      },
      iconColor: Colors.black,
      minDateTime: DateTime(2021, 5, 1),
      maxDateTime: DateTime(2021, 8, 2),
      initialDateTime: DateTime(2021, 5, 1),
      gradientColors: [Color(0xfffdcbf1), Color(0xffe6dee9)],
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainBlue,
        title: Text(
          'Advance Booking',
          style: khulaSemiBold.copyWith(
              color: Colors.white, fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        elevation: 1,
        shadowColor: Theme.of(context).primaryColor,
      ),
      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Drawer(
          child: MenuWidget(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormField(
                    readOnly: true,
                    onTap: () {

                        showPlacePicker(
                          (address) async {
                            if (address == null) {
                              return;
                            }
                            setState(() {
                              destination = CreateRideAddress(address);
                            });
                            homeMapKey.currentState!.zoomMarkers(
                                pickup?.address.latLng, address?.latLng);
                            homeMapKey.currentState!.addLocationMarker(
                                pickup?.address.latLng, address?.latLng);
                            if (pickup != null && vehicleTypeSelected != null) {
                              await _con.doSimulate(
                                  pickup!, destination!, vehicleTypeSelected!);
                            }
                          },
                          defaultLocation: destination != null &&
                                  destination!.address.latLng?.latitude !=
                                      null &&
                                  destination!.address.latLng?.longitude != null
                              ? LatLng(
                                  destination!.address.latLng!.latitude,
                                  destination!.address.latLng!.longitude,
                                )
                              : pickup != null &&
                                      pickup!.address.latLng?.latitude !=
                                          null &&
                                      pickup!.address.latLng?.longitude != null
                                  ? LatLng(
                                      pickup!.address.latLng!.latitude,
                                      pickup!.address.latLng!.longitude,
                                    )
                                  : _currentLocation != null &&
                                          _currentLocation!.latitude != null &&
                                          _currentLocation!.longitude != null
                                      ? LatLng(
                                          _currentLocation!.latitude!,
                                          _currentLocation!.longitude!,
                                        )
                                      : null,
                        );

                    },
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    controller: TextEditingController()
                      ..text = (destination?.address.formattedAddress ?? ''),
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                      color: AppColors.mainBlue,
                      size: 25,
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 50,
                      minHeight: 10,
                    ),
                    contentPadding: EdgeInsets.all(23),
                    hintText: "PickUp Location",
                    hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                    color: AppColors.mainBlue,
                    enabledBorder: destination != null
                        ? OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide.none,
                          )
                        : OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            borderSide: BorderSide.none,
                          ),
                    errorBorder: InputBorder.none,
                    focusedBorder: destination != null
                        ? OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide.none,
                          )
                        : OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            borderSide: BorderSide.none,
                          ),
                    suffixIcon: destination != null
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _con.simulation = null;
                                destination = null;
                              });
                              homeMapKey.currentState!
                                  .zoomMarkers(pickup?.address.latLng, null);
                              homeMapKey.currentState!.addLocationMarker(
                                  pickup?.address.latLng, null);
                            },
                            icon: Icon(
                              FontAwesomeIcons.xmark,
                              color: Colors.red,
                            ),
                          )
                        : null,
                    suffixIconConstraints: destination != null
                        ? BoxConstraints(
                            minWidth: 30,
                            maxWidth: 30,
                            minHeight: 10,
                          )
                        : BoxConstraints(),
                    focusedErrorBorder: InputBorder.none,
                    isRequired: false,
                    labelText: AppLocalizations.of(context)!.whereTo,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      fontSize: 19,
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                    ),
                  ),
                  if (destination == null &&
                      currentUser.value.addresses.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      padding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      itemCount: currentUser.value.addresses.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(
                        height: 0,
                        color: Theme.of(context).primaryColor,
                        thickness: 0.2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var address = currentUser.value.addresses[index];
                        return Material(
                          color: AppColors.mainBlue,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            highlightColor: Theme.of(context).primaryColor,
                            onTap: () async {
                              setState(() {
                                destination = address;
                              });
                              homeMapKey.currentState!.zoomMarkers(
                                  pickup?.address.latLng,
                                  address.address.latLng);
                              homeMapKey.currentState!.addLocationMarker(
                                  pickup?.address.latLng,
                                  address.address.latLng);
                              if (pickup != null &&
                                  vehicleTypeSelected != null) {
                                await _con.doSimulate(pickup!, destination!,
                                    vehicleTypeSelected!);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.locationDot,
                                    size: 25,
                                    color: Theme.of(context).highlightColor,
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: AutoSizeText(
                                      address.address.formattedAddress ?? '',
                                      style: khulaBold.copyWith(
                                        color: Theme.of(context).highlightColor,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  else if (destination != null)
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          readOnly: true,
                          labelText:
                              AppLocalizations.of(context)!.boardingPlace,
                          onTap: () {
                            showPlacePicker(
                              (address) async {
                                if (address == null) {
                                  return;
                                }
                                setState(() {
                                  pickup = CreateRideAddress(address);
                                });
                                homeMapKey.currentState!.zoomMarkers(
                                    address?.latLng,
                                    destination?.address.latLng);
                                homeMapKey.currentState!.addLocationMarker(
                                    address?.latLng,
                                    destination?.address.latLng);
                                if (vehicleTypeSelected != null) {
                                  await _con.doFindNearBy(
                                      pickup!, vehicleTypeSelected!);
                                  if (destination != null) {
                                    await _con.doSimulate(pickup!, destination!,
                                        vehicleTypeSelected!);
                                  }
                                }
                              },
                              defaultLocation: pickup != null &&
                                      pickup!.address.latLng?.latitude !=
                                          null &&
                                      pickup!.address.latLng?.longitude != null
                                  ? LatLng(
                                      pickup!.address.latLng!.latitude,
                                      pickup!.address.latLng!.longitude,
                                    )
                                  : destination != null &&
                                          destination!
                                                  .address.latLng?.latitude !=
                                              null &&
                                          destination!.address.latLng?.longitude !=
                                              null
                                      ? LatLng(
                                          destination!.address.latLng!.latitude,
                                          destination!
                                              .address.latLng!.longitude,
                                        )
                                      : _currentLocation != null &&
                                              _currentLocation!.latitude !=
                                                  null &&
                                              _currentLocation!.longitude !=
                                                  null
                                          ? LatLng(
                                              _currentLocation!.latitude!,
                                              _currentLocation!.longitude!,
                                            )
                                          : null,
                            );
                          },
                          controller: TextEditingController()
                            ..text = (pickup?.address.formattedAddress ?? ''),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: AppColors.mainBlue,
                            size: 25,
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: 50,
                            minHeight: 10,
                          ),
                          contentPadding: EdgeInsets.all(23),
                          color: Theme.of(context).highlightColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: pickup != null
                              ? IconButton(
                                  onPressed: () {
                                    setState(() {
                                      pickup = null;
                                      _con.simulation = null;
                                    });
                                    homeMapKey.currentState!.zoomMarkers(
                                        null, destination?.address.latLng);
                                    homeMapKey.currentState!.addLocationMarker(
                                        null, destination?.address.latLng);
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.xmark,
                                    color: Colors.red,
                                  ),
                                )
                              : null,
                          suffixIconConstraints: destination != null
                              ? BoxConstraints(
                                  minWidth: 30,
                                  maxWidth: 30,
                                  minHeight: 10,
                                )
                              : BoxConstraints(),
                          focusedErrorBorder: InputBorder.none,
                          isRequired: false,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                            fontSize: 19,
                          ),
                          hintText: "DropOff Location",
                          hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      height: 85,
                      child: ListView.builder(
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: setting.value.vehicleTypes.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          VehicleType vehicleType =
                              setting.value.vehicleTypes.elementAt(index);
                          bool selected =
                              vehicleTypeSelected?.id == vehicleType.id;
                          return Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  setState(() => selectedPaymentMethod = null);
                                  if (selected) {
                                    setState(() {
                                      _con.simulation = null;
                                      vehicleTypeSelected = null;
                                    });
                                  } else {
                                    setState(() {
                                      vehicleTypeSelected = vehicleType;
                                    });
                                    if (pickup != null && destination != null) {
                                      await _con
                                          .doFindNearBy(
                                              pickup!, vehicleTypeSelected!)
                                          .then((value) {
                                        if (_con.driversNearBy.isEmpty) {}
                                      });
                                    }
                                    if (pickup != null && destination != null) {
                                      await _con.doSimulate(pickup!,
                                          destination!, vehicleTypeSelected!);
                                    }
                                  }
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: vehicleTypeSelected?.id ==
                                                vehicleType.id
                                            ? AppColors.mainBlue
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.horizontal(
                                          left: index == 0
                                              ? Radius.circular(20)
                                              : Radius.zero,
                                          right: index ==
                                                  setting.value.vehicleTypes
                                                          .length -
                                                      1
                                              ? Radius.circular(20)
                                              : Radius.zero,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            vehicleType.name,
                                            style: kSubtitleStyle.copyWith(
                                                color: selected
                                                    ? Theme.of(context)
                                                        .highlightColor
                                                    : Theme.of(context)
                                                        .primaryColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                          ),
                                          if (vehicleType.picture != null)
                                            CachedNetworkImage(
                                              progressIndicatorBuilder:
                                                  (context, url, progress) =>
                                                      Center(
                                                child: SizedBox(
                                                  width: 30,
                                                  height: 30,
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: progress.progress,
                                                    color: AppColors.mainBlue,
                                                  ),
                                                ),
                                              ),
                                              imageUrl:
                                                  vehicleType.picture!.url,
                                              height: 44,
                                              fit: BoxFit.contain,
                                              alignment: Alignment.bottomCenter,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 4,
                                color: Colors.white,
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: HomeMapScreen(
                    key: homeMapKey,
                    locationChanged: (LocationData? location) {
                      setState(() {
                        _currentLocation = location;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Pick Data and Time for booking",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () {
                _openDateTimePicker(context);
              },
              child: Container(
                height: 60,
                margin: EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.lightBlue3),
                child: Center(
                    child: Text(
                  picked == null
                      ? "tap to pick data and time..."
                      : picked.toString(),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                )),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
            left: Dimensions.PADDING_SIZE_DEFAULT,
            right: Dimensions.PADDING_SIZE_DEFAULT,
            bottom: 20),
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.mainBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(0),
            ),
            onPressed: () {},
            child: Text(
              "Confirm",
              style: poppinsSemiBold.copyWith(
                  color: Theme.of(context).highlightColor),
            ),
          ),
        ),
      ),
    );
  }

  void _openDateTimePickerWithCustomButton(BuildContext context) {
    BottomPicker.dateTime(
      title: 'Set the event exact time and date',
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: Colors.black,
      ),
      onSubmit: (date) {
        print(date);
      },
      onClose: () {
        print('Picker closed');
      },
      buttonText: 'Confirm',
      buttonTextStyle: const TextStyle(color: Colors.white),
      buttonSingleColor: Colors.pink,
      iconColor: Colors.black,
      minDateTime: DateTime(2021, 5, 1),
      maxDateTime: DateTime(2021, 8, 2),
      gradientColors: [Color(0xfffdcbf1), Color(0xffe6dee9)],
    ).show(context);
  }
}
