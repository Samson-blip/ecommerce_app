import 'package:ecommerce_app/chat/screen.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/data/data.dart';
import 'package:ecommerce_app/utilities/post.dart';
import 'package:ecommerce_app/utilities/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> drawerItems = [
    {'text': 'Home', 'icon': Icons.home},
    {'text': 'Contact Us', 'icon': Icons.contact_mail},
    {'text': 'Rate Us', 'icon': Icons.star},
    {'text': 'Settings', 'icon': Icons.settings},
    {'text': 'update', 'icon': Icons.update},
  ];

  Future<String> fetchAndSetUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (userDocs.docs.isNotEmpty) {
        final userData = userDocs.docs[0].data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('username')) {
          final username = userData['username'] as String;
          final dataModel = Provider.of<DataModel>(context, listen: false);
          dataModel.setUsername(username);
          return username;
        }
      }
    }
    return "User";
  }

  Future<List<Widget>?> _buildCardList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Retrieve a list of all user documents in the "users" collection
      final QuerySnapshot userDocs =
          await FirebaseFirestore.instance.collection('users').get();

      List<Widget> cardList = [];

      for (final QueryDocumentSnapshot userDoc in userDocs.docs) {
        // Get data for each user
        final userData = userDoc.data() as Map<String, dynamic>;

        // Use the user's email as their name
        final userEmail = userData['email'];

        // Retrieve the list of user data documents in the "user_data" collection for this user
        final userPosts = await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .collection('user_data')
            .orderBy('timestamp',
                descending: true) // Sort by timestamp in descending order
            .get();

        for (final QueryDocumentSnapshot userDataDoc in userPosts.docs) {
          final userData = userDataDoc.data() as Map<String, dynamic>;

          final String location = userData['location'] ?? '';
          final String productType = userData['productType'] ?? '';
          final String productStatus = userData['productStatus'] ?? '';
          final double productCost = userData['productCost'] ?? 0.0;
          final String imageUrl = userData['imageUrl'] ?? '';
          final Timestamp timestamp =
              userData['timestamp'] as Timestamp? ?? Timestamp.now();

          // Fetch the username based on email
          final QuerySnapshot userDocs = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: userEmail)
              .get();

          String username = 'User'; // Default value
          if (userDocs.docs.isNotEmpty) {
            final userData = userDocs.docs[0].data() as Map<String, dynamic>?;
            if (userData != null && userData.containsKey('username')) {
              username = userData['username'] as String;
            }
          }

          // Use CachedNetworkImage to load and cache the image
          final card = ListTile(
            title: Row(
              children: [
                // Left column for the image
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 200,
                    width: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(imageUrl),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // Right column for the information
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(' $username'),
                          Text(DateFormat('yyyy-MM-dd')
                              .format(timestamp.toDate())),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          left: 10,
                        ),
                        child: Text(' $productType'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2.0,
                          left: 10,
                        ),
                        child: Text(' $location'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2.0,
                          left: 10,
                        ),
                        child: Text(' $productStatus'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2.0,
                          left: 15,
                        ),
                        child: Text('Tsh $productCost'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Handle the "View" button click
                              },
                              child: Text("View"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(userEmail),
                                  ),
                                );
                              },
                              child: Text("Chat"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );

          cardList.add(card);
        }
      }

      return cardList;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.0),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              // Navigate to the message screen here
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Widget>?>(
        future: _buildCardList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerLoadingCard();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView(
              children: snapshot.data!
                  .map((card) => Padding(
                        padding: EdgeInsets.only(
                            bottom: 16.0), // Vertical padding between cards
                        child: SizedBox(
                          height: 250.0, // Adjust the height as needed
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16.0), // Horizontal padding
                            child: card,
                          ),
                        ),
                      ))
                  .toList(),
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add), // Change the icon to a plus icon
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (int index) {
          // Handle bottom navigation actions
          if (index == 1) {
            // Handle the upload action when the Upload tab is selected.
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => UploadPage()));
          }
        },
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: drawerItems.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Add header at the beginning
              return DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue, // Change to your desired header color
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FutureBuilder<String>(
                      future: fetchAndSetUsername(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Text(
                            Provider.of<DataModel>(context)
                                .username, // Use the fetched username from your provider
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Text(
                            'Error',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    const SizedBox(
                        height: 10), // Add spacing between text and avatar
                    const CircleAvatar(
                      radius: 40, // Adjust the size of the avatar as needed
                      backgroundColor:
                          Colors.white, // Background color of the avatar
                      child: Icon(
                        Icons
                            .account_circle, // You can replace this with your avatar image
                        size: 60, // Adjust the size of the icon
                        color: Colors.blue, // Icon color
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // For other list items
              final item = drawerItems[index - 1];
              final isLastItem = (index == drawerItems.length);
              return Column(
                children: [
                  ListTile(
                    title: Text(item['text']),
                    leading: Icon(
                        item['icon']), // Add an icon to the left of the text
                    onTap: () {
                      // Handle item tap
                    },
                  ),
                  if (!isLastItem &&
                      (index % 2) ==
                          0) // Add a divider after every 3rd item except the last one
                    const Divider(
                        color: Colors.black), // Change the color to black
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

Widget buildProfileImage(String imageUrl) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    errorWidget: (context, url, error) => Icon(Icons.error),
    fit: BoxFit.contain,
    height: 200,
    width: 250,
  );
}
