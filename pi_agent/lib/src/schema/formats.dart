/// String `format` checks ported from `@earendil-works/pi-schema` formats.
///
/// Each function mirrors one upstream format validator under
/// `packages/schema/src/formats/typebox/`. In draft-07 `format` is
/// non-assertive by default; these are the assertion-mode checks exercised by
/// the JSON-Schema-Test-Suite optional/format fixtures.
library;

import 'package:pi/src/schema/idna/idn_hostname.dart';

/// Whether [value] is a valid `ipv4` address (four octets 0-255, no leading
/// zeros).
bool isIpv4(String value) {
  final parts = value.split('.');
  if (parts.length != 4) return false;
  for (final part in parts) {
    if (!RegExp(r'^(0|[1-9]\d*)$').hasMatch(part)) return false;
    final n = int.parse(part);
    if (n < 0 || n > 255) return false;
  }
  return true;
}

/// Whether [value] is a valid `uuid` (8-4-4-4-12 hexadecimal digits).
bool isUuid(String value) {
  return RegExp(
          r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
      .hasMatch(value);
}

/// Whether [value] is a valid `date` (`full-date`, RFC 3339 §5.6).
bool isDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) return false;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12) return false;
  final maxDay = _daysInMonth(year, month);
  return day >= 1 && day <= maxDay;
}

int _daysInMonth(int year, int month) {
  const days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month == 2 && _isLeapYear(year)) return 29;
  return days[month - 1];
}

bool _isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

/// Whether [value] is a valid `time` (`full-time`, RFC 3339 §5.6), with an
/// optional `Z` or numeric offset.
bool isTime(String value) {
  final match =
      RegExp(r'^(\d{2}):(\d{2}):(\d{2})(\.\d+)?([Zz]|[+-]\d{2}:\d{2})$')
          .firstMatch(value);
  if (match == null) return false;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final second = int.parse(match.group(3)!);
  final offset = match.group(5)!;
  final isZulu = offset.toUpperCase() == 'Z';
  if (hour > 23 || minute > 59) return false;
  if (!isZulu) {
    final oh = int.parse(offset.substring(1, 3));
    final om = int.parse(offset.substring(4, 6));
    if (oh > 23 || om > 59) return false;
  }
  // A leap second (60) is valid only when the UTC time is 23:59:60.
  if (second == 60) {
    var offsetMinutes = 0;
    if (!isZulu) {
      final sign = offset.startsWith('+') ? 1 : -1;
      offsetMinutes = sign *
          (int.parse(offset.substring(1, 3)) * 60 +
              int.parse(offset.substring(4, 6)));
    }
    var utcMinutes = (hour * 60 + minute - offsetMinutes) % 1440;
    if (utcMinutes < 0) utcMinutes += 1440;
    if (utcMinutes != 23 * 60 + 59) return false;
  } else if (second > 59) {
    return false;
  }
  return true;
}

/// Whether [value] is a valid `date-time` (RFC 3339 §5.6).
bool isDateTime(String value) {
  final match = RegExp(
          r'^(\d{4}-\d{2}-\d{2})[Tt ](\d{2}:\d{2}:\d{2})(\.\d+)?([Zz]|[+-]\d{2}:\d{2})$')
      .firstMatch(value);
  if (match == null) return false;
  return isDate(match.group(1)!) &&
      isTime('${match.group(2)}${match.group(4)}');
}

