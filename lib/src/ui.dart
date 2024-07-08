/// UI library definition.
// All classes in the "UI" library have common imports
// All "UI" library imports must be defined in this file.
library model;

// Imports definition
import 'package:flutter/material.dart';
import 'model.dart';

// Parts definition - Root + page layer
part 'ui/app_root.dart';
part 'ui/main_screen.dart';
part 'ui/receiver_page.dart';
part 'ui/sender_page.dart';

// Parts definition - Fragments layer
part 'ui/fragments/message_popup.dart';
part 'ui/fragments/settings_pane.dart';
part 'ui/fragments/source_selector.dart';
