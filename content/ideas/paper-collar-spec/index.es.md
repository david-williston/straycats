---
title: "El collar de papel: una primera especificación"
slug: "especificacion-del-collar-de-papel"
date: 2026-11-20
weight: 521
tags: ["perdidos-y-encontrados", "seguridad", "comunidad"]
summary: "SC-PC-001 Rev A, un borrador de especificación de fabricación de un collar de papel ya hecho: cuatro tallas, un punto débil que cede primero, un trinquete de un solo sentido y una etiqueta NFC que solo guarda un ID. Redactada con IA para abrir la conversación, y probablemente equivocada en muchas cosas."
question: "¿Valdría la pena fabricar un collar así, y qué te gustaría ver probado primero?"
updated: 2026-11-20
cover:
  image: "collar-render.jpg"
  alt: "Una imagen de un collar de papel para gatos en forma de anillo, con un lado crema estampado con gatos naranjas y grises, flores rosas y hojas verdes y amarillas, y un interior verde azulado con huellas crema. Una pequeña cápsula NFC crema con un símbolo de señal está al frente, una hebilla de trinquete blanca está a la derecha, una fila de pequeñas perforaciones está a la izquierda, y hay gotas de agua sobre el papel"
  caption: "Imagen de concepto, no es un producto real."
---

Quien se encuentra con un gato callejero a veces le pone un [collar de papel](/es/ideas/collar-de-papel/)
con su teléfono, para que el dueño o la próxima persona que vea al gato pueda contactarle.
Quiero llevar esa idea más lejos: una especificación abierta y mundial para collares de gato que
cualquiera pueda fabricar, desde una tira barata y desechable para un callejero hasta un collar
duradero para tu propio gato, para que cualquiera pueda identificar a un gato perdido, herido o
que ha muerto.

Este primer borrador se escribió con IA y probablemente está equivocado en muchas cosas. Es a
propósito: está aquí para abrir la conversación. Si sabes de papel, de etiquetas NFC, de
collares o de gatos, cuéntame qué está mal.

Puedes leerlo abajo, o escuchar primero.

## Escucha el debate

Dos voces generadas por IA discuten los detalles de esta especificación, cada una desde un
lado. Lo hice con NotebookLM de Google a partir de esta página. Igual que la especificación, puede
equivocarse, pero es una buena entrada a las preguntas. El audio está en inglés.

{{< listen src="debate-en.m4a" title="*Standardizing Smart Breakaway Cat Collars*, un debate generado por IA sobre los detalles de esta especificación (en inglés, unos 19 minutos)" >}}

## La especificación

**SC-PC-001 Rev A, borrador, 20 nov 2026.** Esto es una idea en borrador, no un producto. Todas
las cifras y números son objetivos de diseño o suposiciones por probar, salvo que se indique que
tienen fuente. Nada se ha construido ni probado.

*Un newton (N) es una unidad de fuerza. Un newton equivale más o menos al peso de 100 g, así que 10 N son aproximadamente el peso de una bolsa de 1 kg de azúcar.*

Ideas relacionadas:
[El collar de papel](/es/ideas/collar-de-papel/),
[¿Y si todos los gatos pudieran llevar una identidad abierta?](/es/ideas/identidad-abierta-del-gato/),
[Cuando un gato desaparece](/es/ideas/cuando-un-gato-desaparece/),
[¿Callejero, mascota o algo intermedio?](/es/ideas/callejero-o-mascota/),
[Que la ayuda sea más fácil de encontrar que el abandono](/es/ideas/que-la-ayuda-sea-mas-facil-de-encontrar-que-el-abandono/) y
[Privacidad y seguridad de los animales](/es/ideas/privacidad-y-seguridad/).

## 1. Propósito

Un collar de papel barato, atractivo, reversible y resistente al agua, que sirva desde gatitos
hasta gatos grandes. Debe romperse de forma segura, aguantar el uso normal y llevar una etiqueta
NFC que guarde solo un identificador. Sigue la [idea de la identidad abierta](/es/ideas/identidad-abierta-del-gato/):
el collar lleva un ID, no datos personales.

## 2. Requisitos

