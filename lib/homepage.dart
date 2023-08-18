import 'package:animate_do/animate_do.dart';
import 'package:assist_app/services/openai_services.dart';
import 'package:assist_app/utilities/task_pallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechtoText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();

  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechtoText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechtoText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechtoText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    super.dispose();
    speechtoText.stop();
    flutterTts.stop();
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Assistant'),
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              height: 150,
              width: 150,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  image: const DecorationImage(
                      image: AssetImage('assets/asist.jpg'),
                      fit: BoxFit.cover)),
            ),
          ),
          FadeInRight(
            child: Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.15,
                width: double.maxFinite,
                margin: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 35,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(colors: [
                      Colors.blue,
                      Colors.deepPurpleAccent,
                      Colors.white12,
                    ])),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    generatedContent == null
                        ? 'Hey  there, What can I do for you today?'
                        : generatedContent!,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          //Suggestions or example header
          if (generatedImageUrl != null)
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!)),
            ),
          Visibility(
            visible: generatedContent == null && generatedImageUrl == null,
            child: Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                  child: const Text(
                    "Here are a few features",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                //Feature boxes with suggestions
                const FeatureBox(
                    title: "ChatGPT",
                    description:
                        "A smarter way to stay oranised and informed with ChatGPT",
                    color: Colors.lightGreen),
                const FeatureBox(
                    title: "Dall-E",
                    description:
                        "Get inspired and stay creative with your personal assistant powered by Dall-E",
                    color: Colors.deepPurple),
                const FeatureBox(
                    title: "Smart Voice Assistant",
                    description:
                        "Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT",
                    color: Color.fromARGB(255, 142, 245, 145))
              ],
            ),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechtoText.hasPermission && speechtoText.isNotListening) {
            await startListening();
          } else if (speechtoText.isListening) {
            final speech = await openAIService.isArtPromptAPI(lastWords);
            if (speech.contains('https')) {
              generatedImageUrl = speech;
              generatedContent = null;
              setState(() {});
            } else {
              generatedImageUrl = null;
              generatedContent = speech;
              setState(() {});
              await systemSpeak(speech);
            }
            await systemSpeak(speech);
            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        child: Icon(speechtoText.isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
