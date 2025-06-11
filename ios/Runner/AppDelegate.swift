import UIKit
import Flutter
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)

        // Set up MethodChannel for notification service
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "in.fnlsg.card/notifications", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) in
            switch call.method {
            case "scheduleBackgroundCheck":
                guard let args = call.arguments as? [String: Any],
                      let identifier = args["identifier"] as? String,
                      let earliestBeginDate = args["earliestBeginDate"] as? Double else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                    return
                }
                self.scheduleBackgroundCheck(identifier: identifier, earliestBeginDate: earliestBeginDate)
                result(nil)
            case "runNotificationService":
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        // Register background tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "in.fnlsg.card.dailyCheck", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "in.fnlsg.card.immediateCheck", using: nil) { task in
            self.handleBackgroundTask(task: task as! BGProcessingTask)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func scheduleBackgroundCheck(identifier: String, earliestBeginDate: Double) {
        let request = BGProcessingTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSince1970: earliestBeginDate)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
            print("Scheduled background task: \(identifier)")
        } catch {
            print("Failed to schedule background task: \(error)")
        }
    }

    private func handleBackgroundTask(task: BGProcessingTask) {
        // Schedule next daily task if not immediate
        if task.identifier == "in.fnlsg.card.dailyCheck" {
            scheduleBackgroundCheck(
                identifier: "in.fnlsg.card.dailyCheck",
                earliestBeginDate: Date().addingTimeInterval(24 * 60 * 60).timeIntervalSince1970
            )
        }

        // Initialize Flutter engine
        let flutterEngine = FlutterEngine(name: "notificationEngine")
        flutterEngine.run()

        let channel = FlutterMethodChannel(name: "in.fnlsg.card/notifications", binaryMessenger: flutterEngine.binaryMessenger)
        channel.invokeMethod("runNotificationService", arguments: nil) { _ in
            task.setTaskCompleted(success: true)
            flutterEngine.destroyContext()
        }

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            flutterEngine.destroyContext()
        }
    }
}