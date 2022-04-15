import 'package:hospital_finance_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hospital_finance_app/pages/OPD.dart';
import 'package:hospital_finance_app/pages/home_screen.dart';
import 'package:hospital_finance_app/pages/login_page.dart';
import 'package:hospital_finance_app/services/auth_service.dart';
import 'package:provider/provider.dart';
class Wrapper extends StatelessWidget {
  const Wrapper({ Key? key }) : super(key: key);

  @override
  
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (_,AsyncSnapshot<User?> snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          final User? user = snapshot.data;
          return user == null? LoginScreen():HomePage(); 
        }
        else{
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      }
      
    );
  }
}