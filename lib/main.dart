import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:samata_dartachalani/constants.dart';
import 'package:samata_dartachalani/createChalani.dart';
import 'package:samata_dartachalani/createDarta.dart';
import 'package:samata_dartachalani/exportimportJson.dart';

import 'package:samata_dartachalani/models/chalani.dart';
import 'package:samata_dartachalani/models/darta.dart';
import 'package:samata_dartachalani/models/user.dart';
import 'package:samata_dartachalani/tauko.dart';
import 'package:samata_dartachalani/viewAllDartaChalani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Directory appDocumentDir;
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  if (selectedDirectory == null) {
    // User canceled the picker
    return;
  }

  Hive.init(selectedDirectory);
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(DartaAdapter());
  Hive.registerAdapter(ChalaniAdapter());

  await Hive.openBox('settings');
  await Hive.openBox<Darta>('darta');
  await Hive.openBox<Chalani>('chalani');
  await Hive.openBox<User>('users');
  runApp(const MyApp());
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
      home: loggedInUser != null ? const HomePage() : const LoginPage(),
      theme: ThemeData(
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xff0D0D0D)),
          headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xff108841)),
          headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xff108841)),
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
          (user) => user.username == username && user.password == password,
          orElse: () =>
              User(username: '', password: '')); // Handle no match case
      if (user.username.isNotEmpty) {
        Hive.box('settings').put('loggedInUser', user.username);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid username or password')));
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
          child: Column(
            children: [
              const Tauko(
                header: 'Login',
              ),
              Container(
                width: getwidth(context) / 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xff108841)),
                ),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child:
                              Text('', style: gettext(context).headlineSmall),
                        ),
                        SizedBox(height: getheight(context) * 0.04),
                        Text('User:', style: gettext(context).bodyLarge),
                        TextFormField(
                          cursorColor: const Color(0xffBFBABA),
                          controller: usernameController,
                          decoration: InputDecoration(
                            enabledBorder: border,
                            focusedBorder: border,
                            hintText: 'Enter your Username',
                            hintStyle: gettext(context).labelLarge,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: getheight(context) * 0.02),
                        Text('Password:', style: gettext(context).bodyLarge),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _isObscure,
                          cursorColor: const Color(0xffBFBABA),
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
                            if (_formKey.currentState?.validate() ?? false) {
                              _login(usernameController.text.trim(),
                                  passwordController.text.trim());
                            }
                          },
                          child: Container(
                            height: getheight(context) * 0.05,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xff108841),
                            ),
                            child: Center(
                              child: Text('Login',
                                  style: gettext(context).titleMedium),
                            ),
                          ),
                        ),
                        SizedBox(height: getheight(context) * 0.04),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const SignupPage();
                            }));
                          },
                          child: const Text('New User, Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Successful!')));
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Tauko(
                  header: '',
                ),
                Container(
                  width: getwidth(context) / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff108841)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text('SignUp Page',
                                style: gettext(context).headlineSmall),
                          ),
                          SizedBox(height: getheight(context) * 0.02),
                          Text('User:', style: gettext(context).bodyLarge),
                          TextFormField(
                            controller: usernameController,
                            cursorColor: const Color(0xffBFBABA),
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
                          Text('Password:', style: gettext(context).bodyLarge),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _isObscure,
                            cursorColor: const Color(0xffBFBABA),
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
                            cursorColor: const Color(0xffBFBABA),
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
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: getheight(context) * 0.04),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _register(usernameController.text.trim(),
                                    passwordController.text.trim());
                              }
                            },
                            child: Container(
                              height: getheight(context) * 0.05,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xff108841),
                              ),
                              child: Center(
                                child: Text('Sign Up',
                                    style: gettext(context).titleMedium),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Already Registered?, Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) {
    try {
      // Clear the logged-in user session
      Hive.box('settings').delete('loggedInUser');
      print('User session cleared.');

      // Navigate back to the login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      print('Navigation to LoginPage successful.');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: getheight(context) * 0.04),
            const Tauko(
              header: 'Darta-Chalani Portal',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const CreateDartaScreen();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                    // make it sqaure

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    backgroundColor: const Color(0xff108841),
                    minimumSize: const Size(200, 50),
                  ),
                  child: Text('Darta', style: gettext(context).titleMedium),
                ),
                SizedBox(width: getwidth(context) * 0.04),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return const CreateChalaniScreen();
                      }),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    backgroundColor: const Color(0xff108841),
                    minimumSize: const Size(200, 50),
                  ),
                  child: Text('Chalani', style: gettext(context).titleMedium),
                ),
                SizedBox(width: getwidth(context) * 0.04),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const ViewAllScreen();
                    }));
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    backgroundColor: const Color(0xff108841),
                    minimumSize: const Size(200, 50),
                  ),
                  child:
                      Text('View Reports', style: gettext(context).titleMedium),
                ),
              ],
            ),
            SizedBox(height: getheight(context) * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await HiveExportImport.exportData(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                    backgroundColor: const Color(0xff108841),
                    minimumSize: const Size(200, 50),
                  ),
                  child: Text('Export', style: gettext(context).titleMedium),
                ),
                SizedBox(width: getwidth(context) * 0.04),
                ElevatedButton(
                  onPressed: () {
                    HiveExportImport.importData(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff108841),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  child: Text('Import', style: gettext(context).titleMedium),
                ),
                SizedBox(width: getwidth(context) * 0.04),
                // const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  child: const Text('Logout',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18)),
                  onPressed: () {
                    _logout(context);
                  },
                ),
              ],
            ),
            Spacer(),
            Text(
              '2024 © Samata',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: getheight(context) * 0.04),
            SizedBox(height: getheight(context) * 0.04),
          ],
        ),
      ),
    );
  }
}
