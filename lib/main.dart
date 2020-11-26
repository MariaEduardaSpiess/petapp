import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'models/vacina_model.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.dark),
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Deu ruim 1 | ' + snapshot.error);
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return MyApp();
          }
          return Text('Deu ruim 2');
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final CupertinoTabController _controller = CupertinoTabController(initialIndex: 1);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.drop),
            label: 'Próximas vacinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Calendário',
          ),
        ],
      ),
      controller: _controller,
      tabBuilder: (context, i) {
        return CupertinoTabView(builder: (context) {
          return CupertinoPageScaffold(
            child: HomePage(),
          );
        });
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vacinas').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          List<QueryDocumentSnapshot> data = snapshot.data.docs;
          List<VacinaModel> vacinas = new List<VacinaModel>();
          data.forEach((item) => vacinas.add(VacinaModel.fromJson(item.data())));
          return _getHomeWidget(vacinas);
        }
        return Text('Deu ruim 3');
      },
    );
  }

  Widget _getHomeWidget(List<VacinaModel> vacinas) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(50, 130, 0, 50),
          child: Text('Próximas vacinas', textAlign: TextAlign.left, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200)),
        ),
        ListView.separated(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: const EdgeInsets.all(50),
          itemCount: vacinas.length,
          itemBuilder: (BuildContext context, int index) {
            VacinaModel vacina = vacinas.elementAt(index);
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    direction: Axis.vertical,
                    spacing: 10,
                    children: [
                      Text(
                        vacina.nome,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text('Dose: ' + vacina.dose.toString() + ' de ' + vacina.totalDoses.toString()),
                    ],
                  ),
                  Text(vacina.data, textAlign: TextAlign.right),
                ],
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) => const Divider(thickness: 1, height: 80, color: Colors.white),
        ),
      ],
    );
  }
}
