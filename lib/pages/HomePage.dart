// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:license_plate_detect/core/models/PlateInfo.dart';
import 'package:license_plate_detect/core/models/Token.dart';
import 'package:license_plate_detect/core/models/User.dart';
import 'package:license_plate_detect/core/theme/app_color.dart';
import 'package:license_plate_detect/feature/login/presention/LoginPage.dart';
import 'package:license_plate_detect/feature/personalinfomation/presention/PersonalInfomationPage.dart';
import 'package:license_plate_detect/feature/settings/presention/SettingsPage.dart';
import 'package:license_plate_detect/services/api/app_api.dart';
import 'package:license_plate_detect/services/auth/auth.dart';
import '../core/component/build_button.dart';
import '../services/localstorage/localStorage.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

bool loading = true;
Token tokenLocal = new Token();
User userLocal = new User();

File? image;

Image img = Image.asset("assets/0000_02187_b.jpg");


class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;
  
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

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return PersonalInfomationPage();
      }));
    }

    if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return SettingsPage();
      }));
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    tokenLocal = LocalStorage.getToken();
    userLocal = LocalStorage.getUser();
    print('accesstoken: ' + tokenLocal.accessToken!.toString());
    print('tokentype: ' + tokenLocal.tokenType!.toString());
    print('id: ' + userLocal.sId.toString());
    print('email: ' + userLocal.email.toString());
    print('username: ' + userLocal.username.toString());
    print('phone number: ' + userLocal.phoneNumber.toString());
    print('firstname: ' + userLocal.firstName.toString());
    print('lastname: ' + userLocal.lastName.toString());
    print('avatar: ' + userLocal.avatar.toString());
    print(_selectedIndex);
    super.initState();

    // //LocalStorage.writeToken(widget.token.accessToken, widget.token.tokenType);

    // print(LocalStorage.checkToken());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Thông tin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: AppColor.primaryColor,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 20,
            ),
            image != null
                ? Image.file(
                    image!,
                    height: 250,
                    width: 250,
                    fit: BoxFit.fill,
                  )
                : SizedBox(
                    height: 20,
                    child: Icon(
                      Icons.warning,
                      size: 40,
                    ),
                  ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                buildButton(
                    title: 'Pick Gallery',
                    icon: Icons.image_outlined,
                    onClicked: () => pickImage(ImageSource.gallery)),
                SizedBox(
                  height: 24,
                ),
                buildButton(
                    title: 'Pick Camera',
                    icon: Icons.camera_alt_outlined,
                    onClicked: () => pickImage(ImageSource.camera)),
                SizedBox(
                  height: 24,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                height: 20,
                child: Text(
                  'Danh sách biển số xe: ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            image != null
                ? FutureBuilder(
                    future: AppAPI.Upload(image!),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasData) {
                        List<PlateInfo> plates = snapshot.data;
                        print(plates);
                        return Expanded(
                          //height: 100,
                          child: ListView.builder(
                              itemCount: plates.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Card(
                                    color: Colors.grey[400],
                                    child: ListTile(
                                        title: Text(
                                      plates[index].plate!,
                                      style: TextStyle(color: Colors.black),
                                    )));
                              }),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Co loi xay ra!',
                            style:
                                TextStyle(color: Colors.black, fontSize: 24));
                      }
                      return Container();
                    },
                  )
                : SizedBox(
                    height: 30,
                    child: Text(
                      'Khong co du lieu',
                      style: TextStyle(color: Colors.black, fontSize: 24),
                    ),
                  ),
            // ElevatedButton(
            //     onPressed: () {
            //       Authenticate.logout();
            //       Navigator.push(context, MaterialPageRoute(builder: (context) {
            //         return LoginPage();
            //       }));
            //     },
            //     style: ButtonStyle(
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //             RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(10)))),
            //     child: Text('Log out')),
          ],
        ),
      ),
    );
  }
}
