import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 图片处理服务
/// 负责图片选择、上传、格式转换等操作
class ImageProcessingService {
  ImageProcessingService._();
  static ImageProcessingService? _instance;

  static ImageProcessingService getInstance() {
    _instance ??= ImageProcessingService._();
    return _instance!;
  }

  final ImagePicker _picker = ImagePicker();

  /// 从相机拍照
  Future<File?> takePhoto() async {
    try {
      print('[ImageProcessingService.takePhoto] 📷 开始拍照');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // 压缩质量
        maxWidth: 1920, // 最大宽度
        maxHeight: 1920, // 最大高度
      );

      if (image == null) {
        print('[ImageProcessingService.takePhoto] ⚠️ 用户取消拍照');
        return null;
      }

      final file = File(image.path);
      print('[ImageProcessingService.takePhoto] ✅ 拍照成功: ${file.path}');
      return file;
    } catch (e) {
      print('[ImageProcessingService.takePhoto] ❌ 拍照失败: $e');
      rethrow;
    }
  }

  /// 从相册选择图片
  Future<File?> pickImageFromGallery() async {
    try {
      print('[ImageProcessingService.pickImageFromGallery] 🖼️ 开始选择图片');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) {
        print('[ImageProcessingService.pickImageFromGallery] ⚠️ 用户取消选择');
        return null;
      }

      final file = File(image.path);
      print(
          '[ImageProcessingService.pickImageFromGallery] ✅ 选择成功: ${file.path}');
      return file;
    } catch (e) {
      print('[ImageProcessingService.pickImageFromGallery] ❌ 选择失败: $e');
      rethrow;
    }
  }

  /// 保存图片到应用目录
  ///
  /// [imageFile] 原始图片文件
  /// [fileName] 保存的文件名（可选）
  ///
  /// 返回保存后的文件路径
  Future<String> saveImageToAppDirectory(File imageFile,
      {String? fileName}) async {
    try {
      print('[ImageProcessingService.saveImageToAppDirectory] 💾 开始保存图片');

      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(appDir.path, 'transaction_images'));

      // 创建目录（如果不存在）
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // 生成文件名
      final name = fileName ??
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final savedPath = path.join(imagesDir.path, name);

      // 复制文件
      await imageFile.copy(savedPath);

      print(
          '[ImageProcessingService.saveImageToAppDirectory] ✅ 保存成功: $savedPath');
      return savedPath;
    } catch (e) {
      print('[ImageProcessingService.saveImageToAppDirectory] ❌ 保存失败: $e');
      rethrow;
    }
  }

  /// 将图片转换为Base64编码
  ///
  /// [imageFile] 图片文件
  ///
  /// 返回Base64编码的字符串（包含data URI前缀）
  Future<String> convertToBase64(File imageFile) async {
    try {
      print('[ImageProcessingService.convertToBase64] 🔄 开始转换Base64');

      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);

      // 获取文件扩展名以确定MIME类型
      final extension = path.extension(imageFile.path).toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == '.png') {
        mimeType = 'image/png';
      } else if (extension == '.gif') {
        mimeType = 'image/gif';
      } else if (extension == '.webp') {
        mimeType = 'image/webp';
      }

      final dataUri = 'data:$mimeType;base64,$base64String';

      print(
          '[ImageProcessingService.convertToBase64] ✅ 转换完成，大小: ${bytes.length} bytes');
      return dataUri;
    } catch (e) {
      print('[ImageProcessingService.convertToBase64] ❌ 转换失败: $e');
      rethrow;
    }
  }

  /// 删除图片文件
  ///
  /// [imagePath] 图片路径
  Future<void> deleteImage(String imagePath) async {
    try {
      print('[ImageProcessingService.deleteImage] 🗑️ 开始删除图片: $imagePath');

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('[ImageProcessingService.deleteImage] ✅ 删除成功');
      } else {
        print('[ImageProcessingService.deleteImage] ⚠️ 文件不存在');
      }
    } catch (e) {
      print('[ImageProcessingService.deleteImage] ❌ 删除失败: $e');
      // 不抛出异常，静默处理
    }
  }

  /// 获取图片文件大小（字节）
  Future<int> getImageSize(File imageFile) async {
    try {
      return await imageFile.length();
    } catch (e) {
      print('[ImageProcessingService.getImageSize] ❌ 获取大小失败: $e');
      return 0;
    }
  }

  /// 检查图片文件是否存在
  Future<bool> imageExists(String imagePath) async {
    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}
