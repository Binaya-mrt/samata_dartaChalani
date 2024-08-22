import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:samata_dartachalani/createChalani.dart';
import 'package:samata_dartachalani/createDarta.dart';
import 'package:samata_dartachalani/models/chalani.dart';
import 'package:samata_dartachalani/models/darta.dart';
import 'package:samata_dartachalani/models/user.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:path_provider/path_provider.dart';
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
          backgroundColor: Colors.green[300],
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(
              'Samata Gharelu Microfinance Darta Chalani Portal',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 250,
                    width: 300,
                    color: Colors.white,
                    child: Text('Logo here'),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
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
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _login(usernameController.text.trim(),
                                    passwordController.text.trim());
                              }
                            },
                            child: const Text('Login'),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return SignupPage();
                                }));
                              },
                              child: Text('New User, SignUp'))
                        ],
                      ),
                    ),
                  ),
                ],
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
          backgroundColor: Colors.green[300],
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(
              'Samata Gharelu Microfinance Darta Chalani Portal',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 250,
                    width: 300,
                    color: Colors.white,
                    child: Text('Logo here'),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
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
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              labelText: 'Password',
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
                              } else if (confirmPasswordController.text !=
                                  passwordController.text) {
                                return 'Password does not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _register(usernameController.text.trim(),
                                    passwordController.text.trim());
                              }
                            },
                            child: const Text('Signup'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
      appBar: AppBar(
        title: Text('Darta & Chalani Management'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('View All Darta Chalanis'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ViewAllScreen();
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Create Darta'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreateDartaScreen();
                }));
              },
            ),
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Create Chalani'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CreateChalaniScreen();
                }));
              },
            ),
            Spacer(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ViewAllScreen();
                  }));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                ),
                child: Text('View All Darta Chalanis'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CreateDartaScreen();
                  }));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                ),
                child: Text('Create Darta'),
              ),
              SizedBox(height: 20),
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
                  minimumSize: Size(200, 50),
                ),
                child: Text('Create Chalani'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
