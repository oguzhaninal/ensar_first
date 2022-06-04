import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensar_kimya/AltSayfalar/urunEkle.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../renkler.dart';

class Urunler extends StatefulWidget {
  @override
  _UrunlerState createState() => _UrunlerState();
}

class _UrunlerState extends State<Urunler> {
  CollectionReference products =
      FirebaseFirestore.instance.collection('products');
  sil(String yol, String id) {
    FirebaseStorage.instance.getReferenceFromUrl(yol).then((res) {
      res.delete().then((res) {
        print("Deleted!");
      });
    });

    FirebaseFirestore.instance.collection("products").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UrunEkle(),
            ),
          );
        },
        label: Text("Ürün  Ekle"),
        icon: Icon(
          Icons.add,
        ),
        backgroundColor: mainColor,
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder<QuerySnapshot>(
          stream: products.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Yükleniyor");
            }

            return ListView(
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                return ListTile(
                  leading: Image.network(document.data()['imgUrl']),
                  title: Text(document.data()['name']),
                  subtitle: Text(document.data()['description']),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                    ),
                    onPressed: () =>
                        sil(document.data()['imgUrl'], document.data()['ID']),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
