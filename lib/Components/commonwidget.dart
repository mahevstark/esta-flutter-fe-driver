import 'package:driver/Routes/routes.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildCircularButton(BuildContext context,IconData icon, String text,{
  List<ItemsDetails>? details,
  String? url,
  int type = 0,
}) {
  return GestureDetector(
    onTap: (){
      if(type ==1){
        Navigator.pushNamed(context, PageRoutes.iteminfo,arguments: {
          'details':details
        });
      }else if(type == 2){
        _getDirection(url);
      }
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12,vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 8,vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor,
        border: Border.all(width: 0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(icon,size: 18,color: Color (0xFF39c526),),
          ),
          Text(text,style: TextStyle(color: Color (0xFF39c526),),
          ),
        ],
      ),
    ),
  );
}



_getDirection(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}