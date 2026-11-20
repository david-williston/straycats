---
title: "What If Every Cat Could Carry an Open Identity?"
date: 2026-10-21
weight: 250
tags: ["identity", "open-standard", "tech"]
summary: "An idea for an open standard for cat identification: a collar any phone can scan, with no app needed, on one shared platform that no company controls."
question: "If you found a cat wearing a collar like this, would you scan it, and what would you want to see on the screen?"
updated: 2026-11-20
cover:
  image: "cover.jpg"
  alt: "A tabby-and-white cat looking up, wearing a leaf-patterned paper collar, beside three reversible paper collar designs (leaves, cherry blossom and a starry night), each with a pattern on one side and the StrayCats identification on the other"
  caption: "Concept mockup, not a photo and not a real product: a reversible collar with a pattern for everyday wear on one side and the StrayCats identification on the other."
---

*An idea for a global, open standard for cat identification.*

Millions of cats live among us. Some are beloved pets, some are strays, and many are cared for
by several people who may not even know one another.

When someone finds a cat, identifying it isn't always easy.

Microchips help, but they need a special scanner. Collars and identification tags are easier to
recognize, but they can fall off, become damaged, or contain outdated contact information.

**What if we created an open standard for cat identification that anyone could use?**

## The idea

Imagine a simple, inexpensive, breakaway cat collar containing a tiny NFC tag and a printed
QR code.

Someone finds a cat wearing it and taps the tag with their phone:

- If the StrayCats app is installed, it opens straight in the app.
- If not, it opens a web page. At a glance, it shows whether the cat has been reported missing.
  It lets them contact the caretaker through a relay, never showing contact details. And it
  explains how to get the app.

No app is needed to help.

Depending on what caregivers choose to share, the page might include:

- The cat's name, photograph, and identifying features.
- Whether the cat has a home or lives in the community.
- Important medical information.
- How to contact its owner or caregivers.
- How to report a sighting or a concern.

And here's an interesting possibility: **even if the collar falls off, someone finding it could
scan it and help return it to the cat's caregiver.**

I picture a whole range. At one end, a cheap, disposable paper strip for a stray, to help find its
owner. At the other, a durable collar for your own cat. Either way, anyone could identify a cat
that is lost, injured or has died. I've started a draft of the
[paper collar specification](/ideas/paper-collar-spec/).

You could even buy a sheet of paper collars, program each tag with your phone, then lock it. Tags
can be copied, and that's fine: nobody gains anything by copying a cat's tag. If anything changes
or the collar gets damaged, throw it away and use a new one. That's the point of a cheap collar.

## An open standard, not another proprietary product

The goal wouldn't be for Straycats to become a collar manufacturer.

What the specification standardizes is the device, not the data: a collar carries a standard NFC
tag that any phone can read and write. How the tag is programmed is open. People can program it
however they like.

So anyone could make collars to the spec, at different price points, and they would all work the
same way. Shelters, veterinarians, rescue organizations, and independent developers could build
on it too.

## Why it's open source

StrayCats is open source so anyone can see and verify what it does, and trust it. And so anyone
can contribute and make it better.

It is not open so people can split off their own networks. I want one shared, public platform,
because that's where cats and their caretakers connect. It must never be controlled by a
profit-driven company.

The code is licensed under the
[GNU Affero General Public License v3.0](https://github.com/david-williston/straycats/blob/main/LICENSE)
(AGPL-3.0), which keeps it that way: anyone who changes it and runs it as a service must publish
their changes under the same license.

## What about existing microchips?

Implanted microchips are already established, and there's no reason to replace them. Pet
microchips follow a global standard (ISO 11784/11785). But as far as I know, they work at a low
radio frequency (134.2 kHz), while phone NFC works at 13.56 MHz. So it's a difference in
frequency, not just antenna size, and phones can't read them without an add-on reader.

Chips must be injected by a vet, cost money, and need a special scanner. And the registries are
split across many separate databases. NFC tags are cheap, reliable, standard and flexible. They're
easy to put in a collar, and any smartphone can read them. That's why I think collars should carry
NFC.

We can still link a cat's microchip number to the same record. A veterinarian with a microchip
scanner and a neighbor with a phone could then reach the same identity, subject to appropriate
privacy and access controls.

The important thing is the cat's identity, not the device used to identify it.

## One cat, many caregivers

This idea becomes especially interesting for community cats.

A cat might be known by several names, fed by several households, and occasionally treated by
different veterinarians.

Nobody necessarily owns the cat, yet several people care deeply about its welfare.

Straycats could help bring those relationships together without requiring someone to claim
ownership.

A scan could become the beginning of a connection between people who already care for the same
animal.

## Privacy and safety matter

An identification system should never automatically expose someone's phone number, home
address, or a cat's sensitive location information.

Caregivers should control what information is public and how strangers can contact them.

The physical collar should carry an identifier, not private personal information.

And because cat collars can become caught on objects, any design would need to prioritize
appropriate breakaway safety mechanisms.

## Could this become a global standard?

That's the bigger question.

The technology already exists. NFC tags are inexpensive, QR codes are virtually free to
produce, and smartphones are widely available.

The harder challenge is making it work for everyone: an open specification, trustworthy identity
records, responsible governance, and one shared platform that stays open and keeps working even
if individual businesses disappear.

Perhaps Straycats could help bring manufacturers, software developers, animal welfare
organizations, and caregivers together around that goal.

## What do you think?

This is an early idea, not a finished specification.

I'd particularly love to hear from people working in animal identification, veterinary
medicine, NFC technology, manufacturing, and animal rescue.

Are there existing standards we should build upon? What problems haven't we considered? And
what would make an open identification system genuinely useful for cats and the people who
care for them?

**The goal is simple: make it easier for every cat to be recognized, cared for, and connected
to the people looking out for it.**
