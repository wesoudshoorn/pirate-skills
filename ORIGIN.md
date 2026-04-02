# Origin Story: How Pirate Skills Was Built

This document captures the full context of how Pirate Skills was extracted from the PiratePage web app into a standalone Claude Code skill. Written as a reference for contributors and future development.

## The Starting Point: PiratePage Web App

PiratePage (https://piratepage.cc) is an AI-powered landing page generator built as a Next.js web app. It had ~200 PRs of prompt engineering, 16 versions of the SYSTEM prompt, 20 section types, and an 81/81 blind test accuracy rate on copy quality.

The stack: Next.js 16 + React 19 + Prisma + PostgreSQL + Google Gemini AI + Tailwind CSS + shadcn/ui.

The product worked. The problem was distribution. ~20 users, $0 MRR. The web app required signup, database, hosting, billing infrastructure. All that complexity for what was fundamentally a prompt engineering product.

### What Made PiratePage Good

The real IP wasn't the web app. It was:

1. **The 9-question positioning wizard** that forces users to think through their messaging before generating. You can't skip the hard questions. This is the forcing function.

2. **16 versions of battle-tested copywriting rules** including the swap test ("could a competitor use this headline?"), banned headline patterns, eyebrow rules, CTA formulas, and anti-AI-slop checks.

3. **20 section types** with multiple variants each (e.g., features-grid has 5 variants: 3-column, 4-column, bento-4, bento-5, bento-6).

4. **Quality self-validation** that catches generic copy before the user sees it. The system checks every headline, every eyebrow, every CTA against the rules and rewrites failures automatically.

5. **Narrative arc guidance** per page type (homepage, product page, service page, pricing page, customer story) that determines which sections appear and in what order.

## The Shift: Web App to Claude Code Skill

### The Insight

The conversation started with: "What if we extracted EVERYTHING inside of PiratePage into a Claude Code skill that learns heavily from gstack?"

The key realization: PiratePage's value is in its prompts and rules, not its web UI. A Claude Code skill can deliver the same quality with zero infrastructure, zero signup, zero hosting costs. And as an open-source GitHub repo, it has a distribution channel (GitHub stars) that a niche SaaS never had.

### The Strategic Decision

- **The skill IS the product.** The web app becomes legacy/optional.
- **Open source, free.** GitHub stars > MRR.
- **Landing pages only for v1.** Quality over breadth. Blog posts, ads, email come later.

### CEO Review (Selective Expansion)

Ran a full CEO review with gstack's `/plan-ceo-review` skill. Mode: SELECTIVE EXPANSION (hold scope, cherry-pick high-impact additions).

**6 scope expansions accepted:**

| Proposal | Effort | Why |
|----------|--------|-----|
| Standalone repo structure | S | Distribution matters for stars |
| Auto-open HTML in browser | S | Instant gratification |
| Competitive extraction mode | M | Killer differentiator for demos |
| HTML + Markdown + JSON exports | S | Founders need multiple formats |
| Demo GIF in README | S | #1 driver of GitHub stars |
| One-liner install script | S | Lowers adoption friction |

**Deferred:**
- Blog posts, ad copy, email, social posts
- Visual styles via gstack design skills
- HTML feedback panel (in-browser variation switching)
- Prompt evolution eval harness
- .tmpl template build system

### Eng Review

Clean review. The plan creates ~22 files but they're all content/prompt files, not code. No classes, no services, no DB. One architecture decision: inline copywriting rules in SKILL.md (only ~150 lines from SYSTEM-v16, useful during wizard context).

### Architecture Decision: Follow gstack's Pattern

Studied how gstack structures its skills:
- **One SKILL.md per skill.** Even the biggest ones (ship: 99KB, qa: 51KB).
- **Support files only for reference data** (issue taxonomy, report templates).
- **No module loading pattern.** Everything inline in the SKILL.md.

For PiratePage: SKILL.md (~500 lines) + references/ directory (20 HTML files, one per section type). The skill reads reference files only when generating HTML for that specific section type.

## Building the Skill

### What Was Ported

From `src/lib/ai/skills/SYSTEM-v16.md`:
- All copywriting rules (swap test, banned patterns, headline formulas, eyebrow rules, CTA rules, voice rules, anti-AI-slop patterns)

From `src/lib/ai/prompts/generator.ts`:
- Narrative arcs per page type
- Section selection logic
- Generation choices (explaining WHY each section was chosen)

From `src/components/landing-sections/*.tsx`:
- 20 section types converted to static HTML reference files with Tailwind CSS
- Multiple variants per section type (e.g., features-grid has 5 layout variants)

From the web app wizard flow:
- 9 positioning questions
- URL extraction for pre-filling answers
- Voice/tone selection

### What Was Added (Not in PiratePage)

- **Competitive mode:** Paste a competitor's URL, generate a page that counters their positioning
- **Multiple export formats:** HTML (self-contained with Tailwind CDN), Markdown (paste into v0/Cursor), JSON (structured section data)
- **Auto-open in browser:** `open filename.html` after generation
- **Quality self-validation expanded:** 9 checks (was 6 in PiratePage) including topic anchoring, FAQ headline check, screenshot placeholder check

### The Flow Evolution

The flow went through three iterations in this conversation:

**V1 (direct port from web app):**
Positioning wizard (9 questions) -> page type -> outline -> generate.
Problem: 12+ interactions before you see anything.

**V2 (overcorrection):**
Page type + URL in one question -> generate draft immediately -> refine positioning after.
Problem: Removed the forcing function. The 9 questions ARE the product.

**V3 (final, shipped):**
1. Page type first (instant context, not buried after 9 questions)
2. URL + language confirmation
3. 9 positioning questions with pre-filled answers (mandatory, the forcing function stays)
4. Outline approval, then generate

The forcing function is back. Pre-fills make it fast (confirm instead of write from scratch), but you can't skip the thinking.

## Test Drive: offerte.cc

Generated a landing page for offerte.cc (Dutch AI quote generator for service businesses) to test the skill end-to-end.

### What Worked
- URL extraction captured positioning well
- Copy tone was good (casual, knowledgeable friend)
- Section structure made sense for the product
- HTML output was clean, styled, self-contained

### What Needed Fixing (became skill improvements)

1. **Headlines too long and conversational.** Hard to scan. Not every headline made clear it was about quotes. Added "topic anchoring" rule: every headline should make the page topic unambiguous.

2. **Eyebrows too long.** "ALLES WAT OFFERTES MAKEN VERVELEND MAAKT" is a sentence. Added strict rule: 2-4 words max, product facts only.

3. **Missing screenshot placeholders.** Process sections (how-it-works) should default to image placeholders for products with a UI. Added to quality checks.

4. **Generic section titles.** "Veelgestelde vragen over Offerte.cc" is boring. FAQ should lead with the #1 objection. Added FAQ headline check to quality validation.

5. **Language detection missing.** Site was in Dutch but skill generated in English first. Added language confirmation step.

## What's Next

### Immediate backlog
- Logo bar / social proof section in default homepage outlines
- Mock screenshots (better placeholders that look like actual UI wireframes)
- Section discovery (better presentation of available sections during outline)
- Port more variant selection rules from generator.ts

### Future vision
- **Variations browser:** Interactive HTML output where each section has left/right arrows to cycle through 5 pre-generated tones. URL hash encodes selections. Like PiratePage's web editor but in static HTML with vanilla JS.
- **Blog post generation** (expertise extracted, parked on blogpost-page-type branch in PiratePage repo)
- **Ad copy, email sequences, social posts**
- **Visual styles via gstack design skills** (design system integration)
- **Community section types** (contributors adding new sections)

### Repository Links
- **This repo:** https://github.com/wesoudshoorn/pirate-skills (the skill)
- **Source repo:** https://github.com/wesoudshoorn/piratepage (the web app)
- **Live web app:** https://piratepage.cc
- **CEO plan:** Persisted in `~/.gstack/projects/wesoudshoorn-piratepage/ceo-plans/2026-04-01-piratepage-skill-system.md`

## Key Files in the Source Repo

These are the files in the PiratePage web app that the skill was extracted from:

| Skill component | Source file(s) |
|----------------|---------------|
| Copywriting rules | `src/lib/ai/skills/SYSTEM-v16.md` |
| Shared modules | `src/lib/ai/skills/modules/*.md` |
| Generation logic | `src/lib/ai/prompts/generator.ts` |
| Section types | `src/types/page.ts` |
| Section HTML | `src/components/landing-sections/*.tsx` |
| Primitives | `src/components/landing-sections/primitives.tsx` |
| Wizard flow | `src/app/(dashboard)/pages/[pageId]/wizard/` |
| URL extraction | `src/lib/ai/extract-context.ts` |
| Marketing context | `.claude/product-marketing-context.md` |
| Feature overview | `.claude/product-feature-overview.md` |
