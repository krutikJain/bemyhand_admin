import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'ChatPage.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({Key? key}) : super(key: key);

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFf1f2f9),
        title: const Text(
          "Admin Chat",
          style: TextStyle(color: Colors.black),
        ),
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: _firestore.collectionGroup("chat").snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                final data = snapshot.data.docs[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatPage(
                                  photourl:
                                      "https://www.pngmart.com/files/21/Admin-Profile-Vector-PNG-Image.png",
                                  name: "Admin",
                                  userId: data['uid'],
                                )));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    height: 100,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          foregroundImage: NetworkImage(data["dp"]),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          data["name"],
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
