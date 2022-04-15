
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:hospital_finance_app/main.dart';
import 'package:hospital_finance_app/models/payment.dart';
import 'package:hospital_finance_app/pages/IPD.dart';
import 'package:hospital_finance_app/pages/OPD.dart';
import 'package:hospital_finance_app/pages/login_page.dart';
import 'package:hospital_finance_app/pages/other.dart';
import 'package:hospital_finance_app/pages/transactions.dart';
import 'package:hospital_finance_app/pages/wrapper.dart';
import 'package:hospital_finance_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';

final user_mail = auth.FirebaseAuth.instance.currentUser!.email;
final CollectionReference _users = FirebaseFirestore.instance.collection('users');
final CollectionReference _payments = FirebaseFirestore.instance.collection('payments');
final paymentsQuery = FirebaseFirestore.instance.collection('payments').where('user',isEqualTo:user_mail)
  .orderBy('timestamp', descending: true).withConverter<Payment>(
     fromFirestore: (snapshot, _) => Payment.fromJson(snapshot.data()!),
     toFirestore: (payment, _) => payment.toJson(),
   );

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');
  final CollectionReference _collections = FirebaseFirestore.instance.collection('collections');
  final String? user_mail = auth.FirebaseAuth.instance.currentUser!.email;
  var cash;
  var other;
  var last_collected;
  final CollectionReference _payments = FirebaseFirestore.instance.collection('payments');
  
  Future getUserData() async {
    QuerySnapshot qn = await _users.get();
    return qn.docs;
  }
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm?', ),
          content: SingleChildScrollView(
      
              child: StreamBuilder(
            stream: _users.doc(user_mail).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
          
              var userDocument = snapshot.data;
              cash = userDocument!["cash"];
              other = userDocument["other"];
              return Column(children: [Text("Cash: Rs. "+cash.toString()), SizedBox(height: 20,), Text("Other: Rs. "+other.toString())]);
          }),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                try{
                  SnackBar message = SnackBar(content:Text("Rs. "+cash.toString()+" cash and Rs. "+other.toString()+" collected successfully!"),backgroundColor: Colors.green);

                  var newCollRef = _collections.doc();
                  var userRef = _users.doc(user_mail);
                  await FirebaseFirestore.instance.runTransaction((transaction)async {
                    transaction.set(newCollRef,{
                    'cash':cash,
                    'other':other,
                    'collected':FieldValue.serverTimestamp(),
                    'user': user_mail
                  });

                  transaction.update(userRef, {'cash':0,'other':0, 'last_collected':FieldValue.serverTimestamp()});
                  

                  }).catchError((e){
                    message = SnackBar(content:Text("Unable to reach the server. Please check your internet connection"),backgroundColor: Colors.red);
                  }).whenComplete((){
                    ScaffoldMessenger.of(context).showSnackBar(message);
                    Navigator.of(context).pop();
                  });
                  // _collections.add({
                  //   'cash':cash,
                  //   'other':other,
                  //   'collected':FieldValue.serverTimestamp(),
                  //   'user': user_mail
                  // });
                  // _users.doc(user_mail).update({'cash':0,'other':0, 'last_collected':FieldValue.serverTimestamp()});
                }on FirebaseAuthException catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()),backgroundColor: Colors.red));
                  }
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    _users.doc(user_mail).get().then((data) {
          
          setState(() {
           last_collected = data["last_collected"];
           });
          });
    
    return Material(
        child:Scaffold(
          //appBar: AppBar(title: Text("Home", style: TextStyle(color: Colors.black),),backgroundColor: Colors.white),
          body: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            //margin: EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                StreamBuilder(
                stream: _users.doc(user_mail).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
              
                  var userDocument = snapshot.data;
                  cash = userDocument!["cash"];
                  other = userDocument["other"];
                  var time = FieldValue.serverTimestamp();
                  return Column(
                    
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 30,),
                      Text("Welcome, "+userDocument["hosp_name"],style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      SizedBox(height: 30,),
                      Card(
                        
                        //margin: const EdgeInsets.all(30.0),
                        elevation: 1.0,
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                        color: Color.fromRGBO(0, 10, 74, 1),
                        
                        child: Container(
                          alignment: Alignment.centerLeft,
                          //color: Colors.blue,
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //SizedBox(height: 20,),
                              
                              const Text("Since you last collected,",style: TextStyle(fontSize: 20,color: Color.fromRGBO(125, 105, 205, 1,))),
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  const Text("Cash",style: TextStyle(fontSize: 20,color: Colors.white)),
                                  const Text("Other",style: TextStyle(fontSize: 20,color: Colors.white))
                                  ]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[
                                  Text("Rs. "+cash.toString(),style: TextStyle(fontSize: 25,color: Colors.white)),
                                  Text("Rs. "+other.toString(),style: TextStyle(fontSize: 25,color: Colors.white))
                                  ]),     
                              SizedBox(height: 20,), 
                              Center(
                                child: Column(
                                  children: [
                                    Text("Total: Rs. "+(cash+other).toString(),style: TextStyle(fontSize: 20,color: Color.fromRGBO(125, 105, 205, 1,))),
                                    SizedBox(height: 20,),
                                    ElevatedButton (child: Text("Confirm and Collect",textScaleFactor: 1.2,),
                                    onPressed: ((cash == 0&&other==0)?(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There is nothing to collect"),backgroundColor: Colors.red));}
                                    :_showMyDialog),
                                    style: TextButton.styleFrom(shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),backgroundColor: Colors.green,minimumSize: Size(150,30)),),
                                  ],
                                ),
                              ),
                              ]
                            ),
                        ),
                      ),
                      
                    ],
                  );
              }),
                Divider(
                  height: 50,
                  thickness: 2,
                ),

                
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                    Text("Add Payment",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,)),
                    SizedBox(height: 20,),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                    ClipOval(
                    child: Material(
                      color: Color.fromRGBO(0, 10, 74, 1), // Button color
                      child: InkWell(
                        //splashColor: Colors.red, // Splash color
                        onTap: ()async{
                    try{
                            if (!mounted) return;
                            setState(() {
                            });
                            Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OPD()));
                          }on FirebaseAuthException catch(e){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()),backgroundColor: Colors.red));
                          }
                    },
                        child: SizedBox(width: 56, height: 56, child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Icon(Icons.medical_services,color: Colors.white,),Text("OPD",style: TextStyle(color: Colors.white),)])),
                      ),
                    ),
                    ),
                    ClipOval(
                    child: Material(
                      color: Color.fromRGBO(0, 10, 74, 1), // Button color
                      child: InkWell(
                        //splashColor: Colors.red, // Splash color
                        onTap: ()async{
                    try{
                            if (!mounted) return;
                            setState(() {
                            });
                            Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => IPD()));
                          }on FirebaseAuthException catch(e){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()),backgroundColor: Colors.red));
                          }
                    },
                        child: SizedBox(width: 56, height: 56, child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Icon(Icons.bed,color: Colors.white,),Text("IPD",style: TextStyle(color: Colors.white),)])),
                      ),
                    ),
                    ),
                    ClipOval(
                    child: Material(
                      color: Color.fromRGBO(0, 10, 74, 1), // Button color
                      child: InkWell(
                        //splashColor: Colors.red, // Splash color
                        onTap: ()async{
                    try{
                            if (!mounted) return;
                            setState(() {
                            });
                            Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Other()));
                          }on FirebaseAuthException catch(e){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()),backgroundColor: Colors.red));
                          }
                    },
                        child: SizedBox(width: 56, height: 56, child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [Icon(Icons.settings,color: Colors.white,),Text("Other",style: TextStyle(color: Colors.white),)])),
                      ),
                    ),
                    ),
                      ]
                    ),
                  Divider(
                    height: 50,
                  thickness: 2,
                  ),
                  Text("Your Latest Transactions",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,)),
                    SizedBox(height: 10,),

                  last_collected == null? Center(
          child:Text("Unable to connect. Please check your internet connection")
        ) 
        
        
        
        :StreamBuilder<QuerySnapshot>(
          stream: paymentsQuery.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else
          {
            return ListView.builder(
              shrinkWrap: true,
              //pageSize: 5,
              //itemExtent: 5,
              itemCount: 5,
              itemBuilder: (context,index) {
               // var last_collected
               
                  final payment = snapshot.data!.docs[index];
                  var time = payment['timestamp'];
                  TextStyle style;
                  if(time != null){
                     style = TextStyle(fontWeight: (time.compareTo(last_collected)>0?FontWeight.bold:FontWeight.normal));
                  }
                    else{
                      style = TextStyle(fontWeight: FontWeight.bold);
                    }
                    return Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height/9,
                        
                        
                        decoration: BoxDecoration(
                                border: Border.symmetric(horizontal: BorderSide(color: Colors.grey)),),
                        child: ListTile(
                                  title: 
                                  Row(children: [Text("${payment['name']}", style: style,),Spacer(),Text("${payment['channel']}")
                                    , Spacer(),
                                  Text("${payment['payOrReceive'] == 'Pay'?"-":"+"}"+"${payment['amount'].toString()} ${payment['methodOfPayment']}",style: TextStyle(color: payment['payOrReceive'] == 'Pay'?Colors.red:Colors.green),
                                  ),
                                  ]),
                                  
                                  onTap: () => showModalBottomSheet(context: context,
                                   builder: (context) => Container(
                                     child:Column(
                                       children: [
                                        Text("Patient name: "+payment['name'].toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                        Text("Patient mobile: "+payment['mobile'].toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                         (payment['payOrReceive'] == 'Pay')?(Text(("Paid To") + payment['paidTo'].toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 ))):const SizedBox.shrink(),
                                        Text("Amount: ${payment['payOrReceive'] == 'Pay'?"-":"+"}"+"${payment['amount'].toString()} ${payment['methodOfPayment']}",style: TextStyle(color: payment['payOrReceive'] == 'Pay'?Colors.red:Colors.green),),
                                        Text("Method of payment: "+payment['methodOfPayment'].toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                        Text("OPD/IPD/Other: " + payment['channel'].toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                        Text("Paid at: " + (payment['timestamp']?.toDate().toString() ?? "Will be updated when you connect to the internet"), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      payment['timestamp']?.compareTo(last_collected)==1?
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
        
                                      onPressed: (){
                                        showDialog<void>(
                                          context: context,
                                          barrierDismissible: false, // user must tap button!
                                          builder: (BuildContext context){
                                        return AlertDialog(
                                              title: Text('Are you sure you want to delete this record?'),
                                              actions: <Widget>[
                                                 TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                                  TextButton(
                                                    child: Text('Confirm'),
                                                    onPressed: () {
                                                      
                                                      setState(() => {
                                         _payments.doc(payment['index']).delete(),
                                        Navigator.pop(context),
                                        Navigator.pop(context)                            
                                        });
                                        },
                                      ),
                                     
                                                              ],
                                                            );});
                                      },
                                            child: Text("Delete"),
                                            style: TextButton.styleFrom(minimumSize: const Size(100,30)),),
                                    ):const SizedBox.shrink(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                      onPressed: (){
                                            Navigator.pop(context);
                                      },
                                            child: Text("Close"),
                                            style: TextButton.styleFrom(minimumSize: Size(100,30)),),
                                    ),
                                ],
                              ),
                                       ],
                                     ),
        
        
        
                                   )),
                                  
                                ),
                      );
                    
                  
              }
            );
          }
          }
        ),
                

              
                    ElevatedButton (child: Text("Sign out"), onPressed: ()async{
                    try{
                          await authService.signOut();
                            if (!mounted) return;
                            setState(() {
                            });
                            Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => hospApp()));
                          }on FirebaseAuthException catch(e){
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()),backgroundColor: Colors.red));
                          }
                    }),
                    
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton (child: Text("See More Transactions"), 
                      style: ButtonStyle(alignment: Alignment.center,backgroundColor: MaterialStateProperty.all(Color.fromRGBO(0, 10, 74, 1))),
                      onPressed: ()async{
                      try{
                              if (!mounted) return;
                              setState(() {
                              });
                              Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Transactions()));
                            }on FirebaseAuthException catch(e){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()),backgroundColor: Colors.red));
                            }
                      }),
                    )
                ],
              ),
            ),
          ),
        ),
    );
  }
}