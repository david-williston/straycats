---
title: "¿Y si todos los gatos pudieran llevar una identidad abierta?"
slug: "identidad-abierta-del-gato"
date: 2026-10-21
weight: 250
tags: ["identidad", "estandar-abierto", "tecnologia"]
summary: "Una idea para un estándar abierto de identificación de gatos: un collar que cualquier teléfono puede escanear, sin necesidad de app, en una plataforma compartida que ninguna empresa controla."
question: "Si encontraras a un gato con un collar así, ¿lo escanearías, y qué te gustaría ver en la pantalla?"
updated: 2026-11-20
cover:
  image: "cover.jpg"
  alt: "Un gato atigrado y blanco que mira hacia arriba, con un collar de papel estampado de hojas, junto a tres diseños de collar de papel reversible (hojas, flores de cerezo y una noche estrellada), cada uno con un estampado por un lado y la identificación de StrayCats por el otro"
  caption: "Imagen de concepto, no es una foto ni un producto real: un collar reversible con un estampado para el uso diario por un lado y la identificación de StrayCats por el otro."
---

*Una idea para un estándar abierto y global de identificación de gatos.*

Millones de gatos viven entre nosotros. Algunos son queridas mascotas, otros son callejeros, y
de muchos se ocupan varias personas que quizá ni se conocen entre sí.

Cuando alguien encuentra un gato, identificarlo no siempre es fácil.

Los microchips ayudan, pero hace falta un escáner especial. Los collares y las chapas de
identificación son más fáciles de reconocer, pero pueden caerse, estropearse o tener datos de
contacto desactualizados.

**¿Y si creáramos un estándar abierto de identificación de gatos que cualquiera pudiera
usar?**

## La idea

Imagina un collar sencillo, económico y con cierre de seguridad (que se suelta si se
engancha), con una diminuta etiqueta NFC y un código QR impreso.

Alguien encuentra a un gato con ese collar y acerca el teléfono a la etiqueta:

- Si tiene instalada la app de StrayCats, se abre directamente en la app.
- Si no, se abre una página web. De un vistazo muestra si el gato fue reportado como perdido.
  Permite contactar al cuidador a través de un intermediario, sin mostrar nunca sus datos de
  contacto. Y explica cómo conseguir la app.

Para ayudar no hace falta ninguna app.

Según lo que los cuidadores decidan compartir, la página podría incluir:

- El nombre del gato, su fotografía y sus rasgos distintivos.
- Si tiene hogar o vive en la comunidad.
- Información médica importante.
- Cómo contactar a su dueño o a sus cuidadores.
- Cómo informar de un avistamiento o de una preocupación.

Y hay una posibilidad interesante: **aunque el collar se caiga, quien lo encuentre podría
escanearlo y ayudar a devolverlo al cuidador del gato.**

Me imagino toda una gama. En un extremo, una tira de papel barata y desechable para un gato
callejero, para ayudar a encontrar a su dueño. En el otro, un collar resistente para tu propio
gato. En ambos casos, cualquiera podría identificar a un gato que se perdió, está herido o ha
muerto. Ya empecé un borrador de la
[especificación del collar de papel](/es/ideas/especificacion-del-collar-de-papel/).

Incluso podrías comprar una hoja de collares de papel, programar cada etiqueta con tu teléfono y
luego bloquearla. Las etiquetas se pueden copiar, y no pasa nada: nadie gana nada copiando la
etiqueta de un gato. Si algo cambia o el collar se estropea, lo tiras y usas uno nuevo. Para eso
es un collar barato.

## Un estándar abierto, no otro producto propietario

El objetivo no sería que Straycats se convierta en fabricante de collares.

Lo que la especificación estandariza es el dispositivo, no los datos: un collar lleva una
etiqueta NFC estándar que cualquier teléfono puede leer y escribir. Cómo se programa la etiqueta
es abierto. Cada quien puede programarla como quiera.

Así, cualquiera podría fabricar collares según la especificación, a distintos precios, y todos
funcionarían igual. Los refugios, los veterinarios, las organizaciones de rescate y los
desarrolladores independientes también podrían construir sobre ella.