/// Whether [value] is a valid `email` (a pragmatic `local@domain` check).
bool isEmail(String value) {
  if (value.length > 254) return false;
  final at = value.lastIndexOf('@');
  if (at <= 0 || at == value.length - 1) return false;
  final local = value.substring(0, at);
  final domain = value.substring(at + 1);
  if (local.length > 64) return false;
  // A quoted local part may contain spaces and punctuation, but ASCII only.
  if (local.length >= 2 && local.startsWith('"') && local.endsWith('"')) {
    if (local.runes.any((r) => r > 0x7f)) return false;
    return _isDomainLiteralOrHostname(domain);
  }
  if (local.startsWith('.') || local.endsWith('.') || local.contains('..')) {
    return false;
  }
  if (!RegExp(r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+$").hasMatch(local)) {
    return false;
  }
  return _isDomainLiteralOrHostname(domain);
}

bool _isDomainLiteralOrHostname(String domain) {
  // A bracketed domain is an IP-literal: IPv4 or an `IPv6:` tag.
  if (domain.startsWith('[') && domain.endsWith(']')) {
    final inner = domain.substring(1, domain.length - 1);
    if (inner.toLowerCase().startsWith('ipv6:')) return true;
    return isIpv4(inner);
  }
  return isHostname(domain);
}

/// Whether [value] is a valid `hostname` (RFC 1034 labels).
bool isHostname(String value) {
  if (value.isEmpty || value.length > 253) return false;
  final labels = value.split('.');
  for (final label in labels) {
    if (label.isEmpty || label.length > 63) return false;
    if (!RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$')
        .hasMatch(label)) {
      return false;
    }
  }
  return true;
}

/// An IPv6 address (RFC 2373 §2.2), as a case-insensitive pattern.
final RegExp _ipv6 = RegExp(
    r"""^(?:(?:(?:[0-9a-f]{1,4}:){6}|::(?:[0-9a-f]{1,4}:){5}|(?:[0-9a-f]{1,4})?::(?:[0-9a-f]{1,4}:){4}|(?:(?:[0-9a-f]{1,4}:)?[0-9a-f]{1,4})?::(?:[0-9a-f]{1,4}:){3}|(?:(?:[0-9a-f]{1,4}:){0,2}[0-9a-f]{1,4})?::(?:[0-9a-f]{1,4}:){2}|(?:(?:[0-9a-f]{1,4}:){0,3}[0-9a-f]{1,4})?::[0-9a-f]{1,4}:|(?:(?:[0-9a-f]{1,4}:){0,4}[0-9a-f]{1,4})?::)(?:[0-9a-f]{1,4}:[0-9a-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[0-9a-f]{1,4}:){0,5}[0-9a-f]{1,4})?::[0-9a-f]{1,4}|(?:(?:[0-9a-f]{1,4}:){0,6}[0-9a-f]{1,4})?::)$""",
    caseSensitive: false);

/// Maximum instance-string length accepted by the URI-family regexes.
///
/// The `uri` / `uri-reference` / `uri-template` patterns below carry nested
/// quantifiers (`(?:…*)*`) that backtrack catastrophically on a long
/// non-matching input. `checkFormat` runs them on untrusted instance data, so a
/// shared length short-circuit (mirroring [isIri]'s cap) keeps a crafted value
/// from pinning a worker. A URI longer than this is rejected rather than
/// matched.
const int _maxUriLength = 2048;

/// A Uniform Resource Identifier (RFC 3986), absolute with a scheme.
final RegExp _uri = RegExp(
    r"""^[a-z][a-z0-9+\-.]*:(?:\/\/(?:(?:[-a-z0-9._~!$&'()*+,;=:]|%[0-9a-f]{2})*@)?(?:\[(?:(?:(?:[\da-f]{1,4}:){6}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|::(?:[\da-f]{1,4}:){5}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:[\da-f]{1,4})?::(?:[\da-f]{1,4}:){4}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,1}[\da-f]{1,4})?::(?:[\da-f]{1,4}:){3}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,2}[\da-f]{1,4})?::(?:[\da-f]{1,4}:){2}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,3}[\da-f]{1,4})?::[\da-f]{1,4}:(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,4}[\da-f]{1,4})?::(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,5}[\da-f]{1,4})?::[\da-f]{1,4}|(?:(?:[\da-f]{1,4}:){0,6}[\da-f]{1,4})?::)|v[0-9a-f]+\.[-a-z0-9._~!$&'()*+,;=:]+)\]|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)|(?:[-a-z0-9._~!$&'()*+,;=]|%[0-9a-f]{2})*)(?::\d*)?(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*|\/(?:(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})+(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*)?|(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})+(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*)?(?:\?(?:[-a-z0-9._~!$&'()*+,;=:@/?]|%[0-9a-f]{2})*)?(?:#(?:[-a-z0-9._~!$&'()*+,;=:@/?]|%[0-9a-f]{2})*)?$""",
    caseSensitive: false);

/// A URI reference (RFC 3986): a URI, a relative reference, or empty.
final RegExp _uriReference = RegExp(
    r"""^(?:[a-z][a-z0-9+\-.]*:(?:\/\/(?:(?:[-a-z0-9._~!$&'()*+,;=:]|%[0-9a-f]{2})*@)?(?:\[(?:(?:(?:[\da-f]{1,4}:){6}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|::(?:[\da-f]{1,4}:){5}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:[\da-f]{1,4})?::(?:[\da-f]{1,4}:){4}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,1}[\da-f]{1,4})?::(?:[\da-f]{1,4}:){3}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,2}[\da-f]{1,4})?::(?:[\da-f]{1,4}:){2}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,3}[\da-f]{1,4})?::[\da-f]{1,4}:(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,4}[\da-f]{1,4})?::(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,5}[\da-f]{1,4})?::[\da-f]{1,4}|(?:(?:[\da-f]{1,4}:){0,6}[\da-f]{1,4})?::)|v[0-9a-f]+\.[-a-z0-9._~!$&'()*+,;=:]+)\]|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)|(?:[-a-z0-9._~!$&'()*+,;=]|%[0-9a-f]{2})*)(?::\d*)?(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*|\/(?:(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})+(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*)?|(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})+(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*)?|(?:\/\/(?:(?:[-a-z0-9._~!$&'()*+,;=:]|%[0-9a-f]{2})*@)?(?:\[(?:(?:(?:[\da-f]{1,4}:){6}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|::(?:[\da-f]{1,4}:){5}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:[\da-f]{1,4})?::(?:[\da-f]{1,4}:){4}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,1}[\da-f]{1,4})?::(?:[\da-f]{1,4}:){3}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,2}[\da-f]{1,4})?::(?:[\da-f]{1,4}:){2}(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,3}[\da-f]{1,4})?::[\da-f]{1,4}:(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,4}[\da-f]{1,4})?::(?:[\da-f]{1,4}:[\da-f]{1,4}|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d))|(?:(?:[\da-f]{1,4}:){0,5}[\da-f]{1,4})?::[\da-f]{1,4}|(?:(?:[\da-f]{1,4}:){0,6}[\da-f]{1,4})?::)|v[0-9a-f]+\.[-a-z0-9._~!$&'()*+,;=:]+)\]|(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)|(?:[-a-z0-9._~!$&'()*+,;=]|%[0-9a-f]{2})*)(?::\d*)?(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*|\/(?:(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})+(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*)?|(?:[-a-z0-9._~!$&'()*+,;=@]|%[0-9a-f]{2})+(?:\/(?:[-a-z0-9._~!$&'()*+,;=:@]|%[0-9a-f]{2})*)*)?)(?:\?(?:[-a-z0-9._~!$&'()*+,;=:@/?]|%[0-9a-f]{2})*)?(?:#(?:[-a-z0-9._~!$&'()*+,;=:@/?]|%[0-9a-f]{2})*)?$""",
    caseSensitive: false);

/// A URI template (RFC 6570).
final RegExp _uriTemplate = RegExp(
    r"""^(?:(?:[^\x00-\x20"<>%\\^`{|}\x7f]|%[0-9a-f]{2})|\{[+#./;?&=,!@|]?(?:[a-z0-9_]|%[0-9a-f]{2})+(?:\.(?:[a-z0-9_]|%[0-9a-f]{2})+)*(?::[1-9]\d{0,3}|\*)?(?:,(?:[a-z0-9_]|%[0-9a-f]{2})+(?:\.(?:[a-z0-9_]|%[0-9a-f]{2})+)*(?::[1-9]\d{0,3}|\*)?)*\})*$""",
    caseSensitive: false);

/// A relative JSON pointer (RFC 6901 / draft 2020-12 `relative-json-pointer`).
final RegExp _relativeJsonPointer =
    RegExp(r'^(?:0|[1-9][0-9]*)(?:#|(?:\/(?:[^~/]|~0|~1)*)*)$');

/// An ISO-8601 duration (RFC 3339 appendix A).
final RegExp _duration = RegExp(
    r'^P((\d+Y(\d+M(\d+D)?)?|\d+M(\d+D)?|\d+D)(T(\d+H(\d+M(\d+S)?)?|\d+M(\d+S)?|\d+S))?|T(\d+H(\d+M(\d+S)?)?|\d+M(\d+S)?|\d+S)|\d+W)$');

/// An IDN email (RFC 4952): an internationalized local part and a U-label
/// domain. The `u` flag is Dart's `unicode: true`; the lookbehind `(?<!-)`
/// forbids a trailing hyphen on each domain label.
final RegExp _idnEmail = RegExp(
    r"""^(?:[A-Za-z0-9!#$%&'*+/=?^_`{|}~\u{0080}-\u{10FFFF}-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~\u{0080}-\u{10FFFF}-]+)*|"(?:[^"\\]|\\.)*")@[\p{L}\p{N}](?:[\p{L}\p{N}-]{0,62})(?<!-)(?:\.[\p{L}\p{N}](?:[\p{L}\p{N}-]{0,62})(?<!-))*$""",
    caseSensitive: false, unicode: true);

/// Characters forbidden in an IRI (unencoded whitespace, controls, and the
/// ASCII delimiters `< > ^ ` { | } \`).
final RegExp _invalidIriChars = RegExp(r'[\x00-\x20<>^`{|}\\]');

/// A malformed percent-encoding triplet (a `%` not followed by two hex digits).
final RegExp _invalidPercentEncoding = RegExp(r'%(?![0-9a-fA-F]{2})');

/// An IPvFuture literal (`[v1.hex]`), which the WHATWG parser rejects.
final RegExp _ipvFuture = RegExp(r'\[[vV][0-9a-fA-F]+\.[^\]]+\]');

/// A bracketed IP-literal host (`//[...]`) in an authority.
final RegExp _bracketedHost = RegExp(r'//\[[^\]]*\]');

/// A dotted-decimal run (an embedded IPv4) inside a bracketed host.
final RegExp _embeddedIpv4 = RegExp(r'\d+(?:\.\d+){3}');

/// Whether [value] carries a bracketed IP-literal whose embedded IPv4 has an
/// octet with a leading zero (e.g. `[::ffff:192.168.0.01]`). The WHATWG parser
/// rejects such a literal; Dart's [Uri] is inconsistent across SDKs (3.9
/// accepts it, 3.14 rejects it), so the rule is enforced explicitly here.
bool _hasLeadingZeroEmbeddedIpv4(String value) {
  for (final host in _bracketedHost.allMatches(value)) {
    for (final ipv4 in _embeddedIpv4.allMatches(host.group(0)!)) {
      for (final octet in ipv4.group(0)!.split('.')) {
        if (octet.length > 1 && octet.startsWith('0')) return true;
      }
    }
  }
  return false;
}

/// Characters forbidden in an IRI reference (controls, space, DEL, backslash,
/// plus malformed percent triplets).
final RegExp _invalidIriRefChars =
    RegExp(r'[\x00-\x20\x7f\\]|%(?![0-9a-fA-F]{2})');

/// A scheme immediately followed by `//` (a malformed relative reference).
final RegExp _malformedScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+\-.]*\/\/');

/// Whether [value] is a valid `ipv6` address (RFC 2373 §2.2).
bool isIpv6(String value) => _ipv6.hasMatch(value);

/// Whether [value] is a valid `uri` (RFC 3986, absolute with a scheme).
bool isUri(String value) =>
    value.length <= _maxUriLength && _uri.hasMatch(value);

/// Whether [value] is a valid `uri-reference` (RFC 3986).
bool isUriReference(String value) =>
    value.length <= _maxUriLength && _uriReference.hasMatch(value);

/// Whether [value] is a valid `uri-template` (RFC 6570).
bool isUriTemplate(String value) =>
    value.length <= _maxUriLength && _uriTemplate.hasMatch(value);

/// Whether [value] is a valid `relative-json-pointer` (RFC 6901).
bool isRelativeJsonPointer(String value) =>
    _relativeJsonPointer.hasMatch(value);

/// Whether [value] is a valid `duration` (ISO-8601, RFC 3339 appendix A).
bool isDuration(String value) => _duration.hasMatch(value);

/// Whether [value] is a valid `idn-email` (RFC 4952).
///
/// Upstream applies NFC before matching; Dart's core has no normalizer, so the
/// check runs on the input as-is (the ported fixtures are already composed).
bool isIdnEmail(String value) => _idnEmail.hasMatch(value);

/// Whether [value] is a valid `iri` (RFC 3987, absolute).
///
/// Mirrors upstream: reject illegal characters and malformed percent triplets,
/// substitute an IPvFuture literal for the WHATWG parser's benefit, reject a
/// bracketed literal outside the authority, then require a parseable absolute
/// URI. Dart's [Uri] stands in for WHATWG `URL.canParse`.
bool isIri(String value) {
  if (_invalidIriChars.hasMatch(value)) return false;
  if (_invalidPercentEncoding.hasMatch(value)) return false;
  if (_hasLeadingZeroEmbeddedIpv4(value)) return false;
  final narrowed =
      value.length < 2048 ? value.replaceAll(_ipvFuture, '[::1]') : value;
  // A bracketed IP-literal is legal only as the authority host; a stray
  // bracket (e.g. in the path) is a parse error.
  final withoutHost = narrowed.replaceFirst(_bracketedHost, '');
  if (withoutHost.contains('[') || withoutHost.contains(']')) return false;
  final uri = Uri.tryParse(narrowed);
  return uri != null && uri.hasScheme;
}

/// Whether [value] is a valid `iri-reference` (RFC 3987, relative allowed).
bool isIriReference(String value) {
  if (_invalidIriRefChars.hasMatch(value)) return false;
  if (_malformedScheme.hasMatch(value)) return false;
  if (_hasLeadingZeroEmbeddedIpv4(value)) return false;
  return Uri.tryParse(value) != null;
}

/// Whether [value] is a valid `json-pointer` (RFC 6901).
bool isJsonPointer(String value) {
  if (value.isEmpty) return true;
  if (!value.startsWith('/')) return false;
  // Each reference token may only use `~0` and `~1` escapes.
  for (final token in value.substring(1).split('/')) {
    for (var i = 0; i < token.length; i++) {
      if (token[i] == '~' &&
          (i + 1 >= token.length ||
              (token[i + 1] != '0' && token[i + 1] != '1'))) {
        return false;
      }
    }
  }
  return true;
}

/// Whether [value] is a valid `regex` (ECMAScript pattern).
bool isRegex(String value) {
  try {
    RegExp(value);
    return true;
  } on FormatException {
    return false;
  }
}

/// Dispatches a format [name] to its checker, or null when the name is unknown.
bool? checkFormat(String name, String value) {
  switch (name) {
    case 'ipv4':
      return isIpv4(value);
    case 'ipv6':
      return isIpv6(value);
    case 'uuid':
      return isUuid(value);
    case 'date':
      return isDate(value);
    case 'time':
      return isTime(value);
    case 'date-time':
      return isDateTime(value);
    case 'duration':
      return isDuration(value);
    case 'email':
      return isEmail(value);
    case 'idn-email':
      return isIdnEmail(value);
    case 'hostname':
      return isHostname(value);
    case 'idn-hostname':
      return isIdnHostname(value);
    case 'uri':
      return isUri(value);
    case 'uri-reference':
      return isUriReference(value);
    case 'iri':
      return isIri(value);
    case 'iri-reference':
      return isIriReference(value);
    case 'uri-template':
      return isUriTemplate(value);
    case 'json-pointer':
      return isJsonPointer(value);
    case 'relative-json-pointer':
      return isRelativeJsonPointer(value);
    case 'regex':
      return isRegex(value);
    default:
      return null;
  }
}
