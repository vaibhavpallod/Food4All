import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Dashboard.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}



TextEditingController nameController = TextEditingController();
TextEditingController usernameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController collegeController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController password1Controller = TextEditingController();
TextEditingController ieee = TextEditingController();
TextEditingController registrationController = TextEditingController();

double _height;
double _width;
double _pixelRatio;
bool pict = false;
bool _large;
bool _medium;
bool _obscureText = true;
String pictRegID;

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  String mail, password, password1, name,phoneNumber;
  bool _obscureText = true;
  bool _obscureText1 = true;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  void toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  createUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: "$mail", password: "$password");
      users
          .add({
        'email': mail, // John Doe
        'name': name, //// 42
      })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
      Fluttertoast.showToast(msg: 'Signed Up Successfully');
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => Dashboard()));
    } catch (e) {
      if (e.toString().toLowerCase().contains('weak_password')) {
        Fluttertoast.showToast(msg: 'The password provided is too weak.');
      } else if (e.toString().toLowerCase().contains('email_already_in_use')) {
        Fluttertoast.showToast(
            msg: 'The account already exists for that email.');
      } else {
        Fluttertoast.showToast(msg: 'Try again in sometime');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery
        .of(context)
        .size
        .height;
    _width = MediaQuery
        .of(context)
        .size
        .width;
    _pixelRatio = MediaQuery
        .of(context)
        .devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomPaint(
              painter: BackgroundSignUp(),
              child: Stack(
                children: <Widget>[
                  _getBackImage(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          _getHeader(),
                          _getTextFields(),
                          _getSignIn(),
                          _getBottomRow(context),
                        ],
                      ),
                    ),
                  ),
                  _getBackBtn(),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  _getBackImage() {
   return ClipPath(
      clipper: _CustomClipper(),
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              image: AssetImage("images/signup.jpeg"),
            )
        ),
      ),
    );
  }

  _getBackBtn() {
    return Positioned(
      top: 35,
      left: 25,
      child: Icon(
        Icons.arrow_back_ios,
        color: Colors.white,
      ),
    );
  }

  _getBottomRow(context) {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              'Already a user Sign in here',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Text(
            '',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  _getSignIn() {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Sign up',
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.w500),
          ),
          InkWell(
            onTap: ()async{
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                await createUser();
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              radius: 40,
              child: Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  _getTextFields() {
    return Expanded(
      flex: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: _large ? 12 : (_medium ? 10 : 8),
            child: TextFormField(
              controller: nameController,
              validator: (val) {
                if (val.isEmpty) {
                  return 'This field cannot be empty!';
                }
                return null;
              },
              onSaved: (val) => name = val,
              keyboardType: TextInputType.text,
              cursorColor: Color(0xff0aa9d7),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person,
                    color: Color(0xff0aa9d7), size: 20),
                hintText: "Name",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                // setState(()=> {
                //   name = val;
                // });
              },
            ),
          ),
          SizedBox(height: _height / 30.0),
          Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: _large ? 12 : (_medium ? 10 : 8),
            child: TextFormField(
              validator: (val) {
                if (val.isEmpty) {
                  return 'This field cannot be empty!';
                } else if (!validateEmail(val)) {
                  return 'Enter a valid email!';
                }
                return null;
              },
              onSaved: (val) => mail = val,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Color(0xff0aa9d7),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email,
                    color: Color(0xff0aa9d7), size: 20),
                hintText: "Email",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                // setState(() {
                //   email = val;
                // });
              },
            ),
          ),
          SizedBox(height: _height / 30.0),
          Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: _large ? 12 : (_medium ? 10 : 8),
            child: TextFormField(
              validator: (val) => val.length < 6
                  ? 'Password must be at least 6 characters long!'
                  : null,
              onSaved: (val) => password = val,
              controller: passwordController,
              keyboardType: TextInputType.text,
              cursorColor: Color(0xff0aa9d7),
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock,
                      color: Color(0xff0aa9d7), size: 20),
                  hintText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    color: Color(0xff0aa9d7),
                    onPressed: (){
                      setState(() {
                        _obscureText=!_obscureText;
                      });
                    },
                  )),

              obscureText: _obscureText,
            ),
          ),
          SizedBox(height: _height / 30.0),
          Material(
            borderRadius: BorderRadius.circular(10.0),
            elevation: _large ? 12 : (_medium ? 10 : 8),
            child: TextFormField(
              validator: (val) {
                if (val.isEmpty) {
                  return 'This field cannot be empty!';
                } else if (val.trim().length<10) {
                  return 'Enter a valid phone number!';
                }
                return null;
              },
              onSaved: (val) => phoneNumber = val,
              controller: phoneController,
              keyboardType: TextInputType.phone,
              cursorColor: Color(0xff0aa9d7),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone,
                    color: Color(0xff0aa9d7), size: 20),
                hintText: "Phone Number",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                // setState(() {
                //   phoneNumber = val;
                // });
              },
            ),
          ),
        ],
      ),
    );
  }

  _getHeader() {
    return Expanded(
      flex: 3,
      child: Container(
        alignment: Alignment.bottomLeft,
        child: Text(
          'Create\nAccount',
          style: TextStyle(color: Colors.white, fontSize: 40),
        ),
      ),
    );
  }


}


