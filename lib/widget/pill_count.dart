import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PillCount extends StatefulWidget {
  final String icon;
  final String count;
  final String limit;
  const PillCount({
    super.key,
    required this.icon,
    required this.count,
    required this.limit,
  });

  @override
  State<PillCount> createState() => _PillCountState();
}

class _PillCountState extends State<PillCount> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 30,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 3,
        children: [
          SvgPicture.asset(widget.icon, width: 20, height: 20),
          Text(widget.count),
          Text("/"),
          Text(widget.limit),
        ],
      ),
    );
  }
}
