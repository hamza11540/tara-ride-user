import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:driver_customer_app/app_colors.dart';
import 'package:driver_customer_app/src/models/media.dart';
import 'package:driver_customer_app/src/views/widgets/payment_method_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:place_picker/entities/localization_item.dart';
import 'package:place_picker/place_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../controllers/ride_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../../models/create_ride_address.dart';
import '../../models/screen_argument.dart';
import '../../models/selected_payment_method.dart';
import '../../models/vehicle_type.dart';
import '../../repositories/setting_repository.dart';
import '../../repositories/user_repository.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/menu.dart';
import 'home_map.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends StateMVC<HomeScreen> {
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

  _HomeScreenState() : super(RideController()) {
    _con = controller as RideController;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.mainBlue,
            ),
            SizedBox(height: 50),
            Text(
              AppLocalizations.of(context)!.sendingRide,
              style: kTitleStyle.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
      ),
      overlayOpacity: 0.85,
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          key: scaffoldKey,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState!.openDrawer();
              },
              icon: Icon(
                Icons.menu,
                size: 30,
                color: Colors.black,
              ),
            ),
            title: Text(
              "Tara Ride",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            actions: [
              Image.asset(
                  'assets/img/eb669a40-feb6-47af-b97d-3e6571162c41-removebg-preview.png')
            ],
          ),
          drawer: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child: Drawer(
              backgroundColor: Colors.black,
              child: MenuWidget(
                onSwitchTab: (tab) {
                  if (tab == 'Home') {
                    Navigator.pop(context);
                  } else {
                    Navigator.of(context).pushReplacementNamed(
                      '/$tab',
                    );
                  }
                },
              ),
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 35),
            child: vehicleTypeSelected == null || _con.simulation == null
                ? SizedBox()
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BottomAppBar(
                      child: Container(
                        color: AppColors.white,
                        height: ((_con.simulation != null || _con.simulating)
                                ? 150
                                : 0) +
                            (vehicleTypeSelected != null &&
                                    destination != null &&
                                    selectedPaymentMethod != null &&
                                    _con.driversNearBy.isNotEmpty
                                ? 70
                                : 0),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_con.simulating)
                              CircularProgressIndicator(
                                color: AppColors.mainBlue,
                              )
                            else if (_con.simulation != null)
                              Column(
                                children: [
                                  if (pickup != null &&
                                      vehicleTypeSelected != null &&
                                      !_con.loading &&
                                      _con.driversNearBy.isEmpty)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Lottie.asset(
                                            'assets/img/24347-drivers-community.json',
                                            height: 50),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Center(
                                          child: Text(
                                            "Sorry, no driver found nearby.",
                                            style: kSubtitleStyle.copyWith(
                                                color: Colors.red[800],
                                                fontSize: 12),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (vehicleTypeSelected != null &&
                                      destination != null &&
                                      _con.driversNearBy.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: Dimensions.PADDING_SIZE_SMALL),
                                      child: InkWell(
                                        onTap: () {
                                          showGeneralDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel:
                                                  MaterialLocalizations.of(
                                                          context)
                                                      .modalBarrierDismissLabel,
                                              barrierColor: Colors.black45,
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 200),
                                              pageBuilder:
                                                  (BuildContext buildContext,
                                                      Animation animation,
                                                      Animation
                                                          secondaryAnimation) {
                                                return Dialog(
                                                  child:
                                                      PaymentMethodListWidget(
                                                    selectedPaymentMethod,
                                                    (SelectedPaymentMethod?
                                                        paymentMethod) {
                                                      setState(() {
                                                        if (paymentMethod !=
                                                                null &&
                                                            selectedPaymentMethod !=
                                                                null &&
                                                            selectedPaymentMethod!
                                                                    .id ==
                                                                paymentMethod
                                                                    .id) {
                                                          selectedPaymentMethod =
                                                              null;
                                                        } else {
                                                          selectedPaymentMethod =
                                                              paymentMethod;
                                                        }
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                );
                                              });
                                        },
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: AppColors.mainBlue,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: ListTile(
                                            dense: true,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            title: Text(
                                              selectedPaymentMethod == null
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .selectPaymentMethod
                                                  : AppLocalizations.of(
                                                          context)!
                                                      .payWith(
                                                          selectedPaymentMethod!
                                                              .name),
                                              style: kSubtitleStyle.copyWith(
                                                color: Theme.of(context)
                                                    .highlightColor,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            trailing: Icon(
                                              Icons.arrow_forward_ios,
                                              color: Theme.of(context)
                                                  .highlightColor,
                                              size: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            SizedBox(
                              height: Dimensions.PADDING_SIZE_SMALL,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  child: Text(
                                    AppLocalizations.of(context)!.distance,
                                    style: kTitleStyle.copyWith(
                                        height: 1.2,
                                        fontSize:
                                            Dimensions.FONT_SIZE_EXTRA_LARGE_2),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    _con.simulation!.distance,
                                    style: kSubtitleStyle.copyWith(
                                      fontSize:
                                          Dimensions.FONT_SIZE_EXTRA_LARGE,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  child: Text(
                                    AppLocalizations.of(context)!.total,
                                    style: kTitleStyle.copyWith(
                                        height: 1.2,
                                        fontSize:
                                            Dimensions.FONT_SIZE_EXTRA_LARGE_2),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                      '${NumberFormat.simpleCurrency(name: setting.value.currency).currencySymbol} ${_con.simulation!.originalPrice.toStringAsFixed(2)}',
                                      style: kSubtitleStyle.copyWith(
                                          fontSize: Dimensions
                                              .FONT_SIZE_EXTRA_LARGE)),
                                )
                              ],
                            ),
                            if (vehicleTypeSelected != null &&
                                destination != null &&
                                selectedPaymentMethod != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: TextButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      context.loaderOverlay.show();
                                      await _con
                                          .doSubmit(
                                              pickup!,
                                              destination!,
                                              vehicleTypeSelected!,
                                              selectedPaymentMethod!,
                                              observation)
                                          .then((id) {
                                        Navigator.pushNamed(context, '/Ride',
                                            arguments: ScreenArgument({
                                              'rideId': id,
                                            }));
                                      }).catchError((onError) {});
                                      context.loaderOverlay.hide();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                      backgroundColor: AppColors.mainBlue,
                                      minimumSize: Size(
                                          MediaQuery.of(context).size.width,
                                          50),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                      )),
                                  child: AutoSizeText(
                                    AppLocalizations.of(context)!.sendRide,
                                    textAlign: TextAlign.center,
                                    style: khulaBold.merge(
                                      TextStyle(
                                        color: Theme.of(context).highlightColor,
                                        fontSize: Dimensions.FONT_SIZE_LARGE,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                ),
                CarouselSlider(
                  options: CarouselOptions(height: 100.0, autoPlay: true),
                  items: [1, 2, 3, 4, 5].map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("assets/img/OBJECTS.png"),
                                    fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.mainBlue),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Let's go with",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          color: AppColors.white),
                                    ),
                                    Text(
                                      " Tara Ride",
                                      style: TextStyle(
                                          fontSize: 22.0,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Image.asset('assets/img/Group 6006 1.png')
                              ],
                            ));
                      },
                    );
                  }).toList(),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextFormField(
                        readOnly: true,
                        onTap: () {
                          if (!currentUser.value.auth) {
                            Navigator.of(context).pushNamed(
                              '/Login',
                            );
                          } else {
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
                                if (pickup != null &&
                                    vehicleTypeSelected != null) {
                                  await _con.doSimulate(pickup!, destination!,
                                      vehicleTypeSelected!);
                                }
                              },
                              defaultLocation: destination != null &&
                                      destination!.address.latLng?.latitude !=
                                          null &&
                                      destination!.address.latLng?.longitude !=
                                          null
                                  ? LatLng(
                                      destination!.address.latLng!.latitude,
                                      destination!.address.latLng!.longitude,
                                    )
                                  : pickup != null &&
                                          pickup!.address.latLng?.latitude !=
                                              null &&
                                          pickup!.address.latLng?.longitude !=
                                              null
                                      ? LatLng(
                                          pickup!.address.latLng!.latitude,
                                          pickup!.address.latLng!.longitude,
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
                          }
                        },
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        controller: TextEditingController()
                          ..text =
                              (destination?.address.formattedAddress ?? ''),
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
                                  homeMapKey.currentState!.zoomMarkers(
                                      pickup?.address.latLng, null);
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
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
                                          address.address.formattedAddress ??
                                              '',
                                          style: khulaBold.copyWith(
                                            color: Theme.of(context)
                                                .highlightColor,
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
                                        await _con.doSimulate(pickup!,
                                            destination!, vehicleTypeSelected!);
                                      }
                                    }
                                  },
                                  defaultLocation:
                                      pickup != null &&
                                              pickup!.address.latLng?.latitude !=
                                                  null &&
                                              pickup!.address.latLng
                                                      ?.longitude !=
                                                  null
                                          ? LatLng(
                                              pickup!.address.latLng!.latitude,
                                              pickup!.address.latLng!.longitude,
                                            )
                                          : destination != null &&
                                                  destination!.address.latLng
                                                          ?.latitude !=
                                                      null &&
                                                  destination!.address.latLng
                                                          ?.longitude !=
                                                      null
                                              ? LatLng(
                                                  destination!
                                                      .address.latLng!.latitude,
                                                  destination!.address.latLng!
                                                      .longitude,
                                                )
                                              : _currentLocation !=
                                                          null &&
                                                      _currentLocation!
                                                              .latitude !=
                                                          null &&
                                                      _currentLocation!
                                                              .longitude !=
                                                          null
                                                  ? LatLng(
                                                      _currentLocation!
                                                          .latitude!,
                                                      _currentLocation!
                                                          .longitude!,
                                                    )
                                                  : null,
                                );
                              },
                              controller: TextEditingController()
                                ..text =
                                    (pickup?.address.formattedAddress ?? ''),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
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
                                        homeMapKey.currentState!
                                            .addLocationMarker(null,
                                                destination?.address.latLng);
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
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5),
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
                                      setState(
                                          () => selectedPaymentMethod = null);
                                      if (selected) {
                                        setState(() {
                                          _con.simulation = null;
                                          vehicleTypeSelected = null;
                                        });
                                      } else {
                                        setState(() {
                                          vehicleTypeSelected = vehicleType;
                                        });
                                        if (pickup != null &&
                                            destination != null) {
                                          await _con
                                              .doFindNearBy(
                                                  pickup!, vehicleTypeSelected!)
                                              .then((value) {
                                            if (_con.driversNearBy.isEmpty) {}
                                          });
                                        }
                                        if (pickup != null &&
                                            destination != null) {
                                          await _con.doSimulate(
                                              pickup!,
                                              destination!,
                                              vehicleTypeSelected!);
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
                                            borderRadius:
                                                BorderRadius.horizontal(
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1,
                                              ),
                                              if (vehicleType.picture != null)
                                                CachedNetworkImage(
                                                  progressIndicatorBuilder:
                                                      (context, url,
                                                              progress) =>
                                                          Center(
                                                    child: SizedBox(
                                                      width: 30,
                                                      height: 30,
                                                      child:
                                                          CircularProgressIndicator(
                                                        value:
                                                            progress.progress,
                                                        color:
                                                            AppColors.mainBlue,
                                                      ),
                                                    ),
                                                  ),
                                                  imageUrl:
                                                      vehicleType.picture!.url,
                                                  height: 44,
                                                  fit: BoxFit.contain,
                                                  alignment:
                                                      Alignment.bottomCenter,
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
              ],
            ),
          ),
//           body: Stack(
//             children: [
//               HomeMapScreen(
//                 key: homeMapKey,
//                 locationChanged: (LocationData? location) {
//                   setState(() {
//                     _currentLocation = location;
//                   });
//                 },
//               ),
//               Form(
//                 key: _formKey,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Flexible(
//                       child: Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: AppColors.lightBlue3,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         margin: EdgeInsets.only(top: 80, right: 20, left: 20),
//                         height: 85,
//                         child: ListView.builder(
//                           physics: ClampingScrollPhysics(),
//                           scrollDirection: Axis.horizontal,
//                           itemCount: setting.value.vehicleTypes.length,
//                           shrinkWrap: true,
//                           itemBuilder: (context, index) {
//                             VehicleType vehicleType =
//                                 setting.value.vehicleTypes.elementAt(index);
//                             bool selected =
//                                 vehicleTypeSelected?.id == vehicleType.id;
//                             return InkWell(
//                               onTap: () async {
//                                 setState(() => selectedPaymentMethod = null);
//                                 if (selected) {
//                                   setState(() {
//                                     _con.simulation = null;
//                                     vehicleTypeSelected = null;
//                                   });
//                                 } else {
//                                   setState(() {
//                                     vehicleTypeSelected = vehicleType;
//                                   });
//                                   if (pickup != null && destination != null) {
//                                     await _con
//                                         .doFindNearBy(
//                                             pickup!, vehicleTypeSelected!)
//                                         .then((value) {
//                                       if (_con.driversNearBy.isEmpty) {}
//                                     });
//                                   }
//                                   if (pickup != null && destination != null) {
//                                     await _con.doSimulate(pickup!, destination!,
//                                         vehicleTypeSelected!);
//                                   }
//                                 }
//                               },
//                               child: Container(
//                                 width: MediaQuery.of(context).size.width*0.225,
//                                 padding: EdgeInsets.all(10),
//                                 decoration: BoxDecoration(
//                                   color:
//                                       vehicleTypeSelected?.id == vehicleType.id
//                                           ? AppColors.mainBlue
//                                           : Colors.transparent,
//                                   borderRadius: BorderRadius.horizontal(
//                                     left: index == 0
//                                         ? Radius.circular(20)
//                                         : Radius.zero,
//                                     right: index ==
//                                             setting.value.vehicleTypes.length -
//                                                 1
//                                         ? Radius.circular(20)
//                                         : Radius.zero,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       vehicleType.name,
//                                       style: kSubtitleStyle.copyWith(
//                                           color: selected
//                                               ? Theme.of(context).highlightColor
//                                               : Theme.of(context).primaryColor,
//                                           fontSize: 12),
//                                       maxLines: 1,
//                                     ),
//                                     if (vehicleType.picture != null)
//                                       CachedNetworkImage(
//                                         progressIndicatorBuilder:
//                                             (context, url, progress) => Center(
//                                           child: SizedBox(
//                                             width: 30,
//                                             height: 30,
//                                             child: CircularProgressIndicator(
//                                               value: progress.progress,
//                                             ),
//                                           ),
//                                         ),
//                                         imageUrl: vehicleType.picture!.url,
//                                         height: 44,
//                                         fit: BoxFit.contain,
//                                         alignment: Alignment.bottomCenter,
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 130, left: 20, right: 20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     CustomTextFormField(
//                       readOnly: true,
//                       onTap: () {
//                         if (!currentUser.value.auth) {
//                           Navigator.of(context).pushNamed(
//                             '/Login',
//                           );
//                         } else {
//                           showPlacePicker(
//                             (address) async {
//                               if (address == null) {
//                                 return;
//                               }
//                               setState(() {
//                                 destination = CreateRideAddress(address);
//                               });
//                               homeMapKey.currentState!.zoomMarkers(
//                                   pickup?.address.latLng, address?.latLng);
//                               homeMapKey.currentState!.addLocationMarker(
//                                   pickup?.address.latLng, address?.latLng);
//                               if (pickup != null &&
//                                   vehicleTypeSelected != null) {
//                                 await _con.doSimulate(pickup!, destination!,
//                                     vehicleTypeSelected!);
//                               }
//                             },
//                             defaultLocation: destination != null &&
//                                     destination!.address.latLng?.latitude !=
//                                         null &&
//                                     destination!
//                                             .address.latLng?.longitude !=
//                                         null
//                                 ? LatLng(
//                                     destination!.address.latLng!.latitude,
//                                     destination!.address.latLng!.longitude,
//                                   )
//                                 : pickup != null &&
//                                         pickup!.address.latLng?.latitude !=
//                                             null &&
//                                         pickup!.address.latLng?.longitude !=
//                                             null
//                                     ? LatLng(
//                                         pickup!.address.latLng!.latitude,
//                                         pickup!.address.latLng!.longitude,
//                                       )
//                                     : _currentLocation != null &&
//                                             _currentLocation!.latitude !=
//                                                 null &&
//                                             _currentLocation!.longitude !=
//                                                 null
//                                         ? LatLng(
//                                             _currentLocation!.latitude!,
//                                             _currentLocation!.longitude!,
//                                           )
//                                         : null,
//                           );
//                         }
//                       },
//                       floatingLabelBehavior: FloatingLabelBehavior.never,
//                       controller: TextEditingController()
//                         ..text =
//                             (destination?.address.formattedAddress ?? ''),
//                       prefixIcon: Icon(
//                         Icons.location_on_outlined,
//                         color: AppColors.mainBlue,
//                         size: 20,
//                       ),
//                       prefixIconConstraints: BoxConstraints(
//                         minWidth: 30,
//                         minHeight: 10,
//                       ),
//                       contentPadding: EdgeInsets.all(18),
//                       color: AppColors.mainBlue,
//                       enabledBorder: destination != null
//                           ? OutlineInputBorder(
//                               borderRadius: BorderRadius.zero,
//                               borderSide: BorderSide.none,
//                             )
//                           : OutlineInputBorder(
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(5),
//                                 topRight: Radius.circular(5),
//                                 bottomLeft: Radius.circular(20),
//                                 bottomRight: Radius.circular(20),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                       errorBorder: InputBorder.none,
//                       focusedBorder: destination != null
//                           ? OutlineInputBorder(
//                               borderRadius: BorderRadius.zero,
//                               borderSide: BorderSide.none,
//                             )
//                           : OutlineInputBorder(
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(5),
//                                 topRight: Radius.circular(5),
//                                 bottomLeft: Radius.circular(20),
//                                 bottomRight: Radius.circular(20),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                       suffixIcon: destination != null
//                           ? IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _con.simulation = null;
//                                   destination = null;
//                                 });
//                                 homeMapKey.currentState!.zoomMarkers(
//                                     pickup?.address.latLng, null);
//                                 homeMapKey.currentState!.addLocationMarker(
//                                     pickup?.address.latLng, null);
//                               },
//                               icon: Icon(
//                                 FontAwesomeIcons.xmark,
//                                 color: Colors.red,
//                               ),
//                             )
//                           : null,
//                       suffixIconConstraints: destination != null
//                           ? BoxConstraints(
//                               minWidth: 30,
//                               maxWidth: 30,
//                               minHeight: 10,
//                             )
//                           : BoxConstraints(),
//                       focusedErrorBorder: InputBorder.none,
//                       isRequired: false,
//                       labelText: AppLocalizations.of(context)!.whereTo,
//                       labelStyle: TextStyle(
//                         fontWeight: FontWeight.w400,
//                         color:
//                             Theme.of(context).primaryColor.withOpacity(0.5),
//                         fontSize: 19,
//                       ),
//                       style: TextStyle(
//                         fontWeight: FontWeight.w400,
//                         color: Theme.of(context).primaryColor,
//                         fontSize: 15,
//                       ),
//                     ),
//                     if (destination == null &&
//                         currentUser.value.addresses.isNotEmpty)
//                       ListView.separated(
//                         shrinkWrap: true,
//                         padding:
//                             EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                         itemCount: currentUser.value.addresses.length,
//                         separatorBuilder: (BuildContext context, int index) =>
//                             Divider(
//                           height: 0,
//                           color: Theme.of(context).primaryColor,
//                           thickness: 0.2,
//                         ),
//                         itemBuilder: (BuildContext context, int index) {
//                           var address = currentUser.value.addresses[index];
//                           return Material(
//                             color: Theme.of(context).primaryColor,
//                             child: InkWell(
//                               highlightColor: Theme.of(context).primaryColor,
//                               onTap: () async {
//                                 setState(() {
//                                   destination = address;
//                                 });
//                                 homeMapKey.currentState!.zoomMarkers(
//                                     pickup?.address.latLng,
//                                     address.address.latLng);
//                                 homeMapKey.currentState!.addLocationMarker(
//                                     pickup?.address.latLng,
//                                     address.address.latLng);
//                                 if (pickup != null &&
//                                     vehicleTypeSelected != null) {
//                                   await _con.doSimulate(pickup!, destination!,
//                                       vehicleTypeSelected!);
//                                 }
//                               },
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 10, horizontal: 5),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       FontAwesomeIcons.locationDot,
//                                       size: 25,
//                                       color: Theme.of(context).highlightColor,
//                                     ),
//                                     SizedBox(width: 15),
//                                     Expanded(
//                                       child: AutoSizeText(
//                                         address.address.formattedAddress ??
//                                             '',
//                                         style: khulaBold.copyWith(
//                                           color: Theme.of(context)
//                                               .highlightColor,
//                                         ),
//                                         maxLines: 2,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       )
//                     else if (destination != null)
//                       Column(
//                         children: [
// SizedBox(height: 10,),
//                           CustomTextFormField(
//                             readOnly: true,
//                             labelText:
//                                 AppLocalizations.of(context)!.boardingPlace,
//                             hintText:
//                                 AppLocalizations.of(context)!.boardingPlace,
//                             onTap: () {
//                               showPlacePicker(
//                                 (address) async {
//                                   if (address == null) {
//                                     return;
//                                   }
//                                   setState(() {
//                                     pickup = CreateRideAddress(address);
//                                   });
//                                   homeMapKey.currentState!.zoomMarkers(
//                                       address?.latLng,
//                                       destination?.address.latLng);
//                                   homeMapKey.currentState!.addLocationMarker(
//                                       address?.latLng,
//                                       destination?.address.latLng);
//                                   if (vehicleTypeSelected != null) {
//                                     await _con.doFindNearBy(
//                                         pickup!, vehicleTypeSelected!);
//                                     if (destination != null) {
//                                       await _con.doSimulate(pickup!,
//                                           destination!, vehicleTypeSelected!);
//                                     }
//                                   }
//                                 },
//                                 defaultLocation:
//                                     pickup != null &&
//                                             pickup!.address.latLng?.latitude !=
//                                                 null &&
//                                             pickup!.address.latLng
//                                                     ?.longitude !=
//                                                 null
//                                         ? LatLng(
//                                             pickup!.address.latLng!.latitude,
//                                             pickup!.address.latLng!.longitude,
//                                           )
//                                         : destination != null &&
//                                                 destination!.address.latLng
//                                                         ?.latitude !=
//                                                     null &&
//                                                 destination!.address.latLng
//                                                         ?.longitude !=
//                                                     null
//                                             ? LatLng(
//                                                 destination!
//                                                     .address.latLng!.latitude,
//                                                 destination!.address.latLng!
//                                                     .longitude,
//                                               )
//                                             : _currentLocation !=
//                                                         null &&
//                                                     _currentLocation!
//                                                             .latitude !=
//                                                         null &&
//                                                     _currentLocation!
//                                                             .longitude !=
//                                                         null
//                                                 ? LatLng(
//                                                     _currentLocation!
//                                                         .latitude!,
//                                                     _currentLocation!
//                                                         .longitude!,
//                                                   )
//                                                 : null,
//                               );
//                             },
//                             controller: TextEditingController()
//                               ..text =
//                                   (pickup?.address.formattedAddress ?? ''),
//                             floatingLabelBehavior:
//                                 FloatingLabelBehavior.never,
//                             prefixIcon: Icon(
//                               Icons.location_on,
//                               color: AppColors.mainBlue,
//                               size: 20,
//                             ),
//                             prefixIconConstraints: BoxConstraints(
//                               minWidth: 30,
//                               minHeight: 10,
//                             ),
//                             contentPadding: EdgeInsets.only(
//                               left: 18,
//                               top: 18,
//                               bottom: 18,
//                             ),
//                             color: Theme.of(context).highlightColor,
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(20),
//                                 bottomRight: Radius.circular(20),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             errorBorder: InputBorder.none,
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.only(
//                                 bottomLeft: Radius.circular(20),
//                                 bottomRight: Radius.circular(20),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             suffixIcon: pickup != null
//                                 ? IconButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         pickup = null;
//                                         _con.simulation = null;
//                                       });
//                                       homeMapKey.currentState!.zoomMarkers(
//                                           null, destination?.address.latLng);
//                                       homeMapKey.currentState!
//                                           .addLocationMarker(null,
//                                               destination?.address.latLng);
//                                     },
//                                     icon: Icon(
//                                       FontAwesomeIcons.xmark,
//                                       color: Colors.red,
//                                     ),
//                                   )
//                                 : null,
//                             suffixIconConstraints: destination != null
//                                 ? BoxConstraints(
//                                     minWidth: 30,
//                                     maxWidth: 30,
//                                     minHeight: 10,
//                                   )
//                                 : BoxConstraints(),
//                             focusedErrorBorder: InputBorder.none,
//                             isRequired: false,
//                             labelStyle: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               color: Theme.of(context)
//                                   .primaryColor
//                                   .withOpacity(0.5),
//                               fontSize: 19,
//                             ),
//                             hintStyle: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               color: Theme.of(context)
//                                   .primaryColor
//                                   .withOpacity(0.5),
//                               fontSize: 19,
//                             ),
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               color: Theme.of(context).primaryColor,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
        ),
      ),
    );
  }
}
