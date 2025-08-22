import 'dart:typed_data';
import 'package:flutter/foundation.dart';

// Web平台的文件操作兼容层
class PlatformFile {
  final String path;
  Uint8List? _data;
  
  PlatformFile(this.path);
  
  Future<bool> exists() async {
    if (kIsWeb) {
      // Web平台总是返回false，因为我们不能直接访问文件系统
      return _data != null;
    } else {
      // 非Web平台的实现会在实际项目中使用dart:io
      return false;
    }
  }
  
  Future<void> writeAsBytes(Uint8List data) async {
    if (kIsWeb) {
      _data = data;
    } else {
      // 非Web平台的实现
      throw UnimplementedError('Non-web platform file operations not implemented in this demo');
    }
  }
  
  Future<int> length() async {
    if (kIsWeb) {
      return _data?.length ?? 0;
    } else {
      return 0;
    }
  }
  
  Future<Uint8List> readAsBytes() async {
    if (kIsWeb) {
      return _data ?? Uint8List(0);
    } else {
      return Uint8List(0);
    }
  }
  
  Future<void> copy(String newPath) async {
    if (kIsWeb) {
      // Web平台模拟文件复制
      final newFile = PlatformFile(newPath);
      newFile._data = _data;
    } else {
      // 非Web平台的实现
      throw UnimplementedError('Non-web platform file operations not implemented in this demo');
    }
  }
}

class PlatformDirectory {
  final String path;
  
  PlatformDirectory(this.path);
  
  Future<bool> exists() async {
    if (kIsWeb) {
      // Web平台模拟目录存在
      return true;
    } else {
      return false;
    }
  }
  
  Future<void> create({bool recursive = false}) async {
    if (kIsWeb) {
      // Web平台不需要创建目录
      return;
    } else {
      // 非Web平台的实现
      throw UnimplementedError('Non-web platform directory operations not implemented in this demo');
    }
  }
  
  Future<void> delete({bool recursive = false}) async {
    if (kIsWeb) {
      // Web平台不需要删除目录
      return;
    } else {
      // 非Web平台的实现
      throw UnimplementedError('Non-web platform directory operations not implemented in this demo');
    }
  }
}