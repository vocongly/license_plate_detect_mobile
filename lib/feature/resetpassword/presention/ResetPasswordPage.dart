import 'dart:async';

import 'package:flutter/material.dart';
import 'package:license_plate_detect/core/models/checkAndDetail.dart';
import 'package:license_plate_detect/feature/login/presention/LoginPage.dart';
import 'package:license_plate_detect/services/auth/auth.dart';

import '../../../core/component/app_text_field.dart';
import '../../../core/theme/app_color.dart';
import 'package:license_plate_detect/ultis/checkInternet/checkInternet.dart';

import '../../../ultis/toast/customtoast.dart';


class ResetPasswordPage extends StatefulWidget {
  ResetPasswordPage({Key? key,required this.token}) : super(key: key);

  String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {

  TextEditingController newpassword = new TextEditingController();
  TextEditingController confirmnewpassword = new TextEditingController();

  bool showNewPassword= true;
  bool showNewPasswordConfirm= true;

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
              image: const AssetImage("assets/img_reset_password.png"),
            ),
            Text(
              '?????t l???i\nM???t kh???u',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextFields(
                  controller: newpassword,
                  obscureText: showNewPassword,
                  prefix: Icon(Icons.lock_outline_rounded),
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          showNewPassword = !showNewPassword;
                        });
                      },
                      icon: Icon(showNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined)),
                  hint: "M???t kh???u m???i",
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 24,),
                AppTextFields(
                  controller: confirmnewpassword,
                  obscureText: showNewPasswordConfirm,
                  prefix: Icon(Icons.lock_outline_rounded),
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          showNewPasswordConfirm= !showNewPasswordConfirm;
                        });
                      },
                      icon: Icon(showNewPasswordConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined)),
                  hint: "X??c nh???n m???t kh???u m???i",
                  textInputAction: TextInputAction.done,
                ),
              ],
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
                    setState(
                      () => isAlertSet = true,
                    );
                  } else if (newpassword.text == '' || confirmnewpassword.text == '') {
                    CustomToast.presentWarningToast(
                        context, 'Kh??ng ???????c ????? tr???ng c??c ??!');
                  }else if(newpassword.text != confirmnewpassword.text){
                    CustomToast.presentWarningToast(
                        context, 'M???t kh???u ph???i gi???ng nhau!');
                  }else{
                    CheckAndDetail cks = await Authenticate.resetPassword(widget.token,newpassword.text);
                    if(cks.check == true){
                      Timer(const Duration(milliseconds: 100), () {
                        CustomToast.presentSuccessToast(context, cks.detail);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const LoginPage();
                        }));
                      });
                    }else{
                      CustomToast.presentErrorToast(context, cks.detail);
                    }
                  }
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
                child: const Text('?????t l???i m???t kh???u'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
