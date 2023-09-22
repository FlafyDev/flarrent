import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:torrent_frontend/models/torrent.dart';
import 'package:torrent_frontend/widgets/common/button.dart';

class _GlowPainter extends CustomPainter {
  _GlowPainter({
    required this.color,
    required this.progress,
  });

  final Paint _paint = Paint();
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = color
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        10,
      );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width * progress + 10, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}

class TorrentTile extends HookConsumerWidget {
  const TorrentTile({
    super.key,
    required this.quickData,
    this.onPressed,
  });

  final TorrentQuickData quickData;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const borderRadius = 10.0;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 22,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: theme.colorScheme.onSecondary.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              clipper: RectCustomClipper(
                (size) => Rect.fromLTWH(
                  0,
                  size.height - 5,
                  size.width * 0.5,
                  size.height - 5,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: Colors.lightBlue),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CustomPaint(
                painter: _GlowPainter(
                  color: Colors.lightBlue.withOpacity(0.7),
                  progress: 0.5,
                ),
              ),
            ),
          ),
          InkButton(
            borderRadius: BorderRadius.circular(borderRadius),
            onPressed: onPressed ?? () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '[Cerberus] KonoSuba S1 + S2 + OVA + Movie [BD 1080p HEVC 10-bit OPUS] [Dual-Audio]',
                          style: TextStyle(
                            fontFamily: "Roboto",
                            color: theme.colorScheme.onSecondary,
                            fontSize: isFile ? 12 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isFile)
                          WidgetSpan(
                              child: SizedBox(
                            width: 5,
                          )),
                        if (isFile)
                          TextSpan(
                            text: "2.2 of 4.9 GiB (45%)",
                            style: TextStyle(
                              fontSize: isFile ? 11 : 14,
                              color: Color.fromARGB(255, 62, 107, 159),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: isFile ? 2 : 4,
                  ),
                  if (!isFile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "2.2 of 4.9 GiB    45%",
                          style: TextStyle(
                            fontSize: isFile ? 11 : 14,
                            color: Color.fromARGB(255, 62, 107, 159),
                          ),
                        ),
                        Text(
                          "2m 33s     4.4 MB/s",
                          style: TextStyle(
                            fontSize: isFile ? 11 : 14,
                            color: Color.fromARGB(255, 62, 107, 159),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // return Container(
    //   child: ColoredBox(color: Colors.amber),
    // );
  }
}

class TorrentFileTile extends HookConsumerWidget {
  const TorrentFileTile({
    super.key,
    required this.bytesDownloaded,
    required this.bytesToDownload,
    required this.state,
    this.timeLeft,
    this.bytesDownloadSpeed,
    required this.isFile,
    this.onPressed,
  });

  factory TorrentFileTile.fromQuickData({
    required TorrentQuickData data,
    void Function()? onPressed,
  }) {
    return TorrentTile(
      bytesDownloaded: data.downloadedBytes,
      bytesToDownload: data.sizeToDownloadBytes,
      state: data.state,
      timeLeft: data.estimatedTimeLeft,
      bytesDownloadSpeed: data.downloadBytesPerSecond,
      isFile: false,
      onPressed: onPressed,
    );
  }

  factory TorrentTile.fromFileData({
    required TorrentFileData data,
    void Function()? onPressed,
  }) {
    return TorrentTile(
      bytesDownloaded: data.downloadedBytes,
      bytesToDownload: data.sizeBytes,
      state: data.downloadedBytes == data.sizeBytes
          ? TorrentState.completed
          : data.wanted
              ? TorrentState.downloading
              : TorrentState.paused,
      isFile: true,
      onPressed: onPressed,
    );
  }

  final int bytesDownloaded;
  final int bytesToDownload;
  final Duration? timeLeft;
  final int? bytesDownloadSpeed;
  final TorrentState state;
  final bool isFile;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderRadius = isFile ? 5.0 : 10.0;
    final theme = Theme.of(context);

    return Container(
      decoration: isFile
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: 22,
                  blurStyle: BlurStyle.outer,
                ),
              ],
            ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: theme.colorScheme.onSecondary.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              clipper: RectCustomClipper(
                (size) => Rect.fromLTWH(
                  0,
                  size.height - 5,
                  size.width * 0.5,
                  size.height - 5,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: Colors.lightBlue),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CustomPaint(
                painter: _GlowPainter(
                  color: Colors.lightBlue.withOpacity(0.7),
                  progress: 0.5,
                ),
              ),
            ),
          ),
          InkButton(
            borderRadius: BorderRadius.circular(borderRadius),
            // style: ButtonStyle(
            //   padding: MaterialStatePropertyAll(EdgeInsets.zero),
            //   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //     RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //   ),
            //   shadowColor: MaterialStatePropertyAll(Colors.black),
            //   foregroundColor:
            //       MaterialStatePropertyAll(Color.fromARGB(255, 85, 188, 228)),
            //   backgroundColor:
            //       MaterialStatePropertyAll(Color.fromARGB(57, 7, 10, 50)),
            // ),
            onPressed: onPressed ?? () {},
            child: Container(
              padding: EdgeInsets.all(isFile ? 5 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "[Cerberus] KonoSuba S1 + S2 + OVA + Movie [BD 1080p HEVC 10-bit OPUS] [Dual-Audio]",
                          style: TextStyle(
                            fontFamily: "Roboto",
                            color: theme.colorScheme.onSecondary,
                            fontSize: isFile ? 12 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isFile)
                          WidgetSpan(
                              child: SizedBox(
                            width: 5,
                          )),
                        if (isFile)
                          TextSpan(
                            text: "2.2 of 4.9 GiB (45%)",
                            style: TextStyle(
                              fontSize: isFile ? 11 : 14,
                              color: Color.fromARGB(255, 62, 107, 159),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: isFile ? 2 : 4,
                  ),
                  if (!isFile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "2.2 of 4.9 GiB    45%",
                          style: TextStyle(
                            fontSize: isFile ? 11 : 14,
                            color: Color.fromARGB(255, 62, 107, 159),
                          ),
                        ),
                        Text(
                          "2m 33s     4.4 MB/s",
                          style: TextStyle(
                            fontSize: isFile ? 11 : 14,
                            color: Color.fromARGB(255, 62, 107, 159),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    // return Container(
    //   child: ColoredBox(color: Colors.amber),
    // );
  }
}

class RectCustomClipper extends CustomClipper<Rect> {
  const RectCustomClipper(Rect Function(Size size) getClip)
      : _getClip = getClip;

  final Rect Function(Size size) _getClip;

  @override
  Rect getClip(Size size) => _getClip(size);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) =>
      oldClipper != this;
}
