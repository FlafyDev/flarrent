import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TorrentTile extends HookConsumerWidget {
  const TorrentTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 7,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStatePropertyAll(EdgeInsets.zero),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          foregroundColor:
              MaterialStatePropertyAll(Color.fromARGB(255, 85, 188, 228)),
          backgroundColor:
              MaterialStatePropertyAll(Color.fromARGB(60, 8, 31, 50)),
        ),
        onPressed: () {},
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "[Cerberus] KonoSuba S1 + S2 + OVA + Movie [BD 1080p HEVC 10-bit OPUS] [Dual-Audio]",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("2.2 of 4.9 GiB    45%",
                      style:
                          TextStyle(color: Color.fromARGB(255, 62, 107, 159))),
                  Text("2m 33s     4.4 MB/s",
                      style:
                          TextStyle(color: Color.fromARGB(255, 62, 107, 159))),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 10,
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              // colors: [Colors.lightBlue.withOpacity(0.2), Colors.lightBlue.shade200],
                              colors: [
                                Colors.lightBlue.shade900.withOpacity(0.3),
                                Colors.lightBlue.shade900.withOpacity(0.3),
                              ],
                              stops: [
                                0.5,
                                0.9,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
