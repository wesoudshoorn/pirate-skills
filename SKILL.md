---
name: piratepage
version: 2.1.0
description: |
  Generate landing pages with conversion copywriting expertise.
  Use when: "generate a landing page", "piratepage", "create a page",
  "help me with copy", "landing page for my product".
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

## Preamble (run silently before starting)

Check for updates (tries both global and project install paths):

```bash
_UPD=$( ~/.claude/skills/piratepage/bin/piratepage-update-check 2>/dev/null || \
        .claude/skills/piratepage/bin/piratepage-update-check 2>/dev/null || true )
echo "${_UPD:-UP_TO_DATE}"
```

**Handle the result before continuing:**

- **If output starts with `JUST_UPGRADED`**: Parse the old and new versions. Read `CHANGELOG.md` from the skill directory, find the entries between old and new version. Show a brief message: "piratepage updated to vX.Y.Z!" with 3 bullet points of what's new. Then continue with Step 1.

- **If output starts with `UPGRADE_AVAILABLE`**: Parse old and new versions from the output. Use AskUserQuestion:
  - Question: "piratepage **vNEW** is available (you're on vOLD). Upgrade now?"
  - Options: `["Yes, upgrade now", "Not now", "Don't ask again"]`
  - **If "Yes, upgrade now"**:
    1. Detect install type:
       ```bash
       if [ -d "$HOME/.claude/skills/piratepage/.git" ]; then
         echo "global-git"
       elif [ -d ".claude/skills/piratepage" ]; then
         echo "project-vendored"
       else
         echo "global-vendored"
       fi
       ```
    2. For `global-git`: `cd ~/.claude/skills/piratepage && git fetch origin --quiet && git reset --hard origin/main --quiet`
    3. For vendored: `bash ~/.claude/skills/piratepage/install.sh --update` or `bash .claude/skills/piratepage/install.sh --update`
    4. Write upgrade marker:
       ```bash
       mkdir -p ~/.piratepage
       echo "OLD_VERSION" > ~/.piratepage/just-upgraded-from
       rm -f ~/.piratepage/last-update-check ~/.piratepage/update-snoozed
       ```
    5. Show "Upgraded! Here's what's new:" with changelog summary. Continue with Step 1.
  - **If "Not now"**: Write snooze file and continue:
    ```bash
    mkdir -p ~/.piratepage
    LEVEL=1
    [ -f ~/.piratepage/update-snoozed ] && LEVEL=$(( $(awk '{print $2}' ~/.piratepage/update-snoozed) + 1 ))
    echo "REMOTE_VERSION $LEVEL $(date +%s)" > ~/.piratepage/update-snoozed
    ```
  - **If "Don't ask again"**: `mkdir -p ~/.piratepage && touch ~/.piratepage/updates-disabled`. Continue with Step 1.

- **If output is `UP_TO_DATE` or empty**: Continue silently with Step 1.

---

## Step 1: Page Type First

Check for existing positioning data:

```bash
[ -f piratepage.json ] && echo "FOUND" || echo "NOT_FOUND"
[ -f piratepage.json ] && cat piratepage.json || true
```

**If `piratepage.json` exists:** Greet by product name. Show what's been generated. Ask:
"Want to create a new page, iterate on the existing one, or update your positioning?"

**If no `piratepage.json`:** Start with the most important question first via AskUserQuestion:

"What kind of page are we building?

A) Homepage — the full story: what it is, why it matters, proof, CTA (6-10 sections)
B) Product page — deep feature showcase (6-8 sections)
C) Service page — trust-first, process-focused (5-7 sections)
D) Pricing page — plans front and center (4-6 sections)"

This gives you context for everything that follows. Don't bury it after 9 questions.

---

## Step 2: URL + Language

After page type is chosen, ask via AskUserQuestion:

"Paste your URL (or describe your product in a few sentences). I'll scrape it and pre-fill your positioning answers."

If URL provided: WebFetch and extract positioning. If WebFetch fails: "Couldn't scrape that URL. Describe your product in a few sentences instead."

**Language confirmation:** After scraping (or reading the user's description), always confirm the language:

"Your site is in [detected language]. Want me to generate the page in [detected language]?"

Options: A) Yes, [detected language]. B) No, use English. C) Other (let the user type their preferred language).

If no language was detected (e.g., user gave a short English description), default to English without asking.

When generating in a non-English language: write natively. Do not translate from English. JSON keys stay English, all visible copy in the target language.

---

## Step 3: The 9 Positioning Questions (the forcing function)

This is the core of PiratePage. These questions force you to think through positioning before any copy is generated. You can't skip them. They're what makes the output good.

From the extracted URL content or description, pre-fill all 9 answers as best guesses. Then walk through each one via AskUserQuestion, one at a time:

