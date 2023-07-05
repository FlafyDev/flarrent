import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// class TorrentTile extends HookConsumerWidget {
//   const TorrentTile({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return DataRow(cells: [
//       DataCell(Text('Torrent Tile')),
//       DataCell(ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: SizedBox(
//           width: 200,
//           height: 7,
//           child: Stack(
//             children: [
//               Positioned.fill(
//                   child: ColoredBox(color: Colors.grey.withOpacity(0.2))),
//               Positioned.fill(
//                 child: ClipRect(
//                   clipper: RectCustomClipper((size) =>
//                       Rect.fromLTWH(0, 0, size.width * 1, size.height)),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.lightBlue, Colors.lightBlue.shade200],
//                         stops: [
//                           0.5,
//                           0.9,
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )),
//       DataCell(Text('Size')),
//     ]);
//
//     // return Container(
//     //   child: Row(
//     //     children: [
//     //       SizedBox(width: 10),
//     //       ,
//     //       SizedBox(width: 10),
//     //       ,
//     //       Spacer(),
//     //     ],
//     //   ),
//     //   // color: Colors.lightBlue.withOpacity(0.2),
//     //   // hoverColor: Colors.lightBlue.withOpacity(0.2),
//     // );
//   }
// }

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
