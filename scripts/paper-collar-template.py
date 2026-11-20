#!/usr/bin/env python3
"""Build the printable paper collar templates (4 PDFs, one page each).

Plain Python 3, no packages: it writes the PDF by hand using the standard
Helvetica fonts, which every PDF viewer and printer already has, so the
output prints the same everywhere.

    python3 scripts/paper-collar-template.py

Output goes to content/ideas/paper-collar/. Edit the TEXT dict to change wording.
"""
import os

MM = 72 / 25.4
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "content", "ideas", "paper-collar")

SIZES = {"a4": (297, 210), "letter": (279.4, 215.9)}  # landscape, mm
MARGIN = 10        # mm, so home printers don't clip
STRIP_H = 24       # mm
LH = 3.5           # mm, line spacing of the instructions
OVERLAP = 30       # mm, shaded overlap zone

# QR codes: generated once with the Python `segno` package (error correction M,
# automatic mask) and pasted here, so this script needs no packages. Each string is
# one row of modules, 1 = dark. They point at permanent landing pages: never move them.
QR = {
    "en": dict(url="https://straycats.love/c/", module=0.64, rows=[
        "1111111010101010101111111",
        "1000001011100000101000001",
        "1011101010011100101011101",
        "1011101000010100001011101",
        "1011101010110110101011101",
        "1000001001001010101000001",
        "1111111010101010101111111",
        "0000000000010110100000000",
        "1001111111100011010010111",
        "0000100101010111010111110",
        "0110111100110101101101001",
        "1111010011011010111001111",
        "1001111100111001101000001",
        "1001110001101101110010010",
        "1100101010101011001011111",
        "1000110000001011100101101",
        "1011001100111101111110110",
        "0000000010111000100010110",
        "1111111011110100101010001",
        "1000001011010101100010011",
        "1011101010011001111110000",
        "1011101010111111111000011",
        "1011101001010101110011111",
        "1000001001101011011110111",
        "1111111011011000101001001",
    ]),
    "es": dict(url="https://straycats.love/es/c/", module=0.6, rows=[
        "11111110100001110010101111111",
        "10000010110111110101001000001",
        "10111010110001100001101011101",
        "10111010011000110100101011101",
        "10111010111101010111001011101",
        "10000010000001100100001000001",
        "11111110101010101010101111111",
        "00000000000100100000000000000",
        "10011111101111111101110010111",
        "01001000101010100001010110110",
        "01001010010000100010011010100",
        "01000000110010110101111111001",
        "10100011011111100010101100001",
        "01001000100110000110001111111",
        "00010111111010110101011000101",
        "00011100000011101000010010101",
        "10100110010000010001100001000",
        "10010100000000000111100010110",
        "11000111100101101011111111001",
        "11001001010101011000010111100",
        "11110011101101000110111111110",
        "00000000111001001110100011000",
        "11111110100111011001101011000",
        "10000010111101001100100010001",
        "10111010100101011111111111000",
        "10111010111000101010010100010",
        "10111010011001001011000110111",
        "10000010010010110011011101101",
        "11111110110010000111110111000",
    ]),
}
QUIET = 4          # modules of clear space kept around each code

TEXT = {
    "en": dict(
        title="Paper collar for a friendly stray",
        steps=[
            ["1. Print on plain printer paper, not card. Cut along the dashed lines."],
            ["2. Write your phone number on the strip. Scan the code, or visit straycats.love/c, to learn more.",
             "    If the cat is in the StrayCats app, write its ID on the strip."],
            ["3. Only for a friendly cat you can handle easily. Never a nervous or feral cat, and not for kittens."],
            ["4. Wrap it loosely around the neck: two fingers should slide under it easily."],
            ["5. Overlap the ends and tape them together with one small piece of tape, paper to paper. Never tape the whole collar: plain paper tears if the collar",
             "    snags, but tape stops it tearing. No tape on fur."],
            ["6. Check on the cat, and take the collar off if it bothers them."],
        ],
        question="Is this your cat? Please call me.",
        phone="Phone:", catid="Cat ID:", catid_w=13, tape="tape here",
        footer="Free from straycats.love  ·  Not for kittens or nervous cats",
    ),
    "es": dict(
        title="Collar de papel para un gato callejero amistoso",
        steps=[
            ["1. Imprime en papel normal de impresora, no en cartulina. Recorta por las líneas de puntos."],
            ["2. Escribe tu número de teléfono en la tira. Escanea el código, o visita straycats.love/es/c, para saber más.",
             "    Si el gato está en la app de StrayCats, escribe su ID en la tira."],
            ["3. Solo para un gato amistoso que puedas manipular con facilidad. Nunca para un gato nervioso o feral, ni para gatitos."],
            ["4. Ponlo suelto alrededor del cuello: deben caber dos dedos debajo con facilidad."],
            ["5. Superpone los extremos y pégalos con un solo trocito de cinta, papel con papel. Nunca cubras todo el collar con cinta: el papel normal se rompe si el collar",
             "    se engancha, pero la cinta impide que se rompa. Nada de cinta sobre el pelo."],
            ["6. Revisa al gato y quita el collar si le molesta."],
        ],
        question="¿Es tu gato? Por favor, llámame.",
        phone="Teléfono:", catid="ID del gato:", catid_w=19, tape="cinta aquí",
        footer="Gratis en straycats.love  ·  No para gatitos ni gatos nerviosos",
    ),
}

