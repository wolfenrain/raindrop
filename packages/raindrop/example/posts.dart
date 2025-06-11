import 'package:raindrop/raindrop.dart';

class Post extends Schema<Post> {
  Post({
    required String content,
    int? id,
  })  : id = builder.primaryKey('id', (s) => s.id, value: id),
        content = builder.text('content', (s) => s.content, value: content);

  final PrimaryKey id;

  final TextColumn content;

  static final builder = SchemaBuilder<Post>();
}

final posts = table<Post>(
  'posts',
  () => Post(
    id: fakes.primaryKey(),
    content: fakes.text(),
  ),
);
