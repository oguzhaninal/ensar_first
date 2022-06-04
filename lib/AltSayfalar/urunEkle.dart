import 'dart:io';
import 'package:image/image.dart' as ImD;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../renkler.dart';

class UrunEkle extends StatefulWidget {
  @override
  _UrunEkleState createState() => _UrunEkleState();
}

class _UrunEkleState extends State<UrunEkle> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String dsc;
  String imgUrlG;
  String name;
  double price;
  double weight;
  File yuklenecekDosya;
  bool resimYukleniyor = false;
  resimiTelefonaYukle(ImageSource imageSource) async {
    try {
      var alinanDosya = await ImagePicker().getImage(
        source: imageSource,
      );
      setState(() {
        yuklenecekDosya = File(alinanDosya.path);
      });
      Navigator.pop(context);
    } catch (e) {
      print("Hata");
      resimYukleniyor = false;
      Navigator.pop(context);
      final snackBar = SnackBar(content: Text('Resim Yüklenemedi'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  Future<void> resmiSunucuyaYukle() async {
    try {
      setState(() {
        resimYukleniyor = true;
      });
      StorageReference referansYol = FirebaseStorage.instance
          .ref()
          .child("resimler")
          .child("${DateTime.now()}.png");

      StorageUploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
      String url = await (await yuklemeGorevi.onComplete).ref.getDownloadURL();
      setState(() {
        imgUrlG = url;
        resimYukleniyor = false;
      });
    } catch (e) {
      print("Hata");
      resimYukleniyor = false;
      final snackBar = SnackBar(content: Text('Resim Yüklenemedi'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  dbyeUrunEkle(
    String dsc,
    String imgUrl,
    String name,
    double price,
    double weight,
  ) {
    String id = FirebaseFirestore.instance.collection("products").doc().id;
    FirebaseFirestore.instance.collection("products").doc(id).set({
      "description": dsc,
      "imgUrl": imgUrl,
      "name": name,
      "price": price,
      "weight": weight,
      "ID": id
    });
  }

  _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: resimYukleniyor
                ? ListTile(
                    leading: CircularProgressIndicator(),
                    title: Text("Resim Yükleniyor Lütfen Bekleyin"),
                  )
                : Wrap(
                    children: [
                      ListTile(
                          leading: Icon(Icons.camera),
                          title: Text('Fotoğrafını Çek'),
                          onTap: () => {
                                resimiTelefonaYukle(ImageSource.camera),
                              }),
                      ListTile(
                        leading: Icon(Icons.image),
                        title: Text('Galeriden Seç'),
                        onTap: () => {
                          resimiTelefonaYukle(ImageSource.gallery),
                        },
                      ),
                    ],
                  ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: mainColor,
          title: Text(
            "Ürün Detaylarını Giriniz",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (yuklenecekDosya != null) {
              if (_formKey.currentState.validate()) {
                resmiSunucuyaYukle().whenComplete(() {
                  _formKey.currentState.save();
                  if (imgUrlG != null) {
                    dbyeUrunEkle(dsc, imgUrlG, name, price, weight);
                    print("içerde");
                    Navigator.pop(context);
                  }
                });
              }
            } else {
              final snackBar =
                  SnackBar(content: Text('Lütfen Resim Yükleyiniz'));
              _scaffoldKey.currentState.showSnackBar(snackBar);
            }
          },
          label: Text("Yüklemeyi Tamamla"),
          icon: Icon(Icons.add),
          backgroundColor: mainColor,
        ),
        body: Container(
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _settingModalBottomSheet(context),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          size.width * 0.05, size.width * 0.03, 0, 0),
                      child: Container(
                        height: size.height * 0.2,
                        width: size.width * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 2,
                              offset: Offset(0, 2),
                              color: Colors.grey,
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: yuklenecekDosya == null
                            ? Icon(Icons.add_a_photo)
                            : Image.file(yuklenecekDosya),
                      ),
                    ),
                  ),
                  Container(
                    height: size.height * 0.2,
                    width: size.width * 0.6,
                    child: Center(
                        child: Text(
                            "Listelemek İstediğiniz ürünün fotoğrafını ekleyin")),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(size.width * 0.05,
                      size.width * 0.05, size.width * 0.05, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //ürün adı giriş yeri
                      TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return "Lütfen Ürün adını giriniz";
                          }
                        },
                        onSaved: (input) {
                          name = input;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          fillColor: Color(0xFFEEEEF3),
                          filled: true,
                          labelText: "Ürün Adı*",
                          hintText: "Ürünün adını giriniz ...",
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      //ürün açıklama giriş yeri
                      TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return "Lütfen ürün için bir açıklama giriniz";
                          }
                        },
                        onSaved: (input) {
                          dsc = input;
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          fillColor: Color(0xFFEEEEF3),
                          filled: true,
                          labelText: "Ürün Açıklaması*",
                          alignLabelWithHint: true,
                          hintText: "Ürüne dair açıklama yazınız ...",
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),

                      // urun gün/fiyat giriş yeri
                      TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return "Lütfen Ürünüz için fiyat belirtiniz";
                          }
                          if (num.tryParse(input) == null) {
                            return "Lütfen sadece sayı giriniz";
                          }
                        },
                        keyboardType: TextInputType.number,
                        onSaved: (input) {
                          price = double.parse(input);
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          fillColor: Color(0xFFEEEEF3),
                          filled: true,
                          suffix: Text(
                            "₺",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          labelText: "Ürünün Fiyatı*",
                          hintText: "Ürünün fiyatını belirtiniz ...",
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),

                      // kaç gün
                      TextFormField(
                        validator: (input) {
                          if (input.isEmpty) {
                            return "Lütfen Ürün için ağırlık belirtiniz";
                          }
                          if (num.tryParse(input) == null) {
                            return "Lütfen sadece sayı giriniz";
                          }
                        },
                        keyboardType: TextInputType.number,
                        onSaved: (input) {
                          weight = double.parse(input);
                        },
                        decoration: InputDecoration(
                          suffix: Text(
                            "Kg",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          fillColor: Color(0xFFEEEEF3),
                          filled: true,
                          labelText: "Ürünün Ağırlığı",
                          hintText: "Ürünün ağırlığını giriniz",
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                      resimYukleniyor
                          ? ListTile(
                              title: Text("Veriler Yükleniyor..."),
                              trailing: CircularProgressIndicator(),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
