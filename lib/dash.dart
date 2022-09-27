import 'package:flutter/material.dart';
import 'calendar.dart';

class dash extends StatefulWidget {
  dash({Key? key}) : super(key: key);

  @override
  State<dash> createState() => _dashState();
}

class _dashState extends State<dash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Color.fromARGB(225, 38, 39, 39),
        appBar: AppBar(toolbarHeight: 23,backgroundColor: Colors.black,),
        body: Center(
      child: Container(
        width: 400,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/Portrait.png"), fit: BoxFit.cover)),
        child: Column(
          children: <Widget>
          [
            const SizedBox(
              height: 45,
            ),
            
            Image.asset(
              'assets/nav_icon.ico',
              fit: BoxFit.fitWidth,
            ),
            
            const SizedBox(
              height: 35,
            ),
            
            Image.asset('assets/calendar.png'),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 100,vertical: 20)
                ),
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>calendar()),
                  );
                },
                child: const Text("Get started here..",style:TextStyle(fontSize: 18,fontFamily:'Raleway'))),
            

          ],
        ),
      ),
    ));
  }
}
