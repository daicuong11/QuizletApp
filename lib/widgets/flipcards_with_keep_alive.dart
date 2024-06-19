import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class FlipCardWithKeepAlive extends StatefulWidget {
  final FlipCard child;

  FlipCardWithKeepAlive({
    required this.child,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => FlipCardWithKeepAliveState();
}

class FlipCardWithKeepAliveState extends State<FlipCardWithKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
