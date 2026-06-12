import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../core/snapshot.dart';

/// AST visitor that extracts column definitions from schema classes.
///
/// Looks for patterns like:
/// - `$.integer('column_name', (s) => s.column, value)`
/// - `$.text('column_name', (s) => s.column, value)`
/// - `$.dateTime('column_name', (s) => s.column, value)`
///
/// The SQL type is extracted directly from the column method definition by
/// finding the `sqlType` argument passed to the `column()` or `custom()` call.
class ColumnExtractor extends RecursiveAstVisitor<void> {
  /// Creates a new column extractor.
  ColumnExtractor();

  /// Map of schema class name to its columns.
  final Map<String, Map<String, ColumnSnapshot>> schemaColumns = {};

  /// The current schema class being processed.
  String? _currentSchemaClass;

  /// Columns for the current schema class.
  Map<String, ColumnSnapshot>? _currentColumns;

  /// Cache of method name to SQL type extracted from method definitions.
  static final Map<Element, String?> _sqlTypeCache = {};

  /// Extracts the SQL type from a column method definition.
  ///
  /// Looks for the `sqlType` named argument in the method body's call to
  /// `column()` or `custom()`.
  String? _extractSqlTypeFromMethod(MethodInvocation node) {
    final element = node.methodName.staticElement;
    if (element == null) return null;

    // Check cache first
    if (_sqlTypeCache.containsKey(element)) {
      return _sqlTypeCache[element];
    }

    // Get the method body from the element's declaration
    final body = _getMethodBody(element);
    if (body == null) {
      _sqlTypeCache[element] = null;
      return null;
    }

    // Find the sqlType argument in the method body
    final visitor = _SqlTypeVisitor();
    body.accept(visitor);
    _sqlTypeCache[element] = visitor.sqlType;
    return visitor.sqlType;
  }

  /// Gets the method body from an element.
  FunctionBody? _getMethodBody(Element element) {
    if (element is! ExecutableElement) return null;

    // Get the declaration node from the element
    // The declaration is available via the element's enclosing session
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

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Check if this class extends Schema
    final extendsClause = node.extendsClause;
    if (extendsClause != null) {
      final superclass = extendsClause.superclass;
      if (_isSchemaType(superclass)) {
        _currentSchemaClass = node.name.lexeme;
        _currentColumns = {};
        schemaColumns[_currentSchemaClass!] = _currentColumns!;
      }
    }

    super.visitClassDeclaration(node);

    _currentSchemaClass = null;
    _currentColumns = null;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_currentColumns == null) {
      super.visitMethodInvocation(node);
      return;
    }

    // Check if this is a column definition call like $.integer(...) or $.text(...)
    final target = node.target;
    if (target is! PrefixedIdentifier && target is! SimpleIdentifier) {
      super.visitMethodInvocation(node);
      return;
    }

    // Try to extract SQL type from the method definition
    final sqlType = _extractSqlTypeFromMethod(node);
    if (sqlType == null) {
      // Not a column definition method, check for chained calls
      _checkChainedCalls(node);
      super.visitMethodInvocation(node);
      return;
    }

    // Extract column information from arguments
    final args = node.argumentList.arguments;
    if (args.isEmpty) {
      super.visitMethodInvocation(node);
      return;
    }

    // First argument is the column name
    final nameArg = args[0];
    if (nameArg is! StringLiteral) {
      super.visitMethodInvocation(node);
      return;
    }

    final columnName = nameArg.stringValue;
    if (columnName == null) {
      super.visitMethodInvocation(node);
      return;
    }

    // Determine if the column is nullable based on the return type annotation
    // or the field it's assigned to
    final isNullable = _isNullableColumn(node);

    // Check for primaryKey call
    var isPrimaryKey = false;
    var autoIncrement = false;
    _checkPrimaryKeyCall(node, (pk, ai) {
      isPrimaryKey = pk;
      autoIncrement = ai;
    });

    // Check for references call
    final foreignKey = _checkReferencesCall(node);

    // Extract a server-side default (`defaultValue: "datetime('now')"`).
    final defaultValue = _extractDefaultValue(node);

