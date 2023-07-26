import 'dart:io';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;
final storageRef = FirebaseStorage.instance.ref();

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
 final _formKey = GlobalKey<FormState>();

 var _isLogin = false;
 var _enteredEmail = '';
 var _enteredPassword = '';
 var _enteredUsername = '';
 File? _pickedImageFile;
 var _isAuthenticating = false; 

 void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || !_isLogin && _pickedImageFile == null) { return; }

    _formKey.currentState!.save();
    
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

        final imagesRef = storageRef
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

        await imagesRef.putFile(_pickedImageFile!);
        final imageUrl = await imagesRef.getDownloadURL();
        FirebaseFirestore.instance
        .collection('users')
        .doc(userCredentials.user!.uid)
        .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'imageUrl': imageUrl
        });
        
        print(imageUrl);
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {

      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message ?? 'Auth failed')));

      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 0,
                  bottom: 20,
                  left: 20,
                  right: 20
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin) UserImagePicker(onPickImage: (image) {  
                            print(image);
                            _pickedImageFile = image;
                          },),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Address'
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator:(value) {
                              if (value == null || value.trim().isEmpty || !value.contains('@')) {
                                return 'Please enter a vlid email address';
                              }

                              return null;
                            },
                            onSaved:(value) {
                              _enteredEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Username'
                            ),
                            enableSuggestions: false,
                            validator:(value) {
                              if (value == null || value.isEmpty || value.trim().length < 4) {
                                return 'Please enter at least 4 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredUsername = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password'
                            ),
                            validator:(value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a password';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                            obscureText: true,
                            autocorrect: false,
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer
                              ), 
                              child: Text(
                                !_isLogin ? 'Signup' : 'Login', 
                                style: const TextStyle(color: Colors.white)
                              ),
                            ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            }, 
                            child: Text(_isLogin ? 'Create an account' : 'I already have an account'),
                          ),
                        ],
                      )
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}