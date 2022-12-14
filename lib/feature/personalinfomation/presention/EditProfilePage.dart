import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:license_plate_detect/core/models/checkAndDetail.dart';
import 'package:license_plate_detect/feature/personalinfomation/presention/PersonalInfomationPage.dart';
import 'package:license_plate_detect/feature/personalinfomation/widget/button_widget.dart';
import 'package:license_plate_detect/feature/personalinfomation/widget/profile_widget.dart';
import 'package:license_plate_detect/services/auth/auth.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:license_plate_detect/services/localstorage/localStorage.dart';
import 'package:license_plate_detect/ultis/checkInternet/checkInternet.dart';

import '../../../core/models/User.dart';
import '../../../core/theme/app_color.dart';
import '../../../ultis/loading/customloading.dart';
import '../../../ultis/toast/customtoast.dart';
import '../widget/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

File? image;
User user = new User();

class _EditProfilePageState extends State<EditProfilePage> {
  var isDeviceConnected = false;
  bool isAlertSet = false;

  Future pickImage(ImageSource source) async {
    try {
      final imagepost = await ImagePicker().pickImage(source: source);
      if (imagepost == null) return;
      final imageTemporary = File(imagepost!.path);

      setState(() {
        image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image : $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    //print(user.email);
    user = LocalStorage.getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PersonalInfomationPage();
            }));
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColor.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
          child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        children: [
          ProfileWidget(
              imagePath: user.avatar!,
              isEdit: true,
              onNavigator: () {},
              onClicked: () async {
                await showAlertChooseImage(context);
              }),
          SizedBox(
            height: 24,
          ),
          SizedBox(
            height: 24,
          ),
          TextFieldWidget(
              label: 'T??n',
              text: user.firstName!,
              onChanged: (value) {
                if (value != null) user.firstName = value;
              }),
          SizedBox(
            height: 24,
          ),
          TextFieldWidget(
              label: 'H???',
              text: user.lastName!,
              onChanged: (value) {
                if (value != null) user.lastName = value;
              }),
          SizedBox(
            height: 24,
          ),
          TextFieldWidget(
              label: 'S??? ??i???n tho???i',
              text: user.phoneNumber!,
              onChanged: (value) {
                if (value != null) user.phoneNumber = value;
              }),
          SizedBox(
            height: 24,
          ),
          Center(
            child: ButtonWidget(
                text: 'C???p nh???t th??ng tin',
                onClicked: () async {
                  print(user.firstName);
                  print(user.lastName);
                  print(user.phoneNumber);
                  bool checkConnection = await checkInternet.getConnectivity(
                      isDeviceConnected, isAlertSet);
                  if (!checkConnection) {
                    checkInternet.showDialogBox(
                        context, isDeviceConnected, isAlertSet);
                    setState(
                      () => isAlertSet = true,
                    );
                  } else {
                    CheckAndDetail cks = await Authenticate.updateProfile(
                        user.firstName!, user.lastName!, user.phoneNumber!);
                    CustomLoading.loadingtext(context, '??ang c???p nh???t th??ng tin');
                    if (cks.check == true) {
                      CustomLoading.dismisloading(context);
                      CustomToast.presentSuccessToast(
                          context, 'C???p nh???t th??ng tin th??nh c??ng!');
                      //LocalStorage.deleteUser();
                      LocalStorage.writeUser(user);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return PersonalInfomationPage();
                      }));
                    } else if (cks.check == false) {
                      CustomLoading.dismisloading(context);
                      CustomToast.presentErrorToast(context, cks.detail);
                    }
                  }
                }),
          )
        ],
      )),
    );
  }

  showAlertChooseImage(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ch???n ch???c n??ng'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Center(
                      child: TextButton(
                    onPressed: () async {
                      await pickandupdateimage(context, ImageSource.gallery);
                    },
                    child: Text(
                      'Trong m??y',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  )),
                  Center(
                      child: TextButton(
                    onPressed: () async {
                      await pickandupdateimage(context, ImageSource.camera);
                    },
                    child: Text('M??y ???nh',
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                  )),
                ],
              ),
            ),
          );
        });
  }

  Future<void> pickandupdateimage(
      BuildContext context, ImageSource imageSource) async {
    await pickImage(imageSource);
    if (image?.path != null) {
      bool checkConnection =
          await checkInternet.getConnectivity(isDeviceConnected, isAlertSet);
      if (!checkConnection) {
        checkInternet.showDialogBox(context, isDeviceConnected, isAlertSet);
        setState(
          () => isAlertSet = true,
        );
      } else {
        CheckAndDetail cks = await Authenticate.updateImage(image!);
        if (cks.check == true) {
          Navigator.of(context).pop();
          CustomToast.presentSuccessToast(context, 'C???p nh???t th??nh c??ng');
          setState(() {
            user.avatar = cks.detail;
            LocalStorage.deleteUser();
            LocalStorage.writeUser(user);
            print(user.avatar);
          });
        } else {
          CustomToast.presentErrorToast(context, '${cks.detail}');
        }
      }
    } else {
      Navigator.of(context).pop();
      CustomToast.presentWarningToast(context, 'B???n ch??a ch???n h??nh');
    }
  }
}
