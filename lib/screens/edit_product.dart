import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/models/product.dart';
import 'package:shop/providers/products.dart';


class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  var _isInit = true;
  var _isLoading = false;

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController =
      TextEditingController(); //Queremos, neste campo, obter o valor antes do form ser submetido
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  
  var _editedProduct = Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  @override
  void initState() {
    super.initState();

    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //Treta para pegar os parametros da rota
    //Esse código não funciona de maneira decente no initState
    if(_isInit){
      final productId = ModalRoute.of(context).settings.arguments as String;
      if(productId != null){
        _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
                        'title': _editedProduct.title,
                        'description': _editedProduct.description,
                        'price': _editedProduct.price.toString(),
                      };
        _imageUrlController.text = _editedProduct.imageUrl;   //Aqui é separado pois usa controller. Não pode atribuir initialValue direto
      }
    }

    _isInit = false;

  }

  @override
  void dispose() {
    super.dispose();

    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
  }

  void _updateImageUrl(){

    //Tem que validar a imagem aqui mas estou com preguiça

    if(_imageUrlFocusNode.hasFocus){
      setState(() {
        //Aqui não faz nada. Apenas caqueio para forçar o build do widget
      });
    }
  }

  void _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) { return; }
    
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if(_editedProduct.id != null){
      await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      await Provider.of<Products>(context, listen: false)
      .addProduct(_editedProduct)
      .catchError((error){
         showDialog(context: context, builder: (ctx) => AlertDialog(
          title: Text('An error occured!'),
          content: Text(error.toString()),
          actions: <Widget>[
            FlatButton(child: Text('OK'), onPressed: (){ Navigator.of(ctx).pop(); },)
          ],
        ));
      })
      .then((_){
        //Atenção. then depois de catch error sempre executa.
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: (){
            _saveForm();
          }, )
        ],
      ),
      body:  _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (value){
                  _editedProduct = Product(
                    title: value,
                    price: _editedProduct.price,
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite
                  );
                },
                validator: (value){
                  if(value.isEmpty){
                    return 'Please provide a value.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (value){
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: double.parse(value),
                    description: _editedProduct.description,
                    imageUrl: _editedProduct.imageUrl,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite

                  );
                },
                validator: (value){
                  if(value.isEmpty) { return 'Please enter a price'; }

                  if(double.tryParse(value) == null) { return 'Please enter a valid number'; }

                  if(double.parse(value) <=0) { return 'The price must be greater than zero.'; }

                  return null;
                },
              ),
              TextFormField(
                initialValue: _initValues['description'],
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (value){
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    description: value,
                    imageUrl: _editedProduct.imageUrl,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite

                  );
                },
                validator: (value){
                  if(value.isEmpty){ return 'Please enter a description'; }

                  if(value.length < 10){ return 'Should be at least 10 characteres long'; }

                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey)),
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter a URL')
                        : FittedBox(
                            child: Image.network(_imageUrlController.text),
                            fit: BoxFit.cover,
                          ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) => _saveForm(),
                      onSaved: (value){
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imageUrl: value,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite

                          );
                        },
                        validator: (value){
                          if (value.isEmpty) { return 'Please enter a image URL.'; }

                          if(!value.startsWith('http') && !value.startsWith('https')) { return 'Please entar a valid URL.'; }

                          //if(!value.endsWith('.png') && !value.endsWith('.jpg') && !value.endsWith('.jpeg') ) { return 'Please entar a valid URL.'; }

                          return null;
                        },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
