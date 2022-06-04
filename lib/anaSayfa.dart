import 'package:ensar_kimya/renkler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'AltSayfalar/gelen_mesajlar.dart';
import 'AltSayfalar/Urunler.dart';

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "ensar@kimya.com", password: "com.kimya@ensar");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: mainColor,
            title: Text(
              "Ensar Kimya",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            bottom: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              labelStyle: TextStyle(fontSize: 20),
              unselectedLabelColor: Colors.white,
              unselectedLabelStyle: TextStyle(fontSize: 14),
              tabs: [
                Tab(
                  child: Text(
                    "Gelen Mesajlar",
                    textAlign: TextAlign.center,
                  ),
                ),
                // Tab(
                //   child: Text(
                //     "Gönderilen\nÜrünler",
                //     textAlign: TextAlign.center,
                //   ),
                // ),
                Tab(
                  text: "Ürünler",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              GelenMesajlar(),
              // Gonderilenler(),
              Urunler(),
            ],
          ),
        ),
      ),
    );
  }
}
