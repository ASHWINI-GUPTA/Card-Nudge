import { createClient } from "npm:@supabase/supabase-js@^2.50.1";
import admin from "npm:firebase-admin@^11.11.1";

// --- Firebase Admin SDK Initialization ---
const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
let firebaseAdminApp: admin.app.App | undefined;

// --- Supabase Client Initialization ---
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
let supabase: ReturnType<typeof createClient> | undefined;

if (!serviceAccountJson) {
  console.error(
    "❌ Critical: FIREBASE_SERVICE_ACCOUNT_JSON environment variable is missing.",
  );
} else {
  try {
    firebaseAdminApp = admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(serviceAccountJson)),
    });
    console.log("✅ Firebase Admin SDK initialized successfully.");
  } catch (e) {
    console.error("❌ Critical: Failed to initialize Firebase Admin SDK:", e);
  }
}

if (!supabaseUrl || !supabaseKey) {
  console.error(
    "❌ Critical: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables are missing.",
  );
} else {
  supabase = createClient(supabaseUrl, supabaseKey);
  console.log("✅ Supabase client initialized successfully.");
}

/**
 * Deletes stale or invalid device tokens from the "device_tokens" table in Supabase.
 *
 * Logs the attempt, and upon completion, logs either a success or error message.
 * If the provided tokens array is empty, the function returns immediately.
 *
 * @param tokens - An array of device token strings to be deleted.
 * @returns A promise that resolves when the deletion operation is complete.
 */
async function deleteStaleTokens(tokens: string[]) {
  if (!tokens.length) return;
  console.info(
    `🗑️ Attempting to delete stale/invalid tokens: ${tokens.join(", ")}`,
  );
  if (!supabase) {
    console.error("❌ Supabase client not available to delete tokens.");
    return;
  }
  const { error: deleteError } = await supabase
    .from("device_tokens")
    .delete()
    .in("device_token", tokens);

  if (deleteError) {
    console.error(
      `❌ Failed to delete tokens [${tokens.join(", ")}]:`,
      deleteError.message,
    );
  } else {
    console.info(`✅ Successfully deleted stale tokens: ${tokens.join(", ")}`);
  }
}

Deno.serve(async () => {
  // --- Initial Checks for Critical Dependencies within request context ---
  if (!serviceAccountJson || !firebaseAdminApp) {
    console.error(
      "❌ Initial Check: Firebase Admin SDK not ready due to missing env var or failed initialization.",
    );
    return new Response(
      "Internal Server Error: Firebase Admin SDK setup failed.",
      { status: 500 },
    );
  }

  if (!supabaseUrl || !supabaseKey || !supabase) {
    console.error(
      "❌ Initial Check: Supabase client not ready due to missing env vars or failed initialization.",
    );
    return new Response(
      "Internal Server Error: Supabase client configuration failed.",
      { status: 500 },
    );
  }

  const messaging = firebaseAdminApp.messaging();

  console.info("▶️ Running full notification routine...");

  const now = new Date();
  const currentHHMM = "05:30"; // now.toISOString().slice(11, 16);

  const { data: settings, error } = await supabase
    .from("settings")
    .select("user_id")
    .eq("notifications_enabled", true)
    .eq("reminder_time", currentHHMM);

  if (error) {
    console.error("❌ Error fetching user settings:", error);
    return new Response(`Error fetching user settings: ${error.message}`, {
      status: 500,
    });
  }

  const userIds = (settings ?? []).map((s) => s.user_id as string);
  console.info(`👥 Users to notify: ${userIds.length}`);

  // -- Log and Cleanup Variables --
  const notificationLogs: any[] = [];
  const failedTokens: string[] = [];

  for (const userId of userIds) {
    type Payment = {
      id: string;
      due_date: string;
      due_amount: number;
      is_paid: boolean;
      cards: {
        name: string;
        last_4_digits: string;
      };
    };

    const { data: payments, error: payError } = await supabase
      .from("payments")
      .select(`
      id,
      due_date,
      due_amount,
      is_paid,
      cards (
        name,
        last_4_digits
      )
      `)
      .eq("user_id", userId)
      .eq("is_paid", false) as { data: Payment[] | null; error: Error | null };

    if (payError) {
      console.error(`❌ Payment fetch failed for ${userId}:`, payError.message);
      continue;
    }
    if (!payments || payments.length === 0) {
      console.debug(`ℹ️ No unpaid payments found for user ${userId}.`);
      continue;
    }

    for (const p of payments) {
      const card_id = p.id;
      const dueDate = new Date(p.due_date);
      const daysBefore = Math.ceil(
        (dueDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24),
      );
      if (daysBefore < 0) {
        console.debug(
          `ℹ️ Skipping overdue payment for user ${userId} (ID: ${p.id}).`,
        );
        continue; // Skip overdue payments
      }

      // Payment N:1 Cards, p.cards is a single object
      const card = p.cards;
      if (!card) {
        console.warn(
          `⚠️ Payment (ID: ${p.id}) for user ${userId} has no linked card. Skipping notification.`,
        );
        continue;
      }

      const card_name = card.name;
      const last_4_digits = card.last_4_digits;
      const title = daysBefore === 0
        ? "Payment Due Today"
        : `Payment Due in ${daysBefore} day${daysBefore === 1 ? "" : "s"}`;
      const body =
        `Pay ₹${p.due_amount} for ${card_name} (**** ${last_4_digits})`;
      const payload = `/cards/${card_id}`;

      const { data: tokens, error: tokenError } = await supabase
        .from("device_tokens")
        .select("device_token")
        .eq("user_id", userId);

      if (tokenError) {
        console.error(
          `❌ Token fetch failed for ${userId}:`,
          tokenError.message,
        );
        continue;
      }

      const tokensArr = (tokens ?? []).map((t) => t.device_token as string);
      if (!tokensArr.length) {
        console.debug(`ℹ️ No device tokens found for user ${userId}.`);
        continue;
      }

      console.debug(
        `📨 Sending notification to ${userId} [${card_name}] (tokens: ${
          tokensArr.join(", ")
        })...`,
      );

      try {
        const multicastMessage: admin.messaging.MulticastMessage = {
          notification: { title, body },
          data: { route: payload },
          tokens: tokensArr,
        };

        const response = await messaging.sendEachForMulticast(multicastMessage);
        console.debug(
          `✅ Multicast message sent to ${userId} for card ${card_id}:`,
          response,
        );

        // Log notification for each successful token
        for (let i = 0; i < response.responses.length; i++) {
          if (response.responses[i].success) {
            notificationLogs.push({
              user_id: userId,
              card_id: card_id,
              title,
              body,
              payload,
              sent_at: new Date().toISOString(),
            });
          }
        }

        // Collect failed tokens for deletion
        response.responses.forEach((r, idx) => {
          if (!r.success) {
            const error = r.error;
            console.error(
              `❌ FCM send failed for token ${tokensArr[idx]}:`,
              error,
            );
            if (
              error &&
              (
                error.code === "messaging/invalid-registration-token" ||
                error.code === "messaging/registration-token-not-registered" ||
                error.code === "messaging/not-found"
              )
            ) {
              failedTokens.push(tokensArr[idx]);
            }
          }
        });
      } catch (error: unknown) {
        console.error(
          `❌ FCM multicast send failed for user ${userId}:`,
          error,
        );
      }
    }
  }

  if (notificationLogs.length > 0) {
    supabase
      .from("notification_logs")
      .insert(notificationLogs);
  }
  if (failedTokens.length) {
    await deleteStaleTokens(failedTokens);
  }

  // Return success response, background tasks will continue via waitUntil
  return new Response("✅ Notification routine completed", { status: 200 });
});
