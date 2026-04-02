#!/usr/bin/env bash
# Builds gallery.html from references/*.html
# Extracts variants using the delimiter pattern and injects them as <template> elements.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REF_DIR="$SCRIPT_DIR/references"
OUT="$SCRIPT_DIR/gallery.html"

# Section order and labels (matching the PiratePage product sidebar)
declare -a SECTION_KEYS=(
  hero features-grid features-list social-proof testimonials pricing faq cta
  stats text-block pain how-it-works results comparison-table showcase
  news code-sample founder-story statement screenshot
)
declare -A SECTION_LABELS=(
  [hero]="Hero"
  [features-grid]="Features Grid"
  [features-list]="Features List"
  [social-proof]="Social Proof"
  [testimonials]="Testimonials"
  [pricing]="Pricing"
  [faq]="FAQ"
  [cta]="Call to Action"
  [stats]="Stats"
  [text-block]="Text Block"
  [pain]="Pain / Problem"
  [how-it-works]="How It Works"
  [results]="Results"
  [comparison-table]="Comparison Table"
  [showcase]="Showcase"
  [news]="News & Updates"
  [code-sample]="Code Sample"
  [founder-story]="Founder Story"
  [statement]="Statement"
  [screenshot]="Screenshot"
)

# ────────────────────────────────────────────────
# Replace {placeholder} tokens with example content
# ────────────────────────────────────────────────
fill_example_content() {
  sed \
    -e 's/{eyebrow}/Used by 2,000+ teams/g' \
    -e 's/{pill}/Just launched v2.0/g' \
    -e 's/{headline}/Ship your landing page in minutes, not months/g' \
    -e 's/{subheadline}/Stop overthinking your homepage. Get a conversion-ready page with real copy, not lorem ipsum./g' \
    -e 's/{description}/A clean interface that puts your content front and center. No distractions, just results./g' \
    -e 's/{primaryCTA\.text}/Get Started Free/g' \
    -e 's/{primaryCTA\.href}/#/g' \
    -e 's/{secondaryCTA\.text}/See How It Works/g' \
    -e 's/{secondaryCTA\.href}/#/g' \
    -e 's/{socialProof}/Trusted by 500+ startups/g' \
    -e 's/{rating}/4.9\/5/g' \
    -e 's/{reviewCount}/800+ reviews/g' \
    -e 's/{trustBadge}/No credit card required · Cancel anytime/g' \
    -e 's/{image}/Product screenshot showing the main dashboard/g' \
    -e 's/{featuredQuote\.quote}/We shipped our homepage in 2 hours instead of 2 weeks. The copy was better than what our agency wrote./g' \
    -e 's/{featuredQuote\.author}/Sarah Chen/g' \
    -e 's/{featuredQuote\.role}/Founder, LaunchKit/g' \
    -e 's/{checklist\[0\]}/Generate conversion-ready copy in your brand voice/g' \
    -e 's/{checklist\[1\]}/20 section types with 55 design variants/g' \
    -e 's/{checklist\[2\]}/Export as HTML, Markdown, or JSON/g' \
    -e 's/{checklist\[3\]}/Iterate on any section without regenerating the whole page/g' \
    -e 's/{features\[0\]\.title}/Smart Copy Engine/g' \
    -e 's/{features\[0\]\.description}/Writes conversion copy based on your positioning, not generic templates. Every headline is specific to what you sell./g' \
    -e 's/{features\[0\]\.icon}/M3.75 13.5l10.5-11.25L12 10.5H8.25l7.5-7.5/g' \
    -e 's/{features\[0\]\.image}/Screenshot of the copy generation interface/g' \
    -e 's/{features\[0\]\.quote}/The copy quality blew me away./g' \
    -e 's/{features\[0\]\.quoteAuthor}/James Park, CEO/g' \
    -e 's/{features\[1\]\.title}/Section Gallery/g' \
    -e 's/{features\[1\]\.description}/Browse 55 variants across 20 section types. Pick your favorites before generating — the AI respects your taste./g' \
    -e 's/{features\[1\]\.icon}/M2.25 12.75V12A2.25 2.25 0 014.5 9.75h15A2.25 2.25 0 0121.75 12v.75/g' \
    -e 's/{features\[1\]\.image}/Gallery view showing section thumbnails/g' \
    -e 's/{features\[1\]\.quote}/Being able to pick sections beforehand saved us hours./g' \
    -e 's/{features\[1\]\.quoteAuthor}/Maya Johnson, Designer/g' \
    -e 's/{features\[2\]\.title}/One-Click Export/g' \
    -e 's/{features\[2\]\.description}/Export as clean HTML with Tailwind, paste-ready Markdown for v0 or Cursor, or structured JSON for your CMS./g' \
    -e 's/{features\[2\]\.icon}/M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5/g' \
    -e 's/{features\[2\]\.image}/Export dialog showing format options/g' \
    -e 's/{features\[2\]\.values\.planName}/HTML + Markdown + JSON/g' \
    -e 's/{features\[2\]\.values\.competitor1}/HTML only/g' \
    -e 's/{features\[2\]\.values\.competitor2}/PDF only/g' \
    -e 's/{features\[3\]\.title}/Iteration Loop/g' \
    -e 's/{features\[3\]\.description}/Regenerate any section, change the tone, shuffle the order. Your page evolves with your feedback./g' \
    -e 's/{features\[4\]\.title}/Competitive Mode/g' \
    -e 's/{features\[4\]\.description}/Paste a competitor URL and get a page that directly counters their positioning./g' \
    -e 's/{painPoints\[0\]\.title}/Writing copy takes forever/g' \
    -e 's/{painPoints\[0\]\.description}/You stare at a blank page for hours trying to find the right words. Then you hire a copywriter and wait two weeks./g' \
    -e 's/{painPoints\[1\]\.title}/Templates feel generic/g' \
    -e 's/{painPoints\[1\]\.description}/Every template site gives you the same "Welcome to our product" boilerplate that could describe literally anything./g' \
    -e 's/{painPoints\[2\]\.title}/Design and copy are disconnected/g' \
    -e 's/{painPoints\[2\]\.description}/You get a beautiful design, then struggle to fill it with words that actually convert./g' \
    -e 's/{before\.headline}/Without PiratePage/g' \
    -e 's/{before\.points\[0\]}/Blank page anxiety for hours/g' \
    -e 's/{before\.points\[1\]}/Generic template copy that says nothing/g' \
    -e 's/{before\.points\[2\]}/Two-week agency turnaround/g' \
    -e 's/{after\.headline}/With PiratePage/g' \
    -e 's/{after\.points\[0\]}/Conversion-ready page in minutes/g' \
    -e 's/{after\.points\[1\]}/Copy specific to your product/g' \
    -e 's/{after\.points\[2\]}/Iterate instantly, ship today/g' \
    -e 's/{steps\[0\]\.title}/Describe your product/g' \
    -e 's/{steps\[0\]\.description}/Tell us what you sell, who it is for, and what makes it different. Two minutes of input./g' \
    -e 's/{steps\[0\]\.image}/Input form with product description fields/g' \
    -e 's/{steps\[1\]\.title}/Pick your sections/g' \
    -e 's/{steps\[1\]\.description}/Browse the gallery, star your favorites. The AI builds an outline around your choices./g' \
    -e 's/{steps\[1\]\.image}/Section gallery with starred favorites/g' \
    -e 's/{steps\[2\]\.title}/Generate and iterate/g' \
    -e 's/{steps\[2\]\.description}/Get a full page with real copy. Change any section, adjust the tone, or regenerate entirely./g' \
    -e 's/{steps\[2\]\.image}/Generated landing page with iteration options/g' \
    -e 's/{testimonials\[0\]\.quote}/We shipped our homepage in 2 hours instead of 2 weeks. The copy was better than what our agency wrote./g' \
    -e 's/{testimonials\[0\]\.author}/Sarah Chen/g' \
    -e 's/{testimonials\[0\]\.role}/Founder, LaunchKit/g' \
    -e 's/{testimonials\[0\]\.metric}/3x faster launch/g' \
    -e 's/{testimonials\[1\]\.quote}/I stopped dreading the "update the website" task. Now I actually look forward to it./g' \
    -e 's/{testimonials\[1\]\.author}/Marcus Rivera/g' \
    -e 's/{testimonials\[1\]\.role}/Head of Growth, Relay/g' \
    -e 's/{testimonials\[1\]\.metric}/40% more signups/g' \
    -e 's/{testimonials\[2\]\.quote}/The competitive mode is wild. Pasted a competitor URL and got a page that was genuinely better./g' \
    -e 's/{testimonials\[2\]\.author}/Aisha Patel/g' \
    -e 's/{testimonials\[2\]\.role}/Co-founder, Stackform/g' \
    -e 's/{testimonials\[2\]\.metric}/2hr to ship/g' \
    -e 's/{logos\[0\]}/Vercel/g' \
    -e 's/{logos\[1\]}/Linear/g' \
    -e 's/{logos\[2\]}/Notion/g' \
    -e 's/{logos\[3\]}/Resend/g' \
    -e 's/{logos\[4\]}/Clerk/g' \
    -e 's/{badges\[0\]}/SOC 2 Type II/g' \
    -e 's/{badges\[1\]}/Featured in Product Hunt/g' \
    -e 's/{stats\[0\]\.value}/2,000+/g' \
    -e 's/{stats\[0\]\.label}/pages generated/g' \
    -e 's/{stats\[0\]\.context}/Founders and teams have shipped their homepage with PiratePage./g' \
    -e 's/{stats\[1\]\.value}/94%/g' \
    -e 's/{stats\[1\]\.label}/keep-rate/g' \
    -e 's/{stats\[1\]\.context}/Of generated copy that ships without major rewrites./g' \
    -e 's/{stats\[2\]\.value}/2 hrs/g' \
    -e 's/{stats\[2\]\.label}/avg. time to ship/g' \
    -e 's/{stats\[2\]\.context}/From first prompt to live page, including iterations./g' \
    -e 's/{stats\[3\]\.value}/55/g' \
    -e 's/{stats\[3\]\.label}/section variants/g' \
    -e 's/{proofStat}/Over 2,000 teams have stopped guessing and shipped their homepage./g' \
    -e 's/{results\[0\]\.value}/3x faster/g' \
    -e 's/{results\[0\]\.context}/Average time from blank page to shipped homepage, compared to agency or freelancer./g' \
    -e 's/{results\[1\]\.value}/40% fewer/g' \
    -e 's/{results\[1\]\.context}/Revision rounds needed. The AI gets closer to final copy on the first pass./g' \
    -e 's/{results\[2\]\.value}/$2,400 saved/g' \
    -e 's/{results\[2\]\.context}/Average savings vs. hiring a copywriter and designer separately./g' \
    -e 's/{story\.customer}/Sarah Chen, Founder at LaunchKit/g' \
    -e 's/{story\.before}/Spent three weeks going back and forth with a copywriter. The result was generic and we rewrote most of it ourselves./g' \
    -e 's/{story\.after}/Generated a complete landing page in one afternoon. The copy nailed our positioning on the first try./g' \
    -e 's/{story\.quote}/I wish I had this six months ago./g' \
    -e 's/{story\.quoteAuthor}/Sarah Chen, LaunchKit/g' \
    -e 's/{faqs\[0\]\.question}/Is the generated copy actually good?/g' \
    -e 's/{faqs\[0\]\.answer}/94% of generated copy ships without major rewrites. The AI writes specific, benefit-driven copy based on your actual positioning — not generic templates./g' \
    -e 's/{faqs\[1\]\.question}/Can I edit the output?/g' \
    -e 's/{faqs\[1\]\.answer}/Absolutely. Regenerate any section, change the tone, or hand-edit the HTML directly. The output is clean Tailwind CSS you can paste anywhere./g' \
    -e 's/{faqs\[2\]\.question}/What if I already have a design?/g' \
    -e 's/{faqs\[2\]\.answer}/Export as Markdown or JSON and drop it into your existing design system. The copy works independently of the layout./g' \
    -e 's/{faqs\[3\]\.question}/How is this different from ChatGPT?/g' \
    -e 's/{faqs\[3\]\.answer}/PiratePage has a structured conversion framework, 55 battle-tested section variants, and a quality-check loop. It is not a general chatbot — it is a landing page specialist./g' \
    -e 's/{faqs\[4\]\.question}/Do I need to know how to code?/g' \
    -e 's/{faqs\[4\]\.answer}/No. You get a ready-to-use HTML file. Open it in a browser, share the link, or paste into any website builder./g' \
    -e 's/{plans\[0\]\.name}/Starter/g' \
    -e 's/{plans\[0\]\.price}/Free/g' \
    -e 's/{plans\[0\]\.badge}/Try it/g' \
    -e 's/{plans\[0\]\.features\[0\]}/1 page per month/g' \
    -e 's/{plans\[0\]\.features\[1\]}/All 20 section types/g' \
    -e 's/{plans\[0\]\.features\[2\]}/HTML export/g' \
    -e 's/{plans\[0\]\.features\[3\]}/Community support/g' \
    -e 's/{plans\[0\]\.features\[4\]}/Basic analytics/g' \
    -e 's/{plans\[0\]\.features\[5\]}/Standard templates/g' \
    -e 's/{plans\[0\]\.cta\.text}/Start Free/g' \
    -e 's/{plans\[0\]\.cta\.href}/#/g' \
    -e 's/{plans\[1\]\.name}/Pro/g' \
    -e 's/{plans\[1\]\.price}/$29\/mo/g' \
    -e 's/{plans\[1\]\.badge}/Most popular/g' \
    -e 's/{plans\[1\]\.features\[0\]}/Unlimited pages/g' \
    -e 's/{plans\[1\]\.features\[1\]}/All 55 variants/g' \
    -e 's/{plans\[1\]\.features\[2\]}/HTML + Markdown + JSON export/g' \
    -e 's/{plans\[1\]\.cta\.text}/Get Pro/g' \
    -e 's/{plans\[1\]\.cta\.href}/#/g' \
    -e 's/{plans\[2\]\.name}/Team/g' \
    -e 's/{plans\[2\]\.price}/$79\/mo/g' \
    -e 's/{plans\[2\]\.features\[0\]}/Everything in Pro/g' \
    -e 's/{plans\[2\]\.features\[1\]}/Brand voice training/g' \
    -e 's/{plans\[2\]\.features\[2\]}/Priority support/g' \
    -e 's/{plans\[2\]\.cta\.text}/Contact Us/g' \
    -e 's/{plans\[2\]\.cta\.href}/#/g' \
    -e 's/{guarantee}/30-day money-back guarantee. No questions asked./g' \
    -e 's/{testimonial\.quote}/This paid for itself on the first page./g' \
    -e 's/{testimonial\.author}/Marcus Rivera, Relay/g' \
    -e 's/{trustBadges\[0\]}/No credit card required/g' \
    -e 's/{trustBadges\[1\]}/Cancel anytime/g' \
    -e 's/{trustBadges\[2\]}/Free 14-day trial/g' \
    -e 's/{benefits\[0\]\.title}/Real-time Preview/g' \
    -e 's/{benefits\[0\]\.description}/See your page take shape as the AI writes. No waiting for a full render./g' \
    -e 's/{benefits\[1\]\.title}/Section-Level Control/g' \
    -e 's/{benefits\[1\]\.description}/Regenerate one section without touching the rest. Change tone, swap variants, or rewrite./g' \
    -e 's/{benefits\[2\]\.title}/Export Anywhere/g' \
    -e 's/{benefits\[2\]\.description}/Clean HTML, Markdown for v0\/Cursor, or JSON for your CMS. No vendor lock-in./g' \
    -e 's/{items\[0\]\.title}/SaaS Landing Page/g' \
    -e 's/{items\[0\]\.description}/Convert free-trial signups with benefit-driven copy and social proof./g' \
    -e 's/{items\[0\]\.image}/SaaS landing page example/g' \
    -e 's/{items\[0\]\.badge}/Popular/g' \
    -e 's/{items\[0\]\.url}/#/g' \
    -e 's/{items\[1\]\.title}/Developer Tool/g' \
    -e 's/{items\[1\]\.description}/Lead with code samples and API docs. Ship the technical landing page./g' \
    -e 's/{items\[1\]\.image}/Developer tool landing page/g' \
    -e 's/{items\[2\]\.title}/Startup Launch/g' \
    -e 's/{items\[2\]\.description}/Waitlist page with founder story and early social proof./g' \
    -e 's/{items\[2\]\.image}/Startup launch page example/g' \
    -e 's/{items\[3\]\.title}/Agency Portfolio/g' \
    -e 's/{items\[4\]\.title}/E-commerce/g' \
    -e 's/{items\[5\]\.title}/Mobile App/g' \
    -e 's/{content\[paragraph 1\]}/Most founders know exactly what their product does. They can explain it in conversation without breaking a sweat. But the moment they sit down to write a homepage, something breaks./g' \
    -e 's/{content\[paragraph 2\]}/The words get formal. The sentences get long. The specifics that make the product interesting get buried under jargon and hedging./g' \
    -e 's/{story\.paragraph1}/I built three landing pages for my last startup. Each one took two weeks and a copywriter. Each time, I rewrote most of it myself anyway./g' \
    -e 's/{story\.paragraph2}/The problem was not the writing. It was the blank page. Nobody wants to stare at an empty Figma frame and figure out what goes where./g' \
    -e 's/{story\.paragraph3}/So I built PiratePage. It is the tool I wished I had — one that gives you a finished page you can actually ship, not a template you have to fill in./g' \
    -e 's/{founderName}/Alex Morgan/g' \
    -e 's/{founderRole}/Founder, PiratePage/g' \
    -e 's/{blocks\[0\]\.language}/bash/g' \
    -e 's/{blocks\[0\]\.label}/Install/g' \
    -e 's/{blocks\[0\]\.code}/npx piratepage generate --product "my-saas"/g' \
    -e 's/{blocks\[1\]\.language}/typescript/g' \
    -e 's/{blocks\[1\]\.label}/Configure/g' \
    -e 's/{blocks\[1\]\.code}/import { generate } from '\''piratepage'\''\nconst page = await generate({ product: '\''my-saas'\'' })/g' \
    -e 's/{blocks\[2\]\.language}/bash/g' \
    -e 's/{blocks\[2\]\.label}/Deploy/g' \
    -e 's/{blocks\[2\]\.code}/piratepage deploy --domain my-saas.com/g' \
    -e 's/{categories\[0\]\.name}/Core Features/g' \
    -e 's/{categories\[0\]\.features\[0\]\.name}/AI-generated copy/g' \
    -e 's/{categories\[0\]\.features\[0\]\.values\.planName}/Conversion-optimized/g' \
    -e 's/{categories\[0\]\.features\[1\]\.name}/Section variants/g' \
    -e 's/{categories\[1\]\.name}/Export \&amp; Integration/g' \
    -e 's/{categories\[1\]\.features\[0\]\.name}/Multi-format export/g' \
    -e 's/{features\[0\]\.name}/AI copy generation/g' \
    -e 's/{features\[1\]\.name}/Section gallery/g' \
    -e 's/{features\[2\]\.name}/Export formats/g' \
    -e 's/{items\[0\]\.date}/March 2025/g' \
    -e 's/{items\[1\]\.date}/February 2025/g' \
    -e 's/{items\[2\]\.date}/January 2025/g' \
    -e 's/{items\[3\]\.date}/December 2024/g' \
    -e 's/{items\[0\]\.badge}/New/g' \
    -e 's/{items\[1\]\.badge}/Improvement/g' \
    -e 's/{items\[2\]\.badge}/Feature/g' \
    -e 's/{items\[3\]\.badge}/Fix/g'
}

