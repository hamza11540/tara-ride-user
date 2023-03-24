import 'package:flutter/material.dart';

import '../../../app_colors.dart';
import '../../helper/dimensions.dart';
import '../../helper/styles.dart';
import '../widgets/menu.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainBlue,
        title: Text(
          'Privacy Policy',
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
      body: Column(
        children: [
          Text("Will be added")
        ],
      ),
    );
  }
}
