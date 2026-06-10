import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import 'package:raindrop_cli/src/parser/schema_parser.dart';

/// AST visitor that finds table definitions in Dart code.
///
/// Looks for patterns like:
/// - `postgresTable('users', () => User(...))`
/// - `sqliteTable('users', () => User(...))`
/// - `table('users', () => User(...))`
///
/// Table functions are detected by analyzing whether they call `table()`
/// with a `dialect` named argument. Only tables matching the expected
/// dialect are included.
class TableDefinitionVisitor extends RecursiveAstVisitor<void> {
  TableDefinitionVisitor({required this.expectedDialect});

  /// The dialect to filter by. Only tables with this dialect are included.
  final String expectedDialect;

  /// List of table definitions found.
  final List<TableDefinition> tableDefinitions = [];

  /// Cache of function element to dialect name.
  static final Map<Element, String?> _dialectCache = {};

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      final initializer = variable.initializer;
      if (initializer is MethodInvocation) {
        _checkMethodInvocation(initializer);
      } else if (initializer is FunctionExpressionInvocation) {
        _checkFunctionExpression(initializer);
      }
    }
    super.visitTopLevelVariableDeclaration(node);
  }

  void _checkMethodInvocation(MethodInvocation invocation) {
    final methodName = invocation.methodName.name;

    // Try to extract dialect from the function definition
    final dialect = _extractDialectFromFunction(invocation);

    // Skip if we couldn't determine the dialect (not a table function)
    // or if the dialect doesn't match what we're looking for
    if (dialect == null || dialect != expectedDialect) {
      return;
    }

    final arguments = invocation.argumentList.arguments;
    if (arguments.length < 2) {
      return;
    }

    // First argument should be the table name (string literal)
    final tableNameArg = arguments[0];
    if (tableNameArg is! StringLiteral) {
      return;
    }
    final tableName = tableNameArg.stringValue;
    if (tableName == null) {
      return;
    }

    // Second argument is the schema builder.
    final schemaType = _extractSchemaType(arguments[1]);

    // Check for index callback (third argument)
    final indexDefinitions = <IndexDefinition>[];
    if (arguments.length >= 3) {
      final indexArg = arguments[2];
      if (indexArg is FunctionExpression) {
        indexDefinitions.addAll(_extractIndexDefinitions(indexArg));
      }
    }

    tableDefinitions.add(TableDefinition(
      functionName: methodName,
      tableName: tableName,
      schemaType: schemaType,
      indexes: indexDefinitions,
    ));
  }

  void _checkFunctionExpression(FunctionExpressionInvocation invocation) {
    // Handle cases where the function is invoked differently
    final function = invocation.function;
    if (function is! SimpleIdentifier) {
      return;
    }

    final functionName = function.name;

    // Try to extract dialect from the function definition
    final dialect = _extractDialectFromIdentifier(function);

    // Skip if we couldn't determine the dialect (not a table function)
    // or if the dialect doesn't match what we're looking for
    if (dialect == null || dialect != expectedDialect) {
      return;
    }

    final arguments = invocation.argumentList.arguments;
    if (arguments.length < 2) {
      return;
    }

    // First argument should be the table name
    final tableNameArg = arguments[0];
    if (tableNameArg is! StringLiteral) {
      return;
    }
    final tableName = tableNameArg.stringValue;
    if (tableName == null) {
      return;
    }

    // Second argument is the schema builder.
    final schemaType = _extractSchemaType(arguments[1]);

    // Check for index callback (third argument)
    final indexDefinitions = <IndexDefinition>[];
    if (arguments.length >= 3) {
      final indexArg = arguments[2];
      if (indexArg is FunctionExpression) {
        indexDefinitions.addAll(_extractIndexDefinitions(indexArg));
      }
    }

    tableDefinitions.add(TableDefinition(
      functionName: functionName,
      tableName: tableName,
      schemaType: schemaType,
      indexes: indexDefinitions,
    ));
  }

  /// Extracts index definitions from an index callback function.
  ///
  /// Parses expressions like:
  /// ```dart
  /// (table) {
  ///   index('pets_owner').on(table.ownerId);
  ///   uniqueIndex('pets_name_unique').on(table.name);
  ///   index('pets_composite').on(table.userId, table.name);
  /// }
  /// ```
  List<IndexDefinition> _extractIndexDefinitions(FunctionExpression function) {
    final definitions = <IndexDefinition>[];
    final body = function.body;

    if (body is! BlockFunctionBody) {
      return definitions;
    }

    // Get the parameter name (e.g., 'table' in `(table) { ... }`)
    final parameters = function.parameters?.parameters;
    if (parameters == null || parameters.isEmpty) {
      return definitions;
    }
    final paramName = parameters.first.name?.lexeme;
    if (paramName == null) {
      return definitions;
    }

    // Process each statement in the block
    for (final statement in body.block.statements) {
      if (statement is! ExpressionStatement) continue;

      final indexDef = _parseIndexExpression(statement.expression, paramName);
      if (indexDef != null) {
        definitions.add(indexDef);
      }
    }

    return definitions;
  }

  /// Parses an index expression and returns an IndexDefinition if valid.
  ///
  /// Handles expressions like:
  /// - `index('name').on(schema.col)`
  /// - `index('name').on(schema.col1, schema.col2)`
  /// - `uniqueIndex('name').on(schema.col)`
  IndexDefinition? _parseIndexExpression(Expression expr, String schemaParam) {
    // Walk up the chain to find the components
    var currentExpr = expr;
    var isUnique = false;
    List<String>? columnFields;
    String? indexName;
    String? where;

    // Handle .on(col1, col2, ...)
    if (currentExpr is MethodInvocation &&
        currentExpr.methodName.name == 'on') {
      columnFields = _extractColumnFields(currentExpr, schemaParam);
      currentExpr = currentExpr.target!;
    }

    // Handle index('name') or uniqueIndex('name')
    if (currentExpr is MethodInvocation) {
      final methodName = currentExpr.methodName.name;
      if (methodName == 'index' || methodName == 'uniqueIndex') {
        isUnique = methodName == 'uniqueIndex';
        final args = currentExpr.argumentList.arguments;
        if (args.isNotEmpty && args.first is StringLiteral) {
          indexName = (args.first as StringLiteral).stringValue;
        }
        where = _extractWhereArg(args);
      }
    }

    // Also handle function invocation: index('name') or uniqueIndex('name')
    if (currentExpr is FunctionExpressionInvocation) {
      final function = currentExpr.function;
      if (function is SimpleIdentifier) {
        final funcName = function.name;
        if (funcName == 'index' || funcName == 'uniqueIndex') {
          isUnique = funcName == 'uniqueIndex';
          final args = currentExpr.argumentList.arguments;
          if (args.isNotEmpty && args.first is StringLiteral) {
            indexName = (args.first as StringLiteral).stringValue;
          }
          where = _extractWhereArg(args);
        }
      }
    }

    if (indexName != null && columnFields != null && columnFields.isNotEmpty) {
      return IndexDefinition(
        name: indexName,
        columnFields: columnFields,
        isUnique: isUnique,
        where: where,
      );
    }

    return null;
  }

  /// Extracts the `where:` named argument (a raw SQL string) from an
  /// `index('name', where: '...')` / `uniqueIndex(...)` call.
  String? _extractWhereArg(NodeList<Expression> args) {
    for (final arg in args) {
      if (arg is NamedExpression && arg.name.label.name == 'where') {
        final expr = arg.expression;
        if (expr is StringLiteral) {
          return expr.stringValue;
        }
      }
    }
    return null;
  }

  /// Extracts column field names from an `.on()` method invocation.
  ///
  /// Handles both:
  /// - Single column: `on(schema.field)`
  /// - Multiple columns via record: `on((schema.field1, schema.field2))`
  /// - Multiple columns via args (legacy): `on(schema.field1, schema.field2)`
  List<String> _extractColumnFields(
    MethodInvocation onCall,
    String schemaParam,
  ) {
    final fields = <String>[];
    final args = onCall.argumentList.arguments;

    // Check if the single argument is a record literal
    if (args.length == 1 && args.first is RecordLiteral) {
      final record = args.first as RecordLiteral;
      for (final field in record.fields) {
        _extractFieldFromExpression(field, schemaParam, fields);
      }
      return fields;
    }

    // Handle individual arguments (single column or legacy multi-column)
    for (final arg in args) {
      _extractFieldFromExpression(arg, schemaParam, fields);
    }

    return fields;
  }

  /// Extracts a field name from an expression like `schema.fieldName`.
  void _extractFieldFromExpression(
    Expression expr,
    String schemaParam,
    List<String> fields,
  ) {
    if (expr is PrefixedIdentifier) {
      // Handle schema.fieldName
      if (expr.prefix.name == schemaParam) {
        fields.add(expr.identifier.name);
      }
    } else if (expr is PropertyAccess) {
      // Handle more complex property access
      final target = expr.target;
      if (target is SimpleIdentifier && target.name == schemaParam) {
        fields.add(expr.propertyName.name);
      }
    }
  }

  /// Extracts the dialect from a method invocation's function definition.
  String? _extractDialectFromFunction(MethodInvocation node) {
    final element = node.methodName.staticElement;
    return _extractDialectFromElement(element);
  }

  /// Extracts the dialect from an identifier's function definition.
  String? _extractDialectFromIdentifier(SimpleIdentifier identifier) {
    final element = identifier.staticElement;
    return _extractDialectFromElement(element);
  }

  /// Extracts the dialect from an element's function body.
  String? _extractDialectFromElement(Element? element) {
    if (element == null) return null;

    // Check cache first
    if (_dialectCache.containsKey(element)) {
      return _dialectCache[element];
    }

    // Get the function body from the element
    final body = _getFunctionBody(element);
    if (body == null) {
      _dialectCache[element] = null;
      return null;
    }

    // Find the dialect argument in the function body
    final visitor = _DialectVisitor();
    body.accept(visitor);
    _dialectCache[element] = visitor.dialect;
    return visitor.dialect;
  }

  /// Gets the function body from an element.
  FunctionBody? _getFunctionBody(Element element) {
    if (element is! ExecutableElement) return null;

    final session = element.session;
    if (session == null) return null;

    try {
      final result = session.getParsedLibraryByElement(element.library);
      if (result is! ParsedLibraryResult) return null;

      final declaration = result.getElementDeclaration(element);
      if (declaration == null) return null;

      final node = declaration.node;
      if (node is MethodDeclaration) {
        return node.body;
      } else if (node is FunctionDeclaration) {
        return node.functionExpression.body;
      }
    } catch (_) {
      // If we can't get the declaration, return null
    }
    return null;
  }

  /// Extracts the schema type name from the table's second argument, which may
  /// be a builder lambda (`(b) => UserSchema(b)`) or a constructor tear-off
  /// (`UserSchema.new`).
  String? _extractSchemaType(Expression builderArg) {
    if (builderArg is FunctionExpression) {
      return _extractSchemaTypeFromFunction(builderArg);
    }
    if (builderArg is ConstructorReference) {
      return builderArg.constructorName.type.name2.lexeme;
    }
    return null;
  }

  /// Extracts the schema type name from a builder function.
  ///
  /// For example, from `() => User(...)` extracts 'User'.
  String? _extractSchemaTypeFromFunction(FunctionExpression function) {
    final body = function.body;

    if (body is ExpressionFunctionBody) {
      final expression = body.expression;
      if (expression is MethodInvocation) {
        return expression.methodName.name;
      } else if (expression is InstanceCreationExpression) {
        return expression.constructorName.type.name2.lexeme;
      }
    } else if (body is BlockFunctionBody) {
      // Look for return statement
      for (final statement in body.block.statements) {
        if (statement is ReturnStatement) {
          final expression = statement.expression;
          if (expression is MethodInvocation) {
            return expression.methodName.name;
          } else if (expression is InstanceCreationExpression) {
            return expression.constructorName.type.name2.lexeme;
          }
        }
      }
    }

    return null;
  }
}

/// Visitor that finds the `dialect` named argument in a function body.
///
/// Looks for calls to `table()` and extracts the `dialect` argument value.
class _DialectVisitor extends RecursiveAstVisitor<void> {
  String? dialect;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Look for calls to 'table'
    if (node.methodName.name == 'table') {
      // Find the dialect named argument
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'dialect') {
          final expr = arg.expression;
          if (expr is StringLiteral) {
            dialect = expr.stringValue;
            return;
          }
        }
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    // Handle cases where table is invoked as a function expression
    final function = node.function;
    if (function is SimpleIdentifier && function.name == 'table') {
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'dialect') {
          final expr = arg.expression;
          if (expr is StringLiteral) {
            dialect = expr.stringValue;
            return;
          }
        }
      }
    }
    super.visitFunctionExpressionInvocation(node);
  }
}
