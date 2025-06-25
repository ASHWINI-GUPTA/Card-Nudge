import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js";
import admin from "npm:firebase-admin";

// --- Firebase Admin SDK Initialization ---
const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");

if (!serviceAccountJson) {
  console.error(
    "❌ Missing FIREBASE_SERVICE_ACCOUNT_JSON environment variable",
  );
}

let firebaseAdminApp: admin.app.App | undefined;

try {
  // Initialize Firebase Admin SDK only once
  firebaseAdminApp = admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(serviceAccountJson!)),
  });
  console.log("✅ Firebase Admin SDK initialized");
} catch (e) {
  console.error("❌ Failed to initialize Firebase Admin SDK:", e);
}

if (!firebaseAdminApp) {
  console.error(
    "❌ Missing environment variables or Firebase Admin SDK not initialized",
  );
}

serve(async () => {
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
      console.info(
        `✅ Successfully deleted stale tokens: ${tokens.join(", ")}`,
      );
    }
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  if (!supabaseUrl || !supabaseKey) {
    console.error(
      "❌ Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variable",
    );
  }

  const supabase = createClient(
    supabaseUrl!,
    supabaseKey!,
  );

  const messaging = firebaseAdminApp!.messaging();

  console.info("▶️ Running full notification routine...");

  const now = new Date();
  const currentHHMM = "05:30"; // now.toISOString().slice(11, 16);

  const { data: settings, error } = await supabase
    .from("settings")
    .select("user_id")
    .eq("notifications_enabled", true)
    .eq("reminder_time", currentHHMM);

  if (error || !settings) {
    console.error("❌ Error fetching user settings:", error);
  }

  const userIds = (settings ?? []).map((s) => s.user_id);
  console.info(`👥 Users to notify: ${userIds.length}`);

  for (const userId of userIds) {
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
      .eq("is_paid", false);

    if (payError || !payments) {
      console.error(`❌ Payment fetch failed for ${userId}:`, payError);
      continue;
    }
    for (const p of payments) {
      const card_id = p.id;
      const dueDate = new Date(p.due_date);
      const daysBefore = Math.ceil(
        (dueDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24),
      );
      if (daysBefore < 0) continue; // Skip overdue payments

      console.table(p);

      const card_name = p.cards[0].name;
      const last_4_digits = p.cards[0].last_4_digits;
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

      if (tokenError || !tokens) {
        console.error(`❌ Token fetch failed for ${userId}:`, tokenError);
        continue;
      }

      const tokensArr = tokens.map((t) => t.device_token);
      if (!tokensArr.length) continue;

      console.debug(
        `📨 Sending notification to ${userId} [${card_name}] (tokens: ${
          tokensArr.join(", ")
        })...`,
      );

      try {
        const message = {
          notification: { title, body },
          data: { route: payload },
          tokens: tokensArr,
        };

        const response = await messaging.sendEachForMulticast(message);
        console.debug(
          `✅ Multicast message sent to ${userId} for card ${card_id}:`,
          response,
        );

        // Log notification for each successful token
        for (let i = 0; i < response.responses.length; i++) {
          if (response.responses[i].success) {
            const { error: logErr } = await supabase
              .from("notification_logs")
              .insert({
                user_id: userId,
                card_id: card_id,
                title,
                body,
                payload,
                sent_at: new Date().toISOString(),
              });
            if (logErr) {
              console.error(
                `❌ Log insert failed for ${userId}:`,
                logErr.message,
              );
            }
          }
        }

        // Collect failed tokens for deletion
        const failedTokens: string[] = [];
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
        if (failedTokens.length) {
          await deleteStaleTokens(failedTokens);
        }
      } catch (error: unknown) {
        console.error(
          `❌ FCM multicast send failed for user ${userId}:`,
          error,
        );
      }
    }
  }

  return new Response("✅ Notification function completed", { status: 200 });
});