# ────────────────────────────────────────────────
# Extract templates from a single reference file
# ────────────────────────────────────────────────
extract_templates() {
  local section_key="$1"
  local file="$REF_DIR/${section_key}.html"
  [[ -f "$file" ]] || return

  local in_variant=false
  local variant_name=""
  local variant_desc=""
  local buffer=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    # Detect variant header comment
    if [[ "$line" =~ ^[[:space:]]*\<!--[[:space:]]*={5,} ]]; then
      # If we were already collecting a variant, flush it
      if $in_variant && [[ -n "$variant_name" ]]; then
        # Truncate description to first 2 sentences max
        local short_desc
        short_desc="$(echo "$variant_desc" | sed 's/"/\&quot;/g' | sed 's/\([.!?]\) [A-Z].*/\1/' | head -c 200)"
        echo "  <template data-section=\"${section_key}\" data-variant=\"${variant_name}\" data-description=\"${short_desc}\">"
        echo "$buffer" | fill_example_content
        echo "  </template>"
        echo ""
      fi
      # Read the next lines for variant info
      in_variant=false
      variant_name=""
      variant_desc=""
      buffer=""
      # Read VARIANT line
      IFS= read -r next_line || true
      if [[ "$next_line" =~ VARIANT[[:space:]]+[0-9]+:[[:space:]]*(.*) ]]; then
        variant_name="${BASH_REMATCH[1]}"
        variant_name="$(echo "$variant_name" | sed 's/[[:space:]]*$//')"
      fi
      # Read description lines until closing === line
      while IFS= read -r desc_line || [[ -n "$desc_line" ]]; do
        if [[ "$desc_line" =~ ^[[:space:]]*={5,} ]]; then
          break
        fi
        local trimmed
        trimmed="$(echo "$desc_line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
        if [[ -n "$trimmed" ]]; then
          if [[ -n "$variant_desc" ]]; then
            variant_desc="$variant_desc $trimmed"
          else
            variant_desc="$trimmed"
          fi
        fi
      done
      in_variant=true
      continue
    fi

    if $in_variant; then
      buffer+="${line}"$'\n'
    fi
  done < "$file"

  # Flush last variant
  if $in_variant && [[ -n "$variant_name" ]]; then
    local short_desc_last
    short_desc_last="$(echo "$variant_desc" | sed 's/"/\&quot;/g' | sed 's/\([.!?]\) [A-Z].*/\1/' | head -c 200)"
    echo "  <template data-section=\"${section_key}\" data-variant=\"${variant_name}\" data-description=\"${short_desc_last}\">"
    echo "$buffer" | fill_example_content
    echo "  </template>"
  fi
}