| # | Requisito | Objetivo |
|---|---|---|
| R1 | Cierre de seguridad | Cede con una carga de tracción definida por talla (sección 5) |
| R2 | Durabilidad | 30 días de uso nominal al aire libre (objetivo de diseño) |
| R3 | Identificación | Etiqueta NFC (NTAG213) más URL corta impresa y código QR |
| R4 | Resistencia al agua | Aguanta lluvia y acicalamiento, conserva al menos el 50% de su resistencia en seco tras 24 h sumergido (objetivo) |
| R5 | Comodidad | Tira de 8 a 14 mm de ancho, 0,24 mm de grosor lejos de la cápsula |
| R6 | Cierre | Trinquete de un solo sentido, sin cinta, sin adhesivo contra el pelo |
| R7 | Reversible | Estampado en el lado A, ID en el lado B, ambos terminados |
| R8 | Costo | Objetivo de 0,50 US$ o menos por unidad en volumen, con la etiqueta incluida |
| R9 | Ajuste | Cuatro tallas, de gatito a grande, cuello de 12 a 32 cm |

## 3. Tallas

{{< photo src="fig1-plan-view.svg" alt="Vista en planta del collar de papel, talla M. Una tira horizontal de 335 mm con una cabeza de trinquete (ranura y gatillo) a la izquierda, un punto débil de perforación calibrada, una cápsula NFC con un inlay de 12 por 19 mm, y una zona de dientes con paso de 3 mm y una cola afilada a la derecha. Las medidas indicadas son 24 mm de cabeza, 12 mm de ancho de tira, 26 mm de cápsula y 50 mm de zona de dientes." caption="Fig. 1: Vista en planta, talla M, dibujada a escala. Todas las medidas en mm. Dibujo de concepto, no es un producto real. (Etiquetas en inglés.)" >}}

La circunferencia cerrada es el cuello más 20 mm para gatitos y el cuello más 30 mm para adultos,
de modo que quepa un dedo debajo. El trinquete se ajusta en un rango de 60 mm. El largo de la
tira es la cabeza de 24 mm, más la circunferencia máxima, más 10 mm de margen para recortar. Los
rangos de cuello siguen las tablas de tallas de collares para gatos del mercado (ver Fuentes).

| Talla | Cuello (cm) | Circunf. cerrada (cm) | Ancho de tira | Largo de tira |
|---|---|---|---|---|
| K gatito | 12 a 18 | 14 a 20 | 8 mm | 235 mm |
| S pequeño | 16 a 22 | 19 a 25 | 10 mm | 285 mm |
| M mediano | 21 a 27 | 24 a 30 | 12 mm | 335 mm |
| L grande | 26 a 32 | 29 a 35 | 14 mm | 385 mm |

La cápsula NFC mide 14 mm de ancho por 26 mm de largo en todas las tallas. En K, S y M la tira se
ensancha localmente en la cápsula.

## 4. Materiales (base)

- Papel de cara: papel sin pasta mecánica de 90 a 100 g/m², unos 100 µm por capa, con la fibra en el sentido de la tira.
- Barrera: recubrimiento al agua en las dos caras exteriores, unos 10 µm cada uno.
- Núcleo: rieles de adhesivo en los bordes, unos 20 µm, más el inlay NFC.
- Tintas: al agua, no tóxicas, sin pigmentos metálicos ni de metales pesados.
- Alternativa por probar: papel sintético recubierto (con base de película). El [artículo del collar de papel](/es/ideas/collar-de-papel/) descarta el Tyvek porque está hecho para resistir el rasgado.

{{< photo src="exploded-layers.jpg" alt="Una imagen en despiece de un collar de papel reversible para gatos. Pequeños anillos cerrados a la izquierda muestran el lado estampado y el lado liso. A la derecha, de arriba abajo: una tira de papel estampado con un gato azul y hojas, una capa transparente resistente al agua, un inlay NFC con una antena dorada flotando sobre una bandeja poco profunda, una tira base de papel liso con dientes de trinquete, una ranura y perforaciones, y dos tiras finas de borde. Cuatro detalles abajo muestran las capas laminadas, el inlay y la bandeja, los dientes y la ranura, y la cola perforada" caption="Imagen de concepto de las capas, no es un producto real. Muestra la idea, no los materiales ni los grosores exactos de esta especificación." >}}

{{< photo src="fig2-pod-section.svg" alt="Sección de la cápsula NFC. Cinco capas de arriba abajo: un recubrimiento barrera contra el agua de unos 10 µm, papel de cara A impreso de unos 100 µm, una capa de núcleo de unos 160 µm con los rieles de adhesivo y un inlay NFC flotante, papel de cara B impreso de unos 100 µm, y un segundo recubrimiento barrera de unos 10 µm. Dos huecos de 2 mm marcan la holgura entre el inlay y los rieles de adhesivo." caption="Fig. 2: Sección de la cápsula NFC. Grosor exagerado. El inlay no está pegado dentro de la holgura. Dibujo de concepto, no es un producto real. (Etiquetas en inglés.)" >}}

