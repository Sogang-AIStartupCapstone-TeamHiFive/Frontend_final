import 'package:flutter/material.dart';
import 'speechService.dart'; // 음성 인식 서비스 추가

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // TextField의 포커스를 제어하기 위한 FocusNode
  final FocusNode _focusNode = FocusNode();

  final SpeechService _speechService = SpeechService();

  // TextField의 내용을 제어하기 위한 TextEditingController
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // '홈으로 이동' 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Container(
                color: Colors.white,
                child: TextButton(
                  onPressed: () {
                    // 모든 라우트를 제거하고 '/home'으로 이동
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                          (Route<dynamic> route) => false,
                    );
                  },
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
                        size: 35,
                      ),
                      SizedBox(width: 4,),
                      Text(
                        '뒤로 가기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // '게시물 생성' 제목
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.052,
              child: Text(
                '게시물 생성',
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                style: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 12,),
            // 게시물 작성 TextField
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: TextField(
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 24,
                  ),

                  controller: _textController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  expands: true,
                  maxLines: null,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black12,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black12,
                        width: 1.0,
                      ),
                    ),
                    hintText: '화면을 눌러 오늘 있었던 일을 작성해보세요!',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'NotoSans',
                      fontSize: 24,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 40),
                  ),
                ),
              ),
            ),
            // '만들기' 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: () {
                      // 만들기 버튼 클릭 시 처리할 내용
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreatePostPage()),
                      );*/
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFBB2F30),
                      textStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      padding: EdgeInsets.only(bottom: 3),
                    ),
                    child: FittedBox(
                      fit: BoxFit.none,
                      child: Text(
                        '만들기',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'NotoSans',
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // '글로 입력', '음성으로 입력' 버튼 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildInputButton(
                    context: context,
                    iconPath: 'assets/images/04_create_typing.png',
                    label: '글로 입력',
                    onPressed: () {
                      // 글로 입력 버튼 클릭 시 처리할 내용
                      _focusNode.requestFocus();
                    },
                  ),
                  buildInputButton(
                    context: context,
                    iconPath: 'assets/images/04_create_mic.png',
                    label: '음성으로 입력',
                    onPressed: () async {
                      // 음성 인식 버튼 클릭 시 처리
                      String transcript = await _speechService.convertSpeechToText(); // 음성을 녹음하고 텍스트로 변환
                      setState(() {
                        _textController.text = transcript; // 인식된 텍스트를 TextField에 표시
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget buildInputButton({
  required BuildContext context,
  required String iconPath,
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.45,
    height: MediaQuery.of(context).size.height * 0.16,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.15,
            height: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                iconPath,
                width: MediaQuery.of(context).size.width * 0.1, // 아이콘 고정 크기
                height: MediaQuery.of(context).size.width * 0.1,
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 24
            ),
          ),
        ],
      ),
    ),
  );
}