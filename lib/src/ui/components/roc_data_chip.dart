import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../styles/roc_colors.dart';

/// Roc's custom chip widget.
class RocDataChip extends Align {
  RocDataChip({required String text, required Logger logger})
      : super(
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: RocColors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
              ),
            ),
            child: Container(
              width: 150.0,
              height: 35.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(text),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: text));
                        logger.d('Copied to clipboard: ${text}');
                      },
                      icon: Icon(Icons.copy),
                      iconSize: 22.0,
                      color: RocColors.mainBlue,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
}
