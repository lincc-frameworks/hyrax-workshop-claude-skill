# Hyrax Workshop — Dataset Class Skill

This repo contains a skill for creating Hyrax dataset classes, compatible with both [Claude Code](https://docs.claude.ai/en/docs/claude-code) and [Codex CLI](https://developers.openai.com/codex/cli). It is intended for workshop participants who are building dataset classes for their own data — typically prototyping directly in a Jupyter notebook. The skill guides the AI through the correct interface contract, the inline `data_request` / `dataset_config` pattern, and (optionally) how to move the finished class into a standalone package.

You do **not** need an existing project or package to use this skill. It installs into your user-global skills directory, so it is available in every session, including when you launch the CLI next to a notebook.

## Prerequisites

- [Claude Code](https://docs.claude.ai/en/docs/claude-code) and/or [Codex CLI](https://developers.openai.com/codex/cli) installed
- Hyrax installed in the environment you run your notebook from: `pip install hyrax`

## Quick Install (macOS / Linux)

Clone this repo and run the installer. It copies the skill into both `~/.claude/skills/` (Claude Code) and `~/.codex/skills/` (Codex CLI):

```bash
git clone https://github.com/lincc-frameworks/hyrax-workshop-claude-skill.git
cd hyrax-workshop-claude-skill
bash install.sh
```

You can run it from anywhere — it installs to your home directory, not the current project.

## Manual Install (all platforms)

Copy the `hyrax-dataset-class/` folder into your user-global skills directory for the CLI you use:

**Claude Code:**
```
~/.claude/
└── skills/
    └── hyrax-dataset-class/   ← copy this folder here
```

**Codex CLI:**
```
~/.codex/
└── skills/
    └── hyrax-dataset-class/   ← copy this folder here
```

For example:

```bash
# Claude Code
mkdir -p ~/.claude/skills
cp -r .claude/skills/hyrax-dataset-class ~/.claude/skills/

# Codex CLI
mkdir -p ~/.codex/skills
cp -r .claude/skills/hyrax-dataset-class ~/.codex/skills/
```

## How to use the skill

Open Claude Code or Codex CLI from wherever you keep your notebook and say:

> Use $hyrax-dataset-class to create a dataset class for my data.

Then describe your data format, file layout, and which fields you need. The AI will help you write the class in your notebook, wire it into Hyrax via `data_request`, and verify it with `h.prepare()`.

## Helpful Links

- Hyrax GitHub: https://github.com/lincc-frameworks/hyrax
- Hyrax docs: https://hyrax.readthedocs.io/en/stable/
- Dataset class reference: https://hyrax.readthedocs.io/en/stable/dataset_class_reference.html
- External dataset class notebook: https://hyrax.readthedocs.io/en/stable/pre_executed/external_dataset_class.html
- External package setup guide: https://hyrax.readthedocs.io/en/stable/external_library_package.html
- Reference example repo: https://github.com/lincc-frameworks/external_hyrax_example
