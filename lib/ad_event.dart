class AdEvent {
  final String name;
  final String spotId;

  AdEvent({required this.name, required this.spotId});

  factory AdEvent.fromMap(Map<dynamic, dynamic> map) {
    return AdEvent(
      name: map['event'] as String? ?? '',
      spotId: map['spotId']?.toString() ?? '',
    );
  }

  @override
  String toString() => 'AdEvent(name: $name, spotId: $spotId)';
}
