/// The output of `tool/generate_the_magic.dart`: arity-expanded extensions
/// (typed tuple projections, joins, derived schemas) that would be
/// unmaintainable by hand. Everything in this folder is machine-written; edit
/// the generator, not these files.
library;

export 'derived_schemas.dart';
export 'group_by_terms.dart';
export 'index_columns.dart';
export 'inner_joins.dart';
export 'left_joins.dart';
export 'right_joins.dart';
export 'selectable_columns.dart';
export 'updateable_columns.dart';
