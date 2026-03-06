import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

abstract class AFFirebaseStruct extends BaseStruct {
  AFFirebaseStruct(this.firestoreUtilData);

  /// Utility class for Firestore updates
  FirestoreUtilData firestoreUtilData = const FirestoreUtilData();
}

class FirestoreUtilData {
  const FirestoreUtilData({
    this.fieldValues = const {},
    this.clearUnsetFields = true,
    this.create = false,
    this.delete = false,
  });
  final Map<String, dynamic> fieldValues;
  final bool clearUnsetFields;
  final bool create;
  final bool delete;
  static String get name => 'firestoreUtilData';
}

Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data) =>
    mergeNestedFields(data)
        .where((k, _) => k != FirestoreUtilData.name)
        .map((key, value) {
      // Handle Timestamp
      if (value is DateTime) {
        value = value;
      }
      // Handle list of Timestamp
      if (value is Iterable && value.isNotEmpty && value.first is DateTime) {
        value = value.map((v) => (v as DateTime)).toList();
      }
      // Handle GeoPoint
      if (value is GeoPoint) {
        value = value.toLatLng();
      }
      // Handle list of GeoPoint
      if (value is Iterable && value.isNotEmpty && value.first is GeoPoint) {
        value = value.map((v) => (v as GeoPoint).toLatLng()).toList();
      }
      // Handle nested data.
      if (value is Map) {
        value = mapFromFirestore(value as Map<String, dynamic>);
      }
      // Handle list of nested data.
      if (value is Iterable && value.isNotEmpty && value.first is Map) {
        value = value
            .map((v) => mapFromFirestore(v as Map<String, dynamic>))
            .toList();
      }
      return MapEntry(key, value);
    });

Map<String, dynamic> mapToFirestore(Map<String, dynamic> data) =>
    data.where((k, v) => k != FirestoreUtilData.name).where((key, value) => value != null).map((key, value) {
      // Handle GeoPoint
      if (value is LatLng) {
        value = value.toGeoPoint();
      }
      // Handle list of GeoPoint
      if (value is Iterable && value.isNotEmpty && value.first is LatLng) {
        value = value.map((v) => (v as LatLng).toGeoPoint()).toList();
      }
      // Handle Color
      if (value is Color) {
        value = value.toCssString();
      }
      // Handle list of Color
      if (value is Iterable && value.isNotEmpty && value.first is Color) {
        value = value.map((v) => (v as Color).toCssString()).toList();
      }
      // Handle nested data.
      if (value is Map) {
        value = mapToFirestore(value as Map<String, dynamic>);
      }
      // Handle list of nested data.
      if (value is Iterable && value.isNotEmpty && value.first is Map) {
        value = value
            .map((v) => mapToFirestore(v as Map<String, dynamic>))
            .toList();
      }
      return MapEntry(key, value);
    });

List<GeoPoint>? convertToGeoPointList(List<LatLng>? list) =>
    list?.map((e) => e.toGeoPoint()).toList();

extension GeoPointExtension on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(
    latitude: latitude,
    longitude: longitude
  );
}

extension LatLngExtension on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

T? safeGet<T>(T Function() func, [Function(dynamic)? reportError]) {
  try {
    return func();
  } catch (e) {
    reportError?.call(e);
  }
  return null;
}

Map<String, dynamic> mergeNestedFields(Map<String, dynamic> data) {
  final nestedData = data.where((k, _) => k.contains('.'));
  final fieldNames = nestedData.keys.map((k) => k.split('.').first).toSet();
  // Remove nested values (e.g. 'foo.bar') and merge them into a map.
  data.removeWhere((k, _) => k.contains('.'));
  for (var name in fieldNames) {
    final mergedValues = mergeNestedFields(
      nestedData
          .where((k, _) => k.split('.').first == name)
          .map((k, v) => MapEntry(k.split('.').skip(1).join('.'), v)),
    );
    final existingValue = data[name];
    data[name] = {
      if (existingValue != null && existingValue is Map)
        ...existingValue as Map<String, dynamic>,
      ...mergedValues,
    };
  }
  // Merge any nested maps inside any of the fields as well.
  data.where((_, v) => v is Map).forEach((k, v) {
    data[k] = mergeNestedFields(v as Map<String, dynamic>);
  });

  return data;
}

extension _WhereMapExtension<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K, V) test) =>
      Map.fromEntries(entries.where((e) => test(e.key, e.value)));
}

class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
  }) : assert(latitude >= -90 && latitude <= 90,
  'Latitude must be between -90 and 90'),
        assert(longitude >= -180 && longitude <= 180,
        'Longitude must be between -180 and 180');

  /// Create a GeoPoint from PocketBase JSON
  factory GeoPoint.fromPocketBase(Map<String, dynamic> json) {
    if (json['type'] != 'Point' || json['coordinates'] == null) {
      throw const FormatException('Invalid PocketBase GeoJSON structure');
    }

    final coords = json['coordinates'];
    if (coords is! List || coords.length != 2) {
      throw const FormatException('Coordinates must be a list [lon, lat]');
    }

    return GeoPoint(
      latitude: (coords[1] as num).toDouble(),
      longitude: (coords[0] as num).toDouble(),
    );
  }

  /// Convert to PocketBase GeoJSON structure
  Map<String, dynamic> toPocketBase() {
    return {
      "type": "Point",
      "coordinates": [longitude, latitude],
    };
  }

  /// Convert to standard Map (if needed)
  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };

  @override
  String toString() => 'GeoPoint(lat: $latitude, lon: $longitude)';

  /// Optional helper: distance calculation
  double distanceTo(GeoPoint other) {
    const earthRadius = 6371000; // meters
    final lat1 = _degToRad(latitude);
    final lat2 = _degToRad(other.latitude);
    final dLat = lat2 - lat1;
    final dLon = _degToRad(other.longitude - longitude);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(lat1) * cos(lat2) * (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (pi / 180);
}
