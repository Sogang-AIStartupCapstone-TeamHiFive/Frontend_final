import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'friendPostPage.dart';
import 'postPage.dart';
import 'createPage.dart';
import 'friendPage.dart';
import 'profilePage.dart';
import 'UserData.dart';

class Home extends StatefulWidget {
  @override
  _HyFiveHomePageState createState() => _HyFiveHomePageState();
}

class _HyFiveHomePageState extends State<Home> {
  bool _isPostPage = false;
  bool _isFriendPage = false;
  bool _isProfilePage = false;
  Friend? selectedFriend;

  @override
  void initState() {
    super.initState();
    _initializePages();
    _initializeRecorder();
  }

  void _initializePages() {
    _isPostPage = false;
    _isFriendPage = false;
    _isProfilePage = false;
    selectedFriend = null;
  }

  Future<void> _initializeRecorder() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return;
    }
  }

  final List<Map<String, dynamic>> buttonData = [
    {'icon': 'assets/images/01_menu_home.png', 'label': '홈'},
    {'icon': 'assets/images/01_menu_create.png', 'label': '만들기'},
    {'icon': 'assets/images/01_menu_friend.png', 'label': '친구'},
    {'icon': 'assets/images/01_menu_profile.png', 'label': '나'},
  ];

  void _goBackToMainPage() {
    setState(() {
      _initializePages();
    });
  }

  void _onHomeButtonPressed() {
    setState(() {
      _initializePages();
    });
  }

  void _onCreateButtonPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePage()),
    );
  }

  void _onFriendPressed(Friend friend) {
    setState(() {
      _initializePages();
      _isPostPage = true;
      selectedFriend = friend;
    });
  }

  void _onFriendButtonPressed() {
    setState(() {
      _initializePages();
      _isFriendPage = true;
    });
  }

  void _onFriendTileTapped(Friend friend) {
    setState(() {
      _initializePages();
      _isProfilePage = true;
      selectedFriend = friend;
    });
  }

  void _onProfileButtonPressed() {
    setState(() {
      _initializePages();
      _isProfilePage = true;
      selectedFriend = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.08),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppBar(
            title: Text(
              '사진동화',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: screenHeight * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            backgroundColor: Colors.white,
            elevation: 0.0,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isPostPage) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01, horizontal: screenWidth * 0.02),
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: TextButton(
                  onPressed: _goBackToMainPage,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left,
                        color: Colors.black54,
                        size: screenHeight * 0.045,
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        '뒤로 가기',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'NotoSans',
                          fontSize: screenHeight * 0.03,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Expanded(
            child: Container(
              child: _isFriendPage
                  ? FriendPage(onFriendTapped: _onFriendTileTapped)
                  : _isProfilePage
                  ? ProfilePage(selectedFriend: selectedFriend)
                  : _isPostPage
                  ? PostPage(
                userId: selectedFriend?.user_id ?? 0,
                onGoBack: _goBackToMainPage,
              )
                  : FriendPostsPage(onFriendPressed: _onFriendPressed),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: screenHeight * 0.18,
        child: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: buttonData.map((data) {
              return Expanded(
                child: Container(
                  height: screenHeight * 0.11,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () {
                      if (data['label'] == '만들기') {
                        _onCreateButtonPressed();
                      } else if (data['label'] == '홈') {
                        _onHomeButtonPressed();
                      } else if (data['label'] == '친구') {
                        _onFriendButtonPressed();
                      } else if (data['label'] == '나') {
                        _onProfileButtonPressed();
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: screenHeight * 0.06,
                          height: screenHeight * 0.06,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              data['icon'],
                              width: screenHeight * 0.035,
                              height: screenHeight * 0.035,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          data['label'],
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: screenHeight * 0.025,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
