import 'dart:typed_data';

import 'package:dart_fs/fs.dart';
import 'package:dart_fs/disk.dart';
import 'package:test/test.dart';


void main() {
  test('Debug fs', () {
    var disk = Disk.open("data/image.5", 5);
    var fs = Fs(disk);
    expect(() => fs.debug(), returnsNormally);
    print(fs.superblock);
  });
}
