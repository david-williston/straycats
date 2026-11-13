import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';

import '../../../localization/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../places/domain/coarse_area.dart';
import '../../places/presentation/place_map.dart';

/// The size of the card image, in pixels.
const shareCardSize = Size(1080, 1350);

/// What goes on a card, and nothing more: the latest photo, the person's
/// name for the cat, the neighbourhood and its rough area (never a point),
/// and the date it was first met. No counts, no rankings.
class ShareCardData {
  const ShareCardData({
    required this.name,
    required this.photo,
    required this.firstMet,
    this.neighbourhood,
    this.area,
  });

  final String name;
  final File photo;
  final DateTime firstMet;
  final String? neighbourhood;
  final CoarseArea? area;
}

/// The shareable cat card, laid out at [shareCardSize] in warm site colours
/// whatever the app's theme, in the app's current language. Draw it inside
/// a `RepaintBoundary` to turn it into an image.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.data,
    this.showMap = true,
    this.tileProvider,
    this.onTileLoaded,
    this.onTileFailed,
  });

  final ShareCardData data;

  /// False drops the map (offline, or its tiles took too long).
  final bool showMap;
  final TileProvider? tileProvider;
  final VoidCallback? onTileLoaded;
  final VoidCallback? onTileFailed;

  static const _pad = 64.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final named = data.name.trim().isNotEmpty;
    final hasMap = showMap && data.area != null;
    TextStyle style(double size, FontWeight weight, Color color) => TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.2,
    );
    return Theme(
      data: lightTheme(),
      child: SizedBox.fromSize(
        size: shareCardSize,
        child: ColoredBox(
          color: CatColors.lightBackground,
          child: Padding(
            padding: const EdgeInsets.all(_pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The whole photo at its own shape, never cropped; the
                // rounded corners follow the photo, not the space around it.
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48),
                      child: Image.file(
                        data.photo,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const Center(child: Icon(Icons.pets, size: 160)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  named ? data.name.trim() : l10n.shareCardNoName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style(
                    76,
                    named ? FontWeight.w800 : FontWeight.w600,
                    named ? CatColors.lightPrimary : CatColors.lightSecondary,
                  ),
                ),
                if (data.neighbourhood != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 44,
                        color: CatColors.lightAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.seenAround(data.neighbourhood!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: style(
                            44,
                            FontWeight.w600,
                            CatColors.lightContent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (hasMap) ...[
                  const SizedBox(height: 24),
                  PlaceMap(
                    areas: [data.area!],
                    height: 160,
                    zoom: 14,
                    tileProvider: tileProvider,
                    onTileLoaded: onTileLoaded,
                    onTileFailed: onTileFailed,
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  l10n.shareCardKnownSince(
                    DateFormat.yMMMMd(locale).format(data.firstMet),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style(40, FontWeight.w500, CatColors.lightSecondary),
                ),
                const SizedBox(height: 28),
                const Divider(height: 2, color: CatColors.lightBorder),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/icon/icon.png',
                              width: 72,
                              height: 72,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            child: Text(
                              'StrayCats',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style(
                                44,
                                FontWeight.w800,
                                CatColors.lightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        'straycats.love',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: style(
                          44,
                          FontWeight.w600,
                          CatColors.lightAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