"I scraped your site and pre-filled these answers. For each one: confirm it's right, tweak it, or rewrite it."

For each question, present the pre-filled answer with options:
A) This is right
B) Close but needs tweaking (tell me what to change)
C) Completely wrong, let me rewrite

The 9 questions:
1. **What is your product?** A brief, plain-language description.
2. **What is it NOT?** Common misconceptions, what to clarify.
3. **Key takeaway?** If a visitor remembers ONE thing, what should it be?
4. **Word of mouth?** How would an excited user describe it to a friend?
5. **Competitors?** Direct, indirect, and "doing it manually."
6. **How are you different?** Specific differences, not generic claims.
7. **Why do users want this?** What progress are they trying to make?
8. **Objections/fears?** Hesitations at signup/purchase.
9. **Primary CTA?** What should they do next?

Then voice: "How should the copy sound? Casual / Professional / Bold / Understated / Playful / Serious. Any rules to always follow or never break?"

Save everything to `piratepage.json`.

---

## Step 4: Outline + Generation

Now you have page type, language, and validated positioning. Generate the page.

1. Build a section outline based on page type + Section Selection Guide below.
2. Present the outline with "generation choices" explaining WHY each section was picked.
3. Ask for approval: A) Generate it. B) Change something. C) Different page type.
4. Generate the full HTML, run quality checks, open in browser.
5. Present: "Here's your page. Want to iterate?"

---

## Step 5: Competitive Mode

If the user mentions a competitor or pastes a competitor URL:
1. WebFetch the competitor's page
2. Extract their positioning (claims, audience, CTA, emphasis)
3. Frame wizard questions to surface differentiation: "Your competitor leads with [X]. How do you compare?"
4. Generate copy that resonates with visitors who already considered the competitor
5. Don't attack by name. Make the user's product the obvious choice.

---

## Copywriting Rules

Battle-tested. 81/81 blind test accuracy. Apply to every line of copy.

### Headlines: Clear Before Clever
Every headline must name what the product does or who it's for. Reading only headlines top-to-bottom should tell the complete value story. Every headline must make clear what the page is about. If someone reads only the headline and skips the body, they should still know they're looking at a page about [the product's category].

### Banned Headline Patterns
- "Everything you need to [verb]"
- "One [thing] for [generic benefit]"
- "Our clients love our [quality]"
- "The [category] you can actually [verb]"
- "From [X] to [Y]" when both are generic
- "[Brand Name] — [generic tagline]"
- "[Generic adjective] [category] for [vague audience]"

### Swap Test (Hero + CTA Only)
Could a competitor use this exact headline? If yes, rewrite.
- **Track 1:** Name a specific thing (feature, number, technology). "Email API built on React"
- **Track 2:** Describe it so specifically only YOU match. "Gentle sleep coaching: baby sleeping through the night in 2 weeks"

### Headline Formulas (adapt, never copy verbatim)
- **Outcome:** "{Outcome} without {pain}" / "Turn {input} into {outcome}"
- **Problem:** "Never {bad thing} again" / "Stop {pain}. Start {pleasure}."
- **Audience:** "The {category} for {target audience}"
- **Differentiation:** "Finally, {category} that {benefit}"
- **Proof:** "{Number} {people} use {product} to {outcome}"

### Eyebrows
2-4 words max. Product fact, not section label, not a sentence.
BAD: "FEATURES", "OUR PROCESS", "WHY CHOOSE US", "EVERYTHING YOU NEED"
GOOD: "REACT EMAIL API", "60 SECONDS", "TRUSTED BY 2,400+ TEAMS"

### Content Rules
- Headlines: 10 words max, no quotation marks
- Subheadlines: 1-2 sentences max
- Pair every feature with its benefit
- Testimonials: 1-2 sentences, specific outcomes, name + role + metric
- Every section has ONE clear CTA
- CTA formula: [Action Verb] + [What They Get]. Never: "Submit", "Learn More", "Click Here", "Get Started"
- CTAs feel low-risk: free trials, guarantees, "no credit card required"

### Voice
Imperfect rhythm, conversational but not forced. Specific over vague. One strong claim beats three weak ones. Show empathy before selling. Pain sections open with "you" or a scenario, not the product.

### Tone
Confident but not arrogant. Helpful but not pushy. A little funny when it fits.

### Never Sound Like AI
Banned phrases: "That being said", "It's worth noting", "At its core", "In today's digital landscape", "Let's delve into", "When it comes to", "Seamlessly", "Effortlessly", "Cutting-edge", "Revolutionize", "Let's dive in", "Without further ado", "I'm thrilled to announce", "We're proud to..."
Banned vocabulary: delve, crucial, robust, comprehensive, nuanced, leverage, foster, showcase, pivotal, transformative, game-changing, paradigm.

---

## Section Selection Guide

### Available Sections (20 types)

When building an outline, choose from these. The skill has HTML reference files for each.

**Opening sections:**
- `hero` — The 5-second pitch. 5 variants: default, with-image, with-proof, with-screenshot, with-checklist.

**Problem sections:**
- `pain` — Name the frustration. 2 variants: default (numbered list), before-after (two-column contrast).

**Solution sections:**
- `how-it-works` — 3-4 step process. 2 variants: default (text), with-images (screenshots per step).
- `features-grid` — Scannable feature cards. 5 variants: default, bento, icon-grid, showcase, tabs.
- `features-list` — Detailed feature descriptions. 3 variants: default, spotlight (alternating), highlight (with quotes).
- `screenshot` — Full-width product UI. 2 variants: default, with-benefits.

**Proof sections:**
- `testimonials` — Customer quotes. 3 variants: default (stack), featured (single large), with-results (metric cards).
- `social-proof` — Logo bar. Company logos and trust badges.
- `stats` — Key metrics. 3 variants: default (grid), with-context, proof-bar (single line).
- `results` — Customer outcomes. 2 variants: metrics (numbers), story (narrative).

**Objection handling:**
- `faq` — Accordion Q&A. Address objections with the user's actual voice.
- `comparison-table` — Side-by-side vs competitor.
- `pricing` — Plans and pricing. 2 variants: default (multi-plan), single.

**Closing sections:**
- `cta` — Final call to action. 3 variants: default, with-proof, with-trust.

**Special sections:**
- `text-block` — Long-form narrative (founder story, mission).
- `showcase` — Portfolio/examples. 3 variants: grid, cards, logo-cards.
- `statement` — Single bold claim, full-width.
- `news` — Timeline of announcements.
- `code-sample` — Code blocks with syntax highlighting.
- `founder-story` — Personal narrative with signature.

### Variant Selection Rules

**Default to the richest variant.** Screenshot placeholders, images, and visual elements make pages more compelling. Only choose a simpler variant when the product genuinely has nothing visual to show. When in doubt, include a screenshot placeholder — it's always better than a text-only section.

**Hero:**
- Default: `with-screenshot` (generate screenshot placeholder wireframe)
- Only fall back when:
  - Product has no UI at all (pure service/consultancy) → `with-checklist` or `with-proof`
  - Strong testimonial is the #1 selling asset → `with-proof`
- `default` (text-only) should almost never be chosen

**Features-grid:**
- Default: `bento` with screenshot placeholders — this is the right choice most of the time
- Only fall back when:
  - 6+ features that are all brief/equal weight → `icon-grid`
  - Complex features needing sequential focus → `tabs`
- `default` (plain grid, no images) should almost never be chosen

**How-it-works:**
- Default: `with-images` (include screenshot placeholders per step)
- Only fall back to `default` for non-visual products (pure consulting, abstract services)

### Page Type Templates

**Homepage** (6-10 sections):
MUST: hero (with-screenshot preferred), 1-2 feature sections (40-60% of page, bento preferred), cta
SHOULD: pain OR how-it-works (with-images preferred), social-proof (logo bar), testimonials, faq
RECOMMENDED: Include `social-proof` with 4-6 recognizable logos or trust badges after the hero or after testimonials.

**Product Page** (6-8 sections):
MUST: hero (with-screenshot), features-grid or features-list, cta
SHOULD: how-it-works (with-images), testimonials or stats
SKIP: pain

**Service Page** (5-7 sections):
MUST: hero, how-it-works (with-images preferred), cta
SHOULD: testimonials or results, features-list
SKIP: features-grid, pricing

**Pricing Page** (4-6 sections):
MUST: hero (minimal), pricing, faq, cta
SHOULD: testimonials (ROI-focused), comparison-table
SKIP: pain, how-it-works

**Customer Story** (5-7 sections):
MUST: hero, results, cta
SHOULD: pain or text-block, testimonials
SKIP: pricing, features-grid

### Narrative Arcs

**Homepage:** Recognition → Problem → Solution → Proof → Objections → Action
**Product:** Clarity → Value → How it works → Proof → Action
**Service:** Promise → Understanding → Process → Proof → Expertise → Action
**Pricing:** Context → Plans → Comparison → Objections → Proof → Action
**Customer Story:** Hook → Challenge → Solution → Results → Broader proof → Action

---

## HTML Generation

### Reading Reference Files

For each section in the outline, read the corresponding reference file. The files live in `references/` inside the skill directory.

```bash
find ~/.claude/skills -name "SKILL.md" -path "*/piratepage/SKILL.md" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || \
find .claude/skills -name "SKILL.md" -path "*/piratepage/SKILL.md" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || \
echo "NOT_FOUND"
```

Only read reference files for sections in the approved outline. If a file doesn't exist, generate HTML using Tailwind classes consistent with the page style.

### HTML Template

```html
<!DOCTYPE html>
<html lang="{language-code}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{productName} — {keyTakeaway}</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>body { font-family: 'Inter', system-ui, sans-serif; }</style>
</head>
<body class="antialiased bg-white text-neutral-900">
  <div class="min-h-screen">
    <div class="max-w-5xl mx-auto px-8 py-8 space-y-16">
      <!-- sections -->
    </div>
    <footer class="border-t border-neutral-200 py-6 text-center text-sm text-neutral-400">
      Generated with PiratePage
    </footer>
  </div>
</body>
</html>
```

### Image Placeholders

Use mock UI wireframe placeholders, not just grey boxes:

```html
<!-- Simple placeholder -->
<div class="bg-neutral-100 rounded-xl min-h-[200px] flex items-center justify-center text-neutral-400 text-sm">
  [img: description of what goes here]
</div>

<!-- Mock screenshot placeholder (use for product UI sections) -->
<div class="bg-neutral-100 rounded-xl overflow-hidden">
  <div class="bg-neutral-200 h-8 flex items-center px-3 gap-1.5">
    <div class="w-2.5 h-2.5 rounded-full bg-neutral-300"></div>
    <div class="w-2.5 h-2.5 rounded-full bg-neutral-300"></div>
    <div class="w-2.5 h-2.5 rounded-full bg-neutral-300"></div>
    <div class="flex-1 mx-8 h-3.5 bg-neutral-300 rounded"></div>
  </div>
  <div class="p-6 min-h-[180px] flex items-center justify-center text-neutral-400 text-sm">
    [img: description of the screenshot]
  </div>
</div>
```

Use mock screenshot placeholders for: hero (with-screenshot), how-it-works (with-images), features-grid (bento, showcase), screenshot section. Use simple placeholders for: testimonial avatars, logo bars, generic images.

### Invented Content Warning

Mark AI-generated testimonials, stats, and social proof:
```html
<!-- NOTE: Testimonials below are AI-generated examples. Replace with real customer quotes before publishing. -->
```

### Auto-Open

```bash
open "{slug}-landing-page.html" 2>/dev/null || xdg-open "{slug}-landing-page.html" 2>/dev/null || echo "Open {slug}-landing-page.html in your browser."
```

---

## Quality Self-Validation

Run BEFORE presenting to user. Fix failures silently.

1. **Swap Test** — Hero + CTA headlines. Could a competitor use it? Rewrite if yes.
2. **Headline Scan** — Read headlines top-to-bottom. Do they tell the value story for THIS product?
3. **Specificity Check** — Every section must reference something specific (name, feature, number, technology).
4. **Banned Pattern Scan** — Check all copy against banned phrases and vocabulary.
5. **Eyebrow Check** — 2-4 words, product facts, not labels, not sentences.
6. **FAQ Headline Check** — Must NOT be "FAQ" or "Frequently Asked Questions." Lead with the #1 objection.
7. **Screenshot Placeholder Check** — Process sections (how-it-works) and product UI sections must have image placeholders. Use mock screenshot style for product UI.
8. **CTA Check** — [Action Verb] + [What They Get]. No "Learn More" or "Get Started."
9. **Topic Anchoring Check** — Every headline must make clear what the page is about. If a headline could be on any website about anything, it's too generic. Rewrite with the product's category or specific feature.

---

## Export Formats

After presenting, offer via AskUserQuestion:
A) Done, just the HTML
B) Also Markdown (paste into v0/Cursor)
C) Also JSON (structured data)
D) All three

