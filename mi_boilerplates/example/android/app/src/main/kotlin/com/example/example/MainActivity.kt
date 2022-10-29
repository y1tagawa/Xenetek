package com.example.example

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.xenetek.mi_boilerplates/examples"
        private const val METHOD_GET_BUILD_MODEL = "getAndroidBuildModel"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == METHOD_GET_ANDROID_BUILD_MODEL) {
                result.success(Build.MODEL)
            } else {
                result.notImplemented()
            }
        }
    }
}
