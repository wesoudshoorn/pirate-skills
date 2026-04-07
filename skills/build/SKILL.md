---
name: pp-build
version: 0.1.0
description: |
  Build a complete SaaS marketing site from a URL or positioning data.
  Orchestrates all pp-* skills into a single pipeline.
  Use when: "pp-build", "build a site", "generate the whole site",
  "build fast [url]", or "create marketing site".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
  - WebFetch
---

## Purpose

Orchestrate all pp-* skills to generate a complete SaaS marketing site. Two modes: interactive (asks questions at each step) and fast (auto-decides everything from a URL).

## Step 0: Mode Detection

Parse the user's command:
- `/pp-build` → Interactive mode
- `/pp-build fast <url>` → Fast mode. Extract URL, prepend `https://` if no protocol.
- `/pp-build fast` (no URL) → Ask for URL, then run fast mode.

Set `MODE` to `interactive` or `fast`.

## Step 1: Load Sub-Skills

Read all sub-skill SKILL.md files from the skills/ directory relative to this file's location. The orchestrator needs:

```bash
SKILLS_ROOT="$(dirname "$(dirname "$0")")/skills"
```

Read these skill files (in order):
1. `skills/scaffold/SKILL.md` → /pp-scaffold
2. The parent `SKILL.md` → /pp-homepage (existing piratepage, adapted)
3. `skills/competitor/SKILL.md` → /pp-competitor
4. `skills/usecase/SKILL.md` → /pp-usecase
5. `skills/tour/SKILL.md` → /pp-tour

**Skip list** — when executing a loaded skill, skip these sections (already handled by this orchestrator):
- YAML frontmatter / preamble
- Any "Step 0: Fast Mode" sections (the orchestrator controls mode)
- Any "Prerequisites" sections (the orchestrator ensures ordering)

## Step 2: Positioning (/pp-positioning)

**Fast mode:**
1. WebFetch the provided URL.
2. Auto-detect language from content. Default to English.
3. Pre-fill all 9 positioning answers from the extracted content.
4. Set page type to Homepage, voice to Professional.
5. Save to `piratepage.json` in the current directory.
6. Do NOT ask any questions.

**Interactive mode:**
1. Follow the existing piratepage SKILL.md Steps 1-3 (page type, URL + language, 9 positioning questions in 3 batches).
2. Save to `piratepage.json`.

**After positioning is complete** (both modes):

Also extract from the scraped content:
- A list of competitors mentioned or detected (store as `_detected.competitors[]`)
- A list of use cases or verticals mentioned (store as `_detected.usecases[]`)
- A list of key features mentioned (store as `_detected.features[]`)

Save these to `piratepage.json` under a `_detected` key. Sub-skills will use these as defaults.

## Step 3: Scaffold (/pp-scaffold)

Read and execute `skills/scaffold/SKILL.md`.

In fast mode: pass `fast` flag so it skips all questions, uses defaults.
In interactive mode: let it ask about project location and brand colors.

**Wait for scaffold to complete before proceeding.** The Next.js project must exist before other skills can write into it.

After scaffold completes, copy `piratepage.json` to `[project]/data/positioning.json`.

## Step 4: Homepage (/pp-homepage)

Generate the homepage using the existing piratepage SKILL.md's generation logic, but with these adaptations:

1. Read `data/positioning.json` from the scaffolded project.
2. Follow the existing piratepage SKILL.md's section selection, outline, and generation steps.
3. **Output adaptation:** Instead of a self-contained HTML file, write the output as `app/(marketing)/page.tsx` in the Next.js project. Use Tailwind classes that reference the project's tailwind.config. Import components from the project.
4. Run all 10 quality checks.

In fast mode: auto-select sections, auto-generate, no approval gate.
In interactive mode: present outline for approval, then generate.

## Step 5: Pricing (/pp-pricing)

Generate a pricing page:

1. Read positioning.json.
2. If the scraped site had pricing information, extract tiers.
3. If no pricing found, create a placeholder with common SaaS pricing structure (Free/Pro/Enterprise).
4. Write to `app/(marketing)/pricing/page.tsx`.
5. Sections: pricing hero, plan comparison cards, feature comparison table, FAQ (pricing-specific), CTA.

In fast mode: use detected pricing or sensible defaults.
In interactive mode: ask about pricing tiers.

## Step 6: Competitor Pages (/pp-competitor)

Read and execute `skills/competitor/SKILL.md`.

1. Use `_detected.competitors[]` from positioning.json as the default competitor list.
2. In fast mode: generate a page for each detected competitor automatically.
3. In interactive mode: present the detected list, let user add/remove competitors, then generate.
4. Each competitor gets its own MDX file in `content/competitors/`.

**Run competitors in sequence** (each requires a WebFetch of the competitor's site).

## Step 7: Use-Case Pages (/pp-usecase)

Read and execute `skills/usecase/SKILL.md`.

1. Use `_detected.usecases[]` from positioning.json as the default list.
2. In fast mode: generate a page for each detected use case.
3. In interactive mode: present detected list, let user adjust, then generate.
4. Each use case gets its own MDX file in `content/use-cases/`.

## Step 8: Feature Tour Pages (/pp-tour)

Read and execute `skills/tour/SKILL.md`.

1. Use `_detected.features[]` from positioning.json as the default list.
2. In fast mode: generate a page for each detected feature (up to 5 most important).
3. In interactive mode: present detected list, let user select which features get deep-dive pages.
4. Each feature gets its own MDX file in `content/features/`.

## Step 9: SEO Setup

Generate basic SEO files in the project:

1. `public/robots.txt` — allow all crawlers, reference sitemap
2. `public/sitemap.xml` — static sitemap with all generated pages
3. `public/llms.txt` — AI discoverability file with product summary and page index
4. Update root layout metadata with proper OpenGraph tags from positioning

## Step 10: Quality Sweep

Run all 10 quality checks across every generated page:

1. **Swap test** — headlines specific to each page (competitor names, feature names, use-case audiences must appear)
2. **Headline scan** — value story flows top-to-bottom on every page
3. **Specificity check** — no generic filler on any page
4. **Banned pattern scan** — no AI slop anywhere
5. **Eyebrow check** — eyebrows are short and factual
6. **FAQ headline check** — no "FAQ" labels
7. **Wireframe check** — image placeholders have proper styling
8. **CTA check** — every page has a clear CTA
9. **Topic anchoring** — every page's headlines make the topic clear
10. **Cross-page consistency** — product name, CTA, voice consistent across all pages

Fix any failures silently. Log what was fixed.

## Step 11: Launch

```bash
cd [project-name]
npm run dev
```

Open in browser:
```bash
open http://localhost:3000
```

## Step 12: Present Results

Tell the user what was generated:

```
Site generated at [path]:

Pages created:
  - Homepage (app/(marketing)/page.tsx)
  - Pricing (app/(marketing)/pricing/page.tsx)
  - [N] competitor comparison pages (content/competitors/)
  - [N] use-case pages (content/use-cases/)
  - [N] feature pages (content/features/)

SEO:
  - robots.txt, sitemap.xml, llms.txt

The site is running at http://localhost:3000

Next steps:
  - Review each page and adjust copy
  - Run /pp-docs to add documentation
  - Run /pp-article to add blog posts
  - Run /pp-changelog to add a changelog
  - Customize colors/fonts in tailwind.config.ts
```

In interactive mode, also ask:

"What would you like to do next?
A) Review and edit specific pages
B) Add documentation (/pp-docs)
C) Add blog posts (/pp-article)
D) Style the site (customize colors/fonts)
E) Done for now"

In fast mode, just present the summary and stop.
