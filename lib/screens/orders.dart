import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart' show Orders;
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {

  static const routeName = '/orders';

  //Versão 1 -> com future
  // @override
  // void initState() {
  //   super.initState();

  //   Future.delayed(Duration.zero).then((_) async {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  //     //Segundo o max, com listen false não precisa desta gambiarra do do future.

  //     setState(() {
  //       _isLoading = false;
  //     });

  //   });

  // }

  @override
  Widget build(BuildContext context) {
    //final ordersData = Provider.of<Orders>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                //Do error handling aqui
                return Center(child: Text('An error occurred!'));
              } else {
                return  Consumer<Orders>(builder: (ctx, orderData, child) =>  ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                ),) ;
              }
            }
          },
        ));
  }
}
