---
title: "Add the StrayCats card to your site"
summary: "A small, free card that links your website to the StrayCats project. Paste two lines of HTML, and it keeps itself up to date."
ShowToc: true
ShowReadingTime: false
ShowPostNavLinks: false
comments: false
updated: 2026-11-05
---

If you run a clinic, shelter or rescue and want to show you support the cats' side of things, you
can add a small **StrayCats card** to your website. It works on any site (WordPress, Wix, Squarespace,
Hugo or plain HTML), costs nothing, and you never have to update it: when the project's wording or
logo changes, your card changes too.

![The StrayCats logo](../images/straycats-card-logo.webp "The StrayCats logo that appears on the card: a grey cat with a white chest resting in front of a sunset.")

## What it is

The card is a small piece of code that shows the StrayCats logo, a one-sentence description and a link
to this site. It does not use cookies, does not track your visitors and does not load anything except
the card text and the logo from this site. If it can't load, your visitors still see a plain link.

## Copy and paste

Paste this where you want the card to appear (a footer, the "About" page, a sidebar):

```html
<straycats-card>
  <a href="https://straycats.love/">StrayCats project</a>
</straycats-card>
<script src="https://straycats.love/card.js" async></script>
```

For a smaller one-line version, good for a footer:

```html
<straycats-card variant="compact">
  <a href="https://straycats.love/">StrayCats project</a>
</straycats-card>
<script src="https://straycats.love/card.js" async></script>
```

For phones and narrow columns, a medium version keeps the logo beside a short description:

```html
<straycats-card variant="medium">
  <a href="https://straycats.love/">StrayCats project</a>
</straycats-card>
<script src="https://straycats.love/card.js" async></script>
```

The line inside the tag is a safety net: it is what visitors see if their browser blocks scripts, and it
is replaced by the card as soon as the card loads. You can paste the `<script>` line more than once, or
use several cards on a page; it still works.

## Options

Add these to the `<straycats-card>` tag, for example `<straycats-card lang="es" variant="compact">`.

| Option | Values | Default |
|---|---|---|
| `lang` | `en` or `es` | your page's language, else `en` |
| `variant` | `card` (logo, description and link), `medium` (smaller, always side by side, made for phones and narrow columns) or `compact` (one line) | `card` |
| `theme` | `light`, `dark` or `auto` (follows the visitor's device) | `auto` |

## Match your colors

The card has sensible light and dark colors. To match your site, set any of these in your CSS:

```css
straycats-card {
  --straycats-bg: #ffffff;       /* card background */
  --straycats-border: #e3d9cc;   /* card border */
  --straycats-text: #2b2623;     /* text */
  --straycats-accent: #8a4b12;   /* link color */
}
```

Keep the link color dark enough (or light enough on a dark background) to read easily. The logo always
sits on its own cream tile, so it looks right on any background.

## Using Hugo?

Save this as `layouts/_partials/straycats-card.html` (or `layouts/partials/` in older Hugo):

```go-html-template
<straycats-card lang="{{ site.Language.Lang }}">
  <a href="https://straycats.love/">StrayCats project</a>
</straycats-card>
<script src="https://straycats.love/card.js" async></script>
```

Then add one line wherever the card should appear, for example in your footer template:

```go-html-template
{{ partial "straycats-card.html" . }}
```

## Questions

If something doesn't look right, or you'd like a different look, [get in touch](/involve/). Thank you
for helping more people see the cats nobody owns.
