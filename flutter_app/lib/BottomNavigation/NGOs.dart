import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/AddNgo.dart';
import 'package:flutter_app/BottomNavigation/NgoPerson.dart';
import 'package:flutter_app/konstants/loaders.dart';
import 'package:intl/intl.dart';

class NGOs extends StatefulWidget {
  String city;

  NGOs({this.city});

  @override
  _NGOsState createState() => _NGOsState();
}

class _NGOsState extends State<NGOs> {
  bool ngo = false;
  bool load = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference ngoCol = FirebaseFirestore.instance.collection('NGO');
  CollectionReference donCol =
      FirebaseFirestore.instance.collection('donation');
  CollectionReference hungSpot =
  FirebaseFirestore.instance.collection('hungerspot');
  List list;
  String dropVal;
  Map<String,List> completedDonationList=Map();
  List activeDonationList=List();
  List hungerList;
  Map<String,List>cities;
  DateTime _dateTime=DateTime.now().add(Duration(days: 5));

  BuildContext _context;




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkNgo();
  }

  String returnDateFrom(String dateTime){
    print(DateFormat.MMMMd().format(DateFormat.yMMMEd().add_jm().parse(dateTime)));
    return DateFormat.MMMMd().format(DateFormat.yMMMEd().add_jm().parse(dateTime));
  }



  getDonationList() async {
    await donCol.get().then((value) {
      List list=value.docs;
      print(list.length);
      for(int i=0;i<list.length;i++){
        if(list[i]['completed']==true&&list[i]['ngoUID']==FirebaseAuth.instance.currentUser.uid&&isBefore(list[i]['dateTime'])&&completedDonationList.containsKey(returnDateFrom(list[i]['dateTime']))){
          completedDonationList[returnDateFrom(list[i]['dateTime'])].add(list[i]);
        }else if(list[i]['completed']==true&&list[i]['ngoUID']==FirebaseAuth.instance.currentUser.uid&&isBefore(list[i]['dateTime'])){
          completedDonationList[returnDateFrom(list[i]['dateTime'])]=List();
          completedDonationList[returnDateFrom(list[i]['dateTime'])].add(list[i]);
        }else if((list[i]['completed']==false)){
          activeDonationList.add(list[i]);
        }
    }});
    print('hell');
  }

   getHungerSpots()async{
     await hungSpot.get().then((value) {
       setState(() {
         hungerList = value.docs;
         load = false;
       });
     });
  }

  bool isBefore(String date){
    return DateFormat.yMMMEd().add_jm().parse(date).isBefore(_dateTime);
  }

  checkNgo() async {
    User user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot ds = await ngoCol.doc(user.uid).get();
    ngo = ds.exists;
    print(ngo);
    if (!ngo) {
      list = List();
      await ngoCol.get().then((value) {
        list = value.docs;
        cities=Map();
        cities[widget.city]=List();
        print(widget.city);
        dropVal=widget.city;
        for(int i=0;i<list.length;i++){
          if(list[i]==null)continue;
          if(cities.containsKey(list[i]['city'])){
            cities[list[i]['city']].add(list[i]);
          }else{
            cities[list[i]['city']]=List();
            cities[list[i]['city']].add(list[i]);
          }
        }
        // value.docs.forEach((element) {
        //   list.add(element);
        // });
        final snackBar = SnackBar(content: Text('No NGO registered yet'),action: SnackBarAction(
          label: 'Register here',
          onPressed: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => AddNGO()));
          },
        ),);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          load=false;
        });

      });
    } else {
      await getDonationList();
      await getHungerSpots();
    }
    print(list);
  }

  final planetThumbnail = new Container(
    padding: EdgeInsets.symmetric(vertical: 16.0),
    alignment: FractionalOffset.centerLeft,
    child: CircleAvatar(
      backgroundImage: AssetImage("images/ngoCharity2.png"),
      radius: 45,
    ),
  );



  @override
  Widget build(BuildContext context) {


    return load == true
        ? spinkit
        : ngo
            ? NgoPerson(completeDonation: completedDonationList,hungerspot: hungerList,activeDonation: activeDonationList,)
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: DropdownButtonFormField<String>(items: cities.keys.toList().map((String e){
                      return DropdownMenuItem<String>(child: Text(e, style: TextStyle(
                                              fontFamily: 'MontserratMed',
                                              color: Colors.black,
                                            ),),value: e,);
                    }).toList(), value: dropVal,onChanged: (val){
                      setState(() {
                        dropVal=val;
                      });
                    }, ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int pos) {
                      return Container(
                          margin: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 16.0,
                            left: 24.0,
                            right: 24.0,
                          ),
                          child: new Stack(
                            children: <Widget>[
                              Container(
                                height: 130.0,
                                margin: new EdgeInsets.only(left: 46.0),
                                decoration: new BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFFFF512F).withOpacity(0.5),
                                        Color(0xffFFE000).withOpacity(0.5),
                                      ]),
                                  // color: new Color(0xFF333366),
                                  shape: BoxShape.rectangle,
                                  borderRadius: new BorderRadius.circular(8.0),
                                  boxShadow: <BoxShadow>[
                                    new BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10.0,
                                      offset: new Offset(0.0, 10.0),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin:
                                      EdgeInsets.only(left: 50.0, right: 10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cities[dropVal][pos]['name'].toString(),
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white,
                                            fontFamily: 'MontserratBold'),
                                      ),
                                      Text(
                                        "Address:- ${ cities[dropVal][pos]['address'].toString()}",
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Color(0xfff0f8ff),
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.people,
                                                color: Color(0xff041E42),
                                                size: 20.0,
                                              ),
                                              Text(
                                                " ${ cities[dropVal][pos]['capacity'].toString()}",
                                                style: TextStyle(
                                                    fontSize: 13.0,
                                                    color: Colors.white,
                                                    fontFamily:
                                                        'MontserratMed'),
                                              ),
                                            ],
                                          ),
                                          // Row(
                                          //
                                          //   children: [
                                          //     Icon(
                                          //       Icons.location,
                                          //       color: Color(0xff041E42),
                                          //       size: 20.0,
                                          //     ),
                                          //     Text(
                                          //       " ${list[pos]['capacity'].toString()}",
                                          //       style: TextStyle(
                                          //           fontSize: 13.0,
                                          //           color: Colors.white,
                                          //           fontFamily: 'MontserratMed'),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.call,
                                            color: Color(0xff041E42),
                                            size: 20.0,
                                          ),
                                          Text(
                                            " ${ cities[dropVal][pos]['phone'].toString()}",
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                color: Colors.white,
                                                fontFamily: 'MontserratMed'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              planetThumbnail,
                            ],
                          ));

                      //   ListTile(
                      //   title: Text(list[pos]['name'].toString()),
                      //   subtitle: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //           "Address:- ${list[pos]['address'].toString()}"),
                      //       Text(
                      //           "Capacity:- ${list[pos]['capacity'].toString()}"),
                      //       Text("Phone:- ${list[pos]['phone'].toString()}"),
                      //     ],
                      //   ),
                      // );
                    },
                    itemCount: cities[dropVal].length,
                    shrinkWrap: true,
                  ),
                ],
              );
  }
}
