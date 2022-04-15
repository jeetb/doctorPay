//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_finance_app/services/auth_service.dart';
import 'package:hospital_finance_app/utils/routes.dart';
import 'package:provider/provider.dart';

enum paymentMethod { Cash, Other }

class OPD extends StatefulWidget {
  @override
  State<OPD> createState() => _OPDState();
}

class _OPDState extends State<OPD> {
  final _formkey = GlobalKey<FormState>();
  paymentMethod? _method = paymentMethod.Cash;
  FocusNode name = FocusNode();
  FocusNode mobile = FocusNode();
  FocusNode amount = FocusNode();
  TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobController = TextEditingController();
  final TextEditingController _amtController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final CollectionReference _payments = FirebaseFirestore.instance.collection('payments');
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');
  submitOPD() async{
    
        final String? user_mail = auth.FirebaseAuth.instance.currentUser!.email;
        final String? name = _nameController.text.trimRight();
        final double? mobile =double.tryParse(_mobController.text.trimRight());
        final double? amount = double.tryParse(_amtController.text.trimRight());
        final String? comments = _commentsController.text.trimRight();
        final String? methodOfPayment = _method == paymentMethod.Cash?"Cash":"Other";
        var timestamp = FieldValue.serverTimestamp();

        var transaction = await _payments.add({"user":user_mail,
        "name": name,
        "mobile": mobile,
        "amount": amount,
        "comments":comments,
        "methodOfPayment":methodOfPayment,
        "timestamp":timestamp,
        "channel":"OPD",
        "payOrReceive":"Receive",});
        if(methodOfPayment == "Cash"){
          await _users.doc(user_mail).update({
            'cash': FieldValue.increment(amount!)
            });
        }
        else{
          await _users.doc(user_mail).update({
            'other': FieldValue.increment(amount!)});
        }
        if(mounted)setState(() {});
        _nameController.clear();
        _mobController.clear();
        _amtController.clear();
        _commentsController.clear();
  }
  Future<void> _showMyDialog() async {
    if(_formkey.currentState!.validate()){
    return showDialog<void>(
      
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Please confirm the details:', ),
          content: SingleChildScrollView(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                children: <Widget>[
                  Text('Name: '+ _nameController.text.trimRight()),
                  Text('Mobile: '+ _mobController.text.trimRight()),
                  Text('Amount: '+ _amtController.text.trimRight()),
                  Text('Method of Payment: '+  (_method == paymentMethod.Cash?"Cash":"Other")),
                  Text("Comments: " + _commentsController.text.trimRight())
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                try{
                submitOPD();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Record added successfully!"),backgroundColor: Colors.green));
                Navigator.of(context).pop();
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
  }
  @override
  Widget build(BuildContext context) {
        final authService = Provider.of<AuthService>(context);
        return Material(
          child: Scaffold(
            appBar: AppBar(title: Text("OPD: Add payment"),backgroundColor: Colors.blue),
            body: SingleChildScrollView(
              child: Form(
                key: _formkey,
                child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal:16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                        TextFormField(
                          focusNode: name,
                          validator: (String? value){
                          if(value!.isEmpty)
                          {
                            name.requestFocus();
                            return "Name cannot be empty";
                          }
                          if(value.split(" ").length < 3)
                          {
                            name.requestFocus();
                            return "Enter name in this format: <First Name> <Middle Name> <Last Name>";
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Name",
                          hintText: "Name",
                        ),
                        controller: _nameController,
                      ),
                      TextFormField(
                        focusNode: mobile,
                        validator: (String? value){
                        if(value!.isEmpty)
                          {
                            mobile.requestFocus();
                            return "Mobile Number cannot be empty";
                          }
                        },
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          hintText: "Mobile number", 
                          labelText: "Mobile Number"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        controller: _mobController,
                        
                      ),
                      TextFormField(
                        focusNode: amount,
                        validator: (String? value){
                        if(value!.isEmpty)
                          {
                            amount.requestFocus();
                            return "Amount cannot be empty";
                          }
                        },
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Amount",
                          hintText: "Amount"),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                        controller: _amtController,
                        
                      ),
                      SizedBox(height: 20,),
                      Container(
                        child: Text("Mode of Payment", style: TextStyle(fontSize: 16, color: Colors.black54, fontFamily: "OpenSans", fontWeight: FontWeight.w400 ), textAlign: TextAlign.left),alignment: Alignment.centerLeft,),
                      SizedBox(height: 20,),
                      Container(
                        //margin:EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                    children: <Widget>[

                        Flexible(
                          child: ListTile(
                            title: const Text('Cash'),
                            leading: Radio<paymentMethod>(
                              value: paymentMethod.Cash,
                              groupValue: _method,
                              onChanged: (paymentMethod? value) {
                                setState(() {
                                  _method = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            title: const Text('Other'),
                            leading: Radio<paymentMethod>(
                              value: paymentMethod.Other,
                              groupValue: _method,
                              onChanged: (paymentMethod? value) {
                                setState(() {
                                  _method = value;
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                      ),
                       
                  TextFormField(
                    controller: _commentsController,
                    decoration: InputDecoration(alignLabelWithHint: true,labelText: "Comments/Notes",hintText: "Comments/Notes"),
                  ),
                    //margin: EdgeInsets.only(bottom: 4),
                   SizedBox(height: 20,),
                    Row(
                      mainAxisAlignment : MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: _showMyDialog,
                            child: Text("Submit"),
                            style: TextButton.styleFrom(minimumSize: Size(100,30)),),
                        ElevatedButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                            child: Text("Cancel"),
                            style: TextButton.styleFrom(minimumSize: Size(100,30)),),
                      ],
                    ),
                  
                  ]
              ),
                )
                    ),
            ),
          ));
  }
}