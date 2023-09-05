import 'package:flutter/material.dart';
import 'package:funds_minder/Login/auth.dart';
import 'package:funds_minder/Premium/home_premium.dart';
import 'package:provider/provider.dart';

enum AuthMode { signup, login, forgot }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Funds Minder')),
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (!isDarkMode)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                    : Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.5),
                (!isDarkMode)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
                    : const Color.fromARGB(255, 74, 71, 71),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0, 1],
            ),
          ),
        ),
        SizedBox(
          height: deviceSize.height,
          width: deviceSize.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    padding: deviceSize.height > 600
                        ? const EdgeInsets.symmetric(
                            vertical: 40.0, horizontal: 50.0)
                        : const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 200.0),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        gradient: LinearGradient(colors: [
                          (isDarkMode)
                              ? const Color.fromARGB(255, 70, 69, 89)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                          (isDarkMode)
                              ? const Color.fromARGB(255, 70, 69, 89)
                                  .withOpacity(0.3)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3)
                        ])),
                    child: const Text(
                      'Premiere Login',
                      style: TextStyle(
                          fontSize: 30,
                          fontFamily: "Advent-Lt1",
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
              ),
              Flexible(
                flex: deviceSize.width > 600 ? 2 : 1,
                child: const AuthCard(),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  bool _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _showErrorDialogue(String errorMessage) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("An error occured!"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Okay"))
              ],
            ));
  }

  Future<void> _submit() async {
    String? message;
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final provider = Provider.of<Auth>(context, listen: false);
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        message = await provider.signInWithFAuth(
            _authData['email'].toString(), _authData['password'].toString());
      } else {
        if (_authMode == AuthMode.forgot) {
          await provider.resetPassword(email: _authData['email'].toString());
        } else {
          message = await provider.signUpWithFAuth(
              _authData['email'].toString(), _authData['password'].toString());
        }
      }
      FocusScope.of(context).unfocus();
      final didAuth = await provider.isLoggedIn();
      if (message != null) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (_authMode != AuthMode.forgot && didAuth) {
          Navigator.of(context).pushReplacementNamed(HomePremium.homeRoute);
        }
      });
    } on Exception catch (error) {
      var message = "Authentication failed!";
      if (error.toString().contains("EMAIL_EXISTS")) {
        message = "This email address is already in use";
      } else if (error.toString().contains("INVALID_EMAIL")) {
        message = "This is not a valid email address";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        message = "This password is too weak.";
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        message = "Could not find a user with that email";
      } else if (error.toString().contains("INVALID_PASSWORD")) {
        message = "Invalid password";
      }
      _showErrorDialogue(message + error.toString());
    } catch (_) {
      const message = "Could not authenticate! Pls try again later!";
      _showErrorDialogue(message);
    }
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _switchAuthMode() {
    if (_authMode != AuthMode.signup) {
      setState(() {
        _authMode = AuthMode.signup;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _animationController.reverse();
    }
  }

  void _switchForgotAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.forgot;
      });
      _animationController.reverse();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    _animationController.forward();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
        height: _authMode == AuthMode.signup ? 320 : 300,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.signup ? 320 : 300),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value.toString();
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: _authMode != AuthMode.forgot ? 60 : 0,
                      maxHeight: _authMode != AuthMode.forgot ? 150 : 0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _offsetAnimation,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration:
                            const InputDecoration(labelText: "Password"),
                        obscureText: true,
                        controller: _passwordController,
                        enabled: _authMode != AuthMode.forgot,
                        validator: (_authMode != AuthMode.forgot)
                            ? (value) {
                                if (value!.isEmpty || value.length < 5) {
                                  return 'Password is too short!';
                                }
                                return null;
                              }
                            : null,
                        onSaved: (newValue) =>
                            _authData['password'] = newValue.toString(),
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.signup ? 150 : 0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _offsetAnimation,
                      child: TextFormField(
                        style: Theme.of(context).textTheme.bodyMedium,
                        enabled: _authMode == AuthMode.signup,
                        decoration: const InputDecoration(
                            labelText: "Confirm Password"),
                        obscureText: true,
                        validator: _authMode == AuthMode.signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: (!_isLoading) ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8.0),
                    ),
                    child: Text(_authMode == AuthMode.signup
                        ? 'SIGNUP'
                        : (_authMode == AuthMode.login)
                            ? 'LOGIN'
                            : (!_isLoading)
                                ? 'SEND EMAIL'
                                : 'EMAIL SENT'),
                  ),
                TextButton(
                  onPressed: (!_isLoading) ? _switchAuthMode : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                      '${(_authMode != AuthMode.signup) ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                ),
                if (AuthMode.signup != _authMode)
                  TextButton(
                      onPressed: (!_isLoading) ? _switchForgotAuthMode : null,
                      child: const Text("forgot password"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
