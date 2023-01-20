import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:dart_fs/exceptions.dart';

class Disk {
  static const blockSize = 4096;
  final String name;
  File? _file;
  RandomAccessFile? _accessFile;
  int _blocks = 0;
  int _reads = 0;
  int _writes = 0;
  int _mounts = 0;

  Disk(this.name);

  Disk.open(String path, int nblocks) : name = path {
    _file = File(path);
    _blocks = nblocks;
    _file?.createSync();
    _accessFile = _file?.openSync(mode: FileMode.append);
    _accessFile?.truncateSync(nblocks * blockSize);
  }

  get blocksize => blockSize;

  void remove() {
    close();
    _file?.delete();
  }

  void close() {
    _accessFile?.closeSync();
  }

  get size => _blocks;

  get writes => _writes;

  get reads => _reads;

  get mounted => _mounts > 0;

  void unmount() {
    if (_mounts > 0) {
      _mounts--;
    }
  }

  void mount() {
    _mounts++;
  }

  read(int blocknum, ByteData data) {
    _sanityCheck(blocknum);
    try {
      _accessFile?.setPositionSync(blocknum * blockSize);
    } on FileSystemException catch (e) {
      throw UnableToSeekBlock(blocknum, e.message);
    }
    try {
      _accessFile?.readIntoSync(data.buffer.asUint8List());
    } on FileSystemException catch (e) {
      throw UnableToReadBlock(blocknum, e.message);
    }
    _reads++;
  }

  void write(int blocknum, ByteData data) {
    _sanityCheck(blocknum);
    try {
      _accessFile?.setPositionSync(blocknum * blockSize);
    } on FileSystemException catch (e) {
      throw UnableToSeekBlock(blocknum, e.message);
    }

    final buffer = data.buffer;
    try {
      _accessFile?.writeFromSync(buffer.asInt8List());
    } on FileSystemException catch (e) {
      throw UnableToWriteBlock(blocknum, e.message);
    }
    _writes++;
  }

  void _sanityCheck(int blocknum) {
    if (blocknum < 0) {
      throw BlockIsNegativeException(blocknum);
    }
    if (blocknum >= _blocks) {
      throw BlockIsTooLargeException(blocknum);
    }
  }
}
