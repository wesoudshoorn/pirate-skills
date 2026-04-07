---
name: pp-pricing
version: 0.1.0
description: |
  Generate a SaaS pricing page as a Next.js page component.
  Use when: "pp-pricing", "generate pricing page", "build the pricing page".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - WebFetch
---

## Purpose

Generate a complete pricing page for a SaaS marketing site. Outputs a Next.js page component with plan comparison, feature matrix, FAQ, and CTA.

## Prerequisites

1. Next.js project exists (created by /pp-scaffold).
2. `data/positioning.json` exists with completed positioning data.

## Step 0: Fast Mode

If called with `fast` flag, skip all questions and use detected or default pricing.

## Step 1: Detect or Gather Pricing Data

**If the original site was scraped (fast mode from /pp-build):**
- Check if pricing tiers were detected from the scraped content
- Use detected tiers as the starting point

**If no pricing data available:**
- In fast mode: generate a standard 3-tier SaaS pricing structure (Free/Pro/Enterprise)
- In interactive mode: ask via AskUserQuestion:

"What's your pricing structure?

A) Free / Pro / Enterprise (standard 3-tier)
B) Starter / Professional / Business (growth-focused)
C) I'll describe my tiers (let me type them)
D) No pricing yet — generate a placeholder"

Then ask for details:
- Plan names and prices
- Key features per plan
- Which plan to highlight as "most popular"
- Annual vs monthly toggle?

## Step 2: Structure the Pricing Page

Standard pricing page structure:

1. **Pricing Hero**
   - Headline: addresses the "is it worth it?" objection from positioning
   - Subheadline: one line about value, not price
   - Annual/monthly toggle (if applicable)

2. **Plan Cards**
   - 2-4 plan cards side by side
   - Each card: plan name, price, description, feature list, CTA button
   - "Most popular" badge on recommended plan
   - Feature list: checkmarks for included, dashes for excluded

3. **Feature Comparison Table** (if 3+ plans)
   - Full feature matrix
   - Categories: Core, Advanced, Support, Security
   - Checkmarks, limits ("up to 10"), or specific values

4. **Pricing FAQ**
   - 4-6 questions addressing real pricing objections from positioning
   - "Can I switch plans?" / "Is there a free trial?" / "What happens if I cancel?"
   - Lead with the #1 pricing objection, NOT with "Pricing FAQ" as the heading

5. **CTA Section**
   - Final push addressing the main purchase hesitation
   - CTA from positioning data

## Step 3: Generate the Page

Write to `app/(marketing)/pricing/page.tsx`:

```tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Pricing — [Product Name]',
  description: '[Value-focused pricing description]',
}

export default function PricingPage() {
  return (
    <main>
      {/* Pricing Hero */}
      <section id="pricing-hero" className="...">
        ...
      </section>

      {/* Plan Cards */}
      <section id="plans" className="...">
        ...
      </section>

      {/* Feature Comparison */}
      <section id="comparison" className="...">
        ...
      </section>

      {/* FAQ */}
      <section id="faq" className="...">
        ...
      </section>

      {/* CTA */}
      <section id="cta" className="...">
        ...
      </section>
    </main>
  )
}
```

**Pricing-specific component patterns:**
- Plan cards: use CSS grid, responsive (stack on mobile)
- Price display: large number, small period ("/mo"), annual savings badge
- Toggle: simple div-based toggle, no JavaScript library needed. Use React state.
- Feature checkmarks: green checkmark SVG inline, gray dash for excluded
- "Most popular" badge: absolute positioned, brand color background

## Step 4: Quality Checks

Standard 10 checks plus pricing-specific:

- **Price clarity:** Every plan shows the price prominently. No hidden fees language.
- **Value anchoring:** Headline focuses on value/outcome, not cheapness.
- **Objection coverage:** FAQ addresses top 3 pricing objections from positioning.
- **CTA specificity:** Each plan's CTA is specific ("Start free trial", "Get Pro", "Contact sales"), not generic "Sign up".
- **Comparison fairness:** Feature comparison doesn't mislead about what's excluded.

## Step 5: Save Pricing Data

Write pricing tier data to `data/pricing.json` so other pages can reference it:

```json
{
  "currency": "USD",
  "billingPeriods": ["monthly", "annual"],
  "plans": [
    {
      "name": "Free",
      "price": { "monthly": 0, "annual": 0 },
      "description": "For individuals getting started",
      "cta": { "label": "Start free", "href": "/signup" },
      "highlighted": false,
      "features": ["Feature 1", "Feature 2"]
    },
    {
      "name": "Pro",
      "price": { "monthly": 29, "annual": 24 },
      "description": "For growing teams",
      "cta": { "label": "Start free trial", "href": "/signup?plan=pro" },
      "highlighted": true,
      "features": ["Everything in Free", "Feature 3", "Feature 4"]
    }
  ]
}
```

## Step 6: Present

"Pricing page generated at app/(marketing)/pricing/page.tsx

Plans: [list plan names and prices]
Highlighted: [most popular plan]
FAQ: [number] questions covering top pricing objections

Pricing data saved to data/pricing.json for use by other pages."
