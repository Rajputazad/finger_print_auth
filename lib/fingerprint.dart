// ignore_for_file: unused_field, avoid_print, unused_element
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class FingerprintAuth extends StatefulWidget {
  const FingerprintAuth({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FingerprintAuthState createState() => _FingerprintAuthState();
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class _FingerprintAuthState extends State<FingerprintAuth> {
  final auth = LocalAuthentication();
  String authorized = " not authorized";
  bool _canCheckBiometric = false;
  late List<BiometricType> _availableBiometric = [];
  bool authenticated = false;

  Future<void> _authenticate() async {
    try {
      print(_availableBiometric);
      authenticated = await auth.authenticate(
          localizedReason: "Scan your finger to authenticate",
          options: const AuthenticationOptions(biometricOnly: false),
          authMessages: const <AuthMessages>[
            AndroidAuthMessages(
              signInTitle: 'Oops! Biometric authentication required!',
              cancelButton: 'No thanks',
            ),
            IOSAuthMessages(
              cancelButton: 'No thanks',
            ),
          ]);
    } on PlatformException catch (e) {
      SystemNavigator.pop();
      print(e);
    }

    setState(() {
      authorized =
          authenticated ? "Authorized success" : "Failed to authenticate";
      print(authorized);
    });

    if (!authenticated) {
      SystemNavigator.pop();
    } else {
      login = "Wellcome";
      loading = false;
    }
  }

  Future<void> _checkBiometric() async {
    bool canCheckBiometric = false;

    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  Future _getAvailableBiometric() async {
    List<BiometricType> availableBiometric = [];
    try {
      availableBiometric = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    setState(() {
      _availableBiometric = availableBiometric;
      print(availableBiometric);
    });
  }

  String login = "Wellcome";
  _SupportState _supportState = _SupportState.unknown;
  bool loading = true;
  @override
  void initState() {
    // _checkBiometricSupport();
    init();
    super.initState();
  }

  init() async {
    await _checkBiometric();
    await _getAvailableBiometric();
    await _authenticate();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      bool isSupported = await auth.isDeviceSupported();

      print("support:-$isSupported");
      setState(() {
        _supportState =
            isSupported ? _SupportState.supported : _SupportState.unsupported;
      });
      if (_supportState == _SupportState.supported) {
        _checkBiometric();
        _getAvailableBiometric();
      }
      print("_supportState:-$_supportState");
    } catch (e) {
      setState(() {
        _supportState =
            _SupportState.unknown; // Handle any errors appropriately
      });
      print("_supportStateerror:-$_supportState");
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Container(
            color: Colors.blueGrey.shade600,
            child: const Center(
              child: CircularProgressIndicator(),
            ))
        : Scaffold(
            backgroundColor: Colors.blueGrey.shade600,
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      login,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 50.0),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 15.0),
                          child: const Text(
                            "Authenticate using your fingerprint and face id or your password ",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, height: 1.5),
                          ),
                        ),
                        authenticated
                            ? Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                width: double.infinity,
                                child: FloatingActionButton(
                                  backgroundColor: Colors.green,
                                  onPressed: null,
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 14.0),
                                    child: Text(
                                      "Authorized success",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                width: double.infinity,
                                child: FloatingActionButton(
                                  onPressed: _authenticate,
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24.0, vertical: 14.0),
                                    child: Text(
                                      "Authenticate",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                authenticated = false;
                                login = "Login";
                              });
                            },
                            child: const Text("Login again"))
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
