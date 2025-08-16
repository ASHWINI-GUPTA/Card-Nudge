import { SupabaseService } from "../shared/SupabaseService.ts";
import { FirebaseService } from "./services/FirebaseService.ts";
import { NotificationSender } from "./notification/NotificationSender.ts";
import { NotificationLog } from "../shared/models.ts";

// --- Service Initialization ---
const supabaseService = new SupabaseService(
  Deno.env.get("SUPABASE_URL"),
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),
);

const firebaseService = new FirebaseService(
  Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON"),
);

const notificationSender = new NotificationSender(
  supabaseService,
  firebaseService,
);

/**
 * Main handler for the notification routine.
 */
Deno.serve(async (req) => {
  // Only allow GET requests
  if (req.method !== "GET") {
    return new Response(JSON.stringify({ error: "Method Not Allowed" }), {
      headers: { "Content-Type": "application/json" },
      status: 405,
    });
  }

  if (!supabaseService.isInitialized() || !firebaseService.isInitialized()) {
    return new Response("Firebase/Supabase not initialized", { status: 500 });
  }

  const now = new Date();
  const reminderTime = now.toISOString().slice(11, 16); // e.g., "19:24"

  const usersToNotify = await supabaseService.getUsersToNotify(reminderTime);
  const logs: NotificationLog[] = [];
  const failedTokens: string[] = [];

  if (!usersToNotify.length) {
    console.debug(
      `📭 No users configured to receive notifications at ${reminderTime}.`,
    );
    return new Response("No users to notify at this time", { status: 200 });
  }

  console.log(
    `🔔 Processing notifications for ${usersToNotify.length} users at ${reminderTime}.`,
  );

  for (const userId of usersToNotify) {
    await notificationSender.processUserNotifications(
      userId,
      now,
      logs,
      failedTokens,
    );
  }

  if (logs.length) {
    await supabaseService.insertNotificationLog(logs);
  }
  if (failedTokens.length) {
    await supabaseService.deleteStaleTokens(failedTokens);
  }

  console.log("✅ Notification routine complete.");
  return new Response("Notification routine complete", { status: 200 });
});
