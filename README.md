# DOT Joinery

**joinery by Department of Things** — a public workshop notebook of parametric,
3D-printable tools for woodworking, the agent skills that design them, and the
case studies behind both.

🌐 **Live site:** https://dot-joinery.pages.dev

## What's here

| Path | What it is |
|---|---|
| `public/files/` | Project files served by the site — sources, STLs, G-code, viewers |
| `skills/` | Agent skills (`SKILL.md` format) installable via `npx skills add` |
| `src/` | The Astro site (pages, components, content loaders) |

## Projects

All part of one story: drilling thousands of evenly spaced holes into 18 mm
plywood pegboard (10 mm holes, 50 mm grid) without measuring every hole.

| Project | What |
|---|---|
| [FORM / FIELD](https://dot-joinery.pages.dev/projects/pegboard-saddle-jig/) | Interactive explorer — five jig concepts compared in a live 3D viewer |
| [Drilling Jigs — v2](https://dot-joinery.pages.dev/projects/pegboard-drilling-jigs/) | Clean-print edition: corner base + fence, indexing bar, row seeder. OpenSCAD + Fusion 360 |
| [Jig — v3](https://dot-joinery.pages.dev/projects/pegboard-jigs-v3/) | Configurable two-tool system with a browser configurator; full case study included |
| [A1 mini Print Set](https://dot-joinery.pages.dev/projects/pegboard-print-set/) | Print-ready STLs + sliced G-code for all five proposals, Bambu A1 mini |

Every design is parametric — named dimensions drive the geometry, sources are
open (OpenSCAD `.scad` and Fusion 360 Python), and print files are sliced and
ready. No supports anywhere in the system.

## Agent skills

Reusable skills in the open [`SKILL.md`](https://agentskills.io) format that
teach coding agents parametric, FDM-printable CAD design via the Fusion 360
Python API.

| Skill | Install |
|---|---|
| `parametric-cad-engineer` | `npx skills add HShaebi11/dot-joinery --skill parametric-cad-engineer` |

Works with Claude Code, Cursor, Devin, Codex, Windsurf, OpenCode, and 70+
agents — the CLI auto-detects what you have, or pass `-a <agent>` and `-g` for
global installs. Requires Node.js 22.20+.

Browse them at https://dot-joinery.pages.dev/skills/

## Working on the site

```sh
npm install
npm run dev      # local dev server
npm run build    # static build → dist/
npm run preview  # serve the production build
```

- Project metadata lives in `src/data/projects.ts`; READMEs and `SKILL.md`
  files are pulled in automatically at build time — add a project folder or a
  skill folder and it appears on the site.
- The site deploys to Cloudflare Pages from `dist/` — `npm run deploy`
  (builds, then `wrangler pages deploy`; needs `wrangler` auth).

## License

Sources and print files are published for personal and small-shop use.
