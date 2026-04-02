---
name: piratepage-gallery
version: 1.0.0
description: |
  Browse all PiratePage section types and variants visually.
  Use when: "section gallery", "browse sections", "piratepage gallery",
  "show me the sections", "pick my favorite sections".
allowed-tools:
  - Bash
  - Read
---

## Section Gallery

Build and open the section gallery so the user can browse all section types and variants visually, mark favorites, and copy a preference array.

```bash
SKILL_DIR=$(find ~/.claude/skills -name "GALLERY.md" -path "*/piratepage/GALLERY.md" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || \
find .claude/skills -name "GALLERY.md" -path "*/piratepage/GALLERY.md" 2>/dev/null | head -1 | xargs dirname 2>/dev/null || \
echo "NOT_FOUND")
bash "$SKILL_DIR/build-gallery.sh" && \
open "$SKILL_DIR/gallery.html" 2>/dev/null || xdg-open "$SKILL_DIR/gallery.html" 2>/dev/null
```

Tell the user:
- Browse sections in the sidebar, star your favorites
- Each star auto-copies your preference array to clipboard
- When done, paste the JSON back here and I'll save it to your `piratepage.json`

## Handling Pasted Preferences

If the user pastes a JSON object containing `preferredSections`, merge it into `piratepage.json`:

1. Read existing `piratepage.json` (if it exists)
2. Add or replace the `preferredSections` key with the pasted array
3. Write back to `piratepage.json`
4. Confirm: "Saved N section preferences. These will be used next time you generate a page."
