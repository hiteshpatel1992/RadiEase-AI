import 'package:deepgram_speech_to_text/deepgram_speech_to_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fitway_report/templates/chrom_storage.dart';
import 'package:fitway_report/templates/template_saver.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html/parser.dart';
import 'package:record/record.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_library/sound_library.dart';
import 'package:html/parser.dart' show parse;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:html/dom.dart' as dom;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool isGemini = true;
  Deepgram? deepgram;
  final TextEditingController _controller = TextEditingController();
  DeepgramLiveTranscriber? transcriber;
  bool isRecordFetechFromChatgpt = false;
  String template = "";
  String _lastWords = '';
  String chatGpt = "";
  List<dynamic> templateList = [];
  List<String> templateName = [];
  final _openAI = OpenAI.instance.build(
      token:
          "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",
      baseOption: HttpSetup(
        receiveTimeout: const Duration(minutes: 2),
      ),
      enableLog: true);

  @override
  void initState() {
    super.initState();
    // initSystemTray();
    requestMicrophonePermission();
    dropDown();
    initSpeech();

    _controller.addListener(() {
      if (!isAudioStart) {
        setState(() {
          isAudioStart = false;
        });
      }
    });

    ;
  }

  Future<void> dropDown() async {
    templateList = [];
    templateName = [];
    templateList = jsonDecode(getFromLocalStorage("templates")!);

    if (templateList.length == 0) {
      String TemplateText =
          '''TECHNIQUE: Axial CT scan of the brain has been performed using 5 mm contiguous slices on Advanced 40/80 slice CT, without contrast. Additional sagittal and coronal reconstructions were done.
CLINICAL PROFILE:  COMPARISON: None.
FINDINGS:
Acute abnormalities: No obvious infarct or intra / extra-axial haemorrhage is seen. No focal lesion is seen. No midline shift or herniation is seen. 
Cerebral, cerebellar and brainstem parenchyma: The brain parenchyma, brainstem, and cerebellar hemispheres appear normal.
Extra axial spaces: Ventricular system and basal cisterns appear normal. 
Vascular system: Dural venous sinuses appear unremarkable. 
Calvarium: The calvarium and skull base appears normal. No fracture or any focal lesion.
Visualised paranasal sinuses: Clear.
Mastoids: Clear.
IMPRESSION:
No significant intracranial abnormality is seen on the CT head plain study. 
Suggest: Clinical correlation, further evaluation / follow up imaging.''';
      String templateName = "CT HEAD PLAIN STUDY";
      List<Map<String, dynamic>> ListData = [];
      ListData.add({"name": templateName, "template": TemplateText});
      saveToLocalStorage("templates", jsonEncode(ListData));
    }
    for (int i = 0; i < templateList.length; i++) {
      templateName.add(templateList[i]["name"]);
    }
    setState(() {});
  }

  void requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
    } else if (status.isDenied) {
    } else if (status.isPermanentlyDenied) {
      // You can show a dialog or redirect the user to the app settings
    }
  }

  Future<void> initSpeech() async {
    // if (!isGemini) {
    // } else {
    String apiKey = "0f8cf1518b92336f23c20b6a5d95ade6648cd499";

    Map<String, dynamic> params = {
      'model': 'nova-2-medical',
      'detect_language': false,
      'language': 'en-IN',
      "punctuate": true,
      'encoding': 'linear16',
      'sample_rate': 16000,
    };
    deepgram = Deepgram(apiKey, baseQueryParams: params);
    final isValid = await deepgram!.isApiKeyValid();

    Future.delayed(const Duration(seconds: 1), () {
      isAudioStart = true;
      SoundPlayer.play(Sounds.click);
      _startListening();
      setState(() {});
    });

    // }
  }

  void _startListening() async {
    final audioStream = await AudioRecorder().startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    ));
    transcriber = deepgram!.createLiveTranscriber(audioStream);
    transcriber!.start();
    transcriber!.stream.listen((json) async {
      String value =
          jsonDecode(json.json)["channel"]["alternatives"][0]["transcript"];
      if (value.isNotEmpty) {
        _lastWords = "$_lastWords $value";
        _controller.text = _lastWords;
        setState(() {});
      }
    });
  }

  void _stopListening() async {
    isAudioStart = false;
    if (transcriber!.isClosed == false) {
      transcriber!.close();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String textSendtoSpeech = "";
  bool isAudioStart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: isRecordFetechFromChatgpt
          ? Container(
              color: Colors.white,
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _stopListening();
                            chatGpt = "";
                            isAudioStart = false;
                            isRecordFetechFromChatgpt = false;
                            _lastWords = "";
                            _controller.text = "";
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.restart_alt,
                            color: Color.fromARGB(255, 102, 102, 102),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            final clipboard = ClipboardWriter.instance;
                            final item = DataWriterItem();
                            item.add(Formats.htmlText(chatGpt));
                            await clipboard.write([item]);
                          },
                          icon: const Icon(
                            Icons.copy,
                            color: Color.fromARGB(255, 102, 102, 102),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Html(
                        data: chatGpt,
                      ),
                    ),
                  ),

                  // ToolBar(
                  //   // toolBarColor: _toolbarColor,
                  //   padding: const EdgeInsets.all(8),
                  //   iconSize: 25,
                  //   // iconColor: _toolbarIconColor,
                  //   activeIconColor: Colors.greenAccent.shade400,
                  //   controller: _controller,
                  //   crossAxisAlignment: WrapCrossAlignment.start,
                  //   direction: Axis.horizontal,
                  //   customButtons: [
                  //     Container(
                  //       width: 25,
                  //       height: 25,
                  //       decoration: BoxDecoration(
                  //           // color: _hasFocus ? Colors.green : Colors.grey,
                  //           borderRadius: BorderRadius.circular(15)),
                  //     ),
                  //     const InkWell(
                  //       // onTap: () => unFocusEditor(),
                  //       child: const Icon(
                  //         Icons.favorite,
                  //         color: Colors.black,
                  //       ),
                  //     ),
                  //     InkWell(
                  //         onTap: () async {
                  //           var selectedText =
                  //               await _controller.getSelectedText();
                  //           debugPrint('selectedText $selectedText');
                  //           var selectedHtmlText =
                  //               await _controller.getSelectedHtmlText();
                  //           debugPrint('selectedHtmlText $selectedHtmlText');
                  //         },
                  //         child: const Icon(
                  //           Icons.add_circle,
                  //           color: Colors.black,
                  //         )),
                  //   ],
                  // ),
                  // Expanded(
                  //   child: QuillHtmlEditor(
                  //     padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  //     text: chatGpt,
                  //     isEnabled: true,
                  //     controller: _controller,
                  //     minHeight: 300,
                  //   ),
                  // ),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            chatGpt = "";
                            isAudioStart = false;
                            isRecordFetechFromChatgpt = false;
                            _lastWords = "";
                            _controller.text = "";
                            _stopListening();
                            setState(() {});
                          },
                          icon: const Icon(Icons.restart_alt),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const TemplateScreen(),
                                ));

                            dropDown();
                          },
                          icon: const Icon(
                            Icons.feed_outlined,
                            color: Color.fromARGB(255, 102, 102, 102),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _controller,
                        maxLines: null, // Allows for unlimited lines
                        onChanged: (value) {
                          _lastWords = value;
                        },

                        keyboardType:
                            TextInputType.multiline, // Allows multiline input
                        decoration: InputDecoration(
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0), // Border when enabled
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent,
                                  width: 1.0), // Border when focused
                            ),
                            labelText: 'Type or Speak!',
                            labelStyle: GoogleFonts.mulish(
                                fontSize: 22, color: Colors.grey)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        SizedBox(
                          height: 50,
                          width: 180,
                          child: DropdownSearch<String>(
                            suffixProps: DropdownSuffixProps(
                              dropdownButtonProps: DropdownButtonProps(
                                iconClosed: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.asset(
                                    "assets/drop_down.svg",
                                  ),
                                ),
                              ),
                            ),
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: "Templates",
                                labelStyle: GoogleFonts.mulish(
                                  fontSize: 14,
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 215, 215, 215),
                                      width: 1.0), // Focused border color
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue,
                                      width: 2.0), // Border color
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.green,
                                      width: 2.0), // Focused border color
                                ),
                              ),
                            ),
                            popupProps: PopupProps.menu(
                              itemBuilder:
                                  (context, item, isDisabled, isSelected) {
                                return ListTile(
                                  title: Text(
                                    item,
                                    style: GoogleFonts.mulish(
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              },
                              showSearchBox: true, // Enables the search box
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: "Search Template",
                                  hintStyle: GoogleFonts.mulish(
                                    fontSize: 14,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            items: (f, cs) => templateName,
                            onChanged: (value) {
                              int index = templateName.indexOf(value!);
                              template = templateList[index]["template"];
                            },
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                                onPressed: () {
                                  isAudioStart = isAudioStart ? false : true;
                                  if (isAudioStart) {
                                    SoundPlayer.play(Sounds.click);
                                    _startListening();
                                  } else {
                                    SoundPlayer.play(Sounds.action);
                                    _stopListening();
                                  }
                                  setState(() {});
                                },
                                icon: isAudioStart == false
                                    ? const Icon(
                                        Icons.mic,
                                        color:
                                            Color.fromARGB(255, 102, 102, 102),
                                      )
                                    : const Icon(
                                        Icons.pause,
                                        color:
                                            Color.fromARGB(255, 102, 102, 102),
                                      )),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        isAudioStart == false && _lastWords.isNotEmpty
                            ? Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  onPressed: () async {
                                    if (template.isNotEmpty) {
                                      sendDataToAIModel();
                                    } else {
                                      const snackBar = SnackBar(
                                        content:
                                            Text('Please select a template'),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  },
                                  icon: SvgPicture.asset(
                                    height: 20,
                                    width: 20,
                                    "assets/send.svg",
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
    );
  }

  Future<void> sendDataToAIModel() async {
    if (isGemini) {
      EasyLoading.show(status: 'loading...');
      Gemini.instance.promptStream(model: "gemini-1.5-pro", parts: [
        Part.text(
            // 'fill the template and not to change template Output in html format only : $_lastWords  Template:$template'
            'Output in html format only Fill in the attached report template with $_lastWords findings; maintain the architecture/formatting pattern of template:$template'),
      ]).listen((value) {
        chatGpt = "$chatGpt ${value!.output!}";
        String modifiedString = chatGpt.replaceAll("```html", "");
        String modifiedString2 = modifiedString.replaceAll("```", "");
        chatGpt = modifiedString2;
        isRecordFetechFromChatgpt = true;
        EasyLoading.dismiss(animation: true);
        setState(() {});
      });
    } else {
      List<Map<String, dynamic>> messagesHistory = [
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text":
                  "fill the template and not to change template Output in html format only : $_lastWords  Template:$template"
              // "text": "$_lastWords"
            },
          ]
        }
      ];
      EasyLoading.show(status: 'loading...');

      ChatModel? model = GptTurbo0301ChatModel();
      model.model = "gpt-4o";
      final request = ChatCompleteText(
        messages: messagesHistory,
        maxToken: 16380,
        model: model,
      );
      final response = await _openAI.onChatCompletion(request: request);

      for (var element in response!.choices) {
        chatGpt = element.message!.content;
      }
      String modifiedString = chatGpt.replaceAll("```html", "");
      String modifiedString2 = modifiedString.replaceAll("```", "");
      chatGpt = modifiedString2;
      isRecordFetechFromChatgpt = true;
      EasyLoading.dismiss(animation: true);
      setState(() {});
    }
  }

  TextSpan _parseHtmlToTextSpan(String html) {
    dom.Document document = parse(html); // Parse HTML
    return _convertNodeToTextSpan(document.body!);
  }

  // Helper function to convert parsed HTML nodes into TextSpan
  TextSpan _convertNodeToTextSpan(dom.Node node) {
    if (node.nodeType == dom.Node.TEXT_NODE) {
      return TextSpan(text: node.text);
    } else if (node.nodeType == dom.Node.ELEMENT_NODE) {
      dom.Element element = node as dom.Element;
      switch (element.localName) {
        case 'strong':
          return TextSpan(
              text: element.text,
              style: const TextStyle(fontWeight: FontWeight.bold));
        case 'em':
          return TextSpan(
              text: element.text,
              style: const TextStyle(fontStyle: FontStyle.italic));
        case 'h1':
          return TextSpan(
              text: element.text,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
        default:
          return TextSpan(text: element.text);
      }
    }
    return const TextSpan();
  }
}
