import 'package:driver/Locale/locales.dart';
import 'package:driver/Theme/colors.dart';
import 'package:driver/beanmodel/orderhistory.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemInformation extends StatefulWidget{
  @override
  ItemInformationState createState() {
    return ItemInformationState();
  }
  
}

class ItemInformationState extends State<ItemInformation>{

  List<ItemsDetails>? orderDetails =[];

  var apCurrency;

  bool enterfirst = true;

  @override
  void initState() {
    super.initState();
    getSharedValue();
  }

  void getSharedValue() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apCurrency = prefs.getString('app_currency');
    });

  }
  
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    Map<String, dynamic>? receivedData = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if(enterfirst){
      setState(() {
        enterfirst = false;
        orderDetails = receivedData!['details'];
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(locale.itemInfo!,style: TextStyle(
          color: kMainTextColor
        ),),
      ),
      body: (orderDetails!=null && orderDetails!.length>0)?ListView.separated(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              clipBehavior: Clip.hardEdge,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: EdgeInsets.all(5),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                              '${orderDetails![index].varientImage}',
                              fit: BoxFit.cover)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${orderDetails![index].productName} (${orderDetails![index].quantity} ${orderDetails![index].unit})',
                              style: TextStyle(
                                fontSize: 16,
                                color: kWhiteColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${locale.invoice2h} - ${orderDetails![index].qty}',
                              style: TextStyle(
                                fontSize: 13,
                                color: kWhiteColor,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${locale.invoice3h} - $apCurrency ${double.parse((orderDetails![index].price! / orderDetails![index].qty).toString()).round()}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kWhiteColor,
                                  ),
                                ),
                                Text(
                                  '${locale.invoice4h} ${locale.invoice3h} - $apCurrency ${orderDetails![index].price}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kWhiteColor,
                                  ),
                                ),
                              ],
                            )
                          ],
                        )),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, indext) {
            return Divider(
              thickness: 0.1,
              color: Colors.transparent,
            );
          },
          itemCount: orderDetails!.length):SizedBox.shrink(),
    );
  }
  
}