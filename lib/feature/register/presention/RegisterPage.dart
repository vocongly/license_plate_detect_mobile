// ignore_for_file: unnecessary_new

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:license_plate_detect/core/models/checkAndDetail.dart';
import 'package:license_plate_detect/feature/login/presention/LoginPage.dart';
import 'package:license_plate_detect/ultis/checkInternet/checkInternet.dart';
import 'package:license_plate_detect/ultis/dialog/alertDialog.dart';
import 'package:license_plate_detect/ultis/toast/customtoast.dart';

import '../../../core/component/app_text_field.dart';
import '../../../core/models/User.dart';
import '../../../core/theme/app_color.dart';
import '../../../services/auth/auth.dart';
import '../../../ultis/loading/customloading.dart';
import '../../otp/presention/OTPPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool showPassword = true;
  bool showPasswordConfirm = true;

  var isDeviceConnected = false;
  bool isAlertSet = false;

  bool checkSpace() {
    bool check = true;
    if (usernameController.text == '' ||
        passwordController.text == '' ||
        passwordConfirmController.text == '' ||
        phonenumberController.text == '' ||
        emailController.text == '') {
      check = false;
    }
    return check;
  }

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
              height: 200,
              fit: BoxFit.contain,
              image: const AssetImage("assets/img_register.png"),
            ),
            Text(
              '????ng k??',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextFields(
                  controller: usernameController,
                  prefix: Icon(Icons.person_outline),
                  hint: "Username",
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(
                  height: 12,
                ),
                AppTextFields(
                  controller: phonenumberController,
                  prefix: Icon(Icons.phone_outlined),
                  hint: "S??? ??i???n tho???i",
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(
                  height: 12,
                ),
                AppTextFields(
                  controller: emailController,
                  prefix: Icon(Icons.alternate_email_rounded),
                  hint: "?????a ch??? email",
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(
                  height: 12,
                ),
                AppTextFields(
                  obscureText: showPassword,
                  controller: passwordController,
                  prefix: Icon(Icons.lock_outline_rounded),
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                      icon: Icon(showPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined)),
                  hint: "M???t kh???u",
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(
                  height: 12,
                ),
                AppTextFields(
                  obscureText: showPasswordConfirm,
                  controller: passwordConfirmController,
                  prefix: Icon(Icons.lock_outline_rounded),
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          showPasswordConfirm = !showPasswordConfirm;
                        });
                      },
                      icon: Icon(showPasswordConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined)),
                  hint: "X??c nh???n m???t kh???u",
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
                    setState(() {
                      isAlertSet = true;
                    });
                  } else if (!checkSpace()) {
                    CustomToast.presentWarningToast(
                        context, 'Kh??ng ???????c ????? tr???ng c??c ??!');
                  } else if (passwordConfirmController.text !=
                      passwordController.text) {
                    CustomToast.presentWarningToast(
                        context, 'M???t kh???u ph???i gi???ng nhau!');
                  } else {
                    CustomLoading.loadingtext(context, '??ang ????ng k?? t??i kho???n');
                    CheckAndDetail reg = await Authenticate.register(
                        emailController.text,
                        usernameController.text,
                        phonenumberController.text,
                        passwordConfirmController.text);
                    if (reg.check == true) {
                      Timer(const Duration(milliseconds: 100), () {
                        CustomLoading.dismisloading(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return OTPPage(
                            email: emailController.text,
                            username: usernameController.text,
                            phonenumber: phonenumberController.text,
                            password: passwordConfirmController.text,
                          );
                        }));
                      });
                    } else if (reg.check == false) {
                      CustomLoading.dismisloading(context);
                      CustomToast.presentErrorToast(context, '${reg.detail}');
                    }
                  }
                  // Navigator.push(context,
                  //             MaterialPageRoute(builder: (context) {
                  //           return OTPPage();
                  //         }));
                },
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)))),
                child: const Text('????ng k?? t??i kho???n'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
