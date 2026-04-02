---
name: piratepage
version: 3.0.0
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

## Step 0: Fast Mode

If the user's message contains `fast` followed by a URL (e.g., `/piratepage fast talkjs.com`), skip all interactive questions and generate immediately:

1. Extract the URL from the arguments. Prepend `https://` if no protocol is given.
2. WebFetch the URL to extract positioning data.
3. Auto-detect language from the scraped content. Default to English if unclear.
4. Pre-fill all 9 positioning answers from the extracted content. Use your best judgment — do not ask the user to confirm any of them.
5. Set page type to **Homepage**, voice to **Professional**.
6. Save everything to `piratepage.json`.
7. Build the section outline using the Section Selection Guide and Variant Selection Rules (default to richest variants). Do NOT present the outline for approval — go straight to generation.
8. Generate the full HTML, run all quality checks, and open in the browser.
9. Present the page and enter the **Iteration Loop** (Step 5 choices) so the user can tweak if needed.

**Do not ask any questions in fast mode.** The entire point is zero interaction until the page is in the browser.

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

Then ask: "Any voice or style rules? (e.g., always casual, never use jargon, match our brand voice). Or skip and I'll use the positioning to decide."

Save everything to `piratepage.json`.

---

## Step 4: Outline + Generation

Now you have page type, language, and validated positioning. Generate the page with the **Variations Browser** — every section gets 5 tone variants the user can cycle through.

**Section Preferences:** If `piratepage.json` contains a `preferredSections` array, prefer those variants when building the outline. If a preferred variant conflicts with the content (e.g., `hero: with-screenshot` but no product UI), note the conflict and suggest an alternative. Fill remaining required sections using the page type template and variant selection rules.

**Paste-back:** If the user pastes a JSON object containing `preferredSections` at any point, merge it into `piratepage.json` and confirm.

1. Build a section outline based on page type + Section Selection Guide below (respecting any `preferredSections`).
2. Present the outline with "generation choices" explaining WHY each section was picked.
3. Ask for approval: A) Generate it. B) Change something. C) Different page type.
4. **Generate all 5 tone variants for each section.** Work section by section: generate all 5 tones of section 1, then all 5 of section 2, etc. The section structure (layout variant) stays the same across all 5 tones — only the copy changes. All 5 tones must use the same facts, features, names, and numbers from `piratepage.json` — only framing, word choice, and sentence structure differ.
5. Wrap each section in the Variations Browser HTML structure (see HTML Generation below).
6. Run quality checks on ALL variants, open in browser.
7. Present: "Here's your page. Cycle through tones with the arrows on each section."

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

### Available Sections (21 types)

When building an outline, choose from these. The skill has HTML reference files for each.

**Navigation:**
- `navbar` — Sticky top nav bar. 2 variants: default (text logo), with-logo-placeholder (image logo slot). Always placed first, before hero.

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
MUST: navbar, hero (with-screenshot preferred), 1-2 feature sections (40-60% of page, bento preferred), cta
SHOULD: pain OR how-it-works (with-images preferred), social-proof (logo bar), testimonials, faq
RECOMMENDED: Include `social-proof` with 4-6 recognizable logos or trust badges after the hero or after testimonials.

**Product Page** (6-8 sections):
MUST: navbar, hero (with-screenshot), features-grid or features-list, cta
SHOULD: how-it-works (with-images), testimonials or stats
SKIP: pain

**Service Page** (5-7 sections):
MUST: navbar, hero, how-it-works (with-images preferred), cta
SHOULD: testimonials or results, features-list
SKIP: features-grid, pricing

**Pricing Page** (4-6 sections):
MUST: navbar, hero (minimal), pricing, faq, cta
SHOULD: testimonials (ROI-focused), comparison-table
SKIP: pain, how-it-works

**Customer Story** (5-7 sections):
MUST: navbar, hero, results, cta
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

### HTML Template (Variations Browser)

