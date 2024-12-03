import 'dart:convert';

import 'package:fitway_report/templates/add_template_screen.dart';
import 'package:fitway_report/templates/chrom_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  _TemplateScreen createState() => _TemplateScreen();
}

class _TemplateScreen extends State<TemplateScreen> {
  List<dynamic> templateData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFromSharedPrefs();
  }

  Future<void> getDataFromSharedPrefs() async {
    templateData = jsonDecode(getFromLocalStorage("templates")!);
    setState(() {});
  }

  Future<void> callAddTemplateScreen() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddTemplateScreen(),
        ));
    getDataFromSharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                callAddTemplateScreen();
              },
              icon: const Icon(Icons.add))
        ],
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Templates",
          style: GoogleFonts.mulish(fontSize: 18),
        ),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: templateData.isNotEmpty
          ? Column(
              children: [
                Container(
                  height: 1,
                  color: const Color.fromARGB(255, 212, 212, 212),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: ListView.builder(
                      itemCount: templateData.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> temp = templateData[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              border: Border.all(
                                color: const Color.fromARGB(
                                    255, 215, 215, 215), // Border color
                                width: 1.0, // Border width
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 50,
                            // color: Colors.white,
                            child: Row(
                              children: [
                                Text("${temp["name"]}"),
                                const Spacer(),
                                IconButton(
                                  onPressed: () async {
                                    templateData.removeAt(index);
                                    // SharedPreferences prefs =
                                    //     await SharedPreferences.getInstance();

                                    saveToLocalStorage(
                                        "templates", jsonEncode(templateData));
                                    setState(() {});
                                  },
                                  icon: SvgPicture.asset(
                                    "assets/delete.svg",
                                    width: 20,
                                    height: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            )
          : Center(
              child: Column(
                children: [
                  Container(
                    height: 1,
                    color: const Color.fromARGB(255, 212, 212, 212),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/no_template.svg",
                          height: 100,
                          width: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "No Templates Yet!",
                          style: GoogleFonts.mulish(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        SizedBox(
                          height: 45,
                          width: 200,
                          child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                side: const BorderSide(
                                    width: 1.0,
                                    color: Color.fromARGB(255, 6, 0, 187)),
                              ),
                              onPressed: () {
                                callAddTemplateScreen();
                              },
                              child: Text(
                                "Add Template",
                                style: GoogleFonts.mulish(
                                    fontSize: 17,
                                    color:
                                        const Color.fromARGB(255, 6, 0, 187)),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
