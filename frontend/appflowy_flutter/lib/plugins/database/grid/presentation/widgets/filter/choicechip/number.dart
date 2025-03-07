import 'package:flutter/material.dart';

import '../filter_info.dart';
import 'choicechip.dart';

class NumberFilterChoicechip extends StatelessWidget {
  const NumberFilterChoicechip({required this.filterInfo, super.key});

  final FilterInfo filterInfo;

  @override
  Widget build(BuildContext context) {
    return ChoiceChipButton(filterInfo: filterInfo);
  }
}
