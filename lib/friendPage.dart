import 'package:flutter/material.dart';
import 'UserData.dart';

class FriendPage extends StatefulWidget {
  final Function(Friend) onFriendTapped; // 콜백 함수

  FriendPage({required this.onFriendTapped});

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Friend> friends = UserService.getFriends(UserService().usersData).values.where((friend) => friend.user_id != 1).toList();
  List<Friend> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    filteredFriends = friends; // 초기 상태에서 전체 친구 목록을 표시
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredFriends = friends;
      } else {
        filteredFriends = friends.where((friend) {
          final name = friend.name.toLowerCase();
          final id = friend.nickname.toLowerCase();
          return name.contains(query) || id.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:  EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '친구 찾기',
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.07, // 원하는 높이로 설정
                child: TextField(
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 24,
                  ),
                  controller: _searchController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10), // 수직 패딩을 늘려서 높이를 증가시킵니다.
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black12, // 옅은 회색 경계선
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black12, // 포커스 시에도 옅은 회색 경계선 유지
                        width: 1.0,
                      ),
                    ),

                    hintText: '이름 또는 아이디로 친구 검색',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'NotoSans',
                      fontSize: 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4,),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.04,
                child: ElevatedButton(
                  onPressed: _filterFriends, // 버튼 클릭 시 필터링 함수 호출
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFBB2F30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5), // 모서리를 둥글게 설정
                    ),
                    elevation: 0, // 그림자 제거
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white, // 아이콘 색상 설정
                    size: 28.0, // 아이콘 크기 설정
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.016),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredFriends.length,
            itemBuilder: (context, index) {
              final friend = filteredFriends[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildFriendTile(friend),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFriendTile(Friend friend) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              widget.onFriendTapped(friend);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: friend.profile_image_url.isEmpty ? Colors.grey[300] : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: friend.profile_image_url.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      friend.profile_image_url, // 네트워크 이미지를 가져옴
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon( // 이미지 로드 실패 시 대체 아이콘 표시
                          Icons.error,
                          size: 32,
                          color: Colors.red,
                        );
                      },
                    ),
                  )
                      : Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        friend.name,
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 24,
                        ),
                      ),

                      SizedBox(height: 4,),

                      Text(
                        'ID: ${friend.nickname}',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 1,
          ),
        ],
      ),
    );
  }
}