FILES = [
    ("en", "a4", "paper-collar-template-a4.pdf"),
    ("en", "letter", "paper-collar-template-letter.pdf"),
    ("es", "a4", "plantilla-collar-de-papel-a4.pdf"),
    ("es", "letter", "plantilla-collar-de-papel-carta.pdf"),
]


def esc(s):
    b = s.encode("cp1252")
    return b.replace(b"\\", b"\\\\").replace(b"(", b"\\(").replace(b")", b"\\)")


class Page:
    def __init__(self):
        self.ops = []

    def raw(self, s):
        self.ops.append(s.encode() if isinstance(s, str) else s)

    def text(self, x, y, s, size, bold=False, gray=0):
        self.ops.append(f"BT /{'F2' if bold else 'F1'} {size} Tf {gray} g {x*MM:.2f} {y*MM:.2f} Td (".encode()
                        + esc(s) + b") Tj ET")

    def line(self, x1, y1, x2, y2, w=0.6, dash=None, gray=0):
        d = f"[{dash[0]*MM:.2f} {dash[1]*MM:.2f}] 0 d" if dash else "[] 0 d"
        self.raw(f"q {gray} G {w} w {d} {x1*MM:.2f} {y1*MM:.2f} m {x2*MM:.2f} {y2*MM:.2f} l S Q")

    def rect_fill(self, x, y, w, h, gray):
        self.raw(f"q {gray} g {x*MM:.2f} {y*MM:.2f} {w*MM:.2f} {h*MM:.2f} re f Q")

    def circle(self, cx, cy, r, fill=True, w=0.8):
        k = 0.5523 * r
        pts = [(cx + r, cy), (cx + r, cy + k, cx + k, cy + r, cx, cy + r),
               (cx - k, cy + r, cx - r, cy + k, cx - r, cy),
               (cx - r, cy - k, cx - k, cy - r, cx, cy - r),
               (cx + k, cy - r, cx + r, cy - k, cx + r, cy)]
        s = f"{pts[0][0]*MM:.2f} {pts[0][1]*MM:.2f} m "
        for p in pts[1:]:
            s += " ".join(f"{v*MM:.2f}" for v in p) + " c "
        self.raw(f"q 0 g 0 G {w} w {s} {'f' if fill else 'S'} Q")

    def paw(self, cx, cy, s=1.0):
        self.circle(cx, cy, 1.9 * s)                        # pad
        for dx, dy in [(-2.6, 2.6), (-0.9, 3.7), (0.9, 3.7), (2.6, 2.6)]:
            self.circle(cx + dx * s, cy + dy * s, 0.8 * s)  # toes

    def qr(self, x, y, rows, m):
        # dark modules as vector squares, merged into horizontal runs; (x, y) = top-left
        n = len(rows)
        for r, row in enumerate(rows):
            c = 0
            while c < n:
                if row[c] == "1":
                    c2 = c
                    while c2 < n and row[c2] == "1":
                        c2 += 1
                    self.raw(f"0 g {(x + c*m)*MM:.3f} {(y - (r+1)*m)*MM:.3f} {(c2-c)*m*MM:.3f} {m*MM:.3f} re f")
                    c = c2
                else:
                    c += 1

    def scissors(self, x, y):
        # small vector scissors pointing right, centred on (x, y)
        self.circle(x, y + 1.1, 0.9, fill=False, w=0.6)
        self.circle(x, y - 1.1, 0.9, fill=False, w=0.6)
        self.line(x + 0.8, y + 0.6, x + 5, y - 0.9, w=0.6)
        self.line(x + 0.8, y - 0.6, x + 5, y + 0.9, w=0.6)