class BackgroundSignIn extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var sw = size.width;
    var sh = size.height;
    var paint = Paint();

    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, sw, sh));
    paint.color = Colors.grey.shade100;
    canvas.drawPath(mainBackground, paint);

    // Path blueWave = Path();
    // blueWave.lineTo(sw, 0);
    // blueWave.lineTo(sw, sh * 0.5);
    // blueWave.quadraticBezierTo(sw * 0.5, sh * 0.45, sw * 0.2, 0);
    // blueWave.close();
    // paint.color = Colors.lightBlue.shade300;
    // canvas.drawPath(blueWave, paint);

    // Path greyWave = Path();
    // greyWave.lineTo(sw, 0);
    // greyWave.lineTo(sw, sh * 0.1);
    // greyWave.cubicTo(
    //     sw * 0.95, sh * 0.15, sw * 0.65, sh * 0.15, sw * 0.6, sh * 0.38);
    // greyWave.cubicTo(sw * 0.52, sh * 0.52, sw * 0.05, sh * 0.45, 0, sh * 0.4);
    // greyWave.close();
    // paint.color = Colors.grey.shade800;
    // canvas.drawPath(greyWave, paint);

    Path yellowWave = Path();
    yellowWave.lineTo(sw * 0.7, 0);
    yellowWave.cubicTo(
        sw * 0.6, sh * 0.05, sw * 0.27, sh * 0.01, sw * 0.18, sh * 0.12);
    yellowWave.quadraticBezierTo(sw * 0.12, sh * 0.2, 0, sh * 0.2);
    yellowWave.close();
    paint.color = Colors.orange.shade300;
    canvas.drawPath(yellowWave, paint);

    Path yellowWaveBottom = Path();
    yellowWaveBottom.moveTo(sw * 0.3, sh);
    yellowWaveBottom.cubicTo(
        sw * 0.4, sh * 0.95, sw * 0.73, sh * 0.99, sw * 0.82, sh * 0.88);
    yellowWaveBottom.quadraticBezierTo(sw * 0.88, sh * 0.8, sw, sh * 0.8);
    yellowWaveBottom.lineTo(sw, sh);
    yellowWaveBottom.close();
    paint.color = Colors.orange.shade300;
    canvas.drawPath(yellowWaveBottom, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class BackgroundSignUp extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    var sw = size.width;
    var sh = size.height;
    var paint = Paint();


    Path mainBackground = Path();
    mainBackground.addRect(Rect.fromLTRB(0, 0, sw, sh));
    paint.color = Colors.white;
    canvas.drawPath(mainBackground, paint);

    Path blueWave = Path();
    blueWave.lineTo(sw, 0);
    blueWave.lineTo(sw, sh * 0.65);
    blueWave.cubicTo(sw * 0.8, sh * 0.8, sw * 0.55, sh * 0.8, sw * 0.45, sh);
    blueWave.lineTo(0, sh);
    blueWave.close();
    paint.color = Colors.orange;
    canvas.drawPath(blueWave, paint);

    // Path greyWave = Path();
    // greyWave.lineTo(sw, 0);
    // greyWave.lineTo(sw, sh * 0.3);
    // greyWave.cubicTo(sw * 0.65, sh * 0.45, sw * 0.25, sh * 0.35, 0, sh * 0.5);
    // greyWave.close();
    // paint.color = Colors.grey.shade800;
    // canvas.drawPath(greyWave, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}

class ResponsiveWidget {
  static bool isScreenLarge(double width, double pixel) {
    return width * pixel >= 1440;
  }

  static bool isScreenMedium(double width, double pixel) {
    return width * pixel < 1440 && width * pixel >= 1080;
  }

  static bool isScreenSmall(double width, double pixel) {
    return width * pixel <= 720;
  }
}

class _CustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double heightDelta = size.height / 2.2;
    var sw = size.width;
    var sh = size.height;
    var paint = Paint();
    Path greyWave = Path();
    greyWave.lineTo(sw, 0);
    greyWave.lineTo(sw, sh * 0.3);
    greyWave.cubicTo(sw * 0.65, sh * 0.45, sw * 0.25, sh * 0.35, 0, sh * 0.5);
    greyWave.close();
    paint.color = Colors.grey.shade800;
    // canvas.drawImage( Image(image: AssetImage("images/signup.jpeg")), offset, paint);
    // canvas.drawPath(greyWave, paint);
    return greyWave;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}










/*

 child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            tooltip: 'Back',
                          )
                        ],
                      ),
                    ),
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 8),
                        height: 1.0,
                        width: 35.0,
                        color: Colors.black),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 12),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: 'Name',
                              hintStyle: TextStyle(
                                  color:Colors.black)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(left: 12),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                  color:Colors.black)),
                          validator: (val) {
                            if (val.isEmpty) {
                              return 'This field cannot be empty!';
                            } else if (!validateEmail(val)) {
                              return 'Enter a valid email!';
                            }
                            return null;
                          },
                          onSaved: (val) => _mail = val,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color:
                                  Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 12),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: 'Password',
//                            alignLabelWithHint: true,
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                validator: (val) => val.length < 6
                                    ? 'Password must be at least 6 characters long!'
                                    : null,
                                onChanged: (val) => _password = val,
                                obscureText: _obscureText,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                style: TextStyle(
                                  color:
                                  Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 12),
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: 'Confirm Password',
//                            alignLabelWithHint: true,
                                  hintStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                onSaved: (val) => _password1 = val,
                                obscureText: _obscureText1,
                                validator: (val) {
                                  if (val.isEmpty) {
                                    return 'This field cannot be empty!';
                                  } else if (val.compareTo(_password) != 0) {
                                    return 'Passwords doesn\'t match!';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _obscureText1
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText1 = !_obscureText1;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: RaisedButton(
                        splashColor: Colors.grey.shade900,
                        color: Colors.redAccent,
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            _formKey.currentState.save();
                            await createUser();
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              child: Text('Sign Up',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white)),
                            ),
//                          Icon(
//                            Icons.keyboard_arrow_right,
//                            color: Colors.white,
//                          ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: RichText(
                                      text: TextSpan(children: <TextSpan>[
                                        TextSpan(
                                          text: 'Not the first time here? ',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Log In.',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ]),
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),

*/