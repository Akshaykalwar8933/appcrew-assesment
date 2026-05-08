import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/widgets/app_theme.dart';
import '../controllers/notes_controller.dart';

class AddEditNoteView extends StatelessWidget {
  final bool isEdit;
  final String? docId;

  const AddEditNoteView({
    super.key,
    this.isEdit = false,
    this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final  controller = Get.find<NotesController>();
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textDark),
        ),
        title: Text(
          isEdit ? 'Edit Note' : 'New Note',
          style: const TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation<Color>(AppTheme.accent),
              ),
            ),
          )
              : TextButton(
            onPressed: () {
              if (isEdit) {
                controller.updateNote(docId!);
              } else {
                controller.addNote();
              }
            },
            child: Text(
              isEdit ? 'Update' : 'Save',
              style: const TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          )),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: controller.titleController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              decoration: const InputDecoration(
                hintText: 'Note title...',
                hintStyle: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textLight,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            SizedBox(height: 4.h),

            Divider(color: AppTheme.border),
            SizedBox(height: 16.h),

            // Content
            TextField(
              controller: controller.contentController,
              maxLines: null,
              minLines: 15,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textDark,
                height: 1.7,
              ),
              decoration: const InputDecoration(
                hintText: 'Start writing your note here...',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textLight,
                  height: 1.7,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}