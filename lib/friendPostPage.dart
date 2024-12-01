import 'package:flutter/material.dart';
import 'UserData.dart';

class FriendPostsPage extends StatefulWidget {
  final void Function(Friend) onFriendPressed;
  const FriendPostsPage({Key? key, required this.onFriendPressed}) : super(key: key);

  @override
  State<FriendPostsPage> createState() => _FriendPostsPageState();
}

class _FriendPostsPageState extends State<FriendPostsPage> {
  List<Friend> friends = UserService.getFriends(UserService().usersData).values.toList();

  // 선택된 텍스트 상태
  String selectedOption = '친구 이름 순'; // 기본값 설정
  final GlobalKey _buttonKey = GlobalKey(); // 버튼 위치를 찾기 위한 키

  // 옵션 리스트
  final List<String> options = [
    '친구 이름 순',
    '최근 글 올린 친구 순',
    '친한 친구 순'
  ];

  // 드롭다운 메뉴가 열려 있는지 상태
  bool isDropdownOpen = false;

  // 스크롤 컨트롤러
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {}); // 상태를 업데이트하여 스크롤바를 최신 상태로 유지
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 리스너를 제거하고 컨트롤러를 해제하여 메모리 누수 방지
    super.dispose();
  }

  void _showDropdownMenu(BuildContext context) {
    final RenderBox renderBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: buttonPosition.dx,
              top: buttonPosition.dy + buttonSize.height,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: buttonSize.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((String option) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedOption = option;
                            print(selectedOption);
                          });
                          Navigator.of(context).pop(); // 선택 후 닫기
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option,
                                style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 32,
                                  color: option == selectedOption ? Color(0xFFBB2F30) : Colors.black,
                                ),
                              ),
                              if (option == selectedOption)
                                Icon(Icons.check, color: Color(0xFFBB2F30), size: 50,),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (selectedOption == '친구 이름 순') {
      friends.sort((a, b) => a.name.compareTo(b.name));
    }
    if (selectedOption == '최근 글 올린 친구 순') {
      List<int> sortedUserIds = UserService().getUsersSortedByMostRecentPost();
      print(sortedUserIds);

      // friends 리스트를 sortedUserIds의 순서에 맞게 정렬
      friends.sort((a, b) {
        int indexA = sortedUserIds.indexOf(a.user_id);
        int indexB = sortedUserIds.indexOf(b.user_id);
        return indexA.compareTo(indexB); // 리스트 순서대로 정렬
      });
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 36, bottom: 16),
          child: GestureDetector(
            key: _buttonKey,
            onTap: () {
              _showDropdownMenu(context);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 6, right: 6, bottom: 10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFBB2F30),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        selectedOption,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white, size: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: (friends.length / 2).ceil(), // 행의 개수
                itemBuilder: (context, rowIndex) {
                  int startIndex = rowIndex * 2; // 각 행의 시작 인덱스
                  int endIndex = (startIndex + 1 == friends.length) ? startIndex : startIndex + 1; // 각 행의 끝 인덱스 계산

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround, // 항목 간 간격 균등하게 설정
                        children: [
                          for (int index = startIndex; index <= endIndex; index++)
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  widget.onFriendPressed(friends[index]);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // 세로 크기를 내용에 맞춤
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.43,
                                      height: MediaQuery.of(context).size.height * 0.193,
                                      decoration: BoxDecoration(
                                        color: friends[index].profile_image_url.isEmpty ? Colors.grey[300] : null,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: friends[index].profile_image_url.isNotEmpty
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          friends[index].profile_image_url, // 네트워크 이미지를 가져옴
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
                                    Text(
                                      friends[index].name, // 사용자 이름 출력
                                      style: TextStyle(
                                        fontFamily: 'NotoSans',
                                        fontSize: 34,
                                      ), // 텍스트 스타일 지정
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 50), // 각 행과 구분선 사이 간격 설정
                    ],
                  );
                },
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: CustomPaint(
                  painter: CustomScrollbarPainter(
                    scrollController: _scrollController,
                    thumbColor: Color(0xFFBB2F30),
                    trackColor: Color(0xFFB1B1B1),
                    trackPassedColor: Color(0xFF464646),
                    thumbThickness: 10.0,
                    trackThickness: 2.0,
                  ),
                  child: Container(width: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CustomScrollbar extends StatelessWidget {
  final ScrollController scrollController;
  final Color thumbColor;
  final Color trackColor;
  final Color trackPassedColor;
  final double thumbThickness;
  final double trackThickness;

  CustomScrollbar({
    required this.scrollController,
    required this.thumbColor,
    required this.trackColor,
    required this.trackPassedColor,
    required this.thumbThickness,
    required this.trackThickness,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CustomScrollbarPainter(
        scrollController: scrollController,
        thumbColor: thumbColor,
        trackColor: trackColor,
        trackPassedColor: trackPassedColor,
        thumbThickness: thumbThickness,
        trackThickness: trackThickness,
      ),
      child: Container(
        width: thumbThickness,
      ),
    );
  }
}

class CustomScrollbarPainter extends CustomPainter {
  final ScrollController scrollController;
  final Color thumbColor;
  final Color trackColor;
  final Color trackPassedColor;
  final double thumbThickness;
  final double trackThickness;

  CustomScrollbarPainter({
    required this.scrollController,
    required this.thumbColor,
    required this.trackColor,
    required this.trackPassedColor,
    required this.thumbThickness,
    required this.trackThickness,
  }) : super(repaint: scrollController);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = trackThickness;

    final Paint trackPassedPaint = Paint()
      ..color = trackPassedColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = trackThickness;

    final Paint thumbPaint = Paint()
      ..color = thumbColor
      ..strokeCap = StrokeCap.round;

    double maxScrollExtent = scrollController.position.maxScrollExtent;
    double currentScroll = scrollController.position.pixels;
    double scrollableHeight = size.height;

    if (maxScrollExtent == 0) return;

    double thumbHeight =
        (scrollableHeight / (maxScrollExtent + scrollableHeight)) *
            scrollableHeight;
    double thumbTop =
        (currentScroll / maxScrollExtent) * (scrollableHeight - thumbHeight);

    double trackCenterX = size.width - thumbThickness / 2;

    // 지나간 트랙 그리기
    canvas.drawLine(
      Offset(trackCenterX, 0),
      Offset(trackCenterX, thumbTop),
      trackPassedPaint,
    );

    // 아직 지나가지 않은 트랙 그리기
    canvas.drawLine(
      Offset(trackCenterX, thumbTop + thumbHeight),
      Offset(trackCenterX, scrollableHeight),
      trackPaint,
    );

    // thumb 그리기 (모서리가 둥근 직사각형 형태)
    Rect thumbRect = Rect.fromLTWH(
      size.width - thumbThickness,
      thumbTop,
      thumbThickness,
      thumbHeight,
    );

    // 둥근 모서리를 가지는 thumb
    RRect thumbRRect = RRect.fromRectAndRadius(thumbRect, Radius.circular(3));
    canvas.drawRRect(thumbRRect, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomScrollbarPainter oldDelegate) {
    return oldDelegate.scrollController != scrollController ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.trackPassedColor != trackPassedColor ||
        oldDelegate.thumbThickness != thumbThickness ||
        oldDelegate.trackThickness != trackThickness;
  }
}