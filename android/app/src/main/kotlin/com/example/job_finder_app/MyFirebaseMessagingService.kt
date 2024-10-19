package com.example.job_finder_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import androidx.core.app.NotificationCompat
import android.media.RingtoneManager

class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        //Log the message data
        Log.d("FCM", "From:  ${remoteMessage.from}");
        //Log the notification payload
        if (remoteMessage.notification  != null) {
            Log.d("FCM", "Notification title: ${remoteMessage.notification?.title}")
            Log.d("FCM", "Notification body: ${remoteMessage.notification?.body}");
        }

    }
}