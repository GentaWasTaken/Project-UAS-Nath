import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Actionbuttonscreen(),
    );
  }
}
class Actionbuttonscreen extends StatefulWidget {
  const Actionbuttonscreen({super.key});

  @override
  State<Actionbuttonscreen> createState() => _ActionbuttonscreenState();
}
class _ActionbuttonscreenState extends State<Actionbuttonscreen> {
  //TODO: 1. Tempat pasang variabel
  String actionLabel = 'Belum ada aksi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Interaction')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  actionLabel = 'Pengguna melakukan Tap';
                });
              },
              onDoubleTap: () {
                setState(() {
                  actionLabel = 'Pengguna melakukan Tap';
                });
              },
              onLongPress: () {
                setState(() {
                  actionLabel = 'Pengguna melakukan Tap';
                });
              },
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(25) ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Aksi',
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
