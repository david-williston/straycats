/*!
 * Stray Cats supporter card: <straycats-card>
 * Docs: https://straycats.love/embed/
 *
 * VERSIONING: this file's URL is the contract. Breaking changes (renamed attributes,
 * different markup) ship as a NEW filename (card.v2.js), so existing embeds keep working.
 * Non-breaking changes to wording, logo and colors are made in card.json and reach
 * every site automatically.
 *
 * Privacy: no cookies, no storage, no tracking. The only requests are card.json
 * (next to this file) and the logo image.
 */
(function () {
  "use strict";
  if (customElements.get("straycats-card")) return;

  var BASE = "https://straycats.love/";
  var script = document.currentScript;
  var JSON_URL = (script && script.src ? script.src.replace(/[^\/]*([?#].*)?$/, "") : BASE) + "card.json";

  // Shown if card.json can't be fetched, so the link never disappears.
  var FALLBACK = {
    logo: BASE + "images/straycats-card-logo.webp",
    langs: {
      en: { title: "Stray Cats", description: "An open-source, non-profit project, growing in the open, to make caring for cats easier by letting anyone see a cat's story.", tagline: "An open-source, non-profit project to make caring for cats easier.", cta: "Learn about the project", compactText: "Supports the Stray Cats project", url: BASE },
      es: { title: "Stray Cats", description: "Un proyecto de código abierto y sin fines de lucro, que crece a la vista de todos, para que cuidar gatos sea más fácil, dejando que cualquiera vea la historia de un gato.", tagline: "Un proyecto de código abierto y sin fines de lucro para que cuidar gatos sea más fácil.", cta: "Conoce el proyecto", compactText: "Apoya el proyecto Stray Cats", url: BASE + "es/" }
    }
  };

  var CSS =
    ":host{display:block;max-width:640px;margin:1.5rem auto;box-sizing:border-box;" +
    "--bg:var(--straycats-bg,#fff);--border:var(--straycats-border,#e3d9cc);" +
    "--text:var(--straycats-text,#2b2623);--accent:var(--straycats-accent,#8a4b12)}" +
    ":host([theme=dark]){--bg:var(--straycats-bg,#1f1b18);--border:var(--straycats-border,#3d352e);" +
    "--text:var(--straycats-text,#ece5dc);--accent:var(--straycats-accent,#f0b36b)}" +
    "@media (prefers-color-scheme:dark){:host(:not([theme=light]):not([theme=dark])){" +
    "--bg:var(--straycats-bg,#1f1b18);--border:var(--straycats-border,#3d352e);" +
    "--text:var(--straycats-text,#ece5dc);--accent:var(--straycats-accent,#f0b36b)}}" +
    ":host([hidden]){display:none}" +
    ":host([variant=compact]){display:block;max-width:none;margin:.5rem auto;text-align:center}" +
    "*{box-sizing:border-box}" +
    "a{color:var(--accent);font-weight:600;text-decoration:underline;text-underline-offset:2px}" +
    "a:hover{text-decoration-thickness:2px}" +
    "a:focus-visible{outline:3px solid var(--accent);outline-offset:3px;border-radius:4px}" +
    ".logo{flex:none;padding:.5rem;border-radius:12px;background:#fbf6ef;line-height:0}" +
    ".logo img{display:block;width:150px;height:auto}" +
    ".card{display:flex;align-items:center;gap:1.2rem;padding:1rem 1.4rem;border:1px solid var(--border);" +
    "border-radius:14px;background:var(--bg);color:var(--text);font:16px/1.5 system-ui,-apple-system,'Segoe UI',sans-serif}" +
    ".card strong{font-size:1.1rem}" +
    ".card p{margin:.25rem 0 .5rem;font-size:.95rem}" +
    ".mini{display:inline-flex;align-items:center;gap:.5rem;padding:.3rem .7rem;border:1px solid var(--border);border-radius:999px;background:var(--bg);font:14px/1.4 system-ui,-apple-system,'Segoe UI',sans-serif;color:var(--text)}" +
    ".mini .logo{padding:2px 4px;border-radius:6px}" +
    ".mini .logo img{width:auto;height:20px}" +
    ".med{display:flex;align-items:center;gap:.75rem;padding:.75rem;border:1px solid var(--border);border-radius:14px;" +
    "background:var(--bg);color:var(--text);font:15px/1.4 system-ui,-apple-system,'Segoe UI',sans-serif}" +
    ".med .logo{padding:.3rem;border-radius:10px}.med .logo img{width:64px}.med div{min-width:0}" +
    ".med strong{font-size:1rem}.med p{margin:.1rem 0 0;overflow-wrap:anywhere}" +
    ".med a{display:inline-block;padding:.75rem 0}" +
    "@media (max-width:480px){.card{flex-direction:column;text-align:center}}";

  var cache;
  function load() {
    if (cache) return cache;
    cache = new Promise(function (resolve) {
      if (!window.fetch) return resolve(null);
      var ctl = window.AbortController ? new AbortController() : null;
      var timer = setTimeout(function () { if (ctl) ctl.abort(); resolve(null); }, 4000);
      fetch(JSON_URL, { credentials: "omit", referrerPolicy: "no-referrer", signal: ctl && ctl.signal })
        .then(function (r) { return r.ok ? r.json() : null; })
        .then(function (d) { clearTimeout(timer); resolve(d); })
        .catch(function () { clearTimeout(timer); resolve(null); });
    });
    return cache;
  }

  function str(v, d) { return typeof v === "string" && v.trim() ? v : d; }
  function https(v, d) { return typeof v === "string" && /^https:\/\//i.test(v) ? v : d; }

  function el(tag, cls, text) {
    var e = document.createElement(tag);
    if (cls) e.className = cls;
    if (text) e.textContent = text;
    return e;
  }

  class StrayCatsCard extends HTMLElement {
    static get observedAttributes() { return ["lang", "variant", "theme"]; }
    connectedCallback() {
      if (!this._root) {
        this._root = this.attachShadow({ mode: "open" });
        this._root.appendChild(el("style", "", CSS));
        this._body = this._root.appendChild(document.createElement("div"));
      }
      this._draw(FALLBACK);
      var self = this;
      load().then(function (d) { if (d && d.langs) { self._data = d; self._draw(d); } });
    }
    attributeChangedCallback() { if (this._body) this._draw(this._data || FALLBACK); }
    _draw(data) {
      var l = (this.getAttribute("lang") || document.documentElement.lang || "en").slice(0, 2).toLowerCase();
      if (l !== "es") l = "en";
      var d = (data.langs && data.langs[l]) || {};
      var f = FALLBACK.langs[l];
      var url = https(d.url, f.url);
      var logo = https(data.logo, FALLBACK.logo);
      var variant = this.getAttribute("variant");
      var compact = variant === "compact";
      var medium = variant === "medium";

      var a = el("a");
      a.href = url;
      a.rel = "noopener";
      var tile = el("span", "logo");
      var img = el("img");
      img.alt = "";
      img.src = logo;
      img.referrerPolicy = "no-referrer";
      img.loading = "lazy";
      img.decoding = "async";
      img.width = 150;
      img.height = 125;
      tile.appendChild(img);

      var box;
      if (compact) {
        box = el("span", "mini");
        a.textContent = str(d.compactText, f.compactText);
        box.appendChild(tile);
        box.appendChild(a);
      } else if (medium) {
        box = el("div", "med");
        var mt = el("div");
        mt.appendChild(el("strong", "", str(d.title, f.title)));
        mt.appendChild(el("p", "", str(d.tagline, f.tagline)));
        a.textContent = str(d.cta, f.cta) + "\u00a0";
        a.appendChild(el("span", "", "\u2192")).setAttribute("aria-hidden", "true");
        mt.appendChild(a);
        box.appendChild(tile);
        box.appendChild(mt);
      } else {
        box = el("div", "card");
        var text = el("div");
        text.appendChild(el("strong", "", str(d.title, f.title)));
        text.appendChild(el("p", "", str(d.description, f.description)));
        a.textContent = str(d.cta, f.cta) + " ";
        var arrow = a.appendChild(el("span", "", "\u2192"));
        arrow.setAttribute("aria-hidden", "true");
        text.appendChild(a);
        box.appendChild(tile);
        box.appendChild(text);
      }
      box.lang = l;
      this._body.textContent = "";
      this._body.appendChild(box);
    }
  }

  customElements.define("straycats-card", StrayCatsCard);
})();
