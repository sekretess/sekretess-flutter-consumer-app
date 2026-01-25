enum MessageType {
  advertisement,
  keyDistribution,
  private,
  unknown;

  static MessageType fromString(String name) {
    switch (name.toLowerCase()) {
      case 'advert':
        return MessageType.advertisement;
      case 'key_dist':
        return MessageType.keyDistribution;
      case 'private':
        return MessageType.private;
      default:
        return MessageType.unknown;
    }
  }
}
