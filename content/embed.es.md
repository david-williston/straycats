---
title: "Agrega la tarjeta de Stray Cats a tu sitio"
slug: "incrustar"
summary: "Una tarjeta pequeña y gratuita que enlaza tu sitio web con el proyecto Stray Cats. Pega dos líneas de HTML y se mantiene actualizada sola."
ShowToc: true
ShowReadingTime: false
ShowPostNavLinks: false
comments: false
updated: 2026-11-05
---

Si tienes una clínica, un refugio o un grupo de rescate y quieres mostrar que apoyas a los gatos, puedes
agregar una pequeña **tarjeta de Stray Cats** a tu sitio web. Funciona en cualquier sitio (WordPress, Wix,
Squarespace, Hugo o HTML simple), no cuesta nada y nunca tienes que actualizarla: cuando cambia el texto
o el logo del proyecto, tu tarjeta cambia también.

![El logo de Stray Cats](../../images/straycats-card-logo.webp "El logo de Stray Cats que aparece en la tarjeta: un gato gris de pecho blanco descansando frente a un atardecer.")

## Qué es

La tarjeta es un pequeño fragmento de código que muestra el logo de Stray Cats, una descripción de una
frase y un enlace a este sitio. No usa cookies, no rastrea a tus visitantes y no carga nada más que el
texto de la tarjeta y el logo desde este sitio. Si no puede cargar, tus visitantes siguen viendo un
enlace sencillo.

## Copiar y pegar

Pega esto donde quieras que aparezca la tarjeta (un pie de página, la página "Acerca de", una barra
lateral):

```html
<straycats-card lang="es">
  <a href="https://straycats.love/es/">Proyecto Stray Cats</a>
</straycats-card>
<script src="https://straycats.love/card.js" async></script>
```

Para una versión más pequeña de una sola línea, ideal para el pie de página:

```html
<straycats-card lang="es" variant="compact">
  <a href="https://straycats.love/es/">Proyecto Stray Cats</a>
</straycats-card>
<script src="https://straycats.love/card.js" async></script>
```

Para teléfonos y columnas angostas hay una versión mediana, con el logo junto a una descripción corta:

```html
<straycats-card lang="es" variant="medium">
  <a href="https://straycats.love/es/">Proyecto Stray Cats</a>
</straycats-card>
<script src="https://straycats.love/card.js" async></script>
```

La línea dentro de la etiqueta es una red de seguridad: es lo que ven los visitantes si su navegador
bloquea los scripts, y se reemplaza por la tarjeta en cuanto esta carga. Puedes pegar la línea
`<script>` más de una vez, o usar varias tarjetas en una página; sigue funcionando.

## Opciones

Agrégalas a la etiqueta `<straycats-card>`, por ejemplo `<straycats-card lang="es" variant="compact">`.

| Opción | Valores | Predeterminado |
|---|---|---|
| `lang` | `en` o `es` | el idioma de tu página, o `en` |
| `variant` | `card` (logo, descripción y enlace), `medium` (más pequeña, siempre en horizontal, pensada para teléfonos y columnas angostas) o `compact` (una línea) | `card` |
| `theme` | `light`, `dark` o `auto` (sigue el dispositivo del visitante) | `auto` |

## Combina los colores

La tarjeta trae colores claros y oscuros razonables. Para que combine con tu sitio, define cualquiera de
estos en tu CSS:

```css
straycats-card {
  --straycats-bg: #ffffff;       /* fondo de la tarjeta */
  --straycats-border: #e3d9cc;   /* borde */
  --straycats-text: #2b2623;     /* texto */
  --straycats-accent: #8a4b12;   /* color del enlace */
}
```

Procura que el color del enlace sea lo bastante oscuro (o claro sobre fondo oscuro) para leerse con
facilidad. El logo va siempre sobre su propio fondo crema, así que se ve bien con cualquier fondo.

## ¿Usas Hugo?

Guarda esto como `layouts/_partials/straycats-card.html` (o `layouts/partials/` en versiones anteriores
de Hugo):

```go-html-template
<straycats-card lang="{{ site.Language.Lang }}">
  <a href="https://straycats.love/es/">Proyecto Stray Cats</a>
</straycats-card>
<script src="https://straycats.love/card.js" async></script>
```

Luego agrega una línea donde deba aparecer la tarjeta, por ejemplo en la plantilla del pie de página:

```go-html-template
{{ partial "straycats-card.html" . }}
```

## Preguntas

Si algo no se ve bien, o quieres otro aspecto, [escríbeme](/involve/). Gracias por ayudar a que más
personas conozcan a los gatos que nadie tiene.
