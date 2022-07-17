import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/Locale/locales.dart';
import 'package:driver/Pages/drawer.dart';
import 'package:driver/baseurl/baseurlg.dart';
import 'package:driver/beanmodel/notification.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NotificationListPage extends StatefulWidget with WidgetsBindingObserver {
  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  var http = Client();

  bool isLoading = false;
  dynamic apCurrency;

  String storeImage = '';
  List<NotificationData> notificationList = [];

  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() async {
    getNotification();
  }

  @override
  void dispose() {
    http.close();
    super.dispose();
  }

  void getNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    http.post(driverNotificationUri, body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      if (value.statusCode == 200) {
        NotificationModel notification = NotificationModel.fromJson(jsonDecode(value.body));
        if ('${notification.status}' == '1') {
          setState(() {
            notificationList.clear();
            notificationList = List.from(notification.data);
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

  void deleteNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    http.post(driverDeleteAllNotificationUri, body: {'dboy_id': '${prefs.getInt('db_id')}'}).then((value) {
      if (value.statusCode == 200) {
        NotificationModel notification = NotificationModel.fromJson(jsonDecode(value.body));
        if ('${notification.status}' == '1') {
          setState(() {
            notificationList.clear();
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

  Future _removeAllNotificationConfirmationDIalog() async {
    try {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(
                'Delete all notification',
              ),
              contentTextStyle: Theme.of(context).primaryTextTheme.bodyText1,
              content: Text('Are you sure you want to delete all notifications'),
              actions: [
                TextButton(
                  child: Text('No'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text(
                    'Yes',
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    deleteNotification();
                  },
                )
              ],
            );
          });
    } catch (e) {
      print("Exception - event_detail.dart- _removeAllNotificationConfirmationDIalog():" + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: AccountDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          foregroundColor: Colors.black,
          title: Text(
            locale.notifications!,
            style: TextStyle(
              color: Theme.of(context).backgroundColor,
            ),
          ),
          centerTitle: true,
          actions: [
            notificationList.length > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: IconButton(
                        onPressed: () async {
                          await _removeAllNotificationConfirmationDIalog();
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).primaryColor,
                        )),
                  )
                : SizedBox()
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: (!isLoading)
                ? notificationList.length > 0
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 0),
                        shrinkWrap: true,
                        itemCount: notificationList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => ChatInfo(
                              //               chatId: _stores[index].chatId,
                              //               name: _stores[index].name,
                              //               storeId: _stores[index].storeId,
                              //               userFcmToken: _stores[index].userFcmToken,
                              //               userId: _stores[index].userId,
                              //             )));
                            },
                            child: buildNotificationListCard(
                              context,
                              notificationList[index],
                            ),
                          );
                        })
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                          child: Text('No Notifications'),
                        ),
                      )
                : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 0),
                    shrinkWrap: true,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return buildNotificationSHCard();
                    }),
          ),
        ],
      ),
    );
  }

  Widget buildOrderSHCard() {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey[400]!,
              blurRadius: 0.0, // soften the shadow
              spreadRadius: 0.5, //extend the shadow
            ),
          ],
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.grey[300],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              VerticalDivider(
                color: Colors.grey[400],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.grey[300],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.grey[300],
                  ),
                ],
              ),
              VerticalDivider(
                color: Colors.grey[400],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.grey[300],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 10,
                    width: 60,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotificationListCard(BuildContext context, NotificationData notificationData) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.all(0),
          childrenPadding: EdgeInsets.all(0),
          title: Row(
            children: [
              Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: notificationData.image != null
                      ? CachedNetworkImage(
                          width: 60,
                          height: 230,
                          imageUrl: imagebaseUrl + '${notificationData.image}',
                          fit: BoxFit.fill,
                          placeholder: (context, url) => Align(
                            widthFactor: 50,
                            heightFactor: 50,
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.all(5.0),
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/icon.png',
                            fit: BoxFit.fill,
                          ),
                        )
                      : Container(
                          child: Icon(
                          Icons.person,
                          color: Theme.of(context).textTheme.subtitle2!.color,
                        ))),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  notificationData.notTitle!,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 08, right: 08),
              child: Text(
                '${notificationData.notMessage}',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildNotificationSHCard() {
    return Shimmer(
      duration: Duration(seconds: 3),
      color: Colors.white,
      enabled: true,
      direction: ShimmerDirection.fromLTRB(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 70,
                      width: 70,
                      color: Colors.grey[300],
                    )),
                SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 10,
                      width: 60,
                      color: Colors.grey[300],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 10,
                      width: 60,
                      color: Colors.grey[300],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 10,
                      width: 60,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
