import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class UploadedFile {
  final String fileName;
  final Uint8List bytes;
  final DateTime uploadDate;
  final bool isPdf;

  UploadedFile({
    required this.fileName,
    required this.bytes,
    required this.uploadDate,
    this.isPdf = false,
  });
}

class DocumentItem {
  final String type;
  final String requiredFormat;
  final List<UploadedFile> files = []; // List of uploaded files
  final TextEditingController textController;

  DocumentItem({
    required this.type,
    required this.requiredFormat,
  }) : textController = TextEditingController();

  bool get isUploaded =>
      files.isNotEmpty || textController.text.trim().isNotEmpty;

  void dispose() {
    textController.dispose();
  }
}

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final List<DocumentItem> _documents = [
    DocumentItem(type: 'Consent Form', requiredFormat: 'Image'),
    DocumentItem(type: 'Surgery Notes', requiredFormat: 'Image'),
    DocumentItem(type: 'Lab Reports', requiredFormat: 'Image'),
    DocumentItem(type: 'Radiology Reports', requiredFormat: 'Image'),
    DocumentItem(type: 'Discharge Summary', requiredFormat: 'Image'),
    DocumentItem(type: 'Implant Invoice', requiredFormat: 'Image'),
    DocumentItem(type: 'Clinical Photos', requiredFormat: 'Image'),
  ];

  @override
  void dispose() {
    for (var doc in _documents) {
      doc.dispose();
    }
    super.dispose();
  }

  /// Opens the file picker using file_picker (cross-platform).
  Future<void> _pickFile(int index) async {
    final doc = _documents[index];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true, // Needed for web and to get bytes directly
    );

    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    final bytes = pickedFile.bytes;
    if (bytes == null) return;

    final isPdf = pickedFile.extension?.toLowerCase() == 'pdf';

    if (!mounted) return;
    setState(() {
      doc.files.add(UploadedFile(
        fileName: pickedFile.name,
        bytes: bytes,
        uploadDate: DateTime.now(),
        isPdf: isPdf,
      ));
    });
  }

  void _removeFile(int docIndex, int fileIndex) {
    setState(() {
      _documents[docIndex].files.removeAt(fileIndex);
    });
  }

  /// Full-screen zoomable image preview dialog, or opens PDF.
  void _showPreview(UploadedFile file) {
    if (file.isPdf) {
      // PDF viewing is complex cross-platform. 
      // For now, we'll suggest using a PDF viewer or just showing a message.
      // On web, we could still use dart:html if we wanted, but let's stay platform-agnostic.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF Preview not implemented for desktop yet. Only images can be previewed.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                file.fileName,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.memory(file.bytes, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _submitFinalClaim() {
    final allUploaded = _documents.every((d) => d.isUploaded);

    if (!allUploaded) {
      final missing = _documents
          .where((d) => !d.isUploaded)
          .map((d) => d.type)
          .join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pending: $missing'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('Success', style: AppTextStyles.heading2),
          ],
        ),
        content: const Text(
          'All documents uploaded. Claim has been submitted successfully.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text(
              'Return to Dashboard',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Step 4 — Document Upload',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryDark,
        elevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Card ────────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.lightGrey.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.file_upload_outlined,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Upload Required Documents',
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload an image for each document. '
                        'Tap the thumbnail to zoom in, then fill in the notes field manually.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Responsive layout
                      LayoutBuilder(
                        builder: (ctx, constraints) =>
                            constraints.maxWidth > 620
                            ? _buildDesktopTable()
                            : _buildMobileList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Submit button ────────────────────────────────────────────
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _submitFinalClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Finalize Claim Submission',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Desktop table ──────────────────────────────────────────────────────────

  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5), // Document type
          1: FlexColumnWidth(1.1), // Thumbnail
          2: FlexColumnWidth(2.8), // Notes text field
          3: FlexColumnWidth(1.3), // Status
          4: FlexColumnWidth(1.0), // Action
        },
        border: TableBorder(
          horizontalInside: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.5),
          ),
        ),
        children: [
          // Header row
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            children: [
              _tableHeader('Document Type'),
              _tableHeader('Preview'),
              _tableHeader('Notes / Data'),
              _tableHeader('Status'),
              _tableHeader('Action'),
            ],
          ),
          for (int i = 0; i < _documents.length; i++) _buildDesktopRow(i),
        ],
      ),
    );
  }

  TableRow _buildDesktopRow(int i) {
    final doc = _documents[i];
    return TableRow(
      children: [
        // Document name
        _tableCell(doc.type, isBold: true),

        // Thumbnail(s)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: doc.files.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(doc.files.length, (fileIndex) {
                    final file = doc.files[fileIndex];
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () => _showPreview(file),
                          child: Tooltip(
                            message: 'Click to zoom',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: file.isPdf
                                  ? Container(
                                      height: 60,
                                      width: 74,
                                      color: AppColors.lightGrey.withOpacity(0.3),
                                      child: const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.redAccent,
                                        size: 32,
                                      ),
                                    )
                                  : Image.memory(
                                      file.bytes,
                                      height: 60,
                                      width: 74,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: GestureDetector(
                            onTap: () => _removeFile(i, fileIndex),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.cancel,
                                color: AppColors.error,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                )
              : _emptyThumbnail(),
        ),

        // Notes field
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: TextFormField(
            controller: doc.textController,
            maxLines: 3,
            minLines: 1,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Type document notes / key data here…',
              hintStyle: const TextStyle(
                color: AppColors.darkGrey,
                fontSize: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.lightGrey),
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),

        // Status
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: _statusWidget(doc),
        ),

        // Upload / Add More button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _pickFile(i),
              icon: Icon(
                doc.files.isNotEmpty ? Icons.add_a_photo : Icons.upload_file,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                doc.files.isNotEmpty ? 'Add More' : 'Upload',
                style: const TextStyle(color: AppColors.primary, fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile list ────────────────────────────────────────────────────────────

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _documents.length,
      separatorBuilder: (_, __) =>
          const Divider(color: AppColors.lightGrey, height: 1),
      itemBuilder: (_, i) {
        final doc = _documents[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      doc.type,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickFile(i),
                    icon: Icon(
                      doc.files.isNotEmpty ? Icons.add_a_photo : Icons.upload_file,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      doc.files.isNotEmpty ? 'Add More' : 'Upload',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image preview(s)
              if (doc.files.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(doc.files.length, (fileIndex) {
                      final file = doc.files[fileIndex];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: () => _showPreview(file),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: file.isPdf
                                    ? Container(
                                        height: 120,
                                        width: 160,
                                        color: AppColors.lightGrey.withOpacity(0.3),
                                        child: const Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.redAccent,
                                          size: 50,
                                        ),
                                      )
                                    : Image.memory(
                                        file.bytes,
                                        height: 120,
                                        width: 160,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: GestureDetector(
                                onTap: () => _removeFile(i, fileIndex),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.cancel,
                                    color: AppColors.error,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                )
              else ...[
                _emptyThumbnail(fullWidth: true),
              ],
              const SizedBox(height: 12),

              // Notes field
              TextFormField(
                controller: doc.textController,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type document notes / key data here…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.lightGrey),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),

              // Status
              _statusWidget(doc),
            ],
          ),
        );
      },
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────

  Widget _emptyThumbnail({bool fullWidth = false}) {
    return Container(
      height: fullWidth ? 100 : 68,
      width: fullWidth ? double.infinity : 84,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.8)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: AppColors.darkGrey, size: 26),
          SizedBox(height: 4),
          Text(
            'No file uploaded',
            style: TextStyle(fontSize: 11, color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }

  Widget _statusWidget(DocumentItem doc) {
    if (doc.files.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 15),
              const SizedBox(width: 4),
              Text(
                '${doc.files.length} File${doc.files.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(doc.files.last.uploadDate),
            style: const TextStyle(color: AppColors.darkGrey, fontSize: 11),
          ),
        ],
      );
    } else if (doc.textController.text.trim().isNotEmpty) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 15),
          SizedBox(width: 4),
          Text(
            'Manual Entry',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      );
    } else {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pending_actions, color: AppColors.warning, size: 15),
          SizedBox(width: 4),
          Text(
            'Pending',
            style: TextStyle(
              color: AppColors.warning,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      );
    }
  }

  Widget _tableHeader(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.dark,
        fontSize: 13,
      ),
    ),
  );

  Widget _tableCell(String text, {bool isBold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
        color: isBold ? AppColors.dark : AppColors.darkGrey,
        fontSize: 13,
      ),
    ),
  );

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';
}