    _currentColumns![columnName] = ColumnSnapshot(
      name: columnName,
      type: sqlType,
      isNullable: isNullable,
      primaryKey: isPrimaryKey,
      autoIncrement: autoIncrement,
      defaultValue: defaultValue,
      foreignKey: foreignKey,
    );

    super.visitMethodInvocation(node);
  }

  /// Extracts the `defaultValue:` named argument (a raw SQL string literal)
  /// from a column-definition call like `$.text('x', ..., defaultValue: "0")`.
  String? _extractDefaultValue(MethodInvocation node) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'defaultValue') {
        final expr = arg.expression;
        if (expr is StringLiteral) {
          final value = expr.stringValue;
          if (value != null) return value;
        }
        // Resolve a `const` string reference (`defaultValue: _nowIso`).
        if (expr is Identifier) {
          final element = expr.staticElement;
          if (element is VariableElement) {
            final value = element.computeConstantValue()?.toStringValue();
            if (value != null) return value;
          }
        }
      }
    }
    return null;
  }

  bool _isSchemaType(NamedType type) {
    final typeName = type.name2.lexeme;
    return typeName == 'Schema';
  }

  bool _isNullableColumn(MethodInvocation node) {
    // Walk up to find the assignment expression in the initializer list
    AstNode? current = node;
    while (current != null && current is! ConstructorFieldInitializer) {
      current = current.parent;
    }

    if (current is ConstructorFieldInitializer) {
      // Get the field name being assigned to
      final fieldName = current.fieldName.name;

      // Find the class declaration
      AstNode? classNode = current;
      while (classNode != null && classNode is! ClassDeclaration) {
        classNode = classNode.parent;
      }

      if (classNode is ClassDeclaration) {
        // Find the field declaration with this name
        for (final member in classNode.members) {
          if (member is FieldDeclaration) {
            for (final variable in member.fields.variables) {
              if (variable.name.lexeme == fieldName) {
                // Check if the field type is nullable
                final type = member.fields.type;
                if (type is NamedType) {
                  return type.question != null;
                }
              }
            }
          }
        }
      }
    }

    return false;
  }

  void _checkPrimaryKeyCall(
    MethodInvocation node,
    void Function(bool isPrimaryKey, bool autoIncrement) callback,
  ) {
    // Check if this method invocation has a .primaryKey() chained call
    final parent = node.parent;
    if (parent is MethodInvocation && parent.methodName.name == 'primaryKey') {
      var autoIncrement = false;

      // Check for autoIncrement: true argument
      for (final arg in parent.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'autoIncrement') {
          final expr = arg.expression;
          if (expr is BooleanLiteral && expr.value) {
            autoIncrement = true;
          }
        }
      }

      callback(true, autoIncrement);
      return;
    }

    // Check if the parent's parent is the primaryKey call (for chained expressions)
    if (parent is CascadeExpression) {
      final grandparent = parent.parent;
      if (grandparent is MethodInvocation &&
          grandparent.methodName.name == 'primaryKey') {
        callback(true, false);
        return;
      }
    } else if (parent is PropertyAccess) {
      final grandparent = parent.parent;
      if (grandparent is MethodInvocation &&
          grandparent.methodName.name == 'primaryKey') {
        callback(true, false);
        return;
      }
    }

    callback(false, false);
  }

  void _checkChainedCalls(MethodInvocation node) {
    // Handle chained calls like $.integer(...).primaryKey(autoIncrement: true)
    if (node.methodName.name == 'primaryKey') {
      final target = node.target;
      if (target is MethodInvocation) {
        // The target is the actual column definition
        // This is already handled in visitMethodInvocation
      }
    }
  }

  ForeignKeySnapshotRef? _checkReferencesCall(MethodInvocation node) {
    // Look for .references() in the chain
    // Walk up the AST to find a references call
    AstNode? current = node.parent;
    while (current != null) {
      if (current is MethodInvocation &&
          current.methodName.name == 'references') {
        return _extractForeignKeyInfo(current);
      }
      // Stop if we've gone past the expression statement
      if (current is ExpressionStatement) break;
      current = current.parent;
    }
    return null;
  }

  ForeignKeySnapshotRef? _extractForeignKeyInfo(MethodInvocation node) {
    final args = node.argumentList.arguments;
    if (args.isEmpty) return null;

    // First argument is the column getter function
    final columnGetterArg = args[0];
    String? referencedTable;
    String? referencedColumn;

    // Extract table and column from the function expression
    // e.g., () => users.id
    if (columnGetterArg is FunctionExpression) {
      final body = columnGetterArg.body;
      if (body is ExpressionFunctionBody) {
        final expr = body.expression;
        if (expr is PrefixedIdentifier) {
          // users.id -> table=users, column=id
          referencedTable = _resolveTableName(expr.prefix) ?? expr.prefix.name;
          referencedColumn = expr.identifier.name;
        } else if (expr is PropertyAccess) {
          // users.id (when resolved differently)
          final target = expr.target;
          if (target is SimpleIdentifier) {
            referencedTable = _resolveTableName(target) ?? target.name;
          }
          referencedColumn = expr.propertyName.name;
        }
      }
    }

    if (referencedTable == null || referencedColumn == null) return null;

    // Extract onDelete and onUpdate named arguments
    String? onDelete;
    String? onUpdate;

    for (final arg in args) {
      if (arg is NamedExpression) {
        final name = arg.name.label.name;
        final expr = arg.expression;
        if (expr is PrefixedIdentifier) {
          // ReferentialAction.cascade
          final value = _referentialActionToSql(expr.identifier.name);
          if (name == 'onDelete') {
            onDelete = value;
          } else if (name == 'onUpdate') {
            onUpdate = value;
          }
        }
      }
    }

    return ForeignKeySnapshotRef(
      referencedTable: referencedTable,
      referencedColumn: referencedColumn,
      onDelete: onDelete,
      onUpdate: onUpdate,
    );
  }

  /// Resolves the SQL table name for a schema reference such as
  /// `dailyChallenges` by finding its `...Table('name', ...)` initializer in the
  /// declaring library and reading the first (table-name) string argument.
  /// Returns null if it can't be resolved (caller falls back to the
  /// identifier name).
  String? _resolveTableName(SimpleIdentifier ref) {
    final element = ref.staticElement;
    final library = element?.library;
    final session = element?.session;
    if (library == null || session == null) return null;
    try {
      final result = session.getParsedLibraryByElement(library);
      if (result is! ParsedLibraryResult) return null;
      for (final unitResult in result.units) {
        for (final decl in unitResult.unit.declarations) {
          if (decl is! TopLevelVariableDeclaration) continue;
          for (final variable in decl.variables.variables) {
            if (variable.name.lexeme != ref.name) continue;
            final init = variable.initializer;
            if (init is MethodInvocation) {
              final args = init.argumentList.arguments;
              if (args.isNotEmpty && args.first is StringLiteral) {
                return (args.first as StringLiteral).stringValue;
              }
            }
          }
        }
      }
    } catch (_) {
      // Fall through to the caller's identifier-name fallback.
    }
    return null;
  }

  String? _referentialActionToSql(String action) {
    return switch (action) {
      'cascade' => 'CASCADE',
      'setNull' => 'SET NULL',
      'setDefault' => 'SET DEFAULT',
      'restrict' => 'RESTRICT',
      'noAction' => 'NO ACTION',
      _ => null,
    };
  }
}

/// Visitor that finds the `sqlType` named argument in a function body.
///
/// Looks for calls to `column()` or `custom()` and extracts the `sqlType`
/// argument value.
class _SqlTypeVisitor extends RecursiveAstVisitor<void> {
  String? sqlType;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Look for calls to 'column' or 'custom'
    final methodName = node.methodName.name;
    if (methodName == 'column' || methodName == 'custom') {
      // Find the sqlType named argument
      for (final arg in node.argumentList.arguments) {
        if (arg is NamedExpression && arg.name.label.name == 'sqlType') {
          final expr = arg.expression;
          if (expr is StringLiteral) {
            sqlType = expr.stringValue;
            return;
          }
        }
      }
    }
    super.visitMethodInvocation(node);
  }
}
