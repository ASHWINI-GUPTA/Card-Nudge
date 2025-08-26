import { convertToMarkdown, generateSummary } from "./summaryGenerator.ts";
import { SupabaseService } from "../shared/SupabaseService.ts";

// --- Service Initialization ---
const supabaseService = new SupabaseService(
  Deno.env.get("SUPABASE_URL"),
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"),
);

/**
 * Main handler for the generate card summaries function.
 */
Deno.serve(async (req: Request): Promise<Response> => {
  // Only allow GET requests
  if (req.method !== "GET") {
    return new Response(JSON.stringify({ error: "Method Not Allowed" }), {
      headers: { "Content-Type": "application/json" },
      status: 405,
    });
  }

  if (!supabaseService.isInitialized()) {
    return new Response("Supabase not initialized", { status: 500 });
  }

  const cardsWithoutSummary = await supabaseService.getCardsWithoutSummary();

  for (const card of cardsWithoutSummary) {
    console.log(`Generating summary for card: ${card.name} (ID: ${card.id})`);

    let bank = await supabaseService.getBankById(card.bank_id);
    if (!bank) {
      bank = await supabaseService.getUserBankById(card.bank_id);
    }

    if (!bank) {
      console.error(
        `Bank not found for card ${card.id}. Skipping summary generation.`,
      );
      continue;
    }

    // Generate the summary for the card
    const rawSummary = await generateSummary(card, bank);
    const markdownSummary = await convertToMarkdown(rawSummary);

    // Save the summary to Supabase
    await supabaseService.upsertCreditCardSummary({
      card_id: card.id,
      markdown_summary: markdownSummary,
      status: 2, // Completed
      error_message: null,
    });

    console.log(
      `Successfully generated and saved summary for card ${card.id}.`,
    );
  }

  return new Response("Summaries processed", { status: 200 });
});
