import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'ai_analysis_result_screen.dart';

class DocumentItem {
  final String type;
  final String requiredFormat;
  String? fileName;
  DateTime? uploadDate;

  DocumentItem({
    required this.type,
    required this.requiredFormat,
    this.fileName,
    this.uploadDate,
  });

  bool get isUploaded => fileName != null && uploadDate != null;
}

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final List<DocumentItem> _documents = [
    DocumentItem(type: 'Consent Form', requiredFormat: 'PDF'),
    DocumentItem(type: 'Surgery Notes', requiredFormat: 'PDF'),
    DocumentItem(type: 'Lab Reports', requiredFormat: 'PDF'),
    DocumentItem(type: 'Radiology Reports', requiredFormat: 'PDF'),
    DocumentItem(type: 'Discharge Summary', requiredFormat: 'PDF'),
    DocumentItem(type: 'Implant Invoice', requiredFormat: 'PDF'),
    DocumentItem(type: 'Clinical Photos', requiredFormat: 'Image'),
  ];

  Future<void> _pickAndUploadFile(int index) async {
    final doc = _documents[index];

    FileType fileType = FileType.any;
    List<String>? allowedExtensions;

    if (doc.requiredFormat == 'PDF') {
      fileType = FileType.custom;
      allowedExtensions = ['pdf'];
    } else if (doc.requiredFormat == 'Image') {
      fileType = FileType.image;
    }

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          doc.fileName = result.files.first.name;
          doc.uploadDate = DateTime.now();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${doc.type} uploaded successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _submitFinalClaim() {
    final allUploaded = _documents.every((doc) => doc.isUploaded);

    if (!allUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents to proceed.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AiAnalysisResultScreen()),
    );
  }

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
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      color: AppColors.lightGrey.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
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
                        'Please upload all necessary documents to complete the claim submission. Accepted formats: PDF, Image.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Desktop Table View / Mobile List View based on LayoutBuilder
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            return _buildDesktopTable();
                          } else {
                            return _buildMobileList();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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

  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
        },
        border: TableBorder(
          horizontalInside: BorderSide(
            color: AppColors.lightGrey.withValues(alpha: 0.5),
          ),
        ),
        children: [
          // Table Header
          TableRow(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            children: [
              _buildTableHeader('Document Type'),
              _buildTableHeader('Format'),
              _buildTableHeader('Status'),
              _buildTableHeader('Action'),
            ],
          ),
          // Table Rows
          for (int i = 0; i < _documents.length; i++)
            TableRow(
              children: [
                _buildTableCell(_documents[i].type, isBold: true),
                _buildTableCell(_documents[i].requiredFormat),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  child: _documents[i].isUploaded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _documents[i].fileName!,
                                    style: const TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Uploaded: ${_formatDate(_documents[i].uploadDate!)}',
                              style: const TextStyle(
                                color: AppColors.darkGrey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          children: [
                            Icon(
                              Icons.pending_actions,
                              color: AppColors.warning,
                              size: 16,
                            ),
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
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => _pickAndUploadFile(i),
                      icon: Icon(
                        _documents[i].isUploaded
                            ? Icons.refresh
                            : Icons.upload_file,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        _documents[i].isUploaded ? 'Replace' : 'Upload',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _documents.length,
      separatorBuilder: (context, index) =>
          const Divider(color: AppColors.lightGrey, height: 1),
      itemBuilder: (context, index) {
        final doc = _documents[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.type,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: Text(
                            'Required: ${doc.requiredFormat}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _pickAndUploadFile(index),
                    icon: Icon(
                      doc.isUploaded ? Icons.refresh : Icons.upload_file,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      doc.isUploaded ? 'Replace' : 'Upload',
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
              if (doc.isUploaded) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.fileName!,
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Uploaded: ${_formatDate(doc.uploadDate!)}',
                              style: TextStyle(
                                color: AppColors.success.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
            color: isBold ? AppColors.dark : AppColors.darkGrey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
