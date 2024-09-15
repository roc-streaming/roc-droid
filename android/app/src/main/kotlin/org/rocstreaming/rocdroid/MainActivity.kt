package org.rocstreaming.rocdroid

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import org.rocstreaming.connector.AndroidConnectorImpl

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        AndroidConnector.setUp(flutterEngine.dartExecutor.binaryMessenger,
                               AndroidConnectorImpl())
    }
}