Every generated page is a Variations Browser. Each section has invisible chrome that appears on hover: a bordered card, a section type pill (top-left), and numbered 1–5 tone buttons (top-right). The URL hash captures selections.

**The 5 tones (mapped to buttons 1–5):**
1. **Punchy** — Short. Strong verbs. High energy.
2. **Conversational** — Warm, like a knowledgeable friend.
3. **Benefit-focused** — Leads with outcomes. "So what does this mean for me?"
4. **Problem-aware** — Names the frustration before the solution.
5. **Bold-confident** — Assertive. Strong claims backed by specifics.

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
  <style>
    body { font-family: 'Inter', system-ui, sans-serif; }
    .pp-section { border: 1px solid transparent; transition: border-color 0.15s; }
    .pp-section:hover { border-color: #e5e5e5; }
    .pp-chrome { opacity: 0; transition: opacity 0.15s; }
    .pp-section:hover .pp-chrome { opacity: 1; }
    @media (hover: none) { .pp-section { border-color: #e5e5e5; } .pp-chrome { opacity: 1; } }
    @media print { .pp-chrome { display: none; } .pp-section { border: none !important; padding: 0 !important; } }
  </style>
</head>
<body class="antialiased bg-white text-neutral-900">
  <div class="min-h-screen">
    <!-- navbar goes here (outside the content container) -->
    <div class="max-w-5xl mx-auto px-8 py-8 space-y-8">

      <!-- Repeat this wrapper for each section in the outline -->
      <div class="pp-section rounded-2xl p-6 md:p-10" data-section-index="0" data-section-type="{SectionType}" data-section-variant="{variant}">
        <div class="pp-chrome flex items-center justify-between mb-6">
          <span class="text-xs text-neutral-500 bg-neutral-100 px-2.5 py-1 rounded-md">{SectionType} <span class="text-neutral-400">{variant}</span></span>
          <div class="flex items-center gap-1.5">
            <button class="pp-pill w-6 h-6 flex items-center justify-center rounded-md text-xs font-medium bg-neutral-900 text-white" data-tone-index="0">1</button>
            <button class="pp-pill w-6 h-6 flex items-center justify-center rounded-md text-xs font-medium text-neutral-400 hover:text-neutral-900 transition-colors" data-tone-index="1">2</button>
            <button class="pp-pill w-6 h-6 flex items-center justify-center rounded-md text-xs font-medium text-neutral-400 hover:text-neutral-900 transition-colors" data-tone-index="2">3</button>
            <button class="pp-pill w-6 h-6 flex items-center justify-center rounded-md text-xs font-medium text-neutral-400 hover:text-neutral-900 transition-colors" data-tone-index="3">4</button>
            <button class="pp-pill w-6 h-6 flex items-center justify-center rounded-md text-xs font-medium text-neutral-400 hover:text-neutral-900 transition-colors" data-tone-index="4">5</button>
          </div>
        </div>
        <div class="pp-variant" data-tone="punchy">
          <!-- Full section HTML for punchy tone -->
        </div>
        <div class="pp-variant" data-tone="conversational" hidden>
          <!-- Full section HTML for conversational tone -->
        </div>
        <div class="pp-variant" data-tone="benefit" hidden>
          <!-- Full section HTML for benefit-focused tone -->
        </div>
        <div class="pp-variant" data-tone="problem" hidden>
          <!-- Full section HTML for problem-aware tone -->
        </div>
        <div class="pp-variant" data-tone="bold" hidden>
          <!-- Full section HTML for bold-confident tone -->
        </div>
      </div>
      <!-- End section wrapper -->

    </div>
    <footer class="border-t border-neutral-200 py-6 text-center text-sm text-neutral-400">
      Generated with PiratePage
    </footer>
  </div>

  <script>
    (function() {
      const TONES = ['punchy', 'conversational', 'benefit', 'problem', 'bold'];
      const sections = document.querySelectorAll('.pp-section');
      const current = Array.from(sections, sec => {
        const visible = sec.querySelector('.pp-variant:not([hidden])');
        return visible ? TONES.indexOf(visible.dataset.tone) : 0;
      });

      function show(i, ti) {
        const sec = sections[i];
        sec.querySelectorAll('.pp-variant').forEach(v => v.hidden = true);
        const target = sec.querySelector('[data-tone="' + TONES[ti] + '"]');
        if (target) target.hidden = false;
        sec.querySelectorAll('.pp-pill').forEach(pill => {
          const idx = parseInt(pill.dataset.toneIndex);
          if (idx === ti) {
            pill.className = 'pp-pill w-6 h-6 flex items-center justify-center rounded-md text-xs font-medium bg-neutral-900 text-white';
          } else {
            pill.className = 'pp-pill w-6 h-6 flex items-center justify-center rounded-md text-xs font-medium text-neutral-400 hover:text-neutral-900 transition-colors';
          }
        });
        current[i] = ti;
        updateHash();
      }

      function updateHash() {
        history.replaceState(null, '', '#' + current.map(i => TONES[i]).join(','));
      }

      function copyUrl() {
        navigator.clipboard.writeText(location.href).then(() => {
          const toast = document.getElementById('pp-toast');
          toast.innerHTML = '<div style="font-weight:600;font-size:14px">URL copied</div><div style="font-size:12px;opacity:0.7;margin-top:2px">Paste into PiratePage to lock in your picks</div>';
          toast.style.opacity = '1';
          toast.style.transform = 'translateX(-50%) translateY(0)';
          clearTimeout(toast._t);
          toast._t = setTimeout(() => {
            toast.style.opacity = '0';
            toast.style.transform = 'translateX(-50%) translateY(8px)';
          }, 3000);
        });
      }

      function readHash() {
        const h = location.hash.slice(1);
        if (!h) return;
        const parts = h.split(',');
        if (parts.length !== sections.length) return;
        parts.forEach((slug, i) => {
          const ti = TONES.indexOf(slug);
          if (ti >= 0) show(i, ti);
        });
      }

      sections.forEach((sec, i) => {
        sec.querySelectorAll('.pp-pill').forEach(pill => {
          pill.addEventListener('click', () => {
            show(i, parseInt(pill.dataset.toneIndex));
            copyUrl();
          });
        });
      });

      window.addEventListener('hashchange', readHash);
      readHash();
    })();
  </script>
  <div id="pp-toast" style="position:fixed;bottom:24px;left:50%;transform:translateX(-50%) translateY(8px);opacity:0;transition:opacity 0.3s ease,transform 0.3s cubic-bezier(0.16,1,0.3,1);pointer-events:none;background:#fbbf24;color:#18181b;text-align:center;padding:12px 24px;border-radius:10px;z-index:50;"></div>
</body>
</html>
```

**Section wrapper rules:**
- Each `pp-section` has transparent border + `rounded-2xl p-6 md:p-10`. Border and chrome appear on hover only.
- Top-left: section type pill with `bg-neutral-100 rounded-md` (e.g., "Hero with-checklist")
- Top-right: 5 numbered square buttons with `rounded-md` — active is `bg-neutral-900 text-white`, inactive is `text-neutral-400`
- On touch devices (`hover: none`), border and chrome are always visible
- The first tone (`punchy`, button 1) is visible by default; the other 4 have the `hidden` attribute
- Each `pp-variant` contains a complete `<section>` block with the same layout variant but different copy
- All 5 variants of a section use the same structural HTML — only text content differs
- On print, chrome hides and borders/padding are removed

### Image Placeholders

The reference files contain abstract wireframe UI mockups as placeholders — not plain grey boxes. These wireframes use `aspect-ratio` for scalable sizing (never `min-height`):

- **Large (aspect-video):** Dashboard wireframes with browser chrome, sidebar, stat cards, charts/tables. Used in hero with-screenshot, screenshot sections.
- **Medium (aspect-[4/3]):** Form/card or chart+metrics wireframes. Used in hero with-image/with-proof, features-list spotlight, features-grid tabs.
- **Small (aspect-[3/2]):** Mini list or card-preview wireframes. Used in features-grid showcase, showcase cards, how-it-works steps.

Copy the wireframe HTML directly from the reference files. Each wireframe keeps a tiny `[img: {description}]` label at bottom-right for designer reference. Do not replace wireframes with plain grey boxes.

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
7. **Wireframe Check** — Product UI sections must use wireframe placeholders from reference files (aspect-ratio sized, not min-height grey boxes). Never use plain `[img: ...]` text boxes.
8. **CTA Check** — [Action Verb] + [What They Get]. No "Learn More" or "Get Started."
9. **Topic Anchoring Check** — Every headline must make clear what the page is about. If a headline could be on any website about anything, it's too generic. Rewrite with the product's category or specific feature.
10. **Variation Distinctness Check** — Read the headlines of all 5 tones for each section. They must be meaningfully different, not just synonym swaps. Each tone should lead with a different angle (outcome vs. problem vs. proof vs. energy vs. empathy).

---

## Export Formats

Export whichever version the user approved (neutral or styled). After presenting, offer via AskUserQuestion:
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
B) Regenerate a specific section (rewrites all 5 tone variants for that section)
C) Shuffle section order
D) Add/remove a section (new sections get all 5 tones)
E) Regenerate whole page with feedback
F) Export current selection — take the tone combination from the URL hash and output a clean single-tone HTML file (no variations browser chrome)
G) Visually upgrade this page (color, typography, depth, polish)

### Section-Level Changes
Rewrite all 5 tone variants for that section. Run quality checks on all variants. Edit HTML in place.

### Full Regeneration with Feedback
Save feedback to `piratepage.json`. Apply as constraints. Regenerate all sections with all 5 tones. Re-run all quality checks.

### Visual Upgrade (Option G)

Take the neutral monochrome page and redesign it into something that looks like a real, shipped landing page. Not a theme applied on top, but a proper visual pass with personality.

**Iron rules:**
1. **Never change copy.** All text, headlines, CTAs, testimonials stay exactly as written.
2. **Never change structure.** Section order, layout grids, and content hierarchy stay intact.
3. **Only change visual presentation:** colors, fonts, shadows, backgrounds, spacing, hover states, and decorative elements.
4. **Stay self-contained.** One HTML file. Tailwind CDN + Google Fonts only. No build step.
5. **Save as numbered variations:** `{slug}-landing-page-v1.html`, `v2.html`, etc. Keep the original neutral file intact. Each iteration gets a new number so progress is never lost.
6. **Never use `@apply`.** It does not work with the Tailwind CDN script tag. All classes must be inline on elements. No custom CSS class names that reference Tailwind utilities.

#### Step 1: Prompt for Direction

Before touching code, ask the user via AskUserQuestion which visual direction to take. Present 2-3 options tailored to their product, each a coherent combination of:

- **Aesthetic direction** (Clean SaaS, Editorial, Playful, Luxury, Brutally Minimal, Bold Startup)
- **Hero mood** (light or dark)
- **Button shape** (sharp `rounded-lg`, soft `rounded-xl`, pill `rounded-full`)
- **Color approach** (restrained ~10%, balanced ~15%, expressive ~20%)

Example prompt:
"I'll visually upgrade your page. Which direction fits your product?

A) **Clean & Professional** — light hero, sharp buttons, restrained color, geometric display font
B) **Bold & Modern** — dark hero, soft buttons, balanced color, strong sans-serif display font
C) **Warm & Approachable** — light hero with brand-50 tint, pill buttons, balanced color, rounded display font"

Adapt the options to the product. A dev tool shouldn't get "Warm & Approachable." A wellness app shouldn't get "Brutally Minimal."

#### Design Tokens (after direction is chosen)

**Hero mood:**
- **Light hero:** `bg-white` for a clean look, or `bg-brand-50` for a warmer tinted feel. Both work. Pick based on direction.
- **Dark hero:** `bg-dark-950`

**Button shape** — pick ONE and use it consistently for every button on the page.

**Card borders** — default to clean outside borders: `border border-black/10 rounded-2xl`. This works on any background (white, neutral-50, brand-50) without looking dirty. Add `hover:shadow-soft transition-all duration-300` for interactivity.

#### Design Principles

**The page should feel designed, not themed.** A theme is "pick green, apply everywhere." A designed page uses a neutral foundation with brand color appearing in specific, intentional moments.

**Each section is its own room.** Alternate section backgrounds so sections feel distinct. The palette: `white`, `neutral-50`, off-black (`dark-950`), and optionally ONE section in `brand-50`. Give sections generous vertical spacing: `py-24 md:py-32`. Never place `brand-50` next to `neutral-50` — the two light tints look muddy together. Always separate them with a `white` or `dark` section between them.

**Typography does the heavy lifting.** The display font must be legible at large sizes, not just "interesting." Hero headlines use `clamp(2.5rem, 5vw, 4.5rem)` and should fill 2 lines, not 3. Section headlines use `clamp(1.75rem, 3.5vw, 3rem)`. Use CSS `<style>` for clamp values. Container: `max-w-7xl`, hero headline area: `max-w-4xl`.

**Brand color is rare, so it pops.** On light backgrounds, brand color appears ONLY on:
- Eyebrow labels (the small uppercase text above headlines)
- Primary CTA buttons
- Icon containers (light tinted bg + darker icon)
- Metric/stat numbers in testimonials
- One highlight card (e.g. a key feature gets `bg-brand-600` with white text)

Everything else stays neutral (`neutral-900`, `neutral-500`, `neutral-400`).

#### Dark Sections

Use 1-2 dark sections. If you picked a dark hero, the CTA can also be dark (or light for contrast). If you picked a light hero, the CTA should be dark to bookend the page. The "positive" half of a before/after can also be dark.

**Off-black, not black.** Define custom dark colors in Tailwind config with just a whisper of the brand hue:
```
dark: { 700: '#1a1f1c', 800: '#141816', 900: '#0f1210', 950: '#0a0d0b' }
```
Use `bg-dark-950` for backgrounds, `border-dark-700` for borders.

**Text on dark backgrounds: always `text-white` at opacity.** This is the most important rule for dark sections. Never use colored text (like `text-brand-300`) or neutral scale (like `text-neutral-400`) on dark backgrounds. White at different opacities blends smoothly against any dark bg:
- Headlines: `text-white`
- Body text: `text-white/60`
- Secondary buttons: `text-white/70` with `border-white/20`
- Eyebrows/labels: `text-white/40`
- Trust badges / fine print: `text-white/30`
- The only exception: small accent icons (checkmarks, etc.) can use `text-brand-400`

**Buttons on dark backgrounds:**
- Primary: `bg-brand-500 text-white` (same as light sections)
- Secondary: `text-white/70 border border-white/20 hover:border-white/40 hover:text-white`

#### Light Sections

**Text on light backgrounds: always use the neutral scale.** Never use opacity modifiers on text over light backgrounds. Never use brand colors for body text or headlines.
- Headlines: `text-neutral-900`
- Body / descriptions: `text-neutral-500`
- Secondary labels / roles: `text-neutral-400`
- Section header eyebrows: `text-brand-600` (one of the few brand color uses)

#### Shadows and Depth

Define shadow tokens in Tailwind config using plain black rgba (not brand-tinted):
```
'soft': '0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.04)'
'lifted': '0 2px 8px rgba(0,0,0,0.06), 0 12px 32px rgba(0,0,0,0.08)'
'hero': '0 8px 30px rgba(0,0,0,0.15), 0 32px 80px rgba(0,0,0,0.2)'
```

Cards get `border border-black/10 rounded-2xl`. This border works cleanly on any background (white, neutral-50, brand-50) without looking muddy. On hover: `hover:shadow-soft transition-all duration-300`. The hero screenshot gets `shadow-hero`.

#### Hero Treatment

**Always include a nav bar** at the top of the hero section: product name/logo on the left, 2-3 nav links + a CTA button on the right. Keep it simple, not sticky. Use `py-5` padding, place it inside the hero section's container so it shares the hero background.

The hero should feel important but not monopolize the viewport. Use `py-24 md:py-32` for the hero content (below the nav), NOT `min-h-screen`. The user should see the beginning of the next section without scrolling.

**Dark hero:**
- `bg-dark-950` with a subtle ambient glow: `absolute` div with `bg-brand-500/[0.06] blur-[120px]`
- Screenshot mock in dark tones (`bg-dark-900`, `border-dark-700`) breaking into next section with `translate-y-16`
- Next section compensates with `pt-32`

**Light hero:**
- `bg-white` or `bg-neutral-50`, no glow needed
- Screenshot mock in light tones (`bg-neutral-100`, `border border-black/10`, `shadow-hero`) breaking into next section with `translate-y-16`
- Buttons: primary is `bg-brand-500 text-white`, secondary is `text-neutral-600 border border-neutral-300`
- Text: headline `text-neutral-900`, body `text-neutral-500`, eyebrow `text-brand-600`

#### Anti-Slop Checklist

Before saving, verify NONE of these are present:
- `@apply` anywhere in `<style>` tags (breaks with Tailwind CDN)
- Custom CSS class names used on elements (`.card`, `.btn-primary`, etc.)
- `font-display` or `font-body` classes WITHOUT matching `fontFamily` in the Tailwind config (if you use these classes, the config MUST define them)
- Inline `style="font-family:..."` scattered across elements (put fonts in the Tailwind config `fontFamily` and use `font-display`/`font-body` classes instead)
- Mixing native Tailwind colors (e.g. `bg-rose-50`) with custom `brand` colors for the same hue (use `brand-*` everywhere for the accent color)
- Brand-colored text for headlines, body copy, or testimonial quotes
- `text-neutral-*` or `text-brand-*` on dark backgrounds (use `text-white/*` instead)
- Opacity modifiers on text over light backgrounds (use neutral scale instead)
- Purple-to-blue gradient backgrounds
- Decorative blob SVGs or floating gradient shapes
- Brand color on more than ~10% of elements
- Body background in brand-50 (too much theme, use white or neutral-50)
- `min-h-screen` on the hero (too tall, use `py-24 md:py-32` instead)
- 3+ lines where 2 would work (widen the container or bump font size)
- Every page looking the same (vary hero mood, button shape, card style)
- Cool gray text (`text-neutral-300/400`) on warm-tinted backgrounds (`brand-50`, amber-50, etc.) — gray looks dirty next to warm tones. Use `text-neutral-500` minimum or `text-brand-700` on warm backgrounds.
- Text smaller than `text-sm` (`text-xs`) on white/light backgrounds — too small to read comfortably. `text-xs` is only OK for labels inside cards, never for standalone body text.
- `text-neutral-400` or lighter for any text on white backgrounds — minimum contrast for readable body text is `text-neutral-500`. Use `text-neutral-400` only for metadata (dates, roles, captions) that sits next to darker text.
- `brand-50` section adjacent to `neutral-50` section — two light tints side by side look muddy. Always put a `white` or `dark` section between them.
- Missing nav bar — every page needs a simple header with product name + CTA button.

#### Styled HTML Head (MUST use this structure)

```html
<script src="https://cdn.tailwindcss.com"></script>
<script>
tailwind.config = {
  theme: {
    extend: {
      colors: {
        brand: {
          50: '{brand-50}', 100: '{brand-100}', 200: '{brand-200}',
          300: '{brand-300}', 400: '{brand-400}', 500: '{brand-500}',
          600: '{brand-600}', 700: '{brand-700}', 800: '{brand-800}',
          900: '{brand-900}', 950: '{brand-950}'
        },
        dark: { 700: '#1a1f1c', 800: '#141816', 900: '#0f1210', 950: '#0a0d0b' }
      },
      fontFamily: {
        display: ['{display-font}', 'system-ui', 'sans-serif'],
        body: ['{body-font}', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        'soft': '0 1px 3px rgba(0,0,0,0.04), 0 4px 12px rgba(0,0,0,0.04)',
        'lifted': '0 2px 8px rgba(0,0,0,0.06), 0 12px 32px rgba(0,0,0,0.08)',
        'hero': '0 8px 30px rgba(0,0,0,0.15), 0 32px 80px rgba(0,0,0,0.2)',
      }
    }
  }
}
</script>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family={display-font}:wght@400;500;600;700&family={body-font}:wght@400;500;600&display=swap" rel="stylesheet">
<style>
  body { font-family: '{body-font}', system-ui, sans-serif; }
  .hero-headline { font-size: clamp(2.5rem, 5vw, 4.5rem); line-height: 1.05; letter-spacing: -0.03em; }
  .section-headline { font-size: clamp(1.75rem, 3.5vw, 3rem); line-height: 1.1; letter-spacing: -0.02em; }
</style>
```

Pick `{display-font}` for headlines. It must be **legible at large sizes** and available on Google Fonts. Decorative or script fonts don't work for headlines.

**Tested headline fonts by vibe** (all on Google Fonts, all legible at clamp sizes):

| Vibe | Fonts | Use when |
|------|-------|----------|
| Clean geometric | Space Grotesk, Plus Jakarta Sans, Outfit, Sora | SaaS, dev tools, dashboards |
| Warm friendly | Nunito, Quicksand, Rubik | Consumer apps, wellness, creative |
| Editorial serif | Instrument Serif, Fraunces, Lora, Source Serif 4 | Agencies, premium, legal, finance |
| Bold confident | DM Sans (700), Urbanist (700), Bricolage Grotesque | Startups, marketing, bold brands |
| Monospace | JetBrains Mono, IBM Plex Mono, Space Mono | Dev tools, technical, hacker energy |

Pick `{body-font}` for readability. Neutral, doesn't compete: Inter, DM Sans, Source Sans 3, IBM Plex Sans, Nunito Sans, Work Sans.

**Pairing rule:** don't pair two fonts from the same vibe. Serif display + sans body, or bold display + neutral body. Same-vibe pairs look like one font.

**Overused — avoid as display font:** Inter, Roboto, Poppins, Montserrat, Open Sans, Lato. Fine as body fonts, generic as headlines.

Pick the brand color family based on the product domain and voice. Avoid purple-to-blue (generic AI look). Use `500` for buttons, `600` for eyebrows/icons, `50` for icon container backgrounds, `400` for checkmarks on dark.

#### After Styling

Open the styled file in the browser. Then ask via AskUserQuestion:

"Here's your visually upgraded page. The original neutral version is still at `{slug}-landing-page.html`.

What do you think?
A) Love it, keep this version
B) Tweak the colors (tell me what you want)
C) Different font pairing
D) More/less dark sections
E) Go back to the neutral version
F) Try a completely different visual direction"

If F: re-run the refinement with a different color family, different font pairing, and different dark section placement. Save as `{slug}-landing-page-styled-v2.html`.

---

## Notes

- Stay conversational. Natural language in AskUserQuestion prompts, not robotic lists.
- Briefly explain 2-3 key copy decisions after presenting the page.
- **Section Gallery:** Users can run `/piratepage-gallery` to browse all section types and variants visually, mark favorites, and copy a preference array to paste back.
- Never present without quality checks.
- `piratepage.json` is persistent state. Update on every change.
- Detect skill directory dynamically — never hardcode paths.
- When language is non-English, generate natively. Don't translate.