# ────────────────────────────────────────────────
# Build the SECTIONS JS array
# ────────────────────────────────────────────────
build_sections_js() {
  echo "    const SECTIONS = ["
  for key in "${SECTION_KEYS[@]}"; do
    echo "      { key: '${key}', label: '${SECTION_LABELS[$key]}' },"
  done
  echo "    ];"
}

# ────────────────────────────────────────────────
# Write output
# ────────────────────────────────────────────────
cat > "$OUT" << 'SHELL_HEAD'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Section Gallery — PiratePage</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    body { font-family: 'Inter', sans-serif; }
    .section-preview { pointer-events: none; }
    .section-preview a { text-decoration: none !important; border: none !important; outline: none !important; }
    .section-preview [href] { text-decoration: none !important; }
  </style>
</head>
<body class="bg-white text-black h-screen flex overflow-hidden">

  <!-- LEFT SIDEBAR -->
  <aside class="w-60 shrink-0 border-r border-neutral-200 flex flex-col h-screen">
    <div class="px-4 py-4 border-b border-amber-300 bg-amber-100">
      <h1 class="text-sm font-semibold text-amber-900 mb-1">Section Gallery</h1>
      <p class="text-xs text-amber-700 leading-relaxed mb-3">Click sections to save favorites. Copy-paste the array back into PiratePage to save your preferences.</p>
      <div class="flex items-center justify-between gap-2 bg-amber-200/60 rounded-lg px-3 py-2">
        <span class="text-xs font-medium text-amber-800" id="fav-count">0 favorites</span>
        <div class="flex items-center gap-2">
          <button onclick="resetFavorites()" class="text-xs text-amber-600 hover:text-amber-800 transition-colors hidden" id="reset-btn">Reset</button>
          <button onclick="copyFavorites()" class="text-xs font-medium text-white bg-amber-500 rounded w-16 py-1 text-center hover:bg-amber-600 transition-all duration-300" id="copy-btn">Copy</button>
        </div>
      </div>
    </div>
    <nav class="flex-1 overflow-y-auto p-2 space-y-1" id="section-nav"></nav>
  </aside>

  <!-- RIGHT PREVIEW AREA -->
  <main class="flex-1 overflow-y-auto" id="preview-area">
    <div class="px-10 py-8" id="preview-content"></div>
  </main>

  <!-- TEMPLATES (injected by build script) -->