Grosor: unos 0,24 mm a lo largo de la tira y unos 0,38 mm en la cápsula. Las esquinas son
redondeadas con R1,5 mm o más.

## 5. Mecánica y física

**Jerarquía de fallo.** El punto débil debe fallar primero, luego el trinquete y por último el
cuerpo de la tira.

{{< photo src="fig3-force-targets.svg" alt="Objetivos de fuerza de liberación por talla. Para gatito, pequeño, mediano y grande, una ventana de liberación en newtons (nominal, más o menos 25%) queda muy por debajo de la fuerza que aguanta el trinquete y mucho más por debajo del peso del gato. Una línea de referencia a 20 N marca una hebilla de seguridad típica de tienda (4,5 lb)." caption="Fig. 3: Ventanas de liberación, resistencia del trinquete y peso del gato por talla. Objetivos de diseño, no valores medidos. (Etiquetas en inglés.)" >}}

| Talla | Liberación (nominal) | El trinquete aguanta al menos | Cuerpo de la tira, al menos | Peso del gato | Liberación como % del peso |
|---|---|---|---|---|---|
| K | 6 N (1,3 lb) | 9 N | 12 N | 1 kg = 9,8 N | 61% |
| S | 10 N (2,2 lb) | 15 N | 20 N | 3 kg = 29 N | 34% |
| M | 15 N (3,4 lb) | 22 N | 30 N | 5 kg = 49 N | 31% |
| L | 20 N (4,5 lb) | 30 N | 40 N | 7 kg = 69 N | 29% |

La tolerancia de liberación es de ±25%. A modo de comparación, una hebilla de seguridad común de
tienda cede a unas 4,5 lb (20 N), y las fuentes citan entre 2 y 5 lb en general.

**Dimensionado del punto débil.** La tensión de la tira es la misma en toda su longitud, así que
la sección más estrecha fija la carga de rotura. Ancho neto = fuerza de liberación ÷ resistencia
a la tracción del papel por mm. Suposición: 4 N por mm de ancho para papel de 90 a 100 g/m² en el
sentido de la fibra. Esto hay que medirlo.

| Talla | Liberación | Ancho neto en el punto débil | Parte del ancho de la tira |
|---|---|---|---|
| K | 6 N | 1,5 mm | 19% |
| S | 10 N | 2,5 mm | 25% |
| M | 15 N | 3,75 mm | 31% |
| L | 20 N | 5,0 mm | 36% |

Una tira lisa de 12 mm aguantaría unos 48 N con esa resistencia, unas tres veces el objetivo de
la M. Por eso la tira necesita un punto débil diseñado: una zona de 12 mm con puentes de
perforación. La geometría final saldrá de las pruebas de tracción.

**Trinquete.** Una zona de dientes troquelada en la cola (paso de 3 mm, 50 mm de largo) encaja en
una ranura y un gatillo en la cabeza, como una brida de plástico. Es de un solo sentido y no se
puede aflojar una vez cerrado, así que para quitarlo se corta la tira con tijeras.

**Caso del gato colgado.** Si un gato queda colgado del collar, la carga es igual a su peso
corporal. Una liberación al 29 a 34% del peso en S, M y L significa que el collar se abre mucho
antes de que la carga sea peligrosa.

## 6. NFC

- Chip: NXP NTAG213, 144 bytes de memoria de usuario, ISO 14443A, 13,56 MHz.
- Inlay práctico más pequeño: antena de 10 x 17 mm, troquelado de unos 12 x 19 mm, 157 µm de grosor, con cara de PET e impermeable a la lluvia y las salpicaduras (con fuente). Un inlay redondo es mucho más grande (antena de 16 mm como mínimo), así que uno rectangular cabe en una tira estrecha.
- Contenido: una URL NDEF corta, por ejemplo straycats.love/c/ más un ID de 8 caracteres. Cabe de sobra en 144 bytes. Bloquear la etiqueta después de escribirla.
- Respaldo impreso en el lado B: URL corta y un código QR de al menos 12 x 12 mm, para que funcione también con móviles sin NFC.