## Por qué es código abierto

StrayCats es de código abierto para que cualquiera pueda ver y comprobar qué hace, y confiar en
ello. Y para que cualquiera pueda colaborar y mejorarlo.

No es abierto para que la gente cree sus propias redes por separado. Quiero una plataforma
pública y compartida, porque ahí es donde los gatos y sus cuidadores se encuentran. Nunca debe
estar controlada por una empresa que busque lucro.

El código tiene la licencia
[GNU Affero General Public License v3.0](https://github.com/david-williston/straycats/blob/main/LICENSE)
(AGPL-3.0), que lo mantiene así: quien lo modifique y lo ofrezca como servicio debe publicar sus
cambios bajo la misma licencia.

## ¿Y los microchips que ya existen?

Los microchips implantados ya están consolidados, y no hay razón para reemplazarlos. Los de las
mascotas siguen un estándar global (ISO 11784/11785). Pero, hasta donde sé, funcionan con una
radiofrecuencia baja (134,2 kHz), mientras que el NFC de los teléfonos funciona a 13,56 MHz. Es
una diferencia de frecuencia, no solo de tamaño de antena, y los teléfonos no pueden leerlos sin
un lector adicional.

Además, un veterinario tiene que inyectar el chip, cuesta dinero y hace falta un escáner
especial. Y los registros están repartidos en muchas bases de datos separadas. Las etiquetas NFC
son baratas, fiables, estándar y flexibles. Son fáciles de poner en un collar y cualquier
teléfono las lee. Por eso creo que los collares deberían llevar NFC.

Aun así, podemos vincular el número de microchip de un gato con el mismo registro. Un veterinario
con un escáner de microchips y una vecina con un teléfono podrían llegar a la misma identidad,
con los controles de privacidad y acceso adecuados.

Lo importante es la identidad del gato, no el dispositivo con el que se identifica.

## Un gato, muchos cuidadores

Esta idea se vuelve especialmente interesante para los gatos comunitarios.

Un gato puede ser conocido por varios nombres, comer en varias casas y ser atendido de vez en
cuando por distintos veterinarios.

Puede que nadie sea su dueño, y sin embargo varias personas se preocupan profundamente por su
bienestar.

Straycats podría ayudar a unir esas relaciones sin que nadie tenga que reclamar la propiedad.

Un escaneo podría ser el comienzo de una conexión entre personas que ya cuidan al mismo animal.

## La privacidad y la seguridad importan

Un sistema de identificación nunca debería exponer automáticamente el teléfono de alguien, su
domicilio ni datos sensibles sobre dónde está un gato.

Los cuidadores deberían controlar qué información es pública y cómo pueden contactarlos los
desconocidos.

El collar físico debería llevar un identificador, no datos personales privados.

Y como los collares pueden engancharse en objetos, cualquier diseño tendría que dar prioridad a
mecanismos de seguridad que lo suelten cuando haga falta.

## ¿Podría convertirse en un estándar global?

Esa es la pregunta de fondo.

La tecnología ya existe. Las etiquetas NFC son baratas, los códigos QR casi no cuestan nada de
producir y los teléfonos inteligentes están muy extendidos.

El desafío mayor es que funcione para todos: una especificación abierta, registros de identidad
confiables, una gobernanza responsable y una plataforma compartida que siga abierta y funcionando
aunque desaparezcan empresas concretas.

Quizá Straycats podría ayudar a reunir a fabricantes, desarrolladores, organizaciones de
bienestar animal y cuidadores en torno a ese objetivo.

## ¿Qué opinas?

Esta es una idea inicial, no una especificación terminada.

Me encantaría saber de quienes trabajan en identificación animal, medicina veterinaria,
tecnología NFC, fabricación y rescate animal.

¿Hay estándares existentes sobre los que deberíamos construir? ¿Qué problemas no hemos
considerado? ¿Y qué haría que un sistema abierto de identificación sea realmente útil para los
gatos y para las personas que los cuidan?

**El objetivo es simple: que sea más fácil que cada gato sea reconocido, cuidado y conectado
con las personas que velan por él.**
