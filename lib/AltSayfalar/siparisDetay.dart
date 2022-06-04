import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../renkler.dart';

class SiparisDetay extends StatelessWidget {
  final String documentId;
  final bool didSend;
  SiparisDetay(this.documentId, this.didSend);
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    orders.doc(documentId).update({"isShowed": true});
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: mainColor,
          centerTitle: true,
          title: Text(
            "Sipariş Detayı",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButton: !didSend
            ? FloatingActionButton.extended(
                onPressed: () async {
                  orders.doc(documentId).update({"didSend": true});
                  final snackBar =
                      SnackBar(content: Text('Sipariş Gönderilenlere Eklendi'));

                  _scaffoldKey.currentState.showSnackBar(snackBar);
                  await Future.delayed(Duration(milliseconds: 500));
                  Navigator.pop(context);
                },
                label: Text("Siparişi Gönderildi Olarak İşaretle",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                backgroundColor: mainColor,
              )
            : null,
        body: FutureBuilder<DocumentSnapshot>(
          future: orders.doc(documentId).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data = snapshot.data.data();
              return ListView(
                children: [
                  ListTile(
                    title: Text("İsim Soyisim"),
                    subtitle: Text(data["nameSurname"]),
                  ),
                  ListTile(
                    title: Text("Ürün Adı"),
                    subtitle: Text(data["productName"]),
                  ),
                  ListTile(
                    title: Text("Adet"),
                    subtitle: Text(data["count"].toString()),
                  ),
                  ListTile(
                    title: Text("E post"),
                    subtitle: Text(data["eMail"]),
                    trailing: IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data["eMail"]));
                        final snackBar =
                            SnackBar(content: Text('E posta Adres Kopyalandı'));
                        _scaffoldKey.currentState.showSnackBar(snackBar);
                      },
                    ),
                  ),
                  ListTile(
                    title: Text("Telefon Numarası"),
                    subtitle: Text(data["phoneNumber"]),
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: data["phoneNumber"]));
                      final snackBar = SnackBar(
                          content: Text('Telefon Numarası Kopyalandı'));
                      _scaffoldKey.currentState.showSnackBar(snackBar);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.call),
                      onPressed: () => launch("tel://${data["phoneNumber"]}"),
                    ),
                  ),
                  ListTile(
                    title: Text("Şehir"),
                    subtitle: Text(data["city"]),
                  ),
                  ListTile(
                    title: Text("İlçe"),
                    subtitle: Text(data["district"]),
                  ),
                  ListTile(
                    title: Text("Açık Adres"),
                    subtitle: Text(data["address"]),
                  ),
                ],
              );
            }
            return Text("Yükleiyor");
          },
        ),
      ),
    );
  }
}
