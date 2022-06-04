import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GelenMesajlar extends StatelessWidget {
  final CollectionReference orders =
      FirebaseFirestore.instance.collection('contacts');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.white,
        child: StreamBuilder<QuerySnapshot>(
          stream: orders.snapshots(),
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
                  title: Text(document.data()['nameSurname']),
                  subtitle: Text(document.data()['messagge']),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.phone,
                      color: Colors.green,
                    ),
                    onPressed: () async {
                      final snackBar = SnackBar(
                          content: Text('Telefon Numarası Aranıyor...'));
                      _scaffoldKey.currentState.showSnackBar(snackBar);
                      await Future.delayed(Duration(milliseconds: 500));

                      launch("tel://${document.data()['number']}");
                    },
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
