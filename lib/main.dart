import 'package:flutter/material.dart';
import 'package:tabmenu/exemplos/data_table_2.dart';

import 'exemplos/paginated_data_table_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Tab view'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.title),
          bottom: TabBar(
            indicatorColor: Colors.white,
            onTap: (index) {
              setState(() {
                tabIndex = index;
              });
            },
            tabs: [
              Tab(
                icon: Icon(
                  Icons.table_chart,
                  color: tabIndex == 0 ? Colors.white : Colors.black,
                ),
                child: Text(
                  'Exemplo 1',
                  style: TextStyle(
                      color: tabIndex == 0 ? Colors.white : Colors.black),
                ),
              ),
              Tab(
                icon: Icon(Icons.table_chart,
                    color: tabIndex == 1 ? Colors.white : Colors.black),
                child: Text(
                  'Exemplo 2',
                  style: TextStyle(
                      color: tabIndex == 1 ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            DataTable2Demo(),
            PaginatedDataTableDemo(
              title: 'Exemplo 2',
            ),
          ],
        ),
      ),
    );
  }
}
