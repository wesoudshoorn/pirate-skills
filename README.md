# Pirate Skills

AI-powered landing page generator for Claude Code. Paste a URL, get a professional landing page in 2 minutes.

Built on 16 versions of battle-tested conversion copywriting rules (81/81 blind test accuracy). Not generic AI copy. Opinionated, specific, and trained on principles from leading marketing copywriters.

## What it does

1. You type `/piratepage` and paste your URL
2. It scrapes your site, extracts your positioning, and generates a first draft immediately
3. You refine the positioning through 9 quick questions
4. It outputs a self-contained HTML file that opens in your browser

The output is a real landing page with Tailwind CSS styling, proper section structure, and copy that passes the swap test (could a competitor use this headline? if yes, it rewrites automatically).

## Install

### Global (recommended for personal use)

```bash
curl -sSL https://raw.githubusercontent.com/wesoudshoorn/pirate-skills/main/install.sh | bash
```

Installs to `~/.claude/skills/piratepage/`. Auto-checks for updates every time you use `/piratepage`.

### Project-level (recommended for teams)

```bash
curl -sSL https://raw.githubusercontent.com/wesoudshoorn/pirate-skills/main/install.sh | bash -s -- --project
```

Installs to `.claude/skills/piratepage/` in your current project. Commit it so teammates get the skill when they clone the repo. Updates create diffs in your repo — that's the tradeoff for easy team sharing.

### Manual

```bash
git clone https://github.com/wesoudshoorn/pirate-skills.git ~/.claude/skills/piratepage
```

## Usage

In Claude Code, type:

```
/piratepage
```

Then paste your URL or describe your product.

## What's inside

- **SKILL.md** (404 lines) — The complete skill: copywriting rules, positioning wizard, quality self-validation, 5 page types, 20 section types, 5 variation tones
- **references/** (20 HTML files) — Tailwind HTML patterns for every section type and variant
- **install.sh** — One-liner installer

## 5 Page Types

- **Homepage** — Full story: what, why, proof, CTA (6-10 sections)
- **Product Page** — Deep feature showcase (6-8 sections)
- **Service Page** — Trust-first, process-focused (5-7 sections)
- **Pricing Page** — Plans front and center (4-6 sections)
- **Customer Story** — Case study narrative (5-7 sections)

## 20 Section Types

hero, pain, how-it-works, features-grid (5 variants including bento), features-list, testimonials, social-proof, stats, results, pricing, faq, cta, comparison-table, screenshot, showcase, text-block, news, code-sample, founder-story, statement

## Quality Self-Validation

Before showing you anything, the skill runs 9 checks:

1. **Swap test** — Hero/CTA headlines must be specific to YOUR product
2. **Headline scan** — Headlines tell the complete value story top-to-bottom
3. **Specificity check** — Every section references something specific (name, feature, number)
4. **Banned pattern scan** — No "Everything you need to..." or AI vocabulary
5. **Eyebrow check** — 2-4 words, product facts, not section labels
6. **FAQ headline check** — Leads with the #1 objection, not "FAQ"
7. **Screenshot placeholder check** — Process sections include image placeholders
8. **CTA check** — [Action Verb] + [What They Get], no "Learn More"
9. **Topic anchoring** — Every headline makes clear what the page is about

## Export Formats

- **HTML** — Self-contained, opens in browser, Tailwind CDN
- **Markdown** — Flat, paste into v0/Cursor/any AI coding tool
- **JSON** — Structured section data for programmatic use

## Competitive Mode

Paste a competitor's URL and the skill generates a page that specifically counters their positioning. Not by attacking them, but by making your product the obvious choice for someone who already considered the competitor.

## Built from PiratePage

This skill extracts the copywriting intelligence from [PiratePage](https://piratepage.cc), an AI landing page generator with 200+ PRs of prompt engineering. The rules, section types, and quality checks are battle-tested across hundreds of real landing pages.

## License

MIT
