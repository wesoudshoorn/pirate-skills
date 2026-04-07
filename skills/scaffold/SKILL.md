---
name: pp-scaffold
version: 0.1.0
description: |
  Create a Next.js marketing site skeleton from positioning data.
  Use when: "scaffold a site", "set up the project", "create the Next.js structure",
  "pp-scaffold", or as the first step in /pp-build.
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

Create a complete Next.js project structure for a SaaS marketing site. This is the foundation that all other pp-* skills write into. The output is a working Next.js app with MDX support, Tailwind CSS, and the directory structure for all content types.

## Prerequisites

Check for `data/positioning.json` (or `piratepage.json` in the pirate-skills root). If neither exists, tell the user to run `/pp-positioning` first, or run it inline if called from `/pp-build`.

## Step 0: Fast Mode Detection

If called with `fast` argument or from `/pp-build fast`, skip all AskUserQuestion prompts and use defaults for everything.

## Step 1: Project Name and Location

If not in fast mode, ask via AskUserQuestion:

"Where should I create the project?

A) Current directory (create Next.js project here)
B) New subdirectory (I'll name it based on the product)"

In fast mode: create in a new subdirectory named after the product slug from positioning.json.

## Step 2: Initialize Next.js Project

```bash
npx create-next-app@latest [project-name] \
  --typescript \
  --tailwind \
  --eslint \
  --app \
  --src-dir=false \
  --import-alias="@/*" \
  --no-turbopack \
  --yes
```

After creation, install MDX dependencies:

```bash
cd [project-name]
npm install @next/mdx @mdx-js/loader @mdx-js/react
npm install gray-matter next-mdx-remote
```

## Step 3: Configure MDX Support

Update `next.config.ts` to support MDX:

```typescript
import createMDX from '@next/mdx'

const nextConfig = {
  pageExtensions: ['js', 'jsx', 'md', 'mdx', 'ts', 'tsx'],
}

const withMDX = createMDX({})

export default withMDX(nextConfig)
```

Create `mdx-components.tsx` at project root:

```typescript
import type { MDXComponents } from 'mdx/types'

export function useMDXComponents(components: MDXComponents): MDXComponents {
  return {
    ...components,
  }
}
```

## Step 4: Create Directory Structure

```
[project]/
  app/
    (marketing)/
      layout.tsx          # Marketing layout with header + footer
      page.mdx            # Homepage (placeholder, /pp-homepage fills this)
      pricing/
        page.mdx          # Placeholder
      about/
        page.mdx          # Placeholder
    (docs)/
      layout.tsx          # Docs layout with sidebar
      docs/
        [...slug]/
          page.tsx         # Dynamic docs page
    blog/
      layout.tsx          # Blog layout
      page.tsx            # Blog listing
      [slug]/
        page.tsx           # Blog post page
    layout.tsx             # Root layout
    globals.css            # Tailwind directives
  components/
    marketing/
      Header.tsx           # Site header with nav
      Footer.tsx           # Site footer
      Section.tsx          # Reusable section wrapper
    docs/
      Sidebar.tsx          # Docs sidebar nav
    blog/
      PostCard.tsx         # Blog post card for listing
    ui/
      Button.tsx           # Basic button component
  content/
    competitors/           # /pp-competitor writes here
      .gitkeep
    use-cases/             # /pp-usecase writes here
      .gitkeep
    features/              # /pp-tour writes here
      .gitkeep
    changelog/             # /pp-changelog writes here
      .gitkeep
    blog/                  # /pp-article writes here
      .gitkeep
  data/
    positioning.json       # Copied from piratepage.json
    nav.json               # Navigation structure
    competitors.json       # Competitor metadata (empty array)
    features.json          # Feature metadata (empty array)
  lib/
    content.ts             # MDX loading utilities
    positioning.ts         # Read positioning data
  public/
    robots.txt             # Basic robots.txt
```

## Step 5: Configure Tailwind with Brand

Read positioning.json. If it contains voice/tone data, map to Tailwind config:

**tailwind.config.ts:**
```typescript
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './content/**/*.{md,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          // Default neutral palette. /pp-style or user overrides later.
          50: '#f8fafc',
          100: '#f1f5f9',
          200: '#e2e8f0',
          300: '#cbd5e1',
          400: '#94a3b8',
          500: '#64748b',
          600: '#475569',
          700: '#334155',
          800: '#1e293b',
          900: '#0f172a',
          950: '#020617',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        heading: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

export default config
```

In fast mode, use the neutral palette. In interactive mode, ask about brand colors if the user wants to set them now or defer to later.

## Step 6: Create Navigation JSON

Read positioning.json for product name. Generate `data/nav.json`:

```json
{
  "productName": "[from positioning]",
  "header": {
    "logo": { "text": "[product name]" },
    "links": [
      { "label": "Features", "href": "/features" },
      { "label": "Pricing", "href": "/pricing" },
      { "label": "Docs", "href": "/docs" },
      { "label": "Blog", "href": "/blog" },
      { "label": "Changelog", "href": "/changelog" }
    ],
    "cta": { "label": "[from positioning CTA]", "href": "/signup" }
  },
  "footer": {
    "columns": [
      {
        "title": "Product",
        "links": [
          { "label": "Features", "href": "/features" },
          { "label": "Pricing", "href": "/pricing" },
          { "label": "Changelog", "href": "/changelog" }
        ]
      },
      {
        "title": "Resources",
        "links": [
          { "label": "Documentation", "href": "/docs" },
          { "label": "Blog", "href": "/blog" }
        ]
      },
      {
        "title": "Company",
        "links": [
          { "label": "About", "href": "/about" },
          { "label": "Privacy", "href": "/privacy" },
          { "label": "Terms", "href": "/terms" }
        ]
      }
    ]
  }
}
```

## Step 7: Create Layout Components

### Root Layout (`app/layout.tsx`)
- Import Google Fonts (Inter by default)
- Set metadata from positioning.json (product name, description)
- Include globals.css

### Marketing Layout (`app/(marketing)/layout.tsx`)
- Import Header and Footer components
- Render children between them

### Header Component (`components/marketing/Header.tsx`)
- Read nav.json for links
- Responsive: hamburger menu on mobile
- Sticky header with backdrop blur
- CTA button from positioning

### Footer Component (`components/marketing/Footer.tsx`)
- Multi-column footer from nav.json
- Copyright line with product name and year

## Step 8: Create Content Utilities

### `lib/content.ts`
Utility functions for loading MDX content:
- `getContentBySlug(dir, slug)` — load single MDX file with frontmatter
- `getAllContent(dir)` — load all MDX files from a directory, sorted by date
- `getContentSlugs(dir)` — get all available slugs

### `lib/positioning.ts`
- `getPositioning()` — read and parse data/positioning.json
- Export typed interface for positioning data

## Step 9: Create Placeholder Pages

### Homepage (`app/(marketing)/page.mdx`)
```mdx
---
title: [Product Name]
description: [from positioning - key takeaway]
---

# Welcome to [Product Name]

This page will be generated by /pp-homepage.
```

### Pricing (`app/(marketing)/pricing/page.mdx`)
```mdx
---
title: Pricing - [Product Name]
---

# Pricing

This page will be generated by /pp-pricing.
```

## Step 10: Verify and Open

```bash
cd [project-name]
npm run dev
```

Open in browser. Verify:
- Site loads without errors
- Header renders with navigation
- Footer renders with columns
- Placeholder homepage shows
- Tailwind styles are applied

## Output

Tell the user:

"Site scaffolded at [path]. The structure is ready for other pp-* skills:
- /pp-homepage will generate the homepage
- /pp-competitor will create competitor comparison pages in content/competitors/
- /pp-usecase will create use-case pages in content/use-cases/
- /pp-tour will create feature pages in content/features/
- /pp-docs will scaffold documentation in app/(docs)/

Run `npm run dev` to see the site. All other skills write into this structure."
