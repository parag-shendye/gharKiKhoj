import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gharkikhoj/apartment_card.dart';
import 'package:gharkikhoj/config.dart';
import 'package:gharkikhoj/models/apartments.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  GlobalConfiguration().loadFromMap(configs);
  await Supabase.initialize(
      url: GlobalConfiguration().get("URI"),
      anonKey: GlobalConfiguration().get("API_KEY"));

  runApp(MyApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff219ebc)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ghar Ki Khoj'),
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
  List<Apartments> apartments = [];
  late Future<List<Apartments>> _apartmentsFuture;
  // ignore: unused_element
  Future<List<Apartments>> _fetchApartments() async {
    final response = await supabase.from('apartments').select();
    if (response.isEmpty) {
      throw Exception('Failed to fetch apartments: $response');
    }

    final List<Apartments> apartments = [];
    for (final row in response) {
      final apt = Apartments(
          title: row['title'] as String,
          address: row['address'] as String,
          floorArea: row['floor_area'],
          rooms: row['rooms'],
          furnished: row['furnished'] ?? '',
          price: row['price'],
          city: row['city'] as String,
          builtYear: row['built_year'] ?? -1);
      apartments.add(apt);
    }
    return apartments;
  }

  @override
  void initState() {
    super.initState();
    _apartmentsFuture = _fetchApartments();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Center(
              child: _createTitle(context, "assets/images/house_icon.png")),
        ),
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Expanded(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    scrollDirection:
                        Axis.vertical, // Scroll horizontally if needed
                    child: FutureBuilder<List<Apartments>>(
                      future: _apartmentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          final List<Apartments> apartments = snapshot.data!;
                          return SingleChildScrollView(
                              child:
                                  // <Widget>[
                                  //   Row(children: <Widget>[
                                  Expanded(
                            child: SizedBox(
                              height: height,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: apartments.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return ApartmentCard(
                                    apartment: apartments[index],
                                  );
                                },
                              ),
                            ),
                          )
                              // ]
                              );
                          // ],
                          // );
                        }
                      },
                    ) // This trailing comma makes auto-formatting nicer for build methods.
                    ))));
  }

  Widget _createTitle(BuildContext context, String image_path) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image_path,
            width: 50,
            height: 50,
          ),
          SizedBox(
            width: 20,
          ),
          Text(widget.title)
        ],
      ),
    );
  }
}
