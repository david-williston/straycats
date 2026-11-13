import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../localization/app_localizations.dart';
import '../domain/coarse_area.dart';

/// Radius of the circle drawn for a place, in metres. The place is only
/// known to a cell about 1 km across, so that is what is shown.
const placeCircleRadiusMetres = 1000.0;

/// A small, fixed map showing places as translucent circles, with no pin.
/// Each circle is centred on the middle of its geohash cell, never on the
/// original position (which is not kept), so the map cannot show the real
/// spot. If tiles cannot be loaded (offline) the map hides itself and the
/// caller's text label stands alone.
class PlaceMap extends StatefulWidget {
  const PlaceMap({
    super.key,
    required this.areas,
    this.height = 180,
    this.tileProvider,
  });

  final List<CoarseArea> areas;
  final double height;

  /// For tests; defaults to OpenStreetMap over the network.
  final TileProvider? tileProvider;

  /// The circle centres for [areas]: the geohash cell centres.
  static List<LatLng> centres(List<CoarseArea> areas) => [
    for (final a in areas) LatLng(a.center.lat, a.center.lng),
  ];

  @override
  State<PlaceMap> createState() => _PlaceMapState();
}

class _PlaceMapState extends State<PlaceMap> {
  bool _failed = false;

  void _tileFailed() {
    if (_failed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || widget.areas.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final centres = PlaceMap.centres(widget.areas);
    return Semantics(
      label: AppLocalizations.of(context).approximateAreaMap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  initialCenter: centres.first,
                  initialZoom: 13,
                  initialCameraFit: centres.length > 1
                      ? CameraFit.coordinates(
                          coordinates: centres,
                          padding: const EdgeInsets.all(56),
                          maxZoom: 13,
                        )
                      : null,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // Sent as the User-Agent, as the OSM tile policy requires.
                    userAgentPackageName: 'com.straycats.straycats',
                    tileProvider: widget.tileProvider,
                    errorTileCallback: (_, _, _) => _tileFailed(),
                  ),
                  CircleLayer(
                    circles: [
                      for (final c in centres)
                        CircleMarker(
                          point: c,
                          radius: placeCircleRadiusMetres,
                          useRadiusInMeter: true,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.25,
                          ),
                          borderColor: theme.colorScheme.primary,
                          borderStrokeWidth: 2,
                        ),
                    ],
                  ),
                ],
              ),
              // OpenStreetMap's licence asks for this credit on the map.
              Align(
                alignment: Alignment.bottomRight,
                child: ColoredBox(
                  color: theme.colorScheme.surface.withValues(alpha: 0.75),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Text(
                      '© OpenStreetMap contributors',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
