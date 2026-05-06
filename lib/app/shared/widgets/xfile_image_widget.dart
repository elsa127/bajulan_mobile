import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget untuk menampilkan XFile (hasil image_picker)
/// yang support Flutter Web maupun Mobile/Desktop.
class XFileImage extends StatefulWidget {
  final XFile xfile;
  final BoxFit fit;
  final double? width;
  final double? height;

  const XFileImage({
    super.key,
    required this.xfile,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<XFileImage> createState() => _XFileImageState();
}

class _XFileImageState extends State<XFileImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    // Selalu load bytes — works on both web and mobile
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    final bytes = await widget.xfile.readAsBytes();
    if (mounted) setState(() => _bytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Image.memory(
      _bytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
    );
  }
}
