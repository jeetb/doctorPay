import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:hospital_finance_app/pages/signup_page.dart';
import 'package:hospital_finance_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final CollectionReference _cash = FirebaseFirestore.instance.collection('cash_to_collect');

  TextEditingController _emailField = TextEditingController();
  TextEditingController _passwordField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Login to your cashier account"),),
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
                controller: _emailField,
                decoration: InputDecoration(
                  labelText: "Email",
                  hintText: "something@email.com",
                ),
                inputFormatters: [
                FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))
              ],
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
              Row(
                mainAxisAlignment : MainAxisAlignment.spaceAround,
                children:[
              ElevatedButton(
                onPressed: ()async{
                  try{
                  await authService.signInWithEmailAndPassword(
                    _emailField.text,  _passwordField.text
                    );
                    if (!mounted) return;
                    setState(() {
                    });
                  }on FirebaseAuthException catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message.toString()),backgroundColor: Colors.red));
                  }
                }, 
                child: Text("Login")
                ),
              
              ElevatedButton(
                onPressed: (){
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                  );
                }, 
                child: Text("Sign Up")
                ),
              ],
              )
            ],
          ),
        )
      ),
    );
  }
}