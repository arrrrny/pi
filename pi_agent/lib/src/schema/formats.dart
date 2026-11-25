/// String `format` checks ported from `@earendil-works/pi-schema` formats.
///
/// Each function mirrors one upstream format validator under
/// `packages/schema/src/formats/typebox/`. In draft-07 `format` is
/// non-assertive by default; these are the assertion-mode checks exercised by
/// the JSON-Schema-Test-Suite optional/format fixtures.
library;

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

/// Whether [value] is a valid `uri` (absolute URI with a scheme, no whitespace).
bool isUri(String value) {
  if (RegExp(r'\s').hasMatch(value)) return false;
  // Brackets must balance (an IPv6 host is bracketed; stray `[` is not).
  if ('['.allMatches(value).length != ']'.allMatches(value).length) {
    return false;
  }
  final match = RegExp(r'^[A-Za-z][A-Za-z0-9+.\-]*:').firstMatch(value);
  return match != null;
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
    case 'uuid':
      return isUuid(value);
    case 'date':
      return isDate(value);
    case 'time':
      return isTime(value);
    case 'date-time':
      return isDateTime(value);
    case 'email':
      return isEmail(value);
    case 'hostname':
      return isHostname(value);
    case 'uri':
      return isUri(value);
    case 'json-pointer':
      return isJsonPointer(value);
    case 'regex':
      return isRegex(value);
    default:
      return null;
  }
}
