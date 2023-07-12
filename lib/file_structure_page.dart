import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:flutter_application_1/list_photos.dart';
import 'package:flutter_application_1/ShowVideo.dart';
import 'package:flutter_application_1/photos_page.dart';
import 'package:flutter_application_1/selected_photos.dart';
import 'package:flutter_application_1/shared_values.dart';
import 'package:flutter_application_1/show_qr_code_photo.dart';
import 'package:flutter_application_1/videos_page.dart';
import 'package:flutter_tree/flutter_tree.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'app_utility.dart';
import 'model/FileStructureNode.dart';

class FileStructurePage extends StatefulWidget {
  const FileStructurePage({super.key});

  @override
  State<FileStructurePage> createState() => _FileStructurePageState();
}

class _FileStructurePageState extends State<FileStructurePage> {
  List<TreeNodeData>? fileStructureNode;

  @override
  void initState() {
    super.initState();
    FileStructureProvider.getFileStructure().then((fileNode) {
      setState(() {
        fileStructureNode = fileNode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body:
          TreeView(data: fileStructureNode!)
    );
  }

}



class FileStructureProvider {
  static Future<List<TreeNodeData>> getFileStructure() async {
    final response = await http.get(Uri.parse(AppValues.getFileStructureForPhotos()));
    if (response.statusCode == 200) {
      var jsonData = {};
      jsonData = json.decode(response.body);
      //debugPrint("jsonData $jsonData");
      /*FileStructureNode fileStructureNode =  FileStructureNode(name: jsonData["name"],
          children: convertDynamicList(jsonData["children"]));*/
      List<TreeNodeData> treeData = List.generate(
        jsonData["children"].length,
            (index) => mapServerDataToTreeData(jsonData),
      );
      return treeData;
    } else {
      throw Exception('Failed to fetch videos');
    }
  }

  static List<FileStructureNode> convertDynamicList(List<dynamic> dynamicList) {
    List<FileStructureNode> fileNodeList = [];

    for (dynamic item in dynamicList) {
      if (item is Map<String, dynamic>) {
        // Convert the current item to a FileNode object
        FileStructureNode fileNode = FileStructureNode(
          name: item['name'],
          children: convertDynamicList(item['children'] ?? []),
        );

        fileNodeList.add(fileNode);
      }
    }

    return fileNodeList;
  }

  static TreeNodeData mapServerDataToTreeData(Map data) {
    return TreeNodeData(
      extra: data,
      title: data['name'],
      expaned: false,
      checked: false,
      children:
      List.from(data['children'].map((x) => mapServerDataToTreeData(x))),
    );
  }
}
