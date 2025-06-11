package `in`.fnlsg.card

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "in.fnlsg.card/notifications"
    private val RECEIVER_ACTION = "in.fnlsg.card.ALARM"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    try {
                        val delaySeconds = call.argument<Int>("delaySeconds") ?: 0
                        val isOneTime = call.argument<Boolean>("isOneTime") ?: false
                        scheduleAlarm(delaySeconds, isOneTime)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ALARM_ERROR", "Failed to schedule alarm", e.message)
                    }
                }
                else -> result.notImplemented()
            }
        }

        registerReceiver(AlarmReceiver(), IntentFilter(RECEIVER_ACTION).apply {
            addAction(Intent.ACTION_BOOT_COMPLETED)
            addAction(Intent.ACTION_MY_PACKAGE_REPLACED)
        })
    }

    private fun scheduleAlarm(delaySeconds: Int, isOneTime: Boolean) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(RECEIVER_ACTION)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val triggerTime = System.currentTimeMillis() + delaySeconds * 1000L
        if (isOneTime) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
        } else {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                triggerTime,
                pendingIntent
            )
            // Note: For repeating, we reschedule daily in AlarmReceiver to ensure accuracy
        }
    }
}

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action in listOf("in.fnlsg.card.ALARM", Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED)) {
            try {
                // Initialize Flutter engine if needed
                val flutterEngine = FlutterEngine(context)
                val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "in.fnlsg.card/notifications")
                channel.invokeMethod("runNotificationService", null)

                // Reschedule daily alarm if not a one-time or boot event
                if (intent?.action == "in.fnlsg.card.ALARM") {
                    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        0,
                        Intent("in.fnlsg.card.ALARM"),
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    val triggerTime = System.currentTimeMillis() + 24 * 60 * 60 * 1000L
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        triggerTime,
                        pendingIntent
                    )
                }
            } catch (e: Exception) {
                println("AlarmReceiver error: ${e.message}")
            }
        }
    }
}