# Agent Skills

A collection of reusable agent skills for CAD, 3D printing, and related tooling.
Each subfolder is a self-contained skill built on the open `SKILL.md` standard
(`name` + `description` frontmatter + prompt body), compatible with Devin, Claude
Code, Cursor, and other agents that support the `.agents` skills format.

Part of [DOT Joinery](https://github.com/HShaebi11/dot-joinery) —
joinery by Department of Things. Live catalog:
https://joinery.fromdot.work/skills/

## Skills

| Skill | Description |
|---|---|
| `parametric-cad-engineer` | Parametric, FDM-printable CAD design via the Autodesk Fusion 360 Python API — design tokens, parameter dependencies, edge/manufacturing profiles, complete script delivery. |

## Installing a skill

**Recommended — the skills CLI** (requires Node.js 22.20+):

```bash
npx skills add HShaebi11/dot-joinery --skill parametric-cad-engineer
```

Add `-g` to install globally (all projects), `-a <agent>` to target a specific
agent (`claude-code`, `cursor`, `codex`, `devin`, `windsurf`, …), or `-y` to
skip prompts. Without `-a`, the CLI auto-detects your installed agents.

**Manual — symlink into your agent's skills directory:**

```bash
# Devin / agents standard
ln -sfn "/path/to/dot-joinery/skills/<skill-name>" ~/.agents/skills/<skill-name>

# Claude Code
ln -sfn "/path/to/dot-joinery/skills/<skill-name>" ~/.claude/skills/<skill-name>

# Cursor
ln -sfn "/path/to/dot-joinery/skills/<skill-name>" ~/.cursor/skills/<skill-name>
```

Or simply copy the skill folder into the target directory instead of symlinking.

**Project-only:**

```bash
mkdir -p .devin/skills
cp -R "/path/to/dot-joinery/skills/<skill-name>" .devin/skills/
```

Once installed, the skill is invocable by name (e.g. `/parametric-cad-engineer`)
and agents can also auto-invoke it when a request matches its description.
