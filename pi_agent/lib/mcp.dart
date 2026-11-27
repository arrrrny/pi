/// The MCP (Model Context Protocol) surface's public API.
///
/// Dart port of the pure, I/O-free surface of upstream
/// `@earendil-works/pi-mcp` at the registry-pinned SHA: tool/namespace naming,
/// input- and result-schema normalization, and the model-facing content of a
/// tool result. The client, transports, OAuth and config surface stay unported
/// under arrrrny/pi#83.
///
/// ```dart
/// import 'package:pi/mcp.dart';
///
/// createMcpToolName('docs', 'search'); // 'mcp__docs__search'
/// normalizeMcpInputSchema({}); // {'type': 'object', 'properties': {}}
/// ```
library;

export 'src/mcp/input_schema.dart';
export 'src/mcp/model_content.dart';
export 'src/mcp/naming.dart';
export 'src/mcp/protocol/content.dart';
export 'src/mcp/result_schema.dart';
