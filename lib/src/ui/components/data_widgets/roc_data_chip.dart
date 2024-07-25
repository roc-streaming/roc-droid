import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'roc_chip.dart';

/// Roc's custom data chip widget.
class RocDataChip extends RocChip {
  RocDataChip(String text, Logger logger)
      : super(
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
                ),
              ),
            ],
          ),
        );
}
