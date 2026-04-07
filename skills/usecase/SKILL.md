---
name: pp-usecase
version: 0.1.0
description: |
  Generate "Product for X" use-case landing pages.
  Use when: "pp-usecase", "use case page", "product for [audience]",
  "vertical page", or "[product] for [industry]".
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

Generate use-case landing pages that position the product for a specific audience or vertical. Examples: "TalkJS for marketplaces", "AppSignal for Ruby on Rails", "Stripe for SaaS billing". Every section must be specific to that audience — no generic copy that could work on any use-case page.

## Prerequisites

1. Next.js project exists with `data/positioning.json`.
2. The `content/use-cases/` directory exists.

## Step 0: Mode Detection

- **Single use case:** `/pp-usecase "marketplaces"` → generate one page
- **Batch mode:** Use `_detected.usecases[]` from positioning.json → generate all
- **Fast mode:** Auto-generate, no questions
- **Interactive mode:** Ask about audience details and pain points

## Step 1: Define the Use Case

For each use case, establish:

```
AUDIENCE: [who is this page for — specific role + industry/vertical]
JOB TO BE DONE: [what they're trying to accomplish]
THEIR SPECIFIC PAIN: [what's hard about this job today, for THIS audience]
HOW WE FIT: [how our product solves their specific version of the problem]
PROOF: [testimonials, case studies, or stats relevant to this audience]
THEIR VOCABULARY: [industry terms, jargon they use — write in their language]
```

In fast mode: infer all of this from the scraped website content and positioning data.
In interactive mode: ask via AskUserQuestion for each field.

## Step 2: Generate the Use-Case Page

Write to `content/use-cases/[usecase-slug].mdx`:

```mdx
---
title: "[Product] for [Audience] — [Audience-specific value prop]"
description: "[One-line description targeting this audience]"
audience: "[Audience name]"
slug: "[usecase-slug]"
date: "[ISO date]"
---
```

### Section Structure

**1. Audience-Specific Hero**
- Headline speaks DIRECTLY to this audience in their language
- NOT "[Product] for [Audience]" (too literal)
- YES "[Audience-specific pain point]? [Product] was built for this."
- Subheadline: one sentence about how the product fits their world
- CTA: audience-specific action

**2. Their Specific Pain**
- 3-4 pain points this audience specifically feels
- Use their vocabulary, their scenarios, their daily frustrations
- NOT generic pain points that apply to everyone
- Each pain point is a short paragraph with a concrete scenario

**3. How It Works for Them**
- 3-4 steps showing how the product fits into THEIR workflow
- Reference their tools, their processes, their context
- Screenshots or wireframe placeholders showing their use case
- "For [audience], this means..." framing

**4. Key Features (Audience Lens)**
- 3-5 features most relevant to this audience
- Each feature framed as the audience benefit, not the technical spec
- NOT "Real-time messaging" → YES "Buyers and sellers chat without leaving your marketplace"
- Include a wireframe placeholder for each feature showing the audience's context

**5. Proof (Audience-Relevant)**
- Testimonial from someone in this audience/vertical (if available)
- Stats relevant to this audience
- If no audience-specific proof exists, use the closest general proof
- Mark any placeholder testimonials clearly in a comment

**6. Objection Handling**
- 2-3 questions this specific audience would ask
- NOT generic FAQ
- YES "[Audience]-specific concerns"
- Example for marketplaces: "Does it work with our escrow payment flow?"

**7. CTA**
- Audience-specific language
- NOT "Start free trial"
- YES "Start building chat for your marketplace — free for up to 1,000 users"

## Step 3: Quality Checks

Standard 10 checks plus use-case-specific:

1. **Audience swap test:** Take every headline and replace the audience name with a different audience. If the headline still works, it's too generic. FAIL. Every headline must break when the audience changes.
2. **Vocabulary check:** Does the page use the audience's language? Industry terms? Their job titles?
3. **Scenario specificity:** Does every pain point describe a scenario this audience actually faces?
4. **Feature relevance:** Are the highlighted features the ones THIS audience cares about most?
5. **Proof relevance:** Is the social proof from this audience or closely adjacent?

## Step 4: Present

"Use-case page generated: content/use-cases/[slug].mdx

[Product] for [Audience]:
  - Hero: [headline]
  - Pain points: [N] audience-specific pains
  - Features: [N] features through audience lens
  - CTA: [audience-specific CTA text]"
