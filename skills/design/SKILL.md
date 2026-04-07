---
name: pp-design
version: 0.1.0
description: |
  Design system consultation for SaaS marketing sites.
  Understands your product, takes inspiration input, proposes a visual direction,
  generates preview pages, and writes the Tailwind config + DESIGN.md.
  Use when: "pp-design", "design the site", "set up the design system",
  "I want it to look like [this]", or as step 3 in /pp-build.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - WebFetch
  - Agent
---

## Purpose

Establish the visual identity for a SaaS marketing site before generating pages. This skill sits between /pp-scaffold and /pp-homepage in the pipeline. Every subsequent skill reads the design system it produces.

The output is:
1. A `DESIGN.md` file (design system source of truth)
2. An updated `tailwind.config.ts` with the chosen colors, fonts, and spacing
3. A design preview HTML page showing the system applied to a realistic homepage mockup

## Philosophy

**The product does the visual work.** Great SaaS sites let screenshots, code samples, and UI mockups carry the visuals. The design system gets out of the way.

**One accent color, max.** Monochrome + one accent beats a rainbow every time. Color should be functional (CTAs, highlights), not decorative.

**Big bold type.** Headlines are 48-72px, bold weight, tight letter-spacing. Confident, not cute.

**Restraint is the design.** The fewer decorative elements, the more premium it feels. Let whitespace, typography, and content hierarchy do the work.

**No AI slop patterns:**
- No purple/violet gradients
- No 3-column icon grid with colored circles
- No centered-everything with uniform spacing
- No bubbly border-radius on all elements
- No gradient buttons as primary pattern
- No generic stock-photo hero sections
- No decorative blobs or abstract shapes

## Step 0: Mode Detection

- **Fast mode** (from /pp-build fast): Skip all questions. Use the Bold Monochrome preset. Apply directly to tailwind.config.ts and DESIGN.md.
- **Interactive mode**: Walk through the consultation below.
- **With inspiration**: If the user provides screenshots or URLs, analyze them first and propose a direction that matches.

## Step 1: Check for Existing Design System

```bash
ls DESIGN.md tailwind.config.ts 2>/dev/null
```

If DESIGN.md exists: "You already have a design system. Want to update it, start fresh, or skip?"

## Step 2: Read Context

Read `data/positioning.json` for product name, audience, voice.
Read `tailwind.config.ts` for current configuration.
Check for inspiration files:

```bash
ls .context/attachments/*.png .context/attachments/*.jpg 2>/dev/null | head -10
```

If inspiration images exist, read them. Analyze:
- Color palette being used (extract dominant colors)
- Typography style (serif/sans, weight, size relative to layout)
- Layout density (compact/comfortable/spacious)
- Decoration level (minimal/intentional/expressive)
- Overall mood (corporate/startup/editorial/industrial/playful)

## Step 3: Propose the Direction

Based on positioning data + inspiration analysis (if provided), propose a complete design system.

**If inspiration was provided:**
"Based on your inspiration images, here's what I see: [analysis]. Here's a direction that captures that energy for [product name]:"

**If no inspiration:**
"Here's my recommendation for [product name] based on your positioning and audience:"

Present the full proposal:

```
AESTHETIC: [direction name] — [one-line description]
COLOR:
  - Text: [hex]
  - Background: [hex]
  - Accent: [hex] — [why this color]
  - Muted: [hex]
  - Border: [hex]
TYPOGRAPHY:
  - Display: [font name] (from Google Fonts or Fontshare) — [why]
  - Body: [font name] — [why]
  - Mono: [font name] — [for code, labels]
  - Scale: [base]px, [modular scale values]
SPACING: [base unit]px, [density level]
LAYOUT: [approach] — max width, section padding
DECORATION: [level] — [what, if anything]
MOTION: [approach]
```

### Preset Directions (use as starting points, customize per product)

**Bold Monochrome** (default for developer tools)
- Near-black text on white/off-white
- One dark accent (black buttons, minimal color)
- Large bold sans-serif headlines (Cabinet Grotesk, Satoshi, or General Sans)
- Maximum restraint. Typography carries the design.
- Good for: API products, developer tools, infrastructure

**Clean Product-Forward** (default for SaaS with UI)
- White background, one blue or green accent
- Medium-weight clean sans-serif (General Sans, Instrument Sans)
- Product screenshots and UI mockups as hero visuals
- Subtle shadows, rounded corners
- Good for: SaaS products with a visual UI to show

**Industrial Grid** (for products that want to feel technical/precise)
- Visible grid pattern (dots or lines)
- Monospace section labels, exposed structure
- Bold sans-serif + monospace pairing
- Orange or red accent, used sparingly
- Good for: DevOps, monitoring, infrastructure, security

**Editorial** (for content-heavy or premium products)
- Serif headlines + sans body
- Generous whitespace, asymmetric layouts
- Warm accent color
- Good for: Analytics, research tools, premium SaaS

