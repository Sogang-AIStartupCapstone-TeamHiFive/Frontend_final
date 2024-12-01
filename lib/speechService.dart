import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpeechService {
  FlutterSoundRecorder? _recorder;

  SpeechService() {
    _recorder = FlutterSoundRecorder();
    _initializeRecorder(); // 녹음기 초기화
  }

  Future<String> convertSpeechToText() async {
    // Google API를 사용해 녹음 파일을 텍스트로 변환하는 함수입니다. 자세한 내용은 사용 설명서를 참고하세요.
    return await recordAndConvert();
  }

  // 녹음기 초기화 및 마이크 권한 요청
  Future<void> _initializeRecorder() async {
    await Permission.microphone.request(); // 마이크 권한 요청
    await _recorder!.openRecorder(); // 녹음기 열기
  }

  // 음성을 녹음하고 텍스트로 변환
  Future<String> recordAndConvert() async {
    try {
      // 임시 디렉터리에 파일 저장
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/speech_to_text.wav';

      // 음성 녹음 시작
      await _recorder!.startRecorder(
        toFile: filePath,
        codec: Codec.pcm16WAV, // Google API에서 요구하는 형식
      );

      print("녹음 시작: $filePath");

      // 녹음 중...
      await Future.delayed(Duration(seconds: 5)); // 5초간 녹음

      // 녹음 중지
      String? path = await _recorder!.stopRecorder();
      if (path == null) {
        print("녹음 실패");
        return "녹음 실패";
      }

      print("녹음 완료: $path");

      // 음성 파일을 텍스트로 변환
      File audioFile = File(path);
      String transcript = await _convertSpeechToText(audioFile);
      return transcript;
    } catch (e) {
      print('오류 발생: $e');
      return '오류 발생: $e';
    }
  }

  // Google Speech-to-Text API를 호출하여 음성을 텍스트로 변환
  Future<String> _convertSpeechToText(File audioFile) async {
    final String apiKey = 'AIzaSyDYF52I_GsB5Cn_RlrjJ65grRb93_smJlM';
    final String apiUrl = 'https://speech.googleapis.com/v1/speech:recognize?key=$apiKey';

    List<int> audioBytes = audioFile.readAsBytesSync();
    String audioContent = base64Encode(audioBytes);

    var request = {
      "config": {
        "encoding": "LINEAR16",
        "sampleRateHertz": 16000,
        "languageCode": "ko-KR" // 한국어 설정
      },
      "audio": {
        "content": audioContent,
      }
    };

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['results'] != null && responseData['results'].isNotEmpty) {
          return responseData['results'][0]['alternatives'][0]['transcript'];
        } else {
          print("음성 인식 결과 없음");
          return "음성 인식 결과 없음";
        }
      } else {
        print("음성 인식 실패, 상태 코드: ${response.statusCode}");
        print("응답 내용: ${response.body}");
        return "음성 인식 실패";
      }
    } catch (e) {
      print("오류 발생: $e");
      return "오류 발생: $e";
    }
  }
}
