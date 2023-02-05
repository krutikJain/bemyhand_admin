import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPage extends StatefulWidget {
  final String userId, photourl, name;

  const ChatPage(
      {Key? key,
      required this.userId,
      required this.photourl,
      required this.name})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatTimestamp(Timestamp timestamp) {
    var format = DateFormat("dd/MM/yy hh:mm a"); // <- use skeleton here
    return format.format(timestamp.toDate());
  }

  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFf1f2f9),
        shadowColor: Colors.transparent,
        leading: BackButton(
          color: Colors.black,
        ),
        title: Text(
          'Help Centre',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chat')
                  .doc(widget.userId)
                  .collection("messages")
                  .orderBy("time", descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data.docs[index];
                    return data["admin"] == false
                        ? Card(
                            elevation: 0,
                            color: const Color(0xFFf1f2f9),
                            child: data["media"] == true
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              const Color(0xFFf1f2f9),
                                          foregroundImage:
                                              NetworkImage(data["dp"]),
                                        ),
                                      ),
                                      BubbleNormalImage(
                                        id: data['mediaUrl'],
                                        image: Image.network(data["mediaUrl"]),
                                        color: const Color(0xFFf1f2f9),
                                        isSender: false,
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFf1f2f9),
                                        foregroundImage:
                                            NetworkImage(data["dp"]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Message Info!'),
                                                content: Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "Name:",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        Text(
                                                          "Time:",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          data["senderName"],
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        Text(
                                                          formatTimestamp(
                                                              data["time"]),
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);

                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                        },
                                        child: BubbleSpecialTwo(
                                          text: data["text"],
                                          color: Color(0xFFE8E8EE),
                                          tail: false,
                                          isSender: false,
                                          textStyle: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                          )
                        : Card(
                            elevation: 0,
                            color: const Color(0xFFf1f2f9),
                            child: data["media"] == true
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      BubbleNormalImage(
                                        id: data['mediaUrl'],
                                        image: Image.network(data["mediaUrl"]),
                                        isSender: false,
                                        color: const Color(0xFFf1f2f9),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              const Color(0xFFf1f2f9),
                                          foregroundImage:
                                              NetworkImage(data["dp"]),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Message Info!'),
                                                content: Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "Name:",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        Text(
                                                          "Time:",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          data["senderName"],
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        Text(
                                                          formatTimestamp(
                                                              data["time"]),
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                          FocusScopeNode currentFocus =
                                              FocusScope.of(context);

                                          if (!currentFocus.hasPrimaryFocus) {
                                            currentFocus.unfocus();
                                          }
                                        },
                                        child: BubbleSpecialTwo(
                                          text: data["text"],
                                          color: Color(0xFF1B97F3),
                                          tail: false,
                                          textStyle: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        ),
                                      ),
                                      CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFf1f2f9),
                                        foregroundImage:
                                            NetworkImage(data["dp"]),
                                      ),
                                    ],
                                  ),
                          );
                  },
                );
              },
            ),
          ),
          MessageBar(
            onSend: (value) {
              _firestore.collection('chat').doc(widget.userId).set({
                "lastMessagedAdmin": DateTime.now(),
              }, SetOptions(merge: true));
              _firestore
                  .collection('chat')
                  .doc(widget.userId)
                  .collection("messages")
                  .add({
                'senderName': widget.name,
                'text': value,
                "time": DateTime.now(),
                "dp": widget.photourl,
                'media': false,
                "admin": true,
              });
            },
            messageBarColor: const Color(0xFFf1f2f9),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: InkWell(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 24,
                  ),
                  onTap: () {
                    uploadImage(widget.userId);
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }

  uploadImage(String id) async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile image;
    var perm1 = await Permission.manageExternalStorage.request();
    var perm2 = await Permission.photos.request();
    if (perm1 == PermissionStatus.granted) {
      image = (await _imagePicker.getImage(
          source: ImageSource.gallery, imageQuality: 50))!;
      var file = File(image.path);

      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Send This Media?'),
            content: Container(
              child: Image.file(file),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Text("No"),
              ),
              MaterialButton(
                onPressed: () async {
                  Fluttertoast.showToast(
                      msg: "Sending...",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  if (image != null) {
                    var snapshot = await _firebaseStorage
                        .ref()
                        .child("HelpCentreMedia")
                        .child(id)
                        .child(file.path.split('/').last)
                        .putFile(file);
                    var downloadUrl = await snapshot.ref.getDownloadURL();
                    _firestore.collection('chat').doc(widget.userId).set({
                      "lastMessagedAdmin": DateTime.now(),
                    }, SetOptions(merge: true));
                    _firestore
                        .collection('chat')
                        .doc(widget.userId)
                        .collection("messages")
                        .add({
                      'senderName': widget.name,
                      'mediaUrl': downloadUrl,
                      'media': true,
                      "time": DateTime.now(),
                      "dp": widget.photourl,
                      "admin": true,
                    }).whenComplete(() {
                      Fluttertoast.showToast(
                          msg: "Image Sent",
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1,
                          textColor: Colors.white,
                          fontSize: 16.0);
                      Navigator.pop(context);
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    });
                  } else {
                    Fluttertoast.showToast(
                        msg: "No Image Path Received",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }
                },
                child: Text("Yes"),
              ),
            ],
          );
        },
      );
    } else {
      var perm2 = await Permission.manageExternalStorage.request();
      Fluttertoast.showToast(
          msg: "Accept Permission To Send Media",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
