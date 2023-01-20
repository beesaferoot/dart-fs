// Custom Exception Classes
class BlockIsNegativeException implements Exception {
  String cause = "";

  BlockIsNegativeException(int blocknum) {
    cause = "blocknum $blocknum is negative";
  }
}

class BlockIsTooLargeException implements Exception {
  String cause = "";

  BlockIsTooLargeException(int blocknum) {
    cause = "blocknum $blocknum is too large";
  }
}

class UnableToSeekBlock implements Exception {
  String cause = "";

  UnableToSeekBlock(int blocknum, String errorMessage) {
    cause = "Unable to seek block $blocknum: $errorMessage";
  }
}

class UnableToWriteBlock implements Exception {
  String cause = "";

  UnableToWriteBlock(int blocknum, String errorMessage) {
    cause = "Unable to read block $blocknum: $errorMessage";
  }
}

class UnableToReadBlock implements Exception {
  String cause = "";

  UnableToReadBlock(int blocknum, String errorMessage) {
    cause = "Unable to write to block $blocknum: $errorMessage";
  }
}
