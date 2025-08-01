import 'dart:developer' show log;
import 'dart:io';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clipzy/constants.dart';
import 'package:clipzy/models/user.dart' as model;
import 'package:clipzy/views/screens/auth/login_screen.dart';
import 'package:clipzy/views/screens/home_screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  final Rx<File?> _pickedImage = Rx<File?>(null);
  RxBool isLoading = false.obs; // Add this

  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      _pickedImage.value = File(pickedImage.path);
      Get.snackbar(
        'Profile Picture',
        'You have successfully selected your profile picture!',
      );
    }
  }

  Future<String?> uploadProfileImageToCloudinary(File imageFile) async {
    final cloudinary = Cloudinary.fromStringUrl(
      'cloudinary://328191118841655:G0iHWlPWO3rxz_q1K1_NssxSNu4@dsilgv85z',
    );
    try {
      var response = await cloudinary.uploader().upload(imageFile);
      return response?.data?.url;
    } catch (e) {
      log('Cloudinary profile image upload error: $e');
      return null;
    }
  }

  // registering the user
  Future<void> registerUser(
    String username,
    String email,
    String password,
    File? image,
  ) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // Create user with email & password
        isLoading.value = true; // Start loading
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Upload profile photo to Cloudinary
        String? photoUrl = await uploadProfileImageToCloudinary(image);
        // Fallback to default if Cloudinary fails
        photoUrl ??=
            'https://www.pngitem.com/pimgs/m/150-1503945_transparent-user-png-default-user-image-png-png.png';

        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: photoUrl.replaceAll("http:", "https:"),
        );
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
        Get.snackbar('Success', 'Account created!');
      } else {
        Get.snackbar('Error Creating Account', 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar('Error Creating Account', e.toString());
    } finally {
      isLoading.value = false; // End loading
    }
  }

  void loginUser(String email, String password) async {
    try {
      isLoading.value = true; // Start loading

      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        Get.snackbar('Error Logging in', 'Please enter all the fields');
      }
    } catch (e) {
      Get.snackbar('Error Logging in', e.toString());
    } finally {
      isLoading.value = false; // End loading
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }
}
