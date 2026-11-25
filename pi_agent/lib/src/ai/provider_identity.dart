// How pi-ai identifies the calling app to providers.
//
// Port of `packages/ai/src/utils/identity.ts` at upstream
// `c11a73bfba1310dc4075ad836254ea87003f409b`, minus the `withClientIdentity`
// models wrapper (the Dart port has no Models facade yet). Every field is
// optional; absent fields use pi-ai's defaults: a detailed `User-Agent` with
// pi-ai's version and no attribution headers. Plain data, so it can be
// persisted.

/// pi-ai version reported in the detailed `User-Agent`
/// (`PI_AI_VERSION` in version.ts).
const String piAiVersion = '1.6.0';

/// pi's attribution, used by pi-agent-core, pi-durable, and the coding agent.
const ClientAttribution piAttribution = ClientAttribution(
  name: 'pi',
  url: 'https://pi.dev',
  categories: ['cli-agent'],
);

/// How requests are attributed to the calling app. Each provider maps the
/// fields to its own headers.
class ClientAttribution {
  /// App name: OpenRouter app title, NVIDIA invoke origin (first letter
  /// upper-cased), OpenCode client.
  final String name;

  /// App URL: OpenRouter `HTTP-Referer`, the app's identity in OpenRouter's
  /// rankings.
  final String url;

  /// App categories, e.g. `["cli-agent"]`: OpenRouter
  /// `X-OpenRouter-Categories`, comma-separated.
  final List<String>? categories;

  /// The ClientAttribution.
  const ClientAttribution(
      {required this.name, required this.url, this.categories});
}

/// How pi-ai identifies the calling app to providers. Every field is
/// optional; a null field uses the default (a detailed `User-Agent` with
/// pi-ai's version, no attribution) — and merge skips a null field instead
/// of overriding a set one, exactly like upstream's `undefined` checks.
class ClientIdentity {
  /// `"short"`, `"detailed"` (the default when null), or a custom
  /// `User-Agent` value.
  final Object? userAgent;

  /// Provider attribution headers. Null turns off attribution set by a
  /// merged identity.
  final ClientAttribution? attribution;

  /// Version in the detailed `User-Agent`. Default: the pi-ai version.
  final String? version;

  /// Creates a const ClientIdentity.
  const ClientIdentity({this.userAgent, this.attribution, this.version});
}

/// The provider and endpoint a request goes to.
class ClientIdentityTarget {
  /// The provider.
  final String provider;

  /// The baseUrl.
  final String baseUrl;

  /// Creates a const ClientIdentityTarget.
  const ClientIdentityTarget({required this.provider, required this.baseUrl});
}

/// The host of [baseUrl], or null when it does not parse as a URL.
String? _hostOf(String baseUrl) {
  try {
    return Uri.parse(baseUrl).host;
  } on FormatException {
    return null;
  }
}

/// Merge identities field by field; later sources win and absent fields are
/// skipped.
ClientIdentity? mergeClientIdentity(Iterable<ClientIdentity?> sources) {
  Object? userAgent;
  ClientAttribution? attribution;
  String? version;
  var any = false;
  for (final source in sources) {
    if (source == null) continue;
    any = true;
    if (source.userAgent != null) userAgent = source.userAgent;
    if (source.attribution != null) attribution = source.attribution;
    if (source.version != null) version = source.version;
  }
  if (!any) return null;
  return ClientIdentity(
    userAgent: userAgent,
    attribution: attribution,
    version: version,
  );
}

/// The version in the detailed `User-Agent`.
String getClientVersion(ClientIdentity? identity) =>
    identity?.version ?? piAiVersion;

/// The `User-Agent` value of an identity.
///
/// `"detailed"` renders `pi/<version> (<platform>; <runtime>; <arch>)` — the
/// runtime description is injected so hosts without a Node-style runtime
/// string stay deterministic; `"short"` renders `pi`; a custom mode renders
/// its value verbatim.
String formatUserAgent(
  ClientIdentity? identity, {
  String? platform,
  String? runtime,
  String? arch,
}) {
  final mode = identity?.userAgent;
  // Upstream's UserAgentMode is `"short" | "detailed" | { custom }`: an
  // object mode renders its value; `"short"` renders `pi`; any other value
  // falls through to the detailed rendering.
  if (mode is Map && mode['custom'] is String) {
    return mode['custom'] as String;
  }
  if (mode == 'short') return 'pi';
  final product = 'pi/${getClientVersion(identity)}';
  if (runtime == null || runtime.isEmpty) return '$product (browser)';
  return '$product (${platform ?? 'unknown'}; $runtime; ${arch ?? 'unknown'})';
}

bool _matchesHost(String baseUrl, String expectedHost) =>
    _hostOf(baseUrl) == expectedHost;

bool _isOpenRouter(ClientIdentityTarget target) =>
    target.provider == 'openrouter' || target.baseUrl.contains('openrouter.ai');

bool _isNvidiaNim(ClientIdentityTarget target) =>
    target.provider == 'nvidia' ||
    _matchesHost(target.baseUrl, 'integrate.api.nvidia.com');

bool _isOpenCode(ClientIdentityTarget target) =>
    target.provider == 'opencode' ||
    target.provider == 'opencode-go' ||
    _matchesHost(target.baseUrl, 'opencode.ai');

/// Provider attribution headers of an identity for a request target. Empty
/// when attribution is off.
Map<String, String> getAttributionHeaders(
  ClientIdentityTarget target,
  ClientIdentity? identity,
) {
  final attribution = identity?.attribution;
  if (attribution == null) return {};
  final categories = attribution.categories;
  if (_isOpenRouter(target)) {
    return {
      'HTTP-Referer': attribution.url,
      'X-OpenRouter-Title': attribution.name,
      if (categories != null && categories.isNotEmpty)
        'X-OpenRouter-Categories': categories.join(','),
    };
  }
  // NVIDIA expects a capitalized origin, such as `Pi`.
  if (_isNvidiaNim(target)) {
    final name = attribution.name;
    return {
      'X-BILLING-INVOKE-ORIGIN':
          name.isEmpty ? name : '${name[0].toUpperCase()}${name.substring(1)}',
    };
  }
  if (_isOpenCode(target)) return {'x-opencode-client': attribution.name};
  return {};
}

/// OpenCode's per-conversation routing header for requests to OpenCode,
/// including custom providers pointing at it. Null without a session or for
/// other targets.
Map<String, String>? getOpenCodeSessionHeaders(
  ClientIdentityTarget target,
  String? sessionId,
) {
  if (sessionId != null && _isOpenCode(target)) {
    return {'x-opencode-session': sessionId};
  }
  return null;
}

/// Default headers an identity adds to a request: `User-Agent` and provider
/// attribution. APIs apply them below model, provider, and request headers,
/// so configured headers override them and a null request header removes
/// them.
Map<String, String> getIdentityHeaders(
  ClientIdentityTarget target,
  ClientIdentity? identity, {
  String? platform,
  String? runtime,
  String? arch,
}) {
  return {
    'User-Agent': formatUserAgent(
      identity,
      platform: platform,
      runtime: runtime,
      arch: arch,
    ),
    ...getAttributionHeaders(target, identity),
  };
}
