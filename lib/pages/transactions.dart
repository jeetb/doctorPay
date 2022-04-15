
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hospital_finance_app/models/payment.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutterfire_ui/firestore.dart';
import 'package:firebase_core/firebase_core.dart';

final user_mail = auth.FirebaseAuth.instance.currentUser!.email;
final CollectionReference _users = FirebaseFirestore.instance.collection('users');
final CollectionReference _payments = FirebaseFirestore.instance.collection('payments');
final paymentsQuery = FirebaseFirestore.instance.collection('payments').where('user',isEqualTo:user_mail)
  .orderBy('timestamp', descending: true).withConverter<Payment>(
     fromFirestore: (snapshot, _) => Payment.fromJson(snapshot.data()!),
     toFirestore: (payment, _) => payment.toJson(),
   );

  // .withConverter<Payment>(
  //    fromFirestore: (snapshot, _) => Payment.fromJson(snapshot.data()!),
  //    toFirestore: (payment, _) => payment.toJson(),
  //  );

class Transactions extends StatefulWidget {
  const Transactions({ Key? key }) : super(key: key);

  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  var last_collected;
  @override

  Widget build(BuildContext context) {
    
    _users.doc(user_mail).get().then((data) {
          
          setState(() {
           last_collected = data["last_collected"];
           });
          });
    return (
      Scaffold(appBar:AppBar(title:Text("Transactions"),),
      body: last_collected == null? Center(
        child:Text("Unable to connect. Please check your internet connection")
      ) 
      
      
      
      :FirestoreListView<Payment>(
        
        //pageSize: 7,
        query: paymentsQuery,
        
        itemBuilder: (context,snapshot) {
          
         // var last_collected
          final payment = snapshot.data();
          var time = payment.timestamp;
          TextStyle style;
          if(time != null){
             style = TextStyle(fontWeight: (time.compareTo(last_collected)>0?FontWeight.bold:FontWeight.normal));
          }
            else{
              style = TextStyle(fontWeight: FontWeight.bold);
            }
            return Container(
                alignment: Alignment.center,
                height: MediaQuery. of(context).size.height/9,
                
                decoration: BoxDecoration(
                          border: Border.symmetric(horizontal: BorderSide(color: Colors.grey)),),
                child: ListTile(
                          title: 
                          Row(children: [Text("${payment.name}", style: style,),Spacer(),Text("${payment.channel}")
                            , Spacer(),
                          Text("${payment.payOrReceive == 'Pay'?"-":"+"}"+"${payment.amount.toString()} ${payment.methodOfPayment}",style: TextStyle(color: payment.payOrReceive == 'Pay'?Colors.red:Colors.green),
                          ),
                          ]),
                          onTap: () => showModalBottomSheet(context: context,
                           builder: (context) => Container(
                             child:Column(
                               children: [
                                Text("Patient name: "+payment.name.toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                Text("Patient mobile: "+payment.mobile.toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                (payment.paidTo != null)?(Text(("Paid To") + payment.paidTo.toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 ))):const SizedBox.shrink(),
                                Text("Amount: ${payment.payOrReceive == 'Pay'?"-":"+"}"+"${payment.amount.toString()} ${payment.methodOfPayment}",style: TextStyle(color: payment.payOrReceive == 'Pay'?Colors.red:Colors.green),),
                                Text("Method of payment: "+payment.methodOfPayment.toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                Text("OPD/IPD/Other: " + payment.channel.toString(), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                Text("Paid at: " + (payment.timestamp?.toDate().toString() ?? "Will be updated when you connect to the internet"), style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 )),
                                 Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              payment.timestamp?.compareTo(last_collected)==1?
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
                                 _payments.doc(snapshot.id).delete(),
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
      ),
    )
    
    );
  }
}
