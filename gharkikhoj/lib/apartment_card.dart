import 'package:flutter/material.dart';
import 'package:gharkikhoj/models/apartments.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApartmentCard extends StatefulWidget {
  final Apartments apartment;

  ApartmentCard({required this.apartment});

  @override
  _ApartmentCardState createState() => _ApartmentCardState();
}

class _ApartmentCardState extends State<ApartmentCard> {
  late bool _isApplied;

  @override
  void initState() {
    super.initState();
    _isApplied = widget.apartment.applied ?? false;
  }

  Future<void> _toggleApplied() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from("apartments")
        .update({"applied": !_isApplied})
        .eq('address', widget.apartment.address)
        .select();
    if (response.isEmpty) {
      throw Exception('Failed to fetch apartments: $response');
    }

    setState(() {
      _isApplied = !_isApplied;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.apartment.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(widget.apartment.address),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("City: ${widget.apartment.city}"),
                Text("Built: ${widget.apartment.builtYear}"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Floor Area: ${widget.apartment.floorArea} sq.ft"),
                Text("Rooms: ${widget.apartment.rooms}"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Furnished: ${widget.apartment.furnished}"),
                Text("Price: \$${widget.apartment.price}"),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  fixedSize: Size(width, 20.0),
                  backgroundColor: _isApplied ? Colors.green : Colors.red,
                  disabledBackgroundColor: Colors.grey),
              onPressed: _toggleApplied,
              child: Text(
                _isApplied ? "Applied" : "Not Applied",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
