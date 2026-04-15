package com.example.taskproject

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "notification_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                if (call.method == "showNotification") {

                    val msg = call.argument<String>("msg") ?: "New Message"

                    val manager =
                        getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                    // 🔥 CHANNEL CREATE
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val channel = NotificationChannel(
                            "default_channel",
                            "Default",
                            NotificationManager.IMPORTANCE_HIGH
                        )
                        manager.createNotificationChannel(channel)
                    }

                    // 🔥 NOTIFICATION
                    val notification = NotificationCompat.Builder(this, "default_channel")
                        .setContentTitle("New Message")
                        .setContentText(msg)
                        .setSmallIcon(android.R.drawable.ic_dialog_info)
                        .build()

                    manager.notify(1, notification)

                    result.success(null)

                } else {
                    result.notImplemented()
                }
            }
    }
}