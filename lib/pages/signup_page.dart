import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hospital_finance_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({ Key? key }) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');
  TextEditingController _emailField = TextEditingController();
  TextEditingController _hospNameField = TextEditingController();
  TextEditingController _passwordField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Create a new account"),),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          //color: Colors.blueAccent
          ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              
              TextFormField(
                controller: _hospNameField,
                decoration: InputDecoration(
                  labelText: "Hospital Name",
                  hintText: "Hospital Name",
                ),
              ),
              TextFormField(
                controller: _emailField,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "something@email.com",
                ),
              ),
              TextFormField(
                controller: _passwordField,
                decoration: InputDecoration(
                  labelText: "Password",
                  
                  hintText: "password",
                  
                ),
                obscureText: true,
              ),
              SizedBox(height: 20,),
              
              ElevatedButton(
                onPressed: ()async{
                  try{
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: _emailField.text, 
                    password: _passwordField.text
                    );
                  await _users.doc(_emailField.text).set({
                        "hosp_name": _hospNameField.text.trimRight(),
                        "cash": 0,
                        "other": 0
                    });
                    if (!mounted) return;
                    setState(() {
                    });
                    }on FirebaseAuthException catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()),backgroundColor: Colors.red));
                  }
                }, 
                child: Text("Sign Up")
                )
            ],
          ),
        )
      ),
    );
  }
}