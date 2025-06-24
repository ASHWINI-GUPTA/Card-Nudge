import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'npm:@supabase/supabase-js';
import admin from 'npm:firebase-admin';

console.log('🚀 Supabase Edge Function: send-notification initialized');

// --- Firebase Admin SDK Initialization ---
// Parse the service account JSON string from environment variables
const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');

if (!serviceAccountJson) {
  console.error('❌ Missing FIREBASE_SERVICE_ACCOUNT_JSON environment variable');
}

let firebaseAdminApp: admin.app.App | undefined;

try {
  // Initialize Firebase Admin SDK only once
  firebaseAdminApp = admin.initializeApp({
    credential: admin.credential.cert(JSON.parse(serviceAccountJson!)), // Parse the JSON string
  });
  console.log('✅ Firebase Admin SDK initialized');
} catch (e) {
  console.error('❌ Failed to initialize Firebase Admin SDK:', e);
  // This will prevent the function from running if initialization fails
  Deno.exit(1); 
}

serve(async (req) => {
  const fullUrl = req.url;
  const url = new URL(fullUrl);
  
  // Run Debug Flow
  // const isDebug = url.searchParams.get('debug');
  // const debugUserId = url.searchParams.get('userId');
  const isDebug = true;
  const debugUserId = '9a113684-b797-4e3b-8985-8041ffd83c06';

  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  const supabaseUrl = Deno.env.get('SUPABASE_URL');

  if (!serviceKey || !supabaseUrl || !firebaseAdminApp) {
    console.error('❌ Missing environment variables or Firebase Admin SDK not initialized');
    return new Response('Configuration error', { status: 500 });
  }

  const supabase = createClient(supabaseUrl, serviceKey);
  const messaging = firebaseAdminApp.messaging();

  // Helper function to handle token deletion (now supports array)
  async function deleteStaleTokens(tokens: string[]) {
    if (!tokens.length) return;
    console.log(`🗑️ Attempting to delete stale/invalid tokens: ${tokens.join(', ')}`);
    const { error: deleteError } = await supabase
      .from('device_tokens')
      .delete()
      .in('device_token', tokens);

    if (deleteError) {
      console.error(`❌ Failed to delete tokens [${tokens.join(', ')}]:`, deleteError.message);
    } else {
      console.log(`✅ Successfully deleted stale tokens: ${tokens.join(', ')}`);
    }
  }

  // 🚧 Short-circuit for debug mode
  if (isDebug && debugUserId) {
    console.log(`🧪 Debug mode enabled — sending test notification to user ${debugUserId}`);

    const { data: tokens, error: tokenError } = await supabase
      .from('device_tokens')
      .select('device_token')
      .eq('user_id', debugUserId);

    if (tokenError || !tokens || tokens.length === 0) {
      console.error(`❌ No tokens found for user ${debugUserId}:`, tokenError);
      return new Response('No tokens found', { status: 404 });
    }

    const tokensArr = tokens.map((t) => t.device_token);

    if (!tokensArr.length) {
      console.error(`❌ No tokens found for user ${debugUserId}`);
      return new Response('No tokens found', { status: 404 });
    }

    const title = '🔔 Test Notification';
    const body = 'This is a test push notification from Supabase Edge Function.';
    const payload = '/cards';

    console.log(`📨 Sending test notification to ${debugUserId} (tokens: ${tokensArr.join(', ')})...`);

    try {
      const message = {
        notification: { title, body },
        data: { route: payload },
        tokens: tokensArr,
      };

      const response = await messaging.sendEachForMulticast(message);
      console.log(`✅ Multicast message sent to ${debugUserId}:`, response);

      // Collect failed tokens for deletion
      const failedTokens: string[] = [];
      response.responses.forEach((r, idx) => {
        if (!r.success) {
          const error = r.error;
          console.error(`❌ FCM send failed for token ${tokensArr[idx]}:`, error);
          if (
            error.code === 'messaging/invalid-registration-token' ||
            error.code === 'messaging/registration-token-not-registered' ||
            error.code === 'messaging/not-found'
          ) {
            failedTokens.push(tokensArr[idx]);
          }
        }
      });
      if (failedTokens.length) {
        await deleteStaleTokens(failedTokens);
      }
    } catch (error: any) {
      console.error(`❌ FCM multicast send failed:`, error);
    }

    return new Response('✅ Debug notification sent', { status: 200 });
  }

  // 🟩 Proceed with regular flow if debug not requested
  console.log('▶️ Running full notification routine...');

  const now = new Date();
  const currentHHMM = now.toISOString().slice(11, 16);

  const { data: settings, error } = await supabase
    .from('settings')
    .select('user_id')
    .eq('notifications_enabled', true)
    .eq('reminder_time', currentHHMM);

  if (error || !settings) {
    console.error('❌ Error fetching user settings:', error);
    return new Response('Failed to get users', { status: 500 });
  }

  const userIds = settings.map((s) => s.user_id);
  console.log(`👥 Users to notify: ${userIds.length}`);

  for (const userId of userIds) {
    const { data: payments, error: payError } = await supabase
      .from('payments')
      .select(`
        id as card_id, 
        due_date, 
        due_amount, 
        is_paid, 
        cards (name as card_name, last_4_digits)
      `)
      .eq('user_id', userId)
      .eq('is_paid', false);

    if (payError || !payments) {
      console.error(`❌ Payment fetch failed for ${userId}:`, payError);
      continue;
    }

    for (const p of payments) {
      const dueDate = new Date(p.due_date);
      const daysBefore = Math.ceil((dueDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
      if (daysBefore < 0) continue; // Skip overdue payments

      const title = daysBefore === 0
        ? 'Payment Due Today'
        : `Payment Due in ${daysBefore} day${daysBefore === 1 ? '' : 's'}`;
      const body = `Pay ₹${p.due_amount} for ${p.card_name} (**** ${p.last_4_digits})`;
      const payload = `/cards/${p.card_id}`;

      const { data: tokens, error: tokenError } = await supabase
        .from('device_tokens')
        .select('device_token')
        .eq('user_id', userId);

      if (tokenError || !tokens) {
        console.error(`❌ Token fetch failed for ${userId}:`, tokenError);
        continue;
      }

      const tokensArr = tokens.map((t) => t.device_token);
      if (!tokensArr.length) continue;

      console.log(`📨 Sending notification to ${userId} [${p.card_name}] (tokens: ${tokensArr.join(', ')})...`);

      try {
        const message = {
          notification: { title, body },
          data: { route: payload },
          tokens: tokensArr,
        };

        const response = await messaging.sendEachForMulticast(message);
        console.log(`✅ Multicast message sent to ${userId} for card ${p.card_id}:`, response);

        // Log notification for each successful token
        for (let i = 0; i < response.responses.length; i++) {
          if (response.responses[i].success) {
            const { error: logErr } = await supabase
              .from('notification_logs')
              .insert({
                user_id: userId,
                card_id: p.card_id,
                title,
                body,
                payload,
                sent_at: new Date().toISOString(),
              });
            if (logErr) {
              console.error(`❌ Log insert failed for ${userId}:`, logErr.message);
            }
          }
        }

        // Collect failed tokens for deletion
        const failedTokens: string[] = [];
        response.responses.forEach((r, idx) => {
          if (!r.success) {
            const error = r.error;
            console.error(`❌ FCM send failed for token ${tokensArr[idx]}:`, error);
            if (
              error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered' ||
              error.code === 'messaging/not-found'
            ) {
              failedTokens.push(tokensArr[idx]);
            }
          }
        });
        if (failedTokens.length) {
          await deleteStaleTokens(failedTokens);
        }
      } catch (error: any) {
        console.error(`❌ FCM multicast send failed for user ${userId}:`, error);
      }
    }
  }

  return new Response('✅ Notification function completed', { status: 200 });
});

