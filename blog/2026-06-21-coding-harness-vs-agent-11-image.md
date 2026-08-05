# Image brief: coding-harness-vs-agent-11

Generate a raster PNG, ~1600x900 (16:9), then convert to .webp under ~150KB. Not an SVG.

## Brand style
Muted, calm palette with a single warm accent (deep red). Generous negative space. Subtle grain,
soft directional light. Flat-ish with light depth, no glossy 3D render, no neon, no circuitry, no
matrix-code, no robots, no AI cliches. Old-craft / workshop feel, not futuristic. Quiet, slightly
wry mood. Bottom-right corner left quiet for a small star mark. 16:9.

Note: this is the second post in a pair. Keep the same world and palette as the first image
(`loops-hype-vs-real-engineering`): same workshop, same wood tones, the same wax-sealed instrument
reappears so the two images read as a set.

## Scene (the post's metaphor: a harness vs a workshop)
A single composition split by emphasis, left to right, three-quarter or top-down view of a workbench.

On the LEFT, the "harness": one lone metal clamp or jig bolted to the bench, gripping a single tool
(a chisel or a drill bit). That is all it does. It holds one worker and nothing else. Bare, minimal,
a bit lonely. This is the thin scaffolding around a model.

On the RIGHT, "the squad": a deliberately organised tool wall or peg-board, a row of distinct
specialist tools (saw, plane, square, gauge, files, mallet) each hung in its own place, clearly
arranged in working order, not a jumble. It reads as a team with roles. Set into this organised wall,
the verifier from the first image returns: a small brass gauge or balance under a glass cloche with an
intact deep-red wax seal. The seal is the single warm accent. The work hangs all around it; the verdict
sits sealed among the tools, untouchable.

The eye should read: on the left, a clamp that just holds one tool; on the right, a whole organised
workshop with a sealed verdict built into it. The contrast is the point. A harness holds the worker.
The workshop decides how the work gets done, and keeps a verdict the workers cannot fudge. No figures,
no hands, no faces.

## Brand mark
Place the brand star mark small in the bottom-right corner. If the model cannot render the exact mark,
leave the bottom-right corner clean and uncluttered so the star can be composited in afterwards.

## Alt text (add to frontmatter as imageAlt)
On the left, a lone clamp gripping a single tool; on the right, an organised wall of specialist tools
around a small instrument sealed under glass with a wax seal.

## Filename
Source: coding-harness-vs-agent-11.png
Deployed (after conversion): 2026-06-21-coding-harness-vs-agent-11.webp

## Conversion + placement (same pipeline as the first post's image)
1. Convert and downsize the PNG to WebP, ~1600px wide, quality ~82, target under ~150KB:
   `cwebp -q 82 -resize 1600 0 coding-harness-vs-agent-11.png -o 2026-06-21-coding-harness-vs-agent-11.webp`
2. Copy the .webp into jpub's image dir so it uploads on publish:
   `cp 2026-06-21-coding-harness-vs-agent-11.webp ~/shared/content/blog/images/`

## Frontmatter additions needed
After the image is converted and placed, add to the post's frontmatter
(`blog/2026-06-21-coding-harness-vs-agent-11.md`):

```
image: /images/blog/2026-06-21-coding-harness-vs-agent-11.webp
imageAlt: "On the left, a lone clamp gripping a single tool; on the right, an organised wall of specialist tools around a small instrument sealed under glass with a wax seal."
```

Then a `jpub ... --dry-run` should report `Image: /images/blog/2026-06-21-coding-harness-vs-agent-11.webp (found locally, …KB)` before publishing for real.
