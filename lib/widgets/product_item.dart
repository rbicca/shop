import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/screens/produc_detail.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // const ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () => product.toogleFavoriteStatus(authData.token),
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Item added to cart'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(label: 'Undo',onPressed: (){
                  cart.removeSingleItem(product.id);
                },),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