**Límite de carga del inlay.** La hoja de datos del inlay indica un diámetro de curvatura de más
de 50 mm y una tensión de menos de 10 N. Las fuerzas de liberación de M y L (15 y 20 N) superan
los 10 N, así que el inlay no debe soportar carga de la tira. Por eso la Fig. 2 tiene un hueco
flotante: el inlay no está pegado a menos de 2 mm de los rieles de adhesivo, y las capas de papel
llevan la carga alrededor de él.

## 7. Impresión y diseño

- Lado A: biblioteca de estampados con muchos diseños para todas las edades y culturas. Lado B: lado de ID con QR, URL corta y un espacio para una línea de contacto.
- Las hojas se troquelan y se perforan, y se venden en paquetes con varios repuestos, porque los gatos pierden los collares.

## 8. Reglas de seguridad

- Solo para gatos amistosos que se dejan manipular.
- Ajuste: unos dos dedos (uno para gatitos) debajo del collar.
- Recortar la cola a 10 mm o menos después de ajustarlo.
- Revisar el ajuste y el cuello del gato con regularidad. Los cuellos de los gatitos crecen, así que hay que reajustarlos a menudo.
- Quitarlo de inmediato si el gato se rasca por el collar o si el papel está mojado e hinchado.

## 9. Plan de pruebas

| Prueba | Método | Aprobado si |
|---|---|---|
| Tracción de la tira | ISO 1924-2 en probetas, luego tracción en collares terminados a 100 mm/min | Liberación dentro de ±25% del objetivo |
| Resistencia del trinquete | Tracción en collares cerrados | Al menos el valor de la tabla |
| Agua | Prueba Cobb (ISO 535), 24 h sumergido, luego tracción en mojado | Se conserva al menos el 50% de la resistencia |
| NFC | Prueba de lectura en seco, mojado, doblado y tras 30 días | 100% de lectura en móviles comunes |
| Uso | Prueba de ajuste en gatos reales bajo supervisión | Sin irritación de la piel, sin fallos de liberación |

## 10. Puntos abiertos

1. **Talla de gatito frente al límite de curvatura del inlay.** Un cuello de 12 cm es un diámetro de 38 mm, por debajo del mínimo de curvatura de 50 mm del inlay. Opciones: mantener la cápsula como una placa plana, usar un inlay más pequeño de 8,7 mm (existe un anuncio, rendimiento sin verificar) o dejar la talla de gatito más pequeña sin NFC.
2. **Gatitos de menos de 1 kg.** Una liberación de 6 N es el 61% del peso de un gatito de 1 kg. Los gatitos más ligeros probablemente necesiten unos 4 N, por confirmar con una prueba.
3. **Conflicto con el artículo del collar de papel**, que dice "no para gatitos" y "más suelto es más seguro". Esta especificación incluye gatitos y un ajuste firme con trinquete. O se cambia el artículo, o se cambia la especificación.
4. **La resistencia del papel es una suposición.** Medirla antes de fijar el punto débil.
5. **El tamaño del QR y el alcance de lectura NFC** en una cápsula de 14 mm necesitan pruebas reales con móviles.
6. **Costo.** El inlay NFC solo cuesta unos 0,19 a 0,23 € cada uno en volumen (NTAG213, 12 x 19 mm), así que el objetivo de 0,50 US$ es justo y necesita presupuestos de proveedores.

## Fuentes

- [LupinePet, collar de seguridad para gatos, liberación de ~4,5 lb](https://www.chewy.com/lupinapet-microbatch-limited-edition/dp/3678726)
- [Outdoor Bengal sobre fuerzas de liberación](https://www.outdoorbengal.com/blogs/adventure-cat-training/breakaway-collars)
- [Tabla de tallas de collares para gatos de Cheshire & Wain](https://www.cheshireandwain.com/en-nz/products/custom-personalisation-charge)
- [Guía de tallas de Catlog](https://rabo.cat/en-us/catlog/pendant/belt-size)
- [Inlay Circus Mini de Avery Dennison (antena de 16 mm)](https://rfid.averydennison.com/en/home/product-finder/circus-mini.html)
- [Inlay NFC Midas de Avery Dennison (antena de 10 x 17 mm)](https://rfid.averydennison.com/en/home/product-finder/midas-nfc.html)
- [Inlay NFC húmedo NTAG213 de 12 x 19 mm, grosor, límites de curvatura y precio](https://shopnfc.com/en/nfc-stickers/32-12mm-micro-ntag213-stickers.html)
- [Propiedades del Tyvek](https://www.dupont.com/what-is-tyvek.html)
