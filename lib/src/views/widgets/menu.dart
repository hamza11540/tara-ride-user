import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../app_colors.dart';
import '../../controllers/user_controller.dart';
import '../../helper/dimensions.dart';
import '../../helper/assets.dart';
import '../../helper/styles.dart';
import '../../repositories/user_repository.dart';
import 'sign_out_confirmation_dialog.dart';

// ignore: must_be_immutable
class MenuWidget extends StatefulWidget {
  Function? onSwitchTab;
  MenuWidget({Key? key, this.onSwitchTab}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MenuWidgetState();
  }
}

class MenuWidgetState extends StateMVC<MenuWidget> {
  late UserController _userCon;
  var _tabIconIndexSelected = 0;
  var _listGenderText = ["Profile", "Recent Rides"];
  var _listGenderEmpty = ["", ""];

  MenuWidgetState() : super(UserController()) {
    _userCon = controller as UserController;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: !currentUser.value.auth
                ? () {}
                : () {
                    Navigator.of(context).pushReplacementNamed(
                      '/Profile',
                    );
                  },
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 40, bottom: 15),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor),
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.mainBlue, width: 3)),
                  child: ClipOval(
                      child: currentUser.value.picture != null &&
                              currentUser.value.picture!.id != ''
                          ? CachedNetworkImage(
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                              imageUrl: currentUser.value.picture!.url,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(Assets.placeholderUser,
                              color: Theme.of(context).primaryColor,
                              height: 100,
                              width: 100,
                              fit: BoxFit.scaleDown)),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                  child: Text(
                    currentUser.value.name,
                    style: TextStyle(
                        fontFamily: 'Uber',
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                  child: Text(
                    currentUser.value.email,
                    style: TextStyle(
                        fontFamily: 'Uber',
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
                  child: Text(
                    currentUser.value.phone,
                    style: TextStyle(
                        fontFamily: 'Uber',
                        fontSize: Dimensions.FONT_SIZE_LARGE,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                FlutterToggleTab(
                  width: 70,
                  borderRadius: 15,
                  selectedIndex: _tabIconIndexSelected,
                  selectedBackgroundColors: [AppColors.mainBlue],
                  selectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                  unSelectedTextStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  labels: _listGenderText,
                  selectedLabelIndex: (index) {
                    setState(() {
                      _tabIconIndexSelected = index;
                    });
                    if (index == 0) {
                      if (widget.onSwitchTab != null) {
                        widget.onSwitchTab!('Profile');
                      } else {
                        Navigator.of(context).pushReplacementNamed('/Profile');
                      }
                    } else if (index == 1) {
                      if (widget.onSwitchTab != null) {
                        widget.onSwitchTab!('RecentRides');
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed('/RecentRides');
                      }
                    }
                  },
                  marginSelected:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                ),
              ]),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                Divider(
                    color: Theme.of(context).colorScheme.secondary, height: 0),
                ListTile(
                  tileColor: AppColors.mainBlue.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                  horizontalTitleGap: 0,
                  onTap: () async {
                    if (widget.onSwitchTab != null) {
                      widget.onSwitchTab!('Home');
                    } else {
                      Navigator.of(context).pushReplacementNamed('/Home');
                    }
                  },
                  leading: Icon(
                    FontAwesomeIcons.house,
                    color: Colors.white,
                    size: 20,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.home,
                    style: rubikMedium.copyWith(
                        fontSize: Dimensions.FONT_SIZE_DEFAULT,
                        color: Colors.white),
                  ),
                ),
                if (currentUser.value.auth)
                  Column(
                    children: [
                      SizedBox(height: 10),
                      ListTile(
                        tileColor: AppColors.mainBlue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        horizontalTitleGap: 0,
                        onTap: () {
                          if (widget.onSwitchTab != null) {
                            widget.onSwitchTab!('advanceBooking');
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed('/advanceBooking');
                          }
                        },
                        leading: Icon(
                          FontAwesomeIcons.carSide,
                          color: Colors.white,
                          size: 20,
                        ),
                        title: Text(
                          "Advance Booking",
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        tileColor: AppColors.mainBlue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        horizontalTitleGap: 0,
                        onTap: () {},
                        leading: Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                        title: Text(
                          "Share with friends",
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        tileColor: AppColors.mainBlue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        horizontalTitleGap: 0,
                        onTap: () {
                          if (widget.onSwitchTab != null) {
                            widget.onSwitchTab!('privacyPolicy');
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed('/privacyPolicy');
                          }
                        },
                        leading: Icon(
                          Icons.privacy_tip,
                          color: Colors.white,
                          size: 20,
                        ),
                        title: Text(
                          "Privacy Policy",
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        tileColor: AppColors.mainBlue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        horizontalTitleGap: 0,
                        onTap: () {},
                        leading: Icon(
                          Icons.feedback,
                          color: Colors.white,
                          size: 20,
                        ),
                        title: Text(
                          "Feedback",
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        tileColor: AppColors.mainBlue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        horizontalTitleGap: 0,
                        onTap: () {
                          if (widget.onSwitchTab != null) {
                            widget.onSwitchTab!('ratingScreen');
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed('/ratingScreen');
                          }
                        },
                        leading: Icon(
                          Icons.rate_review,
                          color: Colors.white,
                          size: 20,
                        ),
                        title: Text(
                          "Rate Us",
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_DEFAULT,
                              color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        tileColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        horizontalTitleGap: 0,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => SignOutConfirmationDialog(
                                      onConfirmed: () async {
                                    await _userCon.doLogout();
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/Login', (route) => false);
                                    setState(() {});
                                  }));
                        },
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text(
                          AppLocalizations.of(context)!.logout,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              color: Colors.red),
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      SizedBox(height: 10),
                      ListTile(
                        tileColor: AppColors.mainBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30))),
                        horizontalTitleGap: 0,
                        onTap: () {
                          if (widget.onSwitchTab != null) {
                            widget.onSwitchTab!('phoneNumberScreen');
                          } else {
                            Navigator.of(context)
                                .pushReplacementNamed('/phoneNumberScreen');
                          }
                        },
                        leading: Icon(Icons.login,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                          AppLocalizations.of(context)!.login,
                          style: rubikMedium.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
