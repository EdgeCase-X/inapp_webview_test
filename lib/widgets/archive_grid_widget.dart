import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../pages/load_web_archive_page.dart';

class ArchiveGridWidget extends StatefulWidget {
  final List<FileSystemEntity> mhtFiles;
  const ArchiveGridWidget({super.key, required this.mhtFiles});

  @override
  State<ArchiveGridWidget> createState() => _ArchiveGridWidgetState();
}

class _ArchiveGridWidgetState extends State<ArchiveGridWidget> {
  late List<FileSystemEntity> _files;

  @override
  void initState() {
    super.initState();
    _files = List<FileSystemEntity>.from(widget.mhtFiles);
  }

  void _deleteAll() async {
    for (final file in _files) {
      try {
        await file.delete();
      } catch (_) {}
    }
    setState(() {
      _files.clear();
    });
    if (mounted) {
      Fluttertoast.showToast(
        msg: 'All .mht files deleted.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              _files.isEmpty
              ? Center(child: Text('No archives found.'))
              : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      final fileName =
                          file.path.split(Platform.pathSeparator).last;
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => LoadWebArchivePage(
                                    archiveFileName: fileName,
                                  ),
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
        ),
        if (_files.isNotEmpty)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _deleteAll,
              tooltip: 'Delete all .mht files',
              child: Icon(Icons.delete),
            ),
          ),
      ],
    );
  }
}
