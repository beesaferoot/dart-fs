import 'dart:typed_data';
import 'dart:io';

import 'package:dart_fs/disk.dart';

abstract class FileSystem {
  void debug();
  void format();
  int stat();
  int create();
  void remove(int inumber);
  void write(int inumber, DataBlock data);
  DataBlock read(int inumber);
}

class Fs implements FileSystem {
  static final magicNumber = 0xf0f03410;
  static final inodesPerBlock = 128;
  static final pointersPerInode = 5;
  static final pointersPerBlock = 1024;
  Disk _disk;
  List<int> _freeBlockBitMap;
  SuperBlock? _superBlock;
  List<InodeBlock>? _inodeBlocks;
  DataBlock? _data;

  Fs(Disk disk)
      : _disk = disk,
        _freeBlockBitMap = [];

  factory Fs.mount(Disk disk) {
    var fs = Fs(disk);
    fs.loadSuperBlock();
    // TODO: load inodes from disk
    // TODO: initialize free block bitmap (_freeBlockBitMap)
    fs._disk.mount();
    return fs;
  }

  void loadSuperBlock() {
    var bdata = ByteData(_disk.blocksize);
    // read in super block (block zero) from disk
    _disk.read(0, bdata);
    _superBlock = SuperBlock.fromBytes(bdata);
  }

  @override
  void debug() {
    loadSuperBlock();
  }

  @override
  void format() {}

  @override
  int stat() {
    // TODO: implement method
    return 1;
  }

  @override
  int create() {
    // TODO: implement method
    return 1;
  }

  @override
  void remove(int inumber) {}

  @override
  void write(int inumber, DataBlock block) {
    var buff = ByteData.sublistView(block.data);
    _disk.write(inumber, buff);
  }

  @override
  DataBlock read(int inumber) {
    // TODO: implement method
    var bdata = ByteData(_disk.blocksize);
    _disk.read(inumber, bdata);
    return DataBlock(
        bdata.buffer.asUint8List(bdata.offsetInBytes, bdata.lengthInBytes));
  }

  get superblock => _superBlock.toString();
  get magicNo => magicNumber;
  get inodeBlocks => inodesPerBlock;
}

class SuperBlock {
  final int _magicNumber;
  int _blocks;
  int _inodeBlocks;
  int _inodes;

  SuperBlock(
      {required int magicNum,
      required int blocks,
      required int inodeblocks,
      required int inodes})
      : _blocks = blocks,
        _inodeBlocks = inodeblocks,
        _inodes = inodes,
        _magicNumber = magicNum;

  factory SuperBlock.fromBytes(ByteData data) {
    var magicNumber = data.getUint32(0, Endian.little); // takes 4 bytes store
    var blocks = data.getUint32(4, Endian.little); // next 4 bytes
    var inodeBlocks = data.getUint32(8, Endian.little); // next 4 bytes
    var inodes = data.getUint32(12, Endian.little);
    return SuperBlock(
        magicNum: magicNumber,
        blocks: blocks,
        inodeblocks: inodeBlocks,
        inodes: inodes);
  }

  ByteData toBytes() {
    // serializes member fields into bytedata
    var builder = BytesBuilder();
    builder.addByte(_magicNumber);
    builder.addByte(_blocks);
    builder.addByte(_inodeBlocks);
    builder.addByte(_inodeBlocks);
    return ByteData.sublistView(builder.takeBytes());
  }

  @override
  String toString() {
    var strBuffer = StringBuffer("");
    strBuffer.writeln("SuperBlock:");
    strBuffer.writeln("        $_blocks blocks");
    strBuffer.writeln("        $_inodeBlocks inode blocks");
    strBuffer.writeln("        $_inodes inodes");
    return strBuffer.toString();
  }
}

class Inode {
  bool _valid;
  int _size;
  List<int> _directBlock;
  int _indirectBlock;

  Inode({required List<int> directBlock, required indirectBlock})
      : _directBlock = directBlock,
        _indirectBlock = indirectBlock,
        _size = directBlock.length,
        _valid = directBlock.isNotEmpty;
}

class InodeBlock {
  final List<int> _inodes;

  InodeBlock(this._inodes);
}

class DataBlock {
  Uint8List data;

  DataBlock(this.data);
  factory DataBlock.fromByteData(ByteData data) {
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    return DataBlock(bytes);
  }
}
