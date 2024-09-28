import 'dart:io';
import 'dart:ui';

import 'package:chting_app/api/apis.dart';
import 'package:chting_app/helper/dialogs.dart';
import 'package:chting_app/screens/auth/login_screen.dart';
import 'package:chting_app/screens/auth/login_screen1.dart';
import 'package:chting_app/screens/home_screen.dart';
import 'package:chting_app/screens/upload_file_screen.dart';
import 'package:chting_app/screens/redex_balance.dart';
import 'package:chting_app/screens/googleGemini2.dart';
import 'package:chting_app/services/database_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({Key? key}) : super(key: key);

  @override
  _NewsFeedPageState createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _imageFile;
  final DatabaseController _databaseController = DatabaseController();

  Future<void> _uploadImage() async {
    final pickedFile =
    await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _postNewsItem() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      String imageUrl = '';
      if (_imageFile != null) {
        imageUrl = await _databaseController.uploadImage(_imageFile!);
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      await _databaseController.addNewsItem(
        title: title,
        description: description,
        imageUrl: imageUrl,
      );

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null;
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post news item: $e')),
      );
    }
  }

  Future<void> _confirmDeletePost(String newsItemId) async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _deletePost(newsItemId);
    }
  }

  Future<void> _deletePost(String newsItemId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      // Fetch the post to check the author
      final postDoc = await FirebaseFirestore.instance
          .collection('news')
          .doc(newsItemId)
          .get();
      final postData = postDoc.data();
      final postAuthorId = postData?['authorId'];

      if (postAuthorId != user.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You are not authorized to delete this post')),
        );
        return;
      }

      // Proceed to delete the post
      await FirebaseFirestore.instance
          .collection('news')
          .doc(newsItemId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post: $e')),
      );
    }
  }

  Future<void> _toggleLike(String newsItemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;

    try {
      await _databaseController.toggleLike(
        newsItemId: newsItemId,
        userId: userId,
      );
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  Future<void> _addComment(String newsItemId, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _databaseController.addComment(
        newsItemId: newsItemId,
        comment: comment,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
  }

  Future<void> _toggleCommentLike(String newsItemId, String commentId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _databaseController.toggleCommentLike(
        newsItemId: newsItemId,
        commentId: commentId,
      );
    } catch (e) {
      print("Error toggling comment like: $e");
    }
  }

  Future<Map<String, dynamic>?> _getUserInfo(String userId) async {
    return await _databaseController.getUserInfo(userId);
  }

  Future<void> _showCommentDialog(String newsItemId) async {
    final TextEditingController _commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a Comment'),
          content: TextField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Comment'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final comment = _commentController.text.trim();
                if (comment.isNotEmpty) {
                  await _addComment(newsItemId, comment);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comment cannot be empty')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComment(String newsItemId, String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('news')
          .doc(newsItemId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('News Feed'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.groups),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen()),
                );
              },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      //endDrawer: _buildEndDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Post Your Moment'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                      const InputDecoration(labelText: 'Description'),
                    ),
                    SizedBox(height: 8),
                    if (_imageFile != null) Image.file(_imageFile!),
                    ElevatedButton(
                      onPressed: _uploadImage,
                      child: const Text('Pick Image'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: _postNewsItem,
                    child: const Text('Post'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('news')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final newsItems = snapshot.data?.docs ?? [];

          if (newsItems.isEmpty) {
            return const Center(child: Text('No news items available.'));
          }

          return ListView.builder(
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              final newsItem = newsItems[index];
              final title = newsItem['title'] ?? 'No Title';
              final description = newsItem['description'] ?? 'No Description';
              final imageUrl = newsItem['imageUrl'] ?? '';
              final likes = List<String>.from(newsItem['likes'] ?? []);
              final authorId = newsItem['authorId'] ?? '';

              return FutureBuilder<Map<String, dynamic>?>(
                future: _getUserInfo(authorId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.hasError) {
                    return Center(child: Text('Error: ${userSnapshot.error}'));
                  }

                  final userInfo = userSnapshot.data;
                  final username = userInfo?['name'] ?? 'Unknown User';
                  final profileImageUrl = userInfo?['image'] ?? '';

                  // Check if the current user is the author of the post
                  final currentUser = FirebaseAuth.instance.currentUser;
                  final isAuthor =
                      currentUser != null && currentUser.uid == authorId;

                  return Card(
                    margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: profileImageUrl.isNotEmpty
                              ? CircleAvatar(
                              backgroundImage:
                              NetworkImage(profileImageUrl))
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(username),
                          subtitle: Text(title),
                          trailing: isAuthor
                              ? IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _confirmDeletePost(newsItem.id),
                          )
                              : null,
                        ),
                        if (imageUrl.isNotEmpty)
                          Image.network(imageUrl, fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(description),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    likes.contains(FirebaseAuth
                                        .instance.currentUser?.uid)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: likes.contains(FirebaseAuth
                                        .instance.currentUser?.uid)
                                        ? Colors.red
                                        : null,
                                  ),
                                  onPressed: () => _toggleLike(newsItem.id),
                                ),
                                Text('${likes.length}'),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.comment),
                              onPressed: () => _showCommentDialog(newsItem.id),
                            ),
                            // Remove the delete button if not author
                            // if (isAuthor)
                            //   IconButton(
                            //     icon: const Icon(Icons.delete),
                            //     onPressed: () => _confirmDeletePost(newsItem.id),
                            //   ),
                          ],
                        ),
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.expand_more),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return StreamBuilder<
                                      QuerySnapshot<Map<String, dynamic>>>(
                                    stream: FirebaseFirestore.instance
                                        .collection('news')
                                        .doc(newsItem.id)
                                        .collection('comments')
                                        .orderBy('timestamp', descending: true)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError) {
                                        return Center(child: Text(
                                            'Error: ${snapshot.error}'));
                                      }

                                      final comments = snapshot.data?.docs ??
                                          [];
                                      final currentUser = FirebaseAuth.instance
                                          .currentUser;

                                      return ListView(
                                        children: comments.map((doc) {
                                          final commentData = doc.data();
                                          final commentId = doc.id;
                                          final commentUserId = commentData['userId'] ??
                                              '';
                                          final commentText = commentData['comment'] ??
                                              'No Comment';
                                          final commentLikes = List<
                                              String>.from(
                                              commentData['likes'] ?? []);

                                          // Check if the current user is the author of the post or the owner of the comment
                                          final isPostAuthor = currentUser
                                              ?.uid == newsItem['authorId'];
                                          final isCommentOwner = currentUser
                                              ?.uid == commentUserId;

                                          return Dismissible(
                                            key: Key(commentId),
                                            direction: DismissDirection
                                                .endToStart,
                                            // Swipe direction from right to left
                                            background: Container(
                                              color: Colors.red,
                                              child: const Align(
                                                alignment: Alignment
                                                    .centerRight,
                                                // Align the delete icon to the right
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20.0),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            confirmDismiss: (direction) async {
                                              // Only confirm deletion if the user is the post author or the comment owner
                                              if (isPostAuthor ||
                                                  isCommentOwner) {
                                                return await showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Confirm Delete'),
                                                      content: const Text(
                                                          'Are you sure you want to delete this comment?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  true),
                                                          child: const Text(
                                                              'Delete'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                              // Return false if the user does not have permission to delete
                                              return false;
                                            },
                                            onDismissed: (direction) {
                                              // Delete the comment if confirmed
                                              if (isPostAuthor ||
                                                  isCommentOwner) {
                                                _deleteComment(
                                                    newsItem.id, commentId);
                                              }
                                            },
                                            child: FutureBuilder<Map<
                                                String,
                                                dynamic>?>(
                                              future: _getUserInfo(
                                                  commentUserId),
                                              builder: (context, userSnapshot) {
                                                if (userSnapshot
                                                    .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return const Center(
                                                      child: CircularProgressIndicator());
                                                }

                                                if (userSnapshot.hasError) {
                                                  return Center(child: Text(
                                                      'Error: ${userSnapshot
                                                          .error}'));
                                                }

                                                final userData = userSnapshot
                                                    .data;
                                                final commentUser = userData?['name'] ??
                                                    'Anonymous';
                                                final commentUserProfilePicture = userData?['image'] ??
                                                    '';

                                                return ListTile(
                                                  leading: commentUserProfilePicture
                                                      .isNotEmpty
                                                      ? CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                        commentUserProfilePicture),
                                                  )
                                                      : const CircleAvatar(
                                                    child: Icon(Icons.person),
                                                  ),
                                                  title: Text(commentUser),
                                                  subtitle: Text(commentText),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize
                                                        .min,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          commentLikes.contains(
                                                              currentUser?.uid)
                                                              ? Icons.favorite
                                                              : Icons
                                                              .favorite_border,
                                                          color: commentLikes
                                                              .contains(
                                                              currentUser?.uid)
                                                              ? Colors.red
                                                              : null,
                                                        ),
                                                        onPressed: () =>
                                                            _toggleCommentLike(
                                                                newsItem.id,
                                                                commentId),
                                                      ),
                                                      Text('${commentLikes
                                                          .length}'),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: <Widget>[
          // Drawer Header
      Container(
      color: Colors.grey[900],
        child: DrawerHeader(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Stack(
            children: [
              // Local Background Image with Blur
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  image: DecorationImage(
                    image: AssetImage(
                      'images/icon2.png', // Path to your local image
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Apply blur
                  child: Container(
                    color: Colors.black.withOpacity(0.2), // Optional dark overlay
                  ),
                ),
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.grey[800]!.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              // User Info and Avatar
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      user?.photoURL ?? 'https://www.example.com/default_profile_image_url', // Default image if not available
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(width: 15),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          user?.displayName ?? 'User Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis, // Truncate text if it's too long
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          user?.email ?? 'user@example.com',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis, // Truncate text if it's too long
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildDrawerItem(
                  icon: Icons.upload_file,
                  text: 'Upload PDF',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UploadFilesPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet,
                  text: 'Redex Balance',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RedexBalancePage()),
                    );
                    // Handle tap for Redex Balance
                  },
                ),
                // _buildDrawerItem(
                //   icon: Icons.chat,
                //   text: 'Redex Chats',
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (context) => const HomeScreen()),
                //     );
                //   },
                // ),

                _buildDrawerItem(
                  icon: Icons.chat_bubble,
                  text: 'Chat with Redex Assistant',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatScreen2()),
                    );
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.help_outline,
                  text: 'FAQ',
                  onTap: () {
                    // Handle tap for FAQ
                  },
                ),
                SizedBox(
                    height:
                    20), // Spacer to move the logout button to the bottom
                _buildDrawerItem(
                  icon: Icons.logout,
                  text: 'Log Out',
                  textColor: Colors.red[400]!,
                  iconColor: Colors.red[400]!,
                  onTap: () async {
                    Dialogs.showProgressBar(context);
                    await APIs.updateActiveStatus(false);
                    await APIs.auth.signOut().then((value) async {
                      await GoogleSignIn().signOut().then((value) {
                        Navigator.pop(context); // Hide progress dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LoginScreen1()),
                        );
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.black87),
      title: Text(
        text,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildEndDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Notification 1'),
            onTap: () {
              // Handle notification 1 tap
            },
          ),
          ListTile(
            title: const Text('Notification 2'),
            onTap: () {
              // Handle notification 2 tap
            },
          ),
        ],
      ),
    );
  }
}