**Markdown:** flat with `<!-- Generated with PiratePage -->` header.
**JSON:** structured sections array with type, variant, and all content fields.

---

## Iteration Loop

After presenting, offer:
A) Looks good, done
B) Regenerate a specific section
C) Different tone for a section
D) Shuffle section order
E) Add/remove a section
F) Regenerate whole page with feedback

### 5 Variation Tones
1. **Punchy** — Short. Strong verbs. High energy.
2. **Conversational** — Warm, like a knowledgeable friend.
3. **Benefit-focused** — Leads with outcomes. "So what does this mean for me?"
4. **Problem-aware** — Names the frustration before the solution.
5. **Bold-confident** — Assertive. Strong claims backed by specifics.

### Section-Level Changes
Rewrite only that section. Run quality checks. Edit HTML in place. Show what changed.

### Full Regeneration with Feedback
Save feedback to `piratepage.json`. Apply as constraints. Re-run all quality checks.

---

## Notes

- Stay conversational. Natural language in AskUserQuestion prompts, not robotic lists.
- Briefly explain 2-3 key copy decisions after presenting the page.
- Never present without quality checks.
- `piratepage.json` is persistent state. Update on every change.
- Detect skill directory dynamically — never hardcode paths.
- When language is non-English, generate natively. Don't translate.
