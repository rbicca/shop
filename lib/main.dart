import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/auth-screen.dart';
import 'package:shop/screens/products_overview.dart';
import 'package:shop/screens/splash_screen.dart';
import 'providers/auth.dart';

import 'package:shop/screens/cart.dart';
import 'package:shop/screens/edit_product.dart';
import 'package:shop/screens/orders.dart';
import 'package:shop/screens/produc_detail.dart';
import 'package:shop/screens/user_products.dart';

import './providers/products.dart';
import './providers/cart.dart';
import 'package:shop/providers/orders.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth(),),
        ChangeNotifierProxyProvider<Auth, Products>(initialBuilder: (_) => Products(), builder: (ctx, auth, previousProduct) { 
            previousProduct..authToken = auth.token; 
            previousProduct..userId = auth.userId;
            return previousProduct;
          } ),
        ChangeNotifierProvider.value(value: Cart(), ),
        ChangeNotifierProxyProvider<Auth, Orders>(initialBuilder: (_) => Orders(),   builder: (ctx, auth, previousOrders) {
           previousOrders..authToken = auth.token;
           previousOrders..userId = auth.userId;
           return previousOrders;
         } ),
      ],
      child:  Consumer<Auth>(builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home:  auth.isAuth 
            ? ProductsOverviewScreen() 
            : FutureBuilder(
                future: auth.tryAutoLogin(),
                builder: (ctx, authResultSnap ) => 
                    authResultSnap.connectionState == ConnectionState.waiting ? SplashScreen() : AuthScreen()
              ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ) ,
    );
  }
}
