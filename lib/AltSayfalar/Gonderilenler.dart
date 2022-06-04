import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ensar_kimya/AltSayfalar/siparisDetay.dart';
import 'package:flutter/material.dart';


class Gonderilenler extends StatelessWidget {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('orders');

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: orders.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Yükleniyor");
          }
          return ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return document.data()['didSend']
                  ? ListTile(
                      title: Text(document.data()['productName']),
                      subtitle: Text(
                          "Şehir: ${document.data()['city']} -- Adet: ${document.data()['count']} "),
                      trailing: Text(
                        "Tamamlandı",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SiparisDetay(document.data()['ID'],
                                document.data()['didSend']),
                          ),
                        );
                      },
                    )
                  : Container();
            }).toList(),
          );
        },
      ),
    );
  }
}
