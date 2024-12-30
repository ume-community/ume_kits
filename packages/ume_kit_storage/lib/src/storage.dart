import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ume_core/ume_core.dart';

import 'package:path_provider/path_provider.dart';

import 'package:ume_kit_storage/src/directory_inspector.dart';

const storageIconData =
    r'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';

final storageIconBytes = base64Decode(storageIconData);

class Storage extends StatefulWidget implements Pluggable {
  @override
  _StorageState createState() => _StorageState();

  @override
  Widget buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => MemoryImage(storageIconBytes);

  @override
  String get name => 'Storage';

  @override
  String get displayName => 'Storage';

  @override
  void onTrigger() {}
}

class _StorageState extends State<Storage> {
  Future<Map<String, List<Directory?>>> getDirectories() async {
    var directories = <String, List<Directory?>>{};
    directories['Temporary'] = [await getTemporaryDirectory()];
    directories['Application Documents'] = [
      await getApplicationDocumentsDirectory()
    ];

    directories['Application Support'] = [
      await getApplicationSupportDirectory()
    ];

    if (Platform.isIOS || Platform.isMacOS) {
      directories['Library'] = [await getLibraryDirectory()];
    }

    directories['Application Documents'] = [
      await getApplicationDocumentsDirectory()
    ];

    directories['Application Cache'] = [await getApplicationCacheDirectory()];

    if (!Platform.isMacOS) {
      directories['External Storage'] = [await getExternalStorageDirectory()];
      directories['External Cache'] = await getExternalCacheDirectories() ?? [];
      directories['External Storage'] =
          await getExternalStorageDirectories() ?? [];
    }

    directories['Downloads'] = [await getDownloadsDirectory()];
    return directories;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage'),
      ),
      body: FutureBuilder<Map<String, List<Directory?>>>(
          future: getDirectories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final directories = snapshot.data!;

            return ListView.builder(
              itemCount: directories.length,
              itemBuilder: (context, index) {
                final directory = directories.values.elementAt(index);
                return ListTile(
                    leading: Icon(Icons.storage),
                    title: Text(directories.keys.elementAt(index)),
                    subtitle:
                        Text(directories.values.elementAt(index).toString()),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      // 遍历目录下所有文件
                      for (var dir in directory) {
                        debugPrint('Directory: ${dir?.path}');
                        // 获取目录下所有文件
                        final files = await dir?.list().toList();
                        debugPrint('Files: ${files}');
                      }
                    });
              },
            );
          }),
    );
  }
}         // ExpansionTile(
                //   title: Text(directories.keys.elementAt(index)),
                //   subtitle: Text(directory.toString()),
                //   children: [
                //     DirectoryInspectorPage(
                //         directory: directory.elementAt(0) ?? Directory(''))
                //   ],
                // );

           // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DirectoryInspectorPage(
                      //       directory: directory.elementAt(0) ?? Directory(''),
                      //     ),
                      //   ),
                      // );