---
name: pp-tour
version: 0.1.0
description: |
  Generate feature deep-dive / product tour pages.
  Use when: "pp-tour", "feature page", "product tour",
  "deep dive on [feature]", or "feature walkthrough".
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

Generate feature deep-dive pages that explain what a specific product feature does, how it works, and why it matters. Each page turns a feature name into a compelling story with wireframe mockups, use cases, and clear outcomes.

## Prerequisites

1. Next.js project exists with `data/positioning.json`.
2. The `content/features/` directory exists.

## Step 0: Mode Detection

- **Single feature:** `/pp-tour "chat widget"` → generate one page
- **Batch mode:** Use `_detected.features[]` from positioning.json → generate all (up to 5 in fast mode)
- **Fast mode:** Auto-generate, no questions
- **Interactive mode:** Ask about feature details and priority

## Step 1: Define the Feature

For each feature, establish:

```
FEATURE NAME: [user-facing name, not internal codename]
ONE-LINE VALUE: [what it does for the user, in one sentence]
CATEGORY: [e.g., Communication, Analytics, Security, Integrations]
USER OUTCOME: [what the user achieves with this feature]
HOW IT WORKS: [3-5 step explanation]
TECHNICAL DEPTH: [low/medium/high — determines if we show code samples]
RELATED FEATURES: [other features that pair with this one]
```

In fast mode: infer from scraped website content.
In interactive mode: ask via AskUserQuestion.

## Step 2: Generate the Feature Page

Write to `content/features/[feature-slug].mdx`:

```mdx
---
title: "[Feature Name] — [User Outcome]"
description: "[One-line description of what this feature does for users]"
feature: "[Feature Name]"
category: "[Category]"
slug: "[feature-slug]"
date: "[ISO date]"
---
```

### Section Structure

**1. Feature Hero**
- Headline: user outcome, not feature name
- NOT "Chat Widget" → YES "Add real-time messaging to your app in 5 minutes"
- NOT "[Feature Name]" → YES "[What users accomplish with this feature]"
- Subheadline: one concrete sentence about the feature
- CTA: "Try [feature] free" or "See it in action"

**2. The Problem It Solves**
- What was life like BEFORE this feature?
- Specific frustration or manual workaround
- Keep it to 2-3 sentences. Don't belabor the pain.

**3. How It Works**
- 3-5 steps, each with:
  - Step title (action-oriented: "Connect", "Configure", "Launch")
  - 1-2 sentence description
  - Wireframe placeholder showing the UI at this step

Wireframe placeholders use this pattern:
```html
<div className="bg-gray-100 border-2 border-dashed border-gray-300 rounded-lg aspect-video flex items-center justify-center text-gray-400 text-sm">
  [Description of what this screenshot would show]
</div>
```

Keep wireframes descriptive: "[Chat widget embedded in a marketplace product page, showing buyer and seller conversation]" not just "[Screenshot]".

**4. Key Capabilities**
- 3-4 specific things this feature can do
- Each capability: icon placeholder + title + one-sentence description
- Written as user outcomes, not specs
- NOT "WebSocket-based real-time sync" → YES "Messages appear instantly — no page refresh needed"

**5. Code Sample** (if technical depth is medium or high)
- Short, copy-pasteable code showing the simplest usage
- Language appropriate to the product (JS/Python/Ruby/etc.)
- Comments explaining each line
- "Get started in [N] lines of code" framing

```tsx
{/* Only include this section if the feature has a developer-facing API */}
<section>
  <h2>Get started in 5 lines</h2>
  <pre><code>
  // code sample here
  </code></pre>
</section>
```

If the product is not developer-focused, skip this section entirely.

**6. Use Cases**
- 2-3 short use cases showing different ways to use this feature
- Each: one-line title + 2-sentence description + link to relevant use-case page (if it exists)
- Connects feature pages to use-case pages in the content graph

**7. Related Features**
- Links to 2-3 other feature pages
- "Works great with [Feature X]" framing
- Creates internal linking between feature pages

**8. CTA**
- Feature-specific call to action
- NOT "Sign up" → YES "Add [feature] to your app — free to start"
- Include one trust signal (uptime, customers, review score)

## Step 3: Update Feature Metadata

Update `data/features.json`:

```json
[
  {
    "name": "[Feature Name]",
    "slug": "[feature-slug]",
    "category": "[Category]",
    "oneLiner": "[One-line value prop]",
    "generatedAt": "[ISO date]"
  }
]
```

## Step 4: Quality Checks

Standard 10 checks plus feature-specific:

1. **Outcome-first:** Every headline describes what the user achieves, not what the feature is called. If the headline is just the feature name, FAIL.
2. **Wireframe quality:** Every wireframe placeholder has a descriptive label that explains what the screenshot would show. No bare "[Screenshot]" labels.
3. **Step clarity:** The "how it works" section has concrete steps someone could actually follow. No vague "configure your settings" steps.
4. **Code validity:** If a code sample is included, it must be syntactically valid and use the product's actual API patterns (if known from scraped data).
5. **Internal linking:** Related features and use cases link to actual pages that exist or will exist in the content structure.

## Step 5: Present

"Feature page generated: content/features/[slug].mdx

[Feature Name]:
  - Hero: [headline]
  - How it works: [N] steps with wireframes
  - Capabilities: [N] key capabilities
  - Code sample: [included/skipped]
  - Use cases: [N] linked
  - Related: [list related features]

Updated data/features.json"
