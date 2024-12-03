import 'dart:convert';

import 'package:fitway_report/templates/chrom_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTemplateScreen extends StatefulWidget {
  const AddTemplateScreen({super.key});

  @override
  _AddTemplateScreen createState() => _AddTemplateScreen();
}

class _AddTemplateScreen extends State<AddTemplateScreen> {
  String tempName = "";
  String tempDescp = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Add Templates",
          style: GoogleFonts.mulish(fontSize: 18),
        ),
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Template Name",
              style: GoogleFonts.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 50,
              child: TextField(
                controller: TextEditingController(text: ""),
                // Allows for unlimited lines
                focusNode: FocusNode(),
                onChanged: (val) {
                  tempName = val;
                },
                keyboardType: TextInputType.multiline, // Allows multiline input
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 215, 215, 215),
                          width: 1.0), // Border when enabled
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 215, 215, 215),
                          width: 1.0), // Border when focused
                    ),
                    labelText: 'Enter Template Name',
                    labelStyle: GoogleFonts.mulish(
                        fontSize: 15,
                        color: const Color.fromARGB(255, 215, 215, 215))),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Paste Template",
              style: GoogleFonts.mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: TextField(
                minLines: 100,
                controller: TextEditingController(text: ""),
                maxLines: null, // Allows for unlimited lines
                focusNode: FocusNode(),
                keyboardType: TextInputType.multiline,
                onChanged: (val) {
                  tempDescp = val;
                },
                decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 215, 215, 215),
                          width: 1.0), // Border when enabled
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 215, 215, 215),
                          width: 1.0), // Border when focused
                    ),
                    labelText: 'Paste template here',
                    alignLabelWithHint: true,
                    labelStyle: GoogleFonts.mulish(
                        fontSize: 15,
                        color: const Color.fromARGB(255, 215, 215, 215))),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 125, 209),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  side: const BorderSide(
                      width: 1.0, color: Color.fromARGB(255, 0, 125, 209)),
                ),
                onPressed: () async {
                  if (tempName.isNotEmpty && tempDescp.isNotEmpty) {
                    if (getFromLocalStorage("templates") != null) {
                      List<dynamic> ListData =
                          jsonDecode(getFromLocalStorage("templates")!);

                      ListData.add({"name": tempName, "template": tempDescp});
                      saveToLocalStorage("templates", jsonEncode(ListData));
                    } else {
                      List<Map<String, dynamic>> ListData = [];
                      ListData.add({"name": tempName, "template": tempDescp});
                      saveToLocalStorage("templates", jsonEncode(ListData));
                    }
                    Navigator.pop(context);
                  } else {
                    const snackBar = SnackBar(
                      content: Text('Please fill all fields'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: Text(
                  "Save",
                  style: GoogleFonts.mulish(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