def build(lang, size):
    t = TEXT[lang]
    q = QR[lang]
    W, H = SIZES[size]
    p = Page()
    p.rect_fill(0, 0, W, H, 1)  # white page, so previews aren't transparent
    left, right = MARGIN, W - MARGIN
    L = right - left

    y = H - MARGIN - 5
    p.text(left, y, t["title"], 16, bold=True)
    p.paw(right - 4, y + 0.5, 1.0)
    y -= 6
    for step in t["steps"]:
        for ln in step:
            p.text(left, y, ln, 9)
            y -= LH
    top = y + LH - 3          # top edge of first strip
    bottom_limit = MARGIN + 6    # room for footer
    n = int((top - bottom_limit) // STRIP_H)
    p.text(left, MARGIN, t["footer"], 8, gray=0.3)

    for i in range(n):
        ytop = top - i * STRIP_H
        ybot = ytop - STRIP_H
        # shaded overlap zone at the right end
        p.rect_fill(right - OVERLAP, ybot, OVERLAP, STRIP_H, 0.9)
        p.line(right - OVERLAP, ybot, right - OVERLAP, ytop, w=0.4, gray=0.5)
        p.text(right - OVERLAP + 7, ybot + STRIP_H / 2 - 1, t["tape"], 7, gray=0.35)
        # content
        x = left + 5
        p.text(x, ytop - 10, t["question"], 15, bold=True)
        p.text(x, ytop - 19, t["phone"], 8, gray=0.3)
        p.line(x + 17, ytop - 19, x + 17 + 55, ytop - 19, w=0.7)
        cx = x + 80
        p.text(cx, ytop - 19, t["catid"], 8, gray=0.3)
        p.line(cx + t["catid_w"], ytop - 19, cx + t["catid_w"] + 38, ytop - 19, w=0.7)
        p.text(x + 142, ytop - 19, "straycats.love", 11, bold=True)
        p.paw(x + 177, ytop - 19.5, 0.9)
        # QR code, vertically centred, just left of the tape zone (which stays clear)
        rows, m = q["rows"], q["module"]
        size = len(rows) * m
        qx = right - OVERLAP - QUIET * m - size
        p.qr(qx, ytop - (STRIP_H - size) / 2, rows, m)
    # dashed cut lines (n + 1), with scissors at the left end
    for i in range(n + 1):
        yy = top - i * STRIP_H
        p.line(left + 8, yy, right, yy, w=0.6, dash=(2, 1.6))
        p.scissors(left + 1.2, yy)
    return W, H, b"\n".join(p.ops), n


def write_pdf(path, W, H, stream):
    objs = [
        b"<< /Type /Catalog /Pages 2 0 R >>",
        b"<< /Type /Pages /Kids [3 0 R] /Count 1 >>",
        f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {W*MM:.2f} {H*MM:.2f}] "
        f"/Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> /Contents 4 0 R >>".encode(),
        b"<< /Length %d >>\nstream\n" % len(stream) + stream + b"\nendstream",
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>",
        b"<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>",
    ]
    out = bytearray(b"%PDF-1.4\n")
    offs = []
    for i, o in enumerate(objs, 1):
        offs.append(len(out))
        out += f"{i} 0 obj\n".encode() + o + b"\nendobj\n"
    xref = len(out)
    out += f"xref\n0 {len(objs)+1}\n0000000000 65535 f \n".encode()
    for o in offs:
        out += f"{o:010d} 00000 n \n".encode()
    out += f"trailer\n<< /Size {len(objs)+1} /Root 1 0 R >>\nstartxref\n{xref}\n%%EOF\n".encode()
    with open(path, "wb") as f:
        f.write(out)


if __name__ == "__main__":
    for lang, size, name in FILES:
        W, H, stream, n = build(lang, size)
        write_pdf(os.path.join(OUT, name), W, H, stream)
        print(f"{name}: {n} strips, {W - 2*MARGIN:.0f} x {STRIP_H} mm")
