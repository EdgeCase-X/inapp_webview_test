import 'dart:io';

import 'package:flutter/material.dart';

import '../pages/load_web_archive_page.dart';

class ArchiveGridWidget extends StatelessWidget {
  final List<FileSystemEntity> mhtFiles;
  const ArchiveGridWidget({super.key, required this.mhtFiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:
          mhtFiles.isEmpty
              ? Center(child: Text('No archives found.'))
              : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: mhtFiles.length,
                itemBuilder: (context, index) {
                  final file = mhtFiles[index];
                  final fileName = file.path.split(Platform.pathSeparator).last;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  LoadWebArchivePage(archiveFileName: fileName),
                        ),
                      );
                    },
                    child: Card(
                      child: Center(
                        child: Text(
                          fileName,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