SHELL_HEAD

# Inject all templates
for key in "${SECTION_KEYS[@]}"; do
  extract_templates "$key" >> "$OUT"
done

# Write the JS
cat >> "$OUT" << 'SHELL_JS_HEAD'

  <script>
SHELL_JS_HEAD

build_sections_js >> "$OUT"

cat >> "$OUT" << 'SHELL_JS_BODY'

    let activeSection = SECTIONS[0].key;
    let favorites = loadFavorites();

    function loadFavorites() {
      try { return JSON.parse(localStorage.getItem('gallery-favorites')) || []; }
      catch { return []; }
    }
    function saveFavorites() { localStorage.setItem('gallery-favorites', JSON.stringify(favorites)); }
    function isFavorited(s, v) { return favorites.some(f => f.type === s && f.variant === v); }

    function toggleFavorite(s, v) {
      if (isFavorited(s, v)) favorites = favorites.filter(f => !(f.type === s && f.variant === v));
      else favorites.push({ type: s, variant: v });
      saveFavorites(); renderSidebar(); renderPreview(); copyToClipboard();
    }

    function resetFavorites() {
      if (!confirm('Reset all favorites to zero?')) return;
      favorites = [];
      saveFavorites(); renderSidebar(); renderPreview();
    }

    function buildPayload() { return JSON.stringify({ preferredSections: favorites }, null, 2); }
    function copyToClipboard() {
      navigator.clipboard.writeText(buildPayload()).then(flashCopied).catch(() => {});
    }
    function copyFavorites() { copyToClipboard(); }
    function flashCopied() {
      const btn = document.getElementById('copy-btn');
      btn.textContent = 'Copied';
      btn.classList.remove('bg-amber-500');
      btn.classList.add('bg-amber-700');
    }

    function getVariants(key) { return Array.from(document.querySelectorAll(`template[data-section="${key}"]`)); }

    function renderSidebar() {
      const nav = document.getElementById('section-nav');
      nav.innerHTML = '';
      SECTIONS.forEach(({ key, label }) => {
        const count = getVariants(key).length;
        const active = key === activeSection;
        const btn = document.createElement('button');
        btn.className = `w-full text-left px-3 py-2 rounded-lg flex items-center justify-between gap-2 text-sm transition-colors ${active ? 'bg-neutral-900 text-white' : 'text-neutral-700 hover:bg-neutral-100'}`;
        btn.innerHTML = `<span class="truncate font-medium">${label}</span><span class="shrink-0 text-xs px-1.5 py-0.5 rounded font-medium ${active ? 'bg-neutral-700 text-neutral-300' : 'bg-neutral-100 text-neutral-500'}">${count}</span>`;
        btn.addEventListener('click', () => { activeSection = key; renderSidebar(); renderPreview(); });
        nav.appendChild(btn);
      });
      const n = favorites.length;
      document.getElementById('fav-count').textContent = n === 1 ? '1 favorite' : `${n} favorites`;
      document.getElementById('reset-btn').classList.toggle('hidden', n === 0);
    }

    function starSvg(filled) {
      const cls = filled ? 'w-5 h-5 text-amber-400 fill-amber-400' : 'w-5 h-5 text-neutral-300';
      const fill = filled ? 'currentColor' : 'none';
      return `<svg class="${cls}" fill="${fill}" viewBox="0 0 24 24" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 011.04 0l2.125 5.111a.563.563 0 00.475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 00-.182.557l1.285 5.385a.562.562 0 01-.84.61l-4.725-2.885a.563.563 0 00-.586 0L6.982 20.54a.562.562 0 01-.84-.61l1.285-5.386a.562.562 0 00-.182-.557l-4.204-3.602a.563.563 0 01.321-.988l5.518-.442a.563.563 0 00.475-.345L11.48 3.5z"/></svg>`;
    }

    function renderPreview() {
      const el = document.getElementById('preview-content');
      el.innerHTML = '';
      getVariants(activeSection).forEach(tmpl => {
        const v = tmpl.dataset.variant, desc = tmpl.dataset.description || '';
        const fav = isFavorited(activeSection, v);

        // Outer wrapper — centers the max-w-5xl block
        const row = document.createElement('div');
        row.className = 'mb-12 max-w-5xl mx-auto';

        // Card — clickable, full width within max-w
        const card = document.createElement('div');
        card.className = `rounded-2xl border-2 overflow-hidden transition-all duration-200 cursor-pointer ${fav ? 'ring-2 ring-amber-400 border-amber-400 bg-amber-50/30' : 'border-neutral-200 hover:ring-2 hover:ring-amber-200 hover:border-amber-200 hover:bg-amber-50/10'}`;
        card.addEventListener('click', () => toggleFavorite(activeSection, v));

        // Header: star + name + desc
        const hdr = document.createElement('div');
        hdr.className = 'flex items-center gap-3 px-5 py-3 border-b border-neutral-200 bg-neutral-50';
        hdr.innerHTML = `<span class="shrink-0">${starSvg(fav)}</span><span class="text-sm font-semibold text-black font-mono">${v}</span><span class="text-sm text-neutral-500 truncate">${desc}</span>`;

        // Preview body
        const body = document.createElement('div');
        body.className = 'px-10 py-2 section-preview';
        body.appendChild(tmpl.content.cloneNode(true));

        card.appendChild(hdr);
        card.appendChild(body);
        row.appendChild(card);
        el.appendChild(row);
      });
    }

    renderSidebar();
    renderPreview();
  </script>
</body>
</html>
SHELL_JS_BODY

echo "✓ Built gallery.html ($(wc -l < "$OUT" | tr -d ' ') lines) from $(ls "$REF_DIR"/*.html | wc -l | tr -d ' ') reference files"
