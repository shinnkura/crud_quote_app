class Quote {
  final int? id;
  final String text;
  final String author;

  Quote({
    this.id,
    required this.text,
    required this.author,
  });

  Quote copyWith({
    int? id,
    String? text,
    String? author,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'author': author,
    };
  }

  factory Quote.fromMap(Map<String, dynamic> map) {
    return Quote(
      id: map['id'],
      text: map['text'],
      author: map['author'],
    );
  }
}
