# Stray Cats 🐾

An open-source, non-profit idea about how communities could identify, remember and care for
the cats nobody owns (and, one day, dogs).

> **There is no app here (yet).** Stray Cats is at the concept stage: the ideas are still
> being formed, and no software has been written, [on purpose](https://david-williston.github.io/straycats/posts/all-talk-no-code/).
> This repository holds only the project's **website**, a notebook of stories and ideas.
> Cloning it won't give you anything to run except that website.

## Get involved

The most useful thing right now is your experience and your opinion, not code:

- **Read** the stories and ideas: <https://david-williston.github.io/straycats/>
  ([en español](https://david-williston.github.io/straycats/es/))
- **Tell me what I'm missing**: reply to any story by email, or start a conversation in
  [Discussions](https://github.com/david-williston/straycats/discussions)
- **Suggest a correction or a new idea** in [Issues](https://github.com/david-williston/straycats/issues)

If you're a developer, designer or rescuer who'd like to help build it one day, say hi in
Discussions. When there's software to work on, it will be announced on the site.

---

## Working on the website

The rest of this README is for editing the website itself, built with
[Hugo](https://gohugo.io/) and the [PaperMod](https://github.com/adityatelange/hugo-PaperMod)
theme. You only need it to change the site's pages, text or design.

### Run locally

```sh
git clone --recurse-submodules https://github.com/david-williston/straycats.git
cd straycats
npm run dev           # http://localhost:1313 (or: hugo server -D)
```

If you already cloned without submodules: `git submodule update --init --recursive`.

### Add content

```sh
hugo new content ideas/my-idea.md     # a new idea
hugo new content posts/my-story.md    # a new story
```

New files start as `draft: true`; set it to `false` to publish.

The home page lists stories, then ideas, in `weight` order (stories 1–99, ideas 100+), and
the previous/next links follow the same order. Give a new story the next number after the
last one, and a new idea a weight in the hundreds.

### Photos

Pages with photos are *page bundles*: a folder holding `index.md`, `index.es.md` and the
images, shared by both languages.

```
content/posts/the-cats-nobody-owns/
  index.md        index.es.md
  cover.jpg       # landscape (3:2) cover, set in front matter under `cover:`
  vet-visit.jpg   # inline photo
```

In the text:

```
{{</* photo src="vet-visit.jpg" alt="…" caption="…" */>}}
{{</* gallery images="a.jpg b.jpg c.jpg" alt="…" caption="…" */>}}   # add anchor="Top" if heads get cropped
{{</* gallery images="a.jpg b.jpg" alts="Ciccio, a black cat | Tenkilo, a cream cat" caption="…" */>}}   # one description per photo
```

Hugo resizes and converts images at build time. Always write `alt` text (in each language),
and name the cats in it when you know who they are.

### Languages

The site is in **English** (`/`) and **Spanish** (`/es/`). Each page has a translation
alongside it with a `.es.md` suffix:

```
content/posts/the-cats-nobody-owns.md      # English
content/posts/the-cats-nobody-owns.es.md   # Español (give it a Spanish `slug:`)
```

Menus and the home page intro are per language in `hugo.yaml`; the "Respond to this idea"
box text lives in `i18n/`. In content, link to pages by their English path
(e.g. `[feedback](/feedback/)`): links resolve to the right language automatically.

### Audio overviews (NotebookLM)

The site publishes its whole text as one hidden page per language, made for NotebookLM:

- English: <https://david-williston.github.io/straycats/notebooklm/>
- Spanish: <https://david-williston.github.io/straycats/es/notebooklm/>

Each starts with **what's new in this version** (the newest What's New entry, picked up
automatically), then holds every story, idea and the About, Feedback and Saibo pages, with
their titles and addresses, in reading order (`layouts/notebooklm.html`). They update with
every release. Instructions for NotebookLM go in its **Customize** box, not in these pages.

**Set up once** (one notebook per language):

1. In NotebookLM, create a notebook ("Stray Cats" and "Stray Cats en español").
2. Add a source → **Website** → paste the page address above.
3. For the Spanish notebook, set NotebookLM's output language to Spanish, so the audio is in
   Spanish.

**After each major update**, release it, then in each notebook delete the website source and
add the same address again (NotebookLM doesn't refresh website sources by itself). Make two
overviews per language:

These prompts keep the hosts accurate: no talk of an app that exists, no comparisons with
other products, no invented details, and no guessing which cats are male or female.
If a cat's name comes out wrong, add it to the pronunciation line.

*Brief* — Audio Overview → format **Brief** → Customize. English:

```text
Audience: people hearing about Stray Cats for the first time. Tone: warm and curious, like two friends who love cats exploring a thoughtful idea. Light humour is welcome; hype is not.

Get these facts right:
- Stray Cats is an idea, not an app. It's open source, non-profit and at the concept stage: no app or code exists and nothing is launching. Describe features as "could" or "the idea is", never as if they exist.
- It's written by David Williston, who looks after a house full of cats in Puerto Escondido, Mexico.
- The cat's wellbeing always comes first, then the people who care for cats. Fun is the doorway, never the destination.
- Use the cats' real names: Ciccio, Hootie, Lucia, Mika Ella, Ninja, Tenkilo, and Mountain Lion (a nickname; real name unknown). Call each cat by name or "the cat"; don't guess whether a cat is male or female.

Avoid:
- Don't compare Stray Cats to any other app, game, product or company, or use analogies to them. Describe it in its own terms.
- Don't invent details, numbers or stories that aren't in the source.
- Don't discuss the audio overviews or videos mentioned on the pages.

Pronunciation: Ciccio is "CHEE-cho". Puerto Escondido is "PWEHR-toh es-kohn-DEE-doh".

Structure:
1. In a few sentences: the cats nobody owns in Puerto Escondido, and the question of how the world could remember them.
2. The core idea: every cat gets an identity, a growing history and a network of people who care, and meeting a cat could take just one photo, for the cat's benefit.
3. What's new in this version.
4. One gentle line: the project is dedicated to Saibo, David's cat of sixteen years, who died in September 2026.
5. Invite listeners to share their cat stories on the Stray Cats website.
```

Spanish (Spanish notebook):

```text
Público: personas que escuchan sobre Stray Cats por primera vez. Tono: cálido y curioso, como dos amigos a quienes les encantan los gatos explorando una idea bien pensada. Se vale un poco de humor; nada de exageraciones ni tono publicitario.

Estos datos tienen que quedar claros:
- Stray Cats es una idea, no una app. Es de código abierto, sin fines de lucro y está en etapa de concepto: no existe ninguna app ni código, y no se va a lanzar nada. Habla de las funciones como algo que "podría" existir o como "la idea es", nunca como si ya existieran.
- La escribe David Williston, que cuida una casa llena de gatos en Puerto Escondido, México.
- El bienestar del gato siempre va primero, y después las personas que cuidan a los gatos. La diversión es la puerta de entrada, nunca el destino.
- Usa los nombres reales de los gatos: Ciccio, Hootie, Lucia, Mika Ella, Ninja, Tenkilo y Mountain Lion (un apodo en inglés que significa León de Montaña; su nombre real nadie lo conoce). Lucia y Mika Ella son gatas; a los demás llámalos por su nombre o "el gato".

Evita:
- No compares Stray Cats con ninguna otra app, juego, producto o empresa, ni uses analogías con ellos. Descríbela con sus propias palabras.
- No inventes detalles, cifras ni historias que no estén en la fuente.
- No hables de los resúmenes en audio ni de los videos que se mencionan en las páginas.

Pronunciación: Ciccio se pronuncia "CHI-cho". Mountain Lion se dice en inglés.

Estructura:
1. En pocas frases: los gatos que no son de nadie en Puerto Escondido, y la pregunta de cómo el mundo podría recordarlos.
2. La idea central: cada gato tiene una identidad, una historia que crece y una red de personas que se preocupan por él, y conocer a un gato podría tomar solo una foto, por el bien del gato.
3. Lo nuevo en esta versión.
4. Una línea cuidadosa: el proyecto está dedicado a Saibo, el gato de David durante dieciséis años, que murió en septiembre de 2026.
5. Invita a quienes escuchan a compartir sus historias de gatos en el sitio web de Stray Cats.
```

*Deep dive* — Audio Overview → format **Deep Dive** → Customize. English:

```text
Audience: people hearing about Stray Cats for the first time. Tone: warm and curious, like two friends who love cats exploring a thoughtful idea. Light humour is welcome; hype is not.

Get these facts right:
- Stray Cats is an idea, not an app. It's open source, non-profit and at the concept stage: no app or code exists and nothing is launching. Describe features as "could" or "the idea is", never as if they exist.
- It's written by David Williston, who looks after a house full of cats in Puerto Escondido, Mexico.
- The cat's wellbeing always comes first, then the people who care for cats. Fun is the doorway, never the destination.
- Use the cats' real names: Ciccio, Hootie, Lucia, Mika Ella, Ninja, Tenkilo, and Mountain Lion (a nickname; real name unknown). Call each cat by name or "the cat"; don't guess whether a cat is male or female.

Avoid:
- Don't compare Stray Cats to any other app, game, product or company, or use analogies to them. Describe it in its own terms.
- Don't invent details, numbers or stories that aren't in the source.
- Don't discuss the audio overviews or videos mentioned on the pages.

Pronunciation: Ciccio is "CHEE-cho". Puerto Escondido is "PWEHR-toh es-kohn-DEE-doh".

Structure:
1. The stories from Puerto Escondido: the cats nobody owns, the cat with many names, what's lost when caretakers leave.
2. The ideas: identity, encounters, meeting a cat, the care network, privacy and safety. Treat the open questions as genuinely unresolved, and spend time on them.
3. What's new in this version.
4. Near the end, mention briefly and gently that the project is dedicated to Saibo, David's cat of sixteen years, who died in Puerto Escondido in September 2026.
5. End by inviting listeners to share their own cat stories and opinions on the Stray Cats website, leaving them with one or two open questions to think about.
```

Spanish (Spanish notebook):

```text
Público: personas que escuchan sobre Stray Cats por primera vez. Tono: cálido y curioso, como dos amigos a quienes les encantan los gatos explorando una idea bien pensada. Se vale un poco de humor; nada de exageraciones ni tono publicitario.

Estos datos tienen que quedar claros:
- Stray Cats es una idea, no una app. Es de código abierto, sin fines de lucro y está en etapa de concepto: no existe ninguna app ni código, y no se va a lanzar nada. Habla de las funciones como algo que "podría" existir o como "la idea es", nunca como si ya existieran.
- La escribe David Williston, que cuida una casa llena de gatos en Puerto Escondido, México.
- El bienestar del gato siempre va primero, y después las personas que cuidan a los gatos. La diversión es la puerta de entrada, nunca el destino.
- Usa los nombres reales de los gatos: Ciccio, Hootie, Lucia, Mika Ella, Ninja, Tenkilo y Mountain Lion (un apodo en inglés que significa León de Montaña; su nombre real nadie lo conoce). Lucia y Mika Ella son gatas; a los demás llámalos por su nombre o "el gato".

Evita:
- No compares Stray Cats con ninguna otra app, juego, producto o empresa, ni uses analogías con ellos. Descríbela con sus propias palabras.
- No inventes detalles, cifras ni historias que no estén en la fuente.
- No hables de los resúmenes en audio ni de los videos que se mencionan en las páginas.

Pronunciación: Ciccio se pronuncia "CHI-cho". Mountain Lion se dice en inglés.

Estructura:
1. Las historias de Puerto Escondido: los gatos que no son de nadie, el gato de muchos nombres, lo que se pierde cuando los cuidadores se van.
2. Las ideas: identidad, encuentros, conocer a un gato, la red de cuidado, privacidad y seguridad. Trata las preguntas abiertas como preguntas de verdad sin resolver, y dedícales tiempo.
3. Lo nuevo en esta versión.
4. Cerca del final, menciona de forma breve y cuidadosa que el proyecto está dedicado a Saibo, el gato de David durante dieciséis años, que murió en Puerto Escondido en septiembre de 2026.
5. Termina invitando a quienes escuchan a compartir sus propias historias de gatos y sus opiniones en el sitio web de Stray Cats, y déjales una o dos preguntas abiertas para pensar.
```

*One page* (optional, any format) — titles are listed near the top of the source page.
For best results, put this in place of the Structure section of a prompt above:

> Focus only on the page titled "Meeting a Cat". Explain it for someone who has never heard
> of Stray Cats. Mention that it's an open-source, non-profit idea at the concept stage, with
> no app yet. Use the cats' real names from the page.

> Concéntrate solo en la página titulada "Conocer a un gato". Explícala para alguien que
> nunca ha oído hablar de Stray Cats. Menciona que es una idea de código abierto y sin fines
> de lucro, todavía en etapa de concepto, sin app. Usa los nombres reales de los gatos que
> aparecen en la página.

**Then:**

1. Download the audio, make the video, and upload it to YouTube.
2. Embed it in the matching language, with a line saying it was made with NotebookLM and the
   voices are AI-generated. The brief overview replaces the one on the About page and the deep
   dive the one on The Building Blocks (see those pages for the pattern):
   `{{</* youtube id="VIDEO_ID" title="…" loading="lazy" */>}}`
3. Set `updated:` on that page and add the overview to What's New (both languages).

### Making changes

Every change goes through a pull request; `main` is protected. Cut a short-lived branch from
an up-to-date `main` (`content/...`, `fix/...`, `docs/...`, `chore/...`), open a PR, and merge
it once the **Build site** check passes. GitHub deletes the branch on merge. Merging doesn't publish the site;
releasing does (below). See CLAUDE.md for the full conventions.

### Deploy: versioning and releases

Pushing to `main` does **not** publish the site. Publishing is a release:

```sh
npm run release:dry-run   # show which version would be created
npm run deploy            # tag, build, and publish
```

Releases use calendar versions, tagged in git: `vYYYY.MM.DD` for the first release of a day
(Puerto Escondido time), then `vYYYY.MM.DD.1`, `.2` and so on. `npm run deploy` runs
`scripts/release.mjs`, which:

1. Refuses to release if there are uncommitted changes, you're not on `main`, or `main`
   isn't pushed to `origin`.
2. Tags `HEAD` with the next version (or redeploys the existing tag if `HEAD` is already
   released).
3. Builds the site locally, to catch errors before anything is published.
4. Pushes the tag. `.github/workflows/hugo.yml` then builds and deploys it to GitHub Pages
   (follow it with `gh run watch`). If the build or push fails, the new tag is deleted.

Before releasing, add a section at the top of the **What's New** page for readers
(`content/whats-new.md` and `content/whats-new.es.md`): a `## Month D, YYYY: Title` heading,
a `*Version vYYYY.MM.DD*` line, and bullets starting with **New:** or **Updated:** that link
to the pages. On each page you changed meaningfully, set `updated: YYYY-MM-DD` in the front
matter (both languages) so it shows "Updated …" under its title; pages dated after
`params.launched` show a "New" badge for 14 days automatically.

The technical **Change history** page (`content/change-history.md`, linked from What's New)
is built from the commit messages and grouped by release automatically
(`scripts/git-history.mjs`). The footer shows the current version, with `+dev` on builds
that include unreleased changes.

Use `npm run dev` instead of `hugo server` to see the change history and version locally.

The repo's `github-pages` environment must allow deploys from `v*` tags (Settings →
Environments → github-pages → Deployment branches and tags).
