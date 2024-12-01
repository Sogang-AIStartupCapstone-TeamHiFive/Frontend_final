import 'package:flutter/material.dart';
import 'UserData.dart';
import 'postDetailsPage.dart';
import 'dart:math';

class ProfilePage extends StatelessWidget {
  Friend? selectedFriend;

  ProfilePage({required this.selectedFriend}) {
    // 기본적으로 user_id가 1인 사용자의 정보를 가져오도록 설정
    selectedFriend ??= UserService.getFriends(UserService().usersData)[1];
  }

  @override
  Widget build(BuildContext context) {
    final String? randomImage = selectedFriend == null ? null : UserService().getRandomPostImage(selectedFriend!.user_id);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 4), // 바텀 네비게이션 바 높이만큼 여유 공간을 둠
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                    ),
                    child: randomImage != null
                        ? Image.network(
                      randomImage,
                      fit: BoxFit.cover, // 이미지 크기 조정
                    )
                        : null, // 이미지가 없으면 아무것도 표시하지 않음
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 16), // 상하좌우 공백 조정
                  width: 394,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        offset: Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 4,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight( // 내용에 따라 높이가 동적으로 조정됨
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // 높이를 최소로 제한
                      children: [
                        Text(
                          selectedFriend?.name ?? '사용자명',
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8), // 공백 최소화
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${selectedFriend != null ? UserService().getPosts(selectedFriend!.user_id).length : 0}',
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFBB2F30),
                                    height: 1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '게시물 수',
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 20,
                                    color: Color(0xFF544C4C),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${selectedFriend != null ? Random().nextInt(1000) : UserService.getFriends(UserService().usersData).length}',
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFBB2F30),
                                    height: 1,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '친구 수',
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 20,
                                    color: Color(0xFF544C4C),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16), // bio 위 공백 조정
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                selectedFriend?.bio ?? '소개글이 없습니다.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black, // 줄 간격 최소화
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16), // 게시물과 박스 사이 간격 유지
                // 게시물이 들어갈 부분
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 한 행에 3개
                      crossAxisSpacing: 6, // 열 간 간격
                      mainAxisSpacing: 8, // 행 간 간격
                      childAspectRatio: 0.85, // 정사각형 비율
                    ),
                    itemCount: selectedFriend != null ? UserService().getPosts(selectedFriend!.user_id).length : 0,
                    itemBuilder: (context, index) {
                      // 유저의 게시물 리스트 가져오기
                      final posts = selectedFriend != null
                          ? UserService().getPosts(selectedFriend!.user_id)
                          : [];
                      return index < posts.length
                          ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailsPage(post: posts[index]),
                            ),
                          );
                        },
                        child: Image.network(
                          posts[index].images_url[0],
                          fit: BoxFit.cover,
                        ),
                      )
                          : Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: 140,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Color(0xFFD1D1D6),
                  backgroundImage: (selectedFriend?.profile_image_url.isNotEmpty ?? false)
                      ? NetworkImage(selectedFriend!.profile_image_url)
                      : null,
                  child: (selectedFriend?.profile_image_url.isNotEmpty ?? false)
                      ? null // 이미지가 있으면 child는 null
                      : Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
