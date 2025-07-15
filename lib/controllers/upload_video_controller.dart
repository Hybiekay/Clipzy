import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_api/uploader/uploader_utils.dart';
import 'package:cloudinary_api/src/request/model/uploader_params.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_url_gen/transformation/transformation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:clipzy/models/video.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  RxDouble uploadProgress = 0.0.obs;
  RxBool isUploading = false.obs;
  RxString status = "".obs;
  var cloudinary = Cloudinary.fromStringUrl(
    'cloudinary://132994723556147:aVSUhDoUYleignd1YjqvyQAmrLg@dtn3mnyya',
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<File> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo!.file!;
  }

  Future<File> _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  Future<String?> _uploadVideoToCloudinary(File file) async {
    try {
      isUploading.value = true;
      uploadProgress.value = 0.0;

      var response = await cloudinary.uploader().upload(
        file,
        progressCallback: (sent, total) {
          uploadProgress.value = sent / total;
        },
        params: UploadParams(resourceType: 'video', format: 'mp4'),
      );

      isUploading.value = false;
      return response?.data?.url;
    } catch (e) {
      isUploading.value = false;
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  // Same for _uploadFileToCloudinary if you want thumbnail progress

  Future<String?> _uploadFileToCloudinary(File file) async {
    try {
      var response = await cloudinary.uploader().upload(
        file,

        progressCallback: (val, le) {
          print("the $val, and the $le");
        },
      );
      print('Cloudinary response: ${response?.data?.url}');
      return response?.data?.url;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  Future<void> uploadVideo(
    String songName,
    String caption,
    String videoPath,
    File videoFile,
  ) async {
    try {
      String uid = _auth.currentUser!.uid;
      String videoId = Uuid().v4();
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      // File compressedVideo = await _compressVideo(videoPath);
      String? videoUrl = await _uploadVideoToCloudinary(videoFile);
      File thumbnailFile = await _getThumbnail(videoPath);
      String? thumbnailUrl = await _uploadFileToCloudinary(thumbnailFile);

      if (videoUrl == null || thumbnailUrl == null) {
        Get.snackbar('Error', 'Cloudinary upload failed');
        return;
      }

      Video video = Video(
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        uid: uid,
        id: videoId,
        likes: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
        thumbnail: thumbnailUrl,
      );

      print('Saving video metadata to Firestore...');
      await _firestore.collection('videos').doc(videoId).set(video.toJson());
      print('Saved video metadata to Firestore!');
      Get.back();
      Get.snackbar(
        'Success',
        'Video uploaded to Cloudinary and saved in Firebase!',
      );
    } catch (e) {
      print('Error saving video: $e');
      Get.snackbar('Error Uploading Video', e.toString());
    }
  }
}
