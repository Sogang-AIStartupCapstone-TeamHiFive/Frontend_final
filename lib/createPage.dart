import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  bool isListening = false;
  bool isLoading = false;
  late stt.SpeechToText _speech; // STT 객체
  String _sttResult = ""; // STT 변환 결과

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> createPost(String content) async {
    final url = Uri.parse('http://52.78.132.208:8002/posts/');
    final body = jsonEncode({'original': content});

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('성공', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            content: Text('게시물이 성공적으로 생성되었습니다!', style: TextStyle(fontSize: 24)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('확인', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        );
      } else {
        _showErrorDialog('게시물을 생성하지 못했습니다.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('네트워크 오류가 발생했습니다.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> startListening() async {
    PermissionStatus status = await Permission.microphone.request();
    bool hasPermission = status.isGranted;

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("마이크 권한이 필요합니다.")),
      );
      return;
    }

    bool isAvailable = await _speech.initialize(
      onStatus: (status) {
        debugPrint('STT 상태: $status');
        setState(() => isListening = status == "listening");
      },
      onError: (error) {
        debugPrint('STT 에러: ${error.errorMsg}');
        setState(() => isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("음성 인식 실패: ${error.errorMsg}")),
        );
      },
    );

    if (isAvailable) {
      setState(() => isListening = true);
      _speech.listen(
        localeId: 'ko_KR', // 한국어 설정
        listenMode: stt.ListenMode.confirmation, // 자동 중단 방지를 위해 listenMode 설정
        pauseFor: Duration(seconds: 10), // 말의 쉬는 시간이 길어지면 초기화하는 시간 조정 (5초)
        onResult: (result) {
          setState(() {
            _sttResult = result.recognizedWords;
            _textController.text = _sttResult;
            _textController.selection = TextSelection.fromPosition(
                TextPosition(offset: _textController.text.length)); // 커서를 텍스트 끝으로 이동
          });
        },
      );
    } else {
      setState(() => isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("STT 초기화에 실패했습니다.")),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/home',
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chevron_left, color: Colors.black54, size: 35),
                      SizedBox(width: 4),
                      Text('뒤로 가기', style: TextStyle(color: Colors.black, fontSize: 24)),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                '게시물 생성',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  expands: true,
                  maxLines: null,
                  style: TextStyle(fontSize: 32), // STT 텍스트의 폰트 크기 키움
                  decoration: InputDecoration(
                    hintText: '글이나 음성으로 오늘 있었던 일을 작성해보세요!',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, // 버튼 너비 키움
                  height: MediaQuery.of(context).size.height * 0.08, // 버튼 높이 키움
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      final content = _textController.text.trim();
                      if (content.isNotEmpty) {
                        createPost(content);
                      } else {
                        _showErrorDialog('게시물 내용을 입력하세요.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading ? Colors.grey : Color(0xFFBB2F30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // 둥근 모서리 추가
                      ),
                    ),
                    child: isLoading
                        ? SpinKitWaveSpinner(color: Colors.green, size: 80.0) // 로딩 아이콘 크기 조정
                        : Text(
                      '만들기',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900), // 텍스트 크기 키움
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildInputButton(
                    context: context,
                    iconPath: 'assets/images/04_create_typing.png',
                    label: '글로 입력',
                    onPressed: () => _focusNode.requestFocus(),
                  ),
                  buildInputButton(
                    context: context,
                    iconPath: 'assets/images/04_create_mic.png',
                    label: '음성으로 입력',
                    onPressed: isListening ? _stopListening : startListening,
                  ),
                ],
              ),
            ),
            if (isListening)
              Center(
                child: SpinKitWave(color: Colors.red, size: 80.0),
              ),
          ],
        ),
      ),
    );
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
              child: Image.asset(iconPath),
            ),
            SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
