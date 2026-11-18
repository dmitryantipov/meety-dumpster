// 8-bit pixel font (lowercase subset) → 2D. 8-row cell: row 0 ascender, rows 1-5 x-height, rows 6-7 descender.
// Glyphs use only edge-connected pixels (no diagonal-only joints → manifold, printable).

px_glyphs = [
    ["m", ["     ", "XXXXX", "X X X", "X X X", "X X X", "X X X", "     ", "     "]],
    ["e", ["    ",  "XXXX",  "X  X",  "XXXX",  "X   ",  "XXXX",  "    ",  "    "]],
    ["t", [" X ",   "XXX",   " X ",   " X ",   " X ",   " XX",   "   ",   "   "]],
    ["y", ["    ",  "X  X",  "X  X",  "X  X",  "X  X",  "XXXX",  "   X",  "XXXX"]],
];

function px_glyph(ch) = px_glyphs[search([ch], [for (g = px_glyphs) g[0]])[0]][1];
function px_w(ch) = len(px_glyph(ch)[0]);
function px_adv(s, i) = i == 0 ? 0 : px_adv(s, i - 1) + px_w(s[i - 1]) + 1;
function px_width(s) = px_adv(s, len(s)) - 1;

// centred on the origin: x along the text, y up
module pixel_text(s, p) {
    W = px_width(s);
    for (i = [0 : len(s) - 1]) let(g = px_glyph(s[i]), x0 = px_adv(s, i))
        for (r = [0 : 7], c = [0 : len(g[r]) - 1])
            if (g[r][c] == "X")
                translate([(x0 + c - W / 2) * p, (3 - r) * p]) square(p);
}
