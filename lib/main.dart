import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:samata_dartachalani/constants.dart';
import 'package:samata_dartachalani/createChalani.dart';
import 'package:samata_dartachalani/createDarta.dart';
import 'package:samata_dartachalani/models/chalani.dart';
import 'package:samata_dartachalani/models/darta.dart';
import 'package:samata_dartachalani/models/user.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samata_dartachalani/tauko.dart';
import 'package:samata_dartachalani/viewAllDartaChalani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory appDocumentDir;
  if (Platform.isWindows) {
    appDocumentDir = await getApplicationDocumentsDirectory();
  } else {
    throw UnsupportedError('Unsupported platform');
  }

  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(DartaAdapter());
  Hive.registerAdapter(ChalaniAdapter());

  // Hive.registerAdapter(ChalaniAdapter());
  await Hive.openBox<Darta>('darta');
  await Hive.openBox<Chalani>('chalani');
  await Hive.openBox<User>('users');
  await Hive.openBox('settings');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final String? loggedInUser = Hive.box('settings').get('loggedInUser');
    return MaterialApp(
      title: 'Samata gharelu',
      debugShowCheckedModeBanner: false,
      home: loggedInUser != null ? HomePage() : LoginPage(),
      theme: ThemeData(
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: Color(0xff0D0D0D)),
          headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xff108841)),
          headlineSmall: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
          bodyLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
          labelLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: Color(0xffBFBABA)),
          titleMedium: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  late Box<User> userBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
  }

  void _login(String username, String password) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = userBox.values.firstWhere(
          (user) => user.username == username && user.password == password);
      if (user.username.isNotEmpty) {
        // Save the logged-in user session
        Hive.box('settings').put('loggedInUser', user.username);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username or password')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Align(
            alignment: Alignment.topCenter,
            child: Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Tauko(header: 'Darta Chalani Record',),
                    Container(
                      width: getwidth(context) / 3,
                      // height: getheight(context) * 0.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xff108841))),
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Text('Login Page',
                                      style: gettext(context).headlineSmall)),
                              SizedBox(height: getheight(context) * 0.04),
                              Text('User:', style: gettext(context).bodyLarge),
                              TextFormField(
                                cursorColor: Color(0xffBFBABA),
                                controller: usernameController,
                                decoration: InputDecoration(
                                  enabledBorder: border,
                                  focusedBorder: border,
                                  hintText: 'Enter your Username',
                                  hintStyle: gettext(context).labelLarge,
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: getheight(context) * 0.02),
                              Text('Password:',
                                  style: gettext(context).bodyLarge),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure,
                                cursorColor: Color(0xffBFBABA),
                                decoration: InputDecoration(
                                  enabledBorder: border,
                                  focusedBorder: border,
                                  hintText: 'Enter your password',
                                  hintStyle: gettext(context).labelLarge,
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: getheight(context) * 0.04),
                              GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _login(usernameController.text.trim(),
                                        passwordController.text.trim());
                                  }
                                },
                                child: Container(
                                    height: getheight(context) * 0.05,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Color(0xff108841),
                                    ),
                                    child: Center(
                                        child: Text('Login',
                                            style:
                                                gettext(context).titleMedium))),
                              ),
                              SizedBox(height: getheight(context) * 0.04),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return SignupPage();
                                    }));
                                  },
                                  child: Text('New User, Sign Up'))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}



class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late Box<User> userBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
  }

  void _register(String username, String password) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newUser = User(username: username, password: password);
      userBox.add(newUser);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Registration Successful!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Align(
            alignment: Alignment.topCenter,
            child: Expanded(
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Tauko(header: 'Darta Chalani Record',),
                    Container(
                      // height: getheight(context) * 0.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xff108841))),
                      width: getwidth(context) / 3,
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Text('SignUp Page',
                                      style: gettext(context).headlineSmall)),
                              SizedBox(height: getheight(context) * 0.02),
                              Text('User:', style: gettext(context).bodyLarge),
                              TextFormField(
                                controller: usernameController,
                                cursorColor: Color(0xffBFBABA),
                                decoration: InputDecoration(
                                  enabledBorder: border,
                                  focusedBorder: border,
                                  hintText: 'Username',
                                  hintStyle: gettext(context).labelLarge,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: getheight(context) * 0.02),
                              Text('Password:',
                                  style: gettext(context).bodyLarge),
                              TextFormField(
                                controller: passwordController,
                                obscureText: _isObscure,
                                cursorColor: Color(0xffBFBABA),
                                decoration: InputDecoration(
                                  enabledBorder: border,
                                  focusedBorder: border,
                                  hintText: 'Enter your password',
                                  hintStyle: gettext(context).labelLarge,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: getheight(context) * 0.02),
                              Text('Confirm Password:',
                                  style: gettext(context).bodyLarge),
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: _isObscure,
                                cursorColor: Color(0xffBFBABA),
                                decoration: InputDecoration(
                                  enabledBorder: border,
                                  focusedBorder: border,
                                  hintText: 'Rewrite to confirm your password',
                                  hintStyle: gettext(context).labelLarge,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  } else if (confirmPasswordController.text !=
                                      passwordController.text) {
                                    return 'Password does not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              GestureDetector(
                                onTap: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _register(usernameController.text.trim(),
                                        passwordController.text.trim());
                                  }
                                },
                                child: Container(
                                    height: getheight(context) * 0.05,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Color(0xff108841),
                                    ),
                                    child: const Center(
                                        child: Text('Signup',
                                            style: TextStyle(
                                                color: Colors.white)))),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                      'Already have an account, go to login!'))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

class HomePage extends StatelessWidget {
  void _logout(BuildContext context) {
    // Clear the logged-in user session
    Hive.box('settings').delete('loggedInUser');
    // Navigate back to the login page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: <Widget>[
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Colors.blue,
      //         ),
      //         child: Text(
      //           'Menu',
      //           style: TextStyle(
      //             color: Colors.white,
      //             fontSize: 24,
      //           ),
      //         ),
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.list),
      //         title: Text('View All Darta Chalanis'),
      //         onTap: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (context) {
      //             return ViewAllScreen();
      //           }));
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.create),
      //         title: Text('Create Darta'),
      //         onTap: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (context) {
      //             return CreateDartaScreen();
      //           }));
      //         },
      //       ),
      //       ListTile(
      //         leading: Icon(Icons.create),
      //         title: Text('Create Chalani'),
      //         onTap: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (context) {
      //             return CreateChalaniScreen();
      //           }));
      //         },
      //       ),
      //       Spacer(),
      //       ListTile(
      //         leading: Icon(Icons.logout),
      //         title: Text('Logout'),
      //         onTap: () {
      //           _logout(context);
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Tauko(header: 'Please select your choice',),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ViewAllScreen();
                }));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff108841),
                minimumSize: Size(200, 50),
              ),
              child: Text('View All Darta Chalanis',style:gettext(context).titleMedium),
            ),
            SizedBox(height: getheight(context)*0.04),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreateDartaScreen();
                }));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff108841),
                minimumSize: Size(200, 50),
              ),
              child: Text('Create Darta',style:gettext(context).titleMedium),
            ),
            SizedBox(height: getheight(context)*0.04),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return CreateChalaniScreen();
                  }),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff108841),
                minimumSize: Size(200, 50),
              ),
              child: Text('Create Chalani',style:gettext(context).titleMedium),
            ),
            SizedBox(height: getheight(context)*0.04),
             TextButton(
               child:Text('Logout',style: gettext(context).bodyLarge),
              onPressed: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
