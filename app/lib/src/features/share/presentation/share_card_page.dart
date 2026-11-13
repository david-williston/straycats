import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../localization/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../data/card_image.dart';
import '../data/card_sharer.dart';
import 'share_card.dart';

/// How long the map gets to load before the card is made without it.
const mapPatience = Duration(seconds: 3);

/// After the last map tile arrives, a short wait so fades have finished.
const _poll = Duration(milliseconds: 100);
const _mapSettle = Duration(milliseconds: 700);

/// A preview of the cat's card with a Share button. The card is drawn here,
/// made into an image on the device, and handed to the share sheet; it is
/// never uploaded.
class ShareCardPage extends ConsumerStatefulWidget {
  const ShareCardPage({
    super.key,
    required this.data,
    this.tileProvider,
    this.render,
  });

  final ShareCardData data;

  /// For tests; defaults to OpenStreetMap over the network.
  final TileProvider? tileProvider;

  /// For tests; defaults to [renderCardPng].
  final Future<Uint8List> Function(RenderRepaintBoundary)? render;

  @override
  ConsumerState<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends ConsumerState<ShareCardPage> {
  final _boundary = GlobalKey();
  bool _showMap = true;
  bool _sharing = false;
  int _tilesLoaded = 0;
  int _sinceTile = 0; // poll ticks since the last tile arrived

  void _tileLoaded() {
    _tilesLoaded++;
    _sinceTile = 0;
  }

  void _tileFailed() {
    if (mounted && _showMap) setState(() => _showMap = false);
  }

  /// Waits until the map has loaded and settled, up to [mapPatience]; if it
  /// has not, the card goes without it.
  Future<void> _waitForMap() async {
    if (!_showMap || widget.data.area == null) return;
    var waited = Duration.zero;
    while (mounted && _showMap) {
      if (_tilesLoaded > 0 &&
          _sinceTile * _poll.inMilliseconds >= _mapSettle.inMilliseconds) {
        return;
      }
      if (waited >= mapPatience) break;
      await Future<void>.delayed(_poll);
      waited += _poll;
      _sinceTile++;
    }
    if (mounted && _showMap && _tilesLoaded == 0) {
      setState(() => _showMap = false);
    }
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final sharer = ref.read(cardSharerProvider);
    setState(() => _sharing = true);
    try {
      await _waitForMap();
      if (!mounted) return;
      // A frame after any change, so the picture shows what the card shows.
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _boundary.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final png = await (widget.render ?? renderCardPng)(boundary);
      await sharer.share(png);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareFailed)));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareCard)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: FittedBox(
                    // A visible card surface; the image itself is only the
                    // boundary inside it.
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: CatColors.lightCard,
                        borderRadius: BorderRadius.circular(56),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 80,
                            offset: Offset(0, 24),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(56),
                        child: RepaintBoundary(
                          key: _boundary,
                          child: ShareCard(
                            data: widget.data,
                            showMap: _showMap,
                            tileProvider: widget.tileProvider,
                            onTileLoaded: _tileLoaded,
                            onTileFailed: _tileFailed,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton.icon(
                onPressed: _sharing ? null : _share,
                icon: _sharing
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share),
                label: Text(l10n.shareButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
