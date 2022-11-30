package com.example.example

import android.media.RingtoneManager
import android.media.Ringtone
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.Log
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "com.xenetek.mi_boilerplates/examples"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "playSoundAsync") {
                Log.d(TAG, "[i] playSoundAsync")
                try {
                    val type = call.arguments<Int>()
                    Log.d(TAG, "type=$type")
                    // TODO: デフォルトではループしない適当な音源が他に無いのでパラメタは無視する。
                    val notification: Uri =
                        RingtoneManager.getActualDefaultRingtoneUri(
                            applicationContext, RingtoneManager.TYPE_NOTIFICATION)
                    val r: Ringtone =
                        RingtoneManager.getRingtone(applicationContext, notification)
                    r.play()
                    Log.d(TAG, "[o] playSoundAsync")
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                result.success(Build.MODEL)
            } else {
                result.notImplemented()
            }
        }
    }
}
