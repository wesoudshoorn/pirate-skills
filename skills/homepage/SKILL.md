---
name: pp-homepage
version: 0.1.0
description: |
  Generate a SaaS homepage as a Next.js page component.
  Adapts the piratepage copywriting engine for MDX/TSX output.
  Use when: "pp-homepage", "generate homepage", "build the homepage".
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

Generate a complete homepage for a SaaS marketing site. This skill adapts the piratepage copywriting engine (section selection, 5 tone variants, 10 quality checks) but outputs a Next.js page component instead of self-contained HTML.

## Prerequisites

1. A Next.js project must exist (created by /pp-scaffold).
2. `data/positioning.json` must exist with completed positioning data.

If either is missing, tell the user what to run first.

## Step 0: Fast Mode

If called with `fast` flag or from `/pp-build fast`, skip all questions and auto-decide everything.

## Step 1: Read Positioning and Context

```bash
cat data/positioning.json
```

Extract: product name, page type, all 9 positioning answers, voice/tone, language.

Also read:
- `data/nav.json` for navigation structure
- `tailwind.config.ts` for available brand colors

## Step 2: Section Selection

Read the section reference files from the pirate-skills references/ directory. Use the same Section Selection Guide and Page Type Templates from the parent piratepage SKILL.md.

**For a Homepage, the recommended structure is:**

MUST include:
- navbar (already in layout, skip)
- hero (1 of 5 variants)
- One problem/pain section
- One features section (grid or list)
- One proof section (testimonials, stats, or social-proof)
- CTA

SHOULD include:
- how-it-works
- screenshot or showcase
- faq
- second features section or comparison-table

**In fast mode:** Auto-select the richest variants. Do not present for approval.

**In interactive mode:** Present the outline with section choices. Ask:
"Here's the homepage structure I recommend. Want to generate it, or change anything?"

## Step 3: Generate Page Component

For each section in the outline:

1. Read the corresponding reference file from `references/[section-type].html` in the pirate-skills root.
2. Generate copy for all 5 tone variants using the positioning data and copywriting rules.
3. **Output as TSX** instead of raw HTML:
   - Convert HTML structure to JSX (className instead of class, self-closing tags, etc.)
   - Use Tailwind classes that reference the project's theme (brand colors, fonts)
   - Each section is a `<section>` with a descriptive id attribute
   - Use semantic HTML (header, main, section, footer)

**Important output rules:**
- Do NOT use Tailwind CDN. The project has Tailwind configured locally.
- Do NOT include `<html>`, `<head>`, or `<body>` tags. The layout handles those.
- Do NOT include the navbar or footer. The marketing layout renders those.
- DO include only the page content sections.
- Use `Inter` or whatever font is in the project's tailwind.config.
- Use `brand-*` color classes from the Tailwind config.

## Step 4: Write the Page

Write the homepage as `app/(marketing)/page.tsx`:

```tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: '[Product Name] — [Key Takeaway]',
  description: '[From positioning - one-line product description]',
  openGraph: {
    title: '[Product Name] — [Key Takeaway]',
    description: '[One-line description]',
  },
}

export default function HomePage() {
  return (
    <main>
      {/* Hero Section */}
      <section id="hero" className="...">
        ...
      </section>

      {/* Features Section */}
      <section id="features" className="...">
        ...
      </section>

      {/* ... more sections ... */}
    </main>
  )
}
```

## Step 5: Tone Variants

The piratepage system generates 5 tone variants per section. For the Next.js output, handle variants differently than the HTML Variations Browser:

**Default approach:** Generate the homepage using tone 1 (Punchy) as the default. Store all 5 tone variants as a JSON file at `data/homepage-variants.json` so they can be referenced later.

```json
{
  "hero": {
    "punchy": { "headline": "...", "subheadline": "...", "cta": "..." },
    "conversational": { "headline": "...", "subheadline": "...", "cta": "..." },
    "benefit-focused": { "headline": "...", "subheadline": "...", "cta": "..." },
    "problem-aware": { "headline": "...", "subheadline": "...", "cta": "..." },
    "bold-confident": { "headline": "...", "subheadline": "...", "cta": "..." }
  },
  "features": { ... }
}
```

This lets the user swap copy variants without regenerating the entire page.

## Step 6: Quality Checks

Run all 10 quality checks from the piratepage system against the generated page:

1. **Swap test** — Hero headline must be specific to THIS product.
2. **Headline scan** — Headlines tell value story top-to-bottom.
3. **Specificity check** — Every section mentions something specific.
4. **Banned pattern scan** — No AI-slop phrases.
5. **Eyebrow check** — 2-4 words max.
6. **FAQ headline check** — Leads with #1 objection.
7. **Wireframe check** — Image placeholders have aspect-ratio.
8. **CTA check** — [Action Verb] + [What They Get].
9. **Topic anchoring** — Headlines make product clear.
10. **Variation distinctness** — 5 tones are meaningfully different.

Fix any failures by regenerating the affected sections. Do not show failures to the user.

## Step 7: Verify

```bash
cd [project-root]
npm run build 2>&1 | head -20
```

Check that the page compiles without TypeScript or JSX errors. If there are errors, fix them.

## Step 8: Present

Tell the user:

"Homepage generated at app/(marketing)/page.tsx

Sections: [list sections generated]
Default tone: Punchy
All 5 tone variants saved to data/homepage-variants.json

To switch tones, tell me which section and which tone:
  - Punchy (short, high energy)
  - Conversational (warm, friendly)
  - Benefit-focused (outcomes first)
  - Problem-aware (pain then solution)
  - Bold-confident (assertive claims)"

## Copywriting Rules

Inherit ALL copywriting rules from the parent piratepage SKILL.md:

- Clear before clever
- Headlines: outcome, problem, audience, differentiation, or proof formula
- Eyebrows: 2-4 words, product facts only
- Content pairing: feature + benefit always together
- Never sound like AI (banned vocabulary, imperfect rhythm)
- Swap test: every headline specific to this product
- CTA: [Action Verb] + [What They Get], never "Learn More"
- 15 banned headline patterns
- Voice matches positioning.json selection
