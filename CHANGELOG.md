# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.9.1] - 2026-04-16

### Changed
- Picker toolbar now uses `position:sticky` by default, eliminating content overlap
- Toolbar is draggable via a 3-bar grip handle on the right side — grab and drop it anywhere in the section
- Drag is clamped to the section boundary with `overflow:clip` so the toolbar never escapes into adjacent sections
- Added PiratePage skull logo to the left of the pill numbers with a subtle divider
- Tighter, more refined toolbar design: smaller pills (26px), reduced padding, lighter shadow

## [0.9.0] - 2026-04-14

### Added
- Three independent modes: `/piratepage positioning`, `/piratepage mock`, `/piratepage variations`
- Router with context detection and fast mode shortcut
- Mode 3: Variations — generate 5 tone options for any section in your codebase with a picker toolbar
- Picker toolbar (`piratepage-picker.js`) with sliding highlight animation, per-section overlays, URL hash persistence, and clipboard copy
- Styled picker example page with TalkJS demo content
- 3 new page types: Competitor page, Feature Tour, Use Case page
- Page-type-specific quality checks (16 new checks across the 3 types)

### Changed
- SKILL.md fully restructured from monolithic flow to 3-mode skill (926 → 529 lines)
- Visual Upgrade system extracted to `references/visual-upgrade.md` (loaded on demand)
- Mock pages now generate single-tone HTML (no more Variations Browser chrome)
- Picker uses numbered pills (1-5) instead of tone names
- Picker toolbar uses frosted glass with double-border trick (white inner ring + dark outer ring) for visibility on any background

### Removed
- Variations Browser (5-tone inline switching per section) — replaced by Mode 3 picker
- Inline Visual Upgrade instructions — moved to separate reference file

## [0.7.0] - 2026-04-02

### Added
- Fast mode: `/piratepage fast <url>` generates a complete page with zero interaction
- Auto-detects language, pre-fills all positioning answers, picks Homepage layout

## [0.6.0] - 2026-04-02

### Added
- Navbar section type (21st section) with sticky top navigation
- Two variants: default (text logo) and with-logo-placeholder (image logo slot)
- All page type templates now include navbar as first section

## [0.5.0] - 2026-04-02

### Added
- Section gallery skill (`/piratepage-gallery`) for browsing all section types visually
- `build-gallery.sh` script generates interactive HTML gallery
- Star favorites and copy preference JSON to use in future generations

## [0.4.0] - 2026-04-02

### Added
- Variations browser: every section generates in 5 tones (punchy, conversational, benefit-focused, problem-aware, bold-confident)
- Hover chrome with numbered tone buttons per section
- URL hash captures tone selections for sharing
- Variation distinctness quality check (10th check)

## [0.3.0] - 2026-04-02

### Changed
- Replaced grey box image placeholders with wireframe UI mockups
- Three wireframe sizes: large (dashboard), medium (form/chart), small (card preview)
- Wireframes use `aspect-ratio` for scalable sizing

## [0.2.0] - 2026-04-02

### Changed
- Default variant selection biased toward richer sections with visual elements
- `hero: with-screenshot` is now the default hero variant
- `features-grid: bento` is now the default features variant
- `how-it-works: with-images` is now the default process variant

## [0.1.2] - 2026-04-02

### Added
- Origin story document (ORIGIN.md) with full extraction context from PiratePage

## [0.1.1] - 2026-04-02

### Fixed
- Restored forcing function: page type asked first, then URL, then positioning questions
- Added language confirmation step after URL scraping

## [0.1.0] - 2026-04-02

### Added
- Initial release: AI landing page generator skill for Claude Code
- 5 page types (homepage, product, service, pricing, customer story)
- 20 section types with multiple variants each
- 9-question positioning wizard with URL pre-filling
- 9 quality self-validation checks
- Competitive mode for counter-positioning
- HTML, Markdown, and JSON export formats
- Copywriting rules from 16 versions of battle-tested prompts (81/81 blind test accuracy)
- One-liner install script
