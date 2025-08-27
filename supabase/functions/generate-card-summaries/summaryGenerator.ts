import { GoogleGenAI } from "@google/genai";
import { Bank, Card } from "../shared/models.ts";

const AI_API_KEY = Deno.env.get("AI_API_KEY");
const AI_MODEL = Deno.env.get("AI_MODEL");

// Initialize the AI client outside the function to reuse connections if possible
// Ensure AI_API_KEY is available during the Deno deploy process for function initialization
const genAI = AI_API_KEY ? new GoogleGenAI({ apiKey: AI_API_KEY }) : null;

// --- PROMPT DEFINITION ---
// This prompt will be used to guide the AI in generating the summary.
const generateSummaryPrompt = (card: Card, bank: Bank): string => {
  return `You are an expert and highly factual credit card analyst. Your sole purpose is to extract and present a credit card's benefits in a structured, objective, and accurate format.

Your task is to provide a comprehensive and structured breakdown of the key features and benefits for the **${card.name}** credit card from **${bank.name}** on the **${card.card_type}** network.

**Instructions to Prevent Hallucination and Ensure Accuracy:**
1.  **Strictly adhere to the exact structure provided below.** Do not add, remove, or change the heading titles or sub-headings.
2.  **Only use information that is directly available** about the card. Do not infer or invent any numbers, percentages, or features.
3.  **For any section where information is not specified, use the phrase "Not specified."** Do not leave any section or bullet point blank.
4.  **Do not include any details about interest rates, APR, or balance transfers.**
5.  Maintain a completely neutral and factual tone. Avoid any subjective or marketing language.

**Output Structure:**

**Welcome Benefits**
- [Detail any welcome offers or vouchers. If none, write "Not specified."]

**Rewards**
- **Rewards Rate:** [State points earned per spend and on which categories, e.g., "10 Reward Points per ₹100 on dining, movies, groceries, and departmental store purchases. 2 RPs on every ₹100 on all other retail." If not specified, write "Not specified."]
- **Reward Redemption:** [Explain how points can be redeemed and their value, e.g., "Redeem for Gift Vouchers or Statement Credit. 1 Reward Point = ₹0.25." If not specified, write "Not specified."]

**Travel**
- **Domestic Lounge Access:** [State the number of complimentary visits per year and quarter. If not specified, write "Not specified."]
- **International Lounge Access:** [State the number of complimentary visits per year and quarter, along with any associated membership. If not specified, write "Not specified."]
- **Other Travel Perks:** [List any additional travel benefits like special memberships or discounts on hotels/car rentals. If none, write "Not specified."]

**Milestone Benefits**
- **Spend-Based Rewards:** [Detail any rewards earned at specific spending thresholds, e.g., "e-Gift voucher worth ₹7,000 on spending ₹5 lakh in a year." If not specified, write "Not specified."]
- **Annual Fee Waiver:** [State the spending threshold for the annual fee waiver, e.g., "Waived on spending ₹3 lakh or more in the last year." If not specified, write "Not specified."]

**Other Benefits**
- **Insurance:** [Describe any insurance coverage, e.g., "Fraud liability cover (worth ₹1 lakh) applicable from 48 hours prior to 7 days post-reporting." If not specified, write "Not specified."]
- **Golf:** [Detail any golf-related perks. If none, write "Not specified."]
- **Exclusive Discounts:** [List any specific brand or network-exclusive discounts. If none, write "Not specified."]

**Annual Fee**
- [State the annual fee, e.g., "₹2,999 + GST." If not specified, write "Not specified."]
  `;
};

/**
 * Generates a raw, unformatted summary of credit card benefits using an AI model.
 * @param cardName The name of the credit card.
 * @param benefitDetails The raw text detailing the card's benefits.
 * @returns A promise that resolves to the AI-generated summary string.
 * @throws Error if AI_API_KEY is not set or if the AI call fails.
 */
export async function generateSummary(card: Card, bank: Bank): Promise<string> {
  if (!AI_API_KEY || !genAI) {
    throw new Error(
      "AI_API_KEY environment variable not set or AI client not initialized."
    );
  }

  try {
    const response = await genAI.models.generateContent({
      model: AI_MODEL ?? "gemini-2.0-flash",
      contents: generateSummaryPrompt(card, bank),
    });

    const summary = response.text;

    if (!summary) {
      throw new Error("Model did not return a summary.");
    }

    console.log(
      `Generated raw summary for "${card.name}": ${
        summary.substring(0, 100) // Shorten summary to 100 chars
      }...`
    );
    return summary;
  } catch (error) {
    console.error(`Error generating summary for "${card.name}":`, error);
    throw new Error(`Failed to generate summary: ${error}`);
  }
}

const convertToMarkdownPrompt = (rawSummaryText: string): string => {
  return `Your task is to convert the following credit card benefit summary into a clean, well-structured, and highly readable Markdown format.

Summary to Convert:
"""
${rawSummaryText}
"""

**Instructions:**
1.  **Strictly Reformat, Do Not Alter:** Do not add, remove, or change any information. Your only job is to change the formatting.
2.  **Use Markdown Headings:** Use Markdown headings (e.g., '## Key Benefits', '## Rewards', '## Travel Perks') to logically group related information.
3.  **Use Bullet Points:** Use bullet points ('*' or '-') to list individual features and benefits, mind the spacing.
4.  **Bold Keywords:** Bold important numbers, percentages, names, or key phrases to make them stand out (e.g., '**5X points**', '**₹2,999**', '**complimentary lounge access**').
5.  **Clean and Professional:** The final output must be easy to read and have a professional appearance.
6.  **Direct Output:** The response should contain only the Markdown-formatted text, with no introductory or concluding sentences.
7.  **No Code Blocks:** Do not include any code blocks in the output.
8.  **Emojis:** Use emojis to enhance the visual appeal and readability of the Markdown output.
9.  **No Placeholder Text:** Do not include any placeholder text (e.g., "[Insert benefit here]") in the output.
10. **Use of Tables:** Where applicable, use tables to present information in a clear and organized manner.

Markdown Output:

  `;
};

/**
 * Converts a raw text summary into a Markdown-formatted string using an AI model.
 * @param rawSummaryText The raw text summary generated by an AI.
 * @returns A promise that resolves to the Markdown-formatted string.
 * @throws Error if AI_API_KEY is not set or if the AI call fails.
 */
export async function convertToMarkdown(
  rawSummaryText: string
): Promise<string> {
  if (!AI_API_KEY || !genAI) {
    throw new Error(
      "AI_API_KEY environment variable not set or AI client not initialized."
    );
  }

  try {
    const response = await genAI.models.generateContent({
      model: AI_MODEL ?? "gemini-2.0-flash",
      contents: convertToMarkdownPrompt(rawSummaryText),
    });

    const markdownSummary = response.text;

    if (!markdownSummary) {
      throw new Error("AI did not return a markdown summary.");
    }

    console.log(
      `Generated Markdown summary: ${markdownSummary.substring(0, 100)}...`
    );
    return markdownSummary;
  } catch (error) {
    console.error(`Error converting summary to Markdown:`, error);
    throw new Error(`Failed to convert to Markdown: ${error}`);
  }
}
