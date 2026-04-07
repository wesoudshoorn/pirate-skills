---
name: pp-competitor
version: 0.1.0
description: |
  Generate competitor comparison landing pages for SaaS companies.
  Use when: "pp-competitor", "competitor page", "comparison page",
  "vs page", or "[product] vs [competitor]".
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

Generate high-quality "Product vs Competitor" comparison pages. Each page is an MDX file that makes a specific, honest case for why someone should switch from a named competitor. These pages convert at 2-5x the rate of generic landing pages because users searching "[product] vs [competitor]" have high purchase intent.

## Prerequisites

1. Next.js project exists with `data/positioning.json`.
2. The `content/competitors/` directory exists.

## Step 0: Mode Detection

- **Single competitor:** `/pp-competitor intercom.com` → generate one page
- **Batch mode:** `/pp-competitor` with a list in positioning.json `_detected.competitors[]` → generate all
- **Fast mode:** No questions, auto-generate from URL scraping
- **Interactive mode:** Ask about which features to compare, which objections to address

## Step 1: Gather Competitor Data

For each competitor:

1. **WebFetch the competitor's website.** Extract:
   - Product name and tagline
   - Key features (from their features/pricing page)
   - Pricing (if publicly available)
   - Target audience
   - Positioning claims they make

2. **WebFetch their pricing page** (if separate from main page).

3. If WebFetch fails: ask the user to describe the competitor, or work from the competitor name alone using general knowledge.

## Step 2: Build the Comparison Brief

For each competitor, construct a structured brief:

```
COMPETITOR: [name]
URL: [url]
THEIR POSITIONING: [what they claim to be]
THEIR STRENGTHS: [what they're genuinely good at — be honest]
THEIR WEAKNESSES: [where they fall short]
OUR ADVANTAGES: [specific ways we're better for our target user]
THEIR ADVANTAGES: [specific ways they're better — honesty builds trust]
MIGRATION FRICTION: [what makes switching hard]
SEARCH INTENT: [what someone googling "[us] vs [them]" actually wants to know]
```

**Honesty rule:** Never claim the competitor is bad at everything. Acknowledge their strengths. The comparison must be credible. A page that says "we're better in every way" is obviously biased and users will bounce.

## Step 3: Generate the Comparison Page

Write to `content/competitors/[competitor-slug].mdx`:

```mdx
---
title: "[Product] vs [Competitor] — [One-line differentiator]"
description: "[Specific comparison summary for SEO]"
competitor: "[Competitor Name]"
competitorUrl: "[competitor URL]"
date: "[ISO date]"
---
```

### Section Structure

**1. Hero: The Switch Pitch**
- Headline: addresses the specific reason someone would consider switching
- NOT "Why [Product] is better than [Competitor]" (too generic)
- YES "[Specific pain point with Competitor]? Here's how [Product] handles it."
- Subheadline: one sentence positioning the key difference
- CTA: "Try [Product] free" or "See how [Product] compares"

**2. Quick Comparison Table**
A scannable table with 5-8 key dimensions:

| Feature | [Product] | [Competitor] |
|---------|-----------|--------------|
| [Dimension 1] | [Specific claim] | [Honest assessment] |
| [Dimension 2] | ... | ... |
| Pricing | [Our price] | [Their price] |

Rules:
- Use checkmarks, X marks, or specific values (not vague "Good"/"Bad")
- Include at least 1 dimension where the competitor wins (credibility)
- Price comparison must be accurate and current

**3. Deep Dive: Where [Product] Wins**
2-3 sections, each covering one key differentiator. For each:
- Specific feature or capability
- What the user experience looks like with us vs them
- Concrete example or use case
- NOT vague claims like "better user experience"
- YES specific claims like "Messages sync in 50ms vs [Competitor]'s 2-3 second delay"

**4. Honest Assessment: Where [Competitor] Shines**
1 section acknowledging the competitor's genuine strengths:
- "If you need [specific thing], [Competitor] is a solid choice."
- This builds trust and handles the "this page is obviously biased" objection.
- Immediately follow with: "But if [our differentiator matters to you], here's why [Product] is worth switching."

**5. Migration Guide**
- How hard is it to switch? (Easy/Medium/Hard)
- What are the concrete steps?
- How long does it typically take?
- What support do we offer for migration?
- Address the #1 migration fear from positioning data

**6. Objection Handling / FAQ**
3-5 questions that someone comparing the two products would actually ask:
- "Is [Product] as reliable as [Competitor]?"
- "What about [Competitor's key feature]?"
- "How does pricing compare for [specific use case]?"
- Lead with the #1 objection, not "FAQ"

**7. CTA**
- Specific to the comparison context
- NOT "Sign up now"
- YES "Start a free trial — import your [Competitor] data in 5 minutes"
- Include a trust signal (review score, customer count, uptime)

## Step 4: Update Competitor Metadata

Update `data/competitors.json`:

```json
[
  {
    "name": "[Competitor Name]",
    "slug": "[competitor-slug]",
    "url": "[competitor URL]",
    "generatedAt": "[ISO date]",
    "keyDifferentiator": "[one line]"
  }
]
```

## Step 5: Competitor-Specific Quality Checks

In addition to the standard 10 checks:

1. **Factual accuracy:** Every claim about the competitor must be verifiable from their website. No invented features, no made-up pricing, no exaggerated weaknesses.
2. **Specificity:** Every comparison point references a specific feature or metric, not vague superiority claims.
3. **Honesty check:** At least one section acknowledges a competitor strength. If the page is 100% "we're better," it fails.
4. **Migration clarity:** The migration section gives concrete steps, not "contact us."
5. **Search intent match:** The hero headline addresses what someone searching "[product] vs [competitor]" actually wants to know.
6. **No legal risk:** No claims that could be construed as defamation. Stick to verifiable facts and user experience comparisons.

## Step 6: Present

"Competitor page generated: content/competitors/[slug].mdx

[Competitor Name] comparison:
  - Hero: [headline]
  - Comparison: [N] dimensions compared
  - Differentiators: [list key points]
  - Honest: acknowledged [competitor strength]
  - Migration: [easy/medium/hard]

Updated data/competitors.json"