In fast mode: auto-select based on product type from positioning.json:
- API/SDK/developer tool → Bold Monochrome
- SaaS with visual UI → Clean Product-Forward
- DevOps/infrastructure → Industrial Grid
- Content/analytics → Editorial

## Step 4: User Feedback

Present the proposal via AskUserQuestion:

"Here's the design direction for [product]. [Full proposal above.]"

Options:
A) Looks great — generate the preview
B) I want to adjust something
C) Show me a different direction
D) Skip preview, write the config files

If B: ask what to change, adjust, re-propose.
If C: propose an alternative direction.

## Step 5: Generate Preview

Write a self-contained HTML preview page to `design-preview.html` in the project root.

The preview must include:
1. **A realistic homepage mockup** using the proposed design system — hero, logo bar, features, stats, code sample, CTA, footer. Use real product copy from positioning.json.
2. **A chat UI mockup** in the hero (this is TalkJS / a chat product after all — or adapt to whatever the product is)
3. **Typography specimen** — display, body, and mono fonts shown at actual sizes
4. **Color palette** — swatches with hex values
5. **UI components** — buttons (primary, secondary, ghost), inputs, alerts, cards
6. **Dark mode toggle** (CSS custom properties + JS toggle)

Requirements:
- Self-contained HTML, only external dependency is font CDN links
- Mobile responsive
- Must look professional — this IS the taste test
- Use the product name and real copy, not Lorem Ipsum
- No AI slop patterns (see Philosophy section)

Open the preview:
```bash
open design-preview.html
```

Ask: "How does this feel? Want to adjust anything?"

If the user wants changes, regenerate the relevant sections and re-open.

## Step 6: Generate Multiple Variants (if requested)

If the user asks to see options, generate 2-3 variants as separate HTML files:
- `design-variant-a.html`
- `design-variant-b.html`
- `design-variant-c.html`

Each should be a distinctly different take within the general direction. Not wildly different aesthetics, but meaningful variations in color, typography weight, layout density, or decoration level.

Also generate `design-compare.html` with links to all variants.

## Step 7: Write the Design System

Once the user approves a direction, write two files:

### 1. `DESIGN.md`

```markdown
# Design System — [Product Name]

## Aesthetic
- **Direction:** [name]
- **Mood:** [1-2 sentences]

## Color
- **Text:** [hex]
- **Background:** [hex]
- **Accent:** [hex]
- **Muted text:** [hex]
- **Border:** [hex]
- **Semantic:** success [hex], warning [hex], error [hex], info [hex]

## Typography
- **Display:** [font] — [CDN link]
- **Body:** [font] — [CDN link]
- **Mono:** [font] — [CDN link]
- **Scale:** [values in px]

## Spacing
- **Base:** [N]px
- **Density:** [compact/comfortable/spacious]

## Layout
- **Max width:** [value]
- **Section padding:** [value]
- **Border radius:** sm [N]px, md [N]px, lg [N]px

## Components
- **Buttons:** [primary style], [secondary style], [ghost style]
- **Cards:** [border/shadow approach]
- **Inputs:** [border, focus state]
- **Code blocks:** [background, font]

## Anti-patterns (never do)
- [List the specific slop patterns to avoid for this design]
```

### 2. Update `tailwind.config.ts`

Update the Tailwind config to include the design system tokens:

```typescript
import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./app/**/*.{ts,tsx,mdx}', './components/**/*.{ts,tsx}', './content/**/*.mdx'],
  theme: {
    extend: {
      colors: {
        brand: {
          DEFAULT: '[accent hex]',
          // ... full palette
        },
        surface: '[bg hex]',
        muted: '[muted hex]',
      },
      fontFamily: {
        display: ['[Display Font]', 'system-ui', 'sans-serif'],
        body: ['[Body Font]', 'system-ui', 'sans-serif'],
        mono: ['[Mono Font]', 'monospace'],
      },
      fontSize: {
        // Custom scale from the design system
      },
      borderRadius: {
        // Custom radius scale
      },
    },
  },
  plugins: [],
}
```

Also update `app/layout.tsx` to import the fonts from Google Fonts or Fontshare.

## Step 8: Confirm

"Design system written:
- DESIGN.md — your design source of truth
- tailwind.config.ts — updated with design tokens
- app/layout.tsx — fonts loaded

All /pp-* skills will now read DESIGN.md and use these tokens when generating pages.

Next: run /pp-homepage to regenerate the homepage with the new design system."

## Integration with /pp-build

In the /pp-build pipeline, /pp-design runs after /pp-scaffold and before /pp-homepage:

```
/pp-build [fast] [url]
  1. /pp-positioning
  2. /pp-scaffold
  3. /pp-design        ← THIS SKILL
  4. /pp-homepage
  5. /pp-pricing
  ...
```

In fast mode: auto-select the preset based on product type, write configs, move on.
In interactive mode: full consultation with preview and iteration.
