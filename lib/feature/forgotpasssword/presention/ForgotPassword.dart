import 'dart:async';

import 'package:flutter/material.dart';
import 'package:license_plate_detect/core/models/checkAndDetail.dart';
import 'package:license_plate_detect/core/theme/app_color.dart';
import 'package:license_plate_detect/feature/login/presention/LoginPage.dart';
import 'package:license_plate_detect/feature/otp/presention/OTPPage.dart';
import 'package:license_plate_detect/services/auth/auth.dart';
import 'package:license_plate_detect/ultis/checkInternet/checkInternet.dart';
import 'package:license_plate_detect/ultis/toast/customtoast.dart';

import '../../../core/component/app_text_field.dart';
import '../../otpresetpassword/presention/OTPResetPassword.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  TextEditingController emailController = TextEditingController();

  var isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom,
            left: 24,
            right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(
              width: size.width,
              height: 300,
              fit: BoxFit.contain,
              image: const AssetImage("assets/img_forgot_password.png"),
            ),
            Text(
              'Qu??n\nM???t kh???u',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              "?????ng lo l???ng! Vui l??ng nh???p email li??n quan ?????n t??i kho???n c???a b???n",
              style: Theme.of(context).textTheme.button?.copyWith(color: Colors.grey),
            ),
            const SizedBox(),
            AppTextFields(
              controller: emailController,
              prefix: Icon(Icons.alternate_email_rounded),
              hint: "?????a ch??? email",
              textInputAction: TextInputAction.done,
            ),
            SizedBox(
              width: size.width,
              height: 64,
              child: ElevatedButton(
                onPressed: () async {
                  bool checkConnection = await checkInternet.getConnectivity(
                      isDeviceConnected, isAlertSet);
                  if (!checkConnection) {
                    checkInternet.showDialogBox(
                        context, isDeviceConnected, isAlertSet);
                    setState(() {
                      isAlertSet = true;
                    });
                  }else if(emailController.text == ''){
                    CustomToast.presentWarningToast(context, 'Kh??ng ???????c ????? tr???ng email!');
                  }else{
                    CheckAndDetail cks = await Authenticate.forgotpassword(emailController.text);
                    if(cks.check == true){
                      Timer(const Duration(milliseconds: 100), () {
                        CustomToast.presentSuccessToast(context,cks.detail);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return OTPResetPasswordPage(email: emailController.text,);
                        }));
                      });
                    }else{
                      CustomToast.presentErrorToast(context,cks.detail);
                    }
                  }
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
                child: const Text('X??c nh???n'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
