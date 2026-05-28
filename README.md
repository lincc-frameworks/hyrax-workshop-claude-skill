# Hyrax Workshop — Dataset Class Skill

This repo contains a Claude Code skill for creating Hyrax dataset classes in external Python projects. It is intended for workshop participants who are building dataset classes in their own projects (not inside the Hyrax source repo). The skill guides Claude Code through the correct interface contract, config patterns, and test structure for external Hyrax dataset classes.

## Prerequisites

- [Claude Code](https://docs.claude.ai/en/docs/claude-code) installed
- Your own project directory with a `.claude/` folder (created when you first run `claude` inside a project)
- Hyrax installed: `pip install hyrax`

## Quick Install (macOS, default Claude Code setup)

Run the installer **from your project's root directory** (not from inside this repo):

```bash
git clone https://github.com/lincc-frameworks/hyrax-workshop-claude-skill.git
cd /path/to/my-astronomy-project   # ← your project, not the cloned repo
bash /path/to/hyrax-workshop-claude-skill/install.sh
```

## Manual Install (all platforms / non-default setups)

1. Clone or download this repo
2. Copy `.claude/skills/hyrax-dataset-class/` into `.claude/skills/` inside your project root:

```
my-project/
└── .claude/
    └── skills/
        └── hyrax-dataset-class/   ← copy this folder here
```

If `.claude/skills/` doesn't exist yet, create it first.

## How to use the skill

Open Claude Code from your project directory and say:

> Use $hyrax-dataset-class to create a dataset class for my data.

Then describe your data format, file layout, and which fields you need. Claude Code will guide you through building the class.

## Helpful Links

- Hyrax GitHub: https://github.com/lincc-frameworks/hyrax
- Hyrax docs: https://hyrax.readthedocs.io/en/stable/
- Dataset class reference: https://hyrax.readthedocs.io/en/stable/dataset_class_reference.html
- External dataset class notebook: https://hyrax.readthedocs.io/en/stable/pre_executed/external_dataset_class.html
- External package setup guide: https://hyrax.readthedocs.io/en/stable/external_library_package.html
- Reference example repo: https://github.com/lincc-frameworks/external_hyrax_example
