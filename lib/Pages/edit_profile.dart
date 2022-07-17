import 'dart:convert';

import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/driverprofile.dart';

import 'package:flutter/material.dart';
import 'package:driver/Components/custom_button.dart';
import 'package:driver/Components/entry_field.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late DriverProfilePeople profilePeople;
  var http = Client();
  bool isLoading = false;
  TextEditingController nameC = TextEditingController();
  TextEditingController genderC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDrierStatus();
  }

  void getDrierStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    http.post(driverProfileUri, body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      print('dvd - ${value.body}');
      if (value.statusCode == 200) {
        DriverProfilePeople dstatus = DriverProfilePeople.fromJson(jsonDecode(value.body));
        if ('${dstatus.status}' == '1') {
          setState(() {
            profilePeople = dstatus;
            nameC.text = '${profilePeople.driverData!.boyName}';
            phoneC.text = '${profilePeople.driverData!.boyPhone}';
            emailC.text = '${profilePeople.driverData!.password}';
            prefs.setString('boy_name', '${nameC.text}');
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return Scaffold(
      drawer: AccountDrawer(),
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: Text(locale.myAccount!.toUpperCase()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Divider(
                thickness: 8,
                color: Theme.of(context).dividerColor,
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 14),
                child: Text(
                  locale.profileInfo!,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ),
              EntryField(
                label: locale.fullName!.toUpperCase(),
                labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.w500,
                labelFontSize: 16,
                controller: nameC,
              ),
              EntryField(
                label: locale.phoneNumber!.toUpperCase(),
                labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.w500,
                labelFontSize: 16,
                controller: phoneC,
              ),
              EntryField(
                label: locale.password1!.toUpperCase(),
                labelColor: Theme.of(context).disabledColor,
                labelFontWeight: FontWeight.w500,
                labelFontSize: 16,
                controller: emailC,
              ),
              SizedBox(height: 80),
            ],
          ),
          Align(
              alignment: AlignmentDirectional.bottomCenter,
              child: isLoading
                  ? Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: Align(
                        heightFactor: 40,
                        widthFactor: 40,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : CustomButton(
                      label: locale.updateInfo,
                      onTap: () {
                        if (!isLoading) {
                          if (nameC.text.length > 0) {
                            if (nameC.text.length > 0) {
                              if (nameC.text.length > 0) {
                                setState(() {
                                  isLoading = true;
                                });
                                updateYourProfile(context);
                              } else {
                                ToastContext().init(context);
                                Toast.show(locale.pleaseallfield!, duration: Toast.lengthShort, gravity: Toast.center);
                              }
                            } else {
                              ToastContext().init(context);
                              Toast.show(locale.pleaseallfield!, duration: Toast.lengthShort, gravity: Toast.center);
                            }
                          } else {
                            ToastContext().init(context);
                            Toast.show(locale.pleaseallfield!, duration: Toast.lengthShort, gravity: Toast.center);
                          }
                        }
                      },
                    )),
        ],
      ),
    );
  }

  void updateYourProfile(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.post(driverupdateprofileUri, body: {
      'dboy_id': '${prefs.getInt('db_id')}',
      'boy_name': '${nameC.text}',
      'boy_phone': '${phoneC.text}',
      'password': '${emailC.text}',
    }).then((value) {
      print('dv - ${value.body}');
      var js = jsonDecode(value.body);
      if ('${js['status']}' == '1') {
        prefs.setString('boy_name', '${nameC.text}');
        prefs.setString('boy_phone', '${phoneC.text}');
        prefs.setString('password', '${emailC.text}');
      }
      ToastContext().init(context);
      Toast.show(js['message'], duration: Toast.lengthShort, gravity: Toast.center);
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      print(e);
    });
  }
}
