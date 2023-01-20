import 'dart:typed_data';
import 'dart:convert';

import 'package:dart_fs/disk.dart';
import 'package:test/test.dart';

void main() {
  test('open disk image', () {
    var disk = Disk.open("test_image10", 10);
    expect(disk.name, "test_image10");
    expect(disk.size, 10);
    expect(disk.mounted, false);
    disk.remove();
  });

  test('write to disk', () {
    var disk = Disk.open("test_image10", 10);
    expect(disk.name, "test_image10");
    var data =
        ByteData.sublistView(Uint8List.fromList(utf8.encode("Hello World")));
    expect(() => disk.write(0, data), returnsNormally);
    expect(disk.writes, 1);

    expect(() => disk.write(1, data), returnsNormally);
    expect(disk.writes, 2);
    disk.remove();
  });

  test('read from disk', () {
  var disk = Disk.open("test_image10", 10);
  var wdata =
      ByteData.sublistView(Uint8List.fromList(utf8.encode("Hello World")));
  expect(() => disk.write(0, wdata), returnsNormally);
  var rdata = ByteData(disk.blocksize);
  disk.read(0, rdata);
  expect(() => disk.read(0, rdata), returnsNormally);
  var list =
      rdata.buffer.asUint8List(rdata.offsetInBytes, rdata.lengthInBytes);
    expect(utf8.decode(list.sublist(0, 11)), "Hello World");
    disk.remove();
  });

  test('test for corrupt disk read', () {
    var disk = Disk.open("data/test_image.5", 10);
    // var wdata =
    //     ByteData.sublistView(Uint8List.fromList(utf8.encode("Hello World")));
    // expect(() => disk.write(0, wdata), returnsNormally);
    var rdata = ByteData(disk.blocksize);
    disk.read(0, rdata);
    disk.close();
    // expect(() => disk.read(0, rdata), returnsNormally);
    // var list = rdata.buffer.asUint8List();
    // print(list.sublist(0, 11));
  });
}
