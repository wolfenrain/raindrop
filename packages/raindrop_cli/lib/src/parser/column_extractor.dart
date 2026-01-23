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

    _currentColumns![columnName] = ColumnSnapshot(
      name: columnName,
      type: sqlType,
      nullable: isNullable,
      primaryKey: isPrimaryKey,
      autoIncrement: autoIncrement,
    );

    super.visitMethodInvocation(node);
  }

  bool _isSchemaType(NamedType type) {
    final typeName = type.name2.lexeme;
    return typeName == 'Schema';
  }

  bool _isNullableColumn(MethodInvocation node) {
    // Check if the parent is an assignment to a nullable field
    final parent = node.parent;
    if (parent is AssignmentExpression) {
      final leftSide = parent.leftHandSide;
      if (leftSide is SimpleIdentifier) {
        // Check the field declaration type
        // This is a simplified check - a full implementation would
        // resolve the type
        return false;
      }
    }

    // Check if there's a null value passed (third argument)
    final args = node.argumentList.arguments;
    if (args.length >= 3) {
      final valueArg = args[2];
      if (valueArg is NullLiteral) {
        return true;
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
