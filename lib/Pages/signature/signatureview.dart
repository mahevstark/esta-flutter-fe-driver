import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Routes/routes.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:toast/toast.dart';
//import 'package:http_parser/http_parser.dart';

class SignatureView extends StatefulWidget {
  @override
  SignatureViewState createState() => SignatureViewState();
}

class SignatureViewState extends State<SignatureView> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.red,
    exportBackgroundColor: kWhiteColor,
  );

  OrderHistory? orderDetails;
  bool enterFirst = false;
  bool isLoading = false;
  dynamic apCurency;
  dynamic distance;
  dynamic time;

  @override
  void initState() {
    super.initState();
    getSharedValue();
    _controller.addListener(() => print("Value changed"));
  }

  void getSharedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurency = prefs.getString('app_currency');
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  String calculateTime(lat1, lon1, lat2, lon2) {
    double kms = calculateDistance(lat1, lon1, lat2, lon2);
    double kmsPerMin = 0.5;
    double minsTaken = kms / kmsPerMin;
    double min = minsTaken;
    if (min < 60) {
      return "" + '${min.toInt()}' + " mins";
    } else {
      double tt = min % 60;
      String minutes = '${tt.toInt()}';
      minutes = minutes.length == 1 ? "0" + minutes : minutes;
      return '${(min.toInt() / 60).toStringAsFixed(2)}' + " hour " + minutes + " mins";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    final Map<String, Object>? dataObject = ModalRoute.of(context)!.settings.arguments as Map<String, Object>?;
    if (!enterFirst) {
      setState(() {
        enterFirst = true;
        orderDetails = dataObject!['OrderDetail'] as OrderHistory?;
        distance = calculateDistance(double.parse('${orderDetails!.userLat}'), double.parse('${orderDetails!.userLng}'), double.parse('${orderDetails!.storeLat}'), double.parse('${orderDetails!.storeLng}')).toStringAsFixed(2);
        time = calculateTime(double.parse('${orderDetails!.userLat}'), double.parse('${orderDetails!.userLng}'), double.parse('${orderDetails!.storeLat}'), double.parse('${orderDetails!.storeLng}'));
        print('$distance');
        print('$time');
      });
    }

    return Scaffold(
      backgroundColor: kCardBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: kWhiteColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${locale.order} - #${orderDetails!.cartId}',
                    // 'Order',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w500, color: kMainTextColor, fontSize: 12)),
                SizedBox(
                  height: 5,
                ),
                Text('${locale.order} ${locale.invoice3h} - $apCurency ${orderDetails!.remainingPrice!.toStringAsFixed(2)}',
                    // 'Order',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w300, color: kMainTextColor, fontSize: 13)),
              ],
            ),
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: ElevatedButton(
                  style: ButtonStyle(
                    shadowColor: MaterialStateProperty.all(kMainColor),
                    overlayColor: MaterialStateProperty.all(kMainColor),
                    backgroundColor: MaterialStateProperty.all(kMainColor),
                    foregroundColor: MaterialStateProperty.all(kMainColor),
                  ),
                  onPressed: () {
                    setState(() => _controller.clear());
                  },
                  child: Text(
                    locale.clearview!,
                    style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.w400),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 10.0,
            left: 10.0,
            right: 10.0,
            bottom: 10.0,
            child: Signature(
              controller: _controller,
              width: MediaQuery.of(context).size.width - 20,
              height: MediaQuery.of(context).size.height - 70,
              backgroundColor: kWhiteColor,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Text('Sign/Signature Here'),
          ),
          Positioned(
              bottom: 10.0,
              width: MediaQuery.of(context).size.width,
              child: isLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width - 100,
                      height: 52,
                      alignment: Alignment.center,
                      child: Align(
                        heightFactor: 40,
                        widthFactor: 40,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          if (!isLoading) {
                            setState(() {
                              isLoading = true;
                            });
                            uploadSignature(context, locale);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Card(
                          elevation: 5,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 100,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: kMainColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              locale.markAsDelivered!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: kWhiteColor, fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ))
        ],
      ),
    );
  }

  void uploadSignature(context, AppLocalizations locale) async {
    Uint8List? data = await _controller.toPngBytes();

    final directory = await getApplicationDocumentsDirectory();

    if(data != null) {
      File _image = await File('${directory.path}/image.png').writeAsBytes(data);

      print(_image.path);
      var dio = Dio();
      var formData = FormData.fromMap(
        {
          'cart_id': '${orderDetails!.cartId}',
          'user_signature': await MultipartFile.fromFile(_image.path),
        },
      );

      await dio
          .post(deliveryCompletedUri.toString(),
          data: formData,
          options: Options(
            // headers: await global.getApiHeaders(false),
          ))
          .then((response) {
        print(response.data);
        if ('${response.data['status']}' == '1') {
          Navigator.pushNamed(context, PageRoutes.orderDeliveredPage, arguments: {
            'OrderDetail': orderDetails,
            'dis': distance,
            'time': time,
          }).then((value) {});
        }
        ToastContext().init(context);
        Toast.show(response.data['message'], gravity: Toast.center, duration: Toast.lengthShort);

        setState(() {
          isLoading = false;
        });
      }).catchError((e) {
        print(e.toString());
      });
    } else {
      print('Unable to get user signature image. Function uploadSignature line 216');
    }
  }
}
