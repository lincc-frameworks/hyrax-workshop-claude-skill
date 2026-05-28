# Plan: Hyrax External Dataset Class Skill — Workshop Distribution

## Context and Problem Statement

**Workshop goal:** Participants are building dataset classes that are **external** to the Hyrax framework — i.e., they live in their own repos/packages, not inside `lincc-frameworks/hyrax`. This is different from the existing Claude Code skill, which was written to help Hyrax contributors create dataset classes **inside** the Hyrax source tree.

**The key difference — internal vs. external:**
- **Internal:** The dataset class goes in `src/hyrax/datasets/`, config defaults go in `src/hyrax/hyrax_default_config.toml`, and tests go in `tests/hyrax/`. The class is part of Hyrax itself.
- **External:** The dataset class goes in the user's own Python package (e.g., `my_survey_lib/datasets/my_dataset.py`), config defaults go in the user's own TOML config file, and tests go in their own test directory. Hyrax is a dependency, not the host repo. The class is referenced by fully-qualified import path: `"dataset_class": "my_package.datasets.my_dataset.MyDataset"`.

The workflow for external users is: prototype in a notebook → move to a standalone package → install locally → wire into Hyrax config.

**The task:** Create a new standalone GitHub repository containing a lightly adapted version of the Hyrax dataset class skill, plus installation tooling, so workshop participants can quickly add it as a local Claude Code project skill.

**Constraints:**
- Must be completable by one person in ~1-2 hours of manual work
- Participants are comfortable with GitHub (clone, copy, paste) but are **new to Claude Code**
- The skill content changes are small and surgical — a few word/sentence tweaks, not a rewrite
- This is a one-off for the workshop; no need for a single source of truth across repos

---

## Reference Material (verified URLs)

### HYRAX Repo and Docs
- **GitHub:** https://github.com/lincc-frameworks/hyrax
- **Read the Docs (stable):** https://hyrax.readthedocs.io/en/stable/
- **Dataset class reference (interface contract):** https://hyrax.readthedocs.io/en/stable/dataset_class_reference.html
- **External dataset class notebook (key reference for workshop):** https://hyrax.readthedocs.io/en/stable/pre_executed/external_dataset_class.html
- **External package setup guide:** https://hyrax.readthedocs.io/en/stable/external_library_package.html *(verify exact URL at RTD)*
- **Reference example repo for external packages:** https://github.com/lincc-frameworks/external_hyrax_example

### What the External Dataset Class Notebook Covers
The notebook at `docs/pre_executed/external_dataset_class.ipynb` (published at the URL above) is the primary reference for what workshop participants are doing. It covers:
1. Writing the minimum required methods (`__len__`, `get_<field>`, `get_object_id`) inheriting from `HyraxDataset`
2. Wiring the class into Hyrax using `h.set_config("data_request", {...})` and `h.prepare()`
3. The `data_request` config structure: `{step: {friendly_name: {dataset_class, data_location, fields, primary_id_field}}}`
4. Handling variable-length fields with `collate_<field>` methods
5. Moving the finished class into a standalone Python package for production use

The key pattern for external use is that `dataset_class` in the config can be either a bare class name (if the class is defined in the notebook/session) or a **fully-qualified import path** like `"my_package.datasets.my_dataset.MyDataset"`.

### Existing Skill Location in HYRAX Repo
The skill lives at:
```
.claude/skills/hyrax-dataset-class/
├── SKILL.md                          ← main skill prompt (copy and adapt)
├── references/
│   ├── config-rules.md               ← config instructions (needs surgical edits)
│   └── test-checklist.md             ← copy as-is
└── agents/
    └── openai.yaml                   ← display metadata, copy as-is
```

There is also `.claude/settings.json` and `.claude/hooks/session-start.sh` in the HYRAX repo. These are Hyrax-internal (the hook activates a Conda venv for Hyrax's web environment) and should **not** be included in the new repo.

---

## Target Repository Structure

```
hyrax-workshop-skill/               ← repo root
├── README.md                        ← step-by-step setup instructions for participants
├── install.sh                       ← macOS auto-installer (default Claude Code paths)
└── .claude/
    └── skills/
        └── hyrax-dataset-class/
            ├── SKILL.md
            ├── references/
            │   ├── config-rules.md
            │   └── test-checklist.md
            └── agents/
                └── openai.yaml
```

Participants clone this repo and either run `install.sh` or follow the manual README instructions to copy `.claude/skills/hyrax-dataset-class/` into the `.claude/skills/` directory of their own project.

---

## Required Skill Edits (Surgical Changes)

The following changes adapt the skill from **internal** (contributing to Hyrax source) to **external** (writing a dataset class in the user's own project). All other content should be copied verbatim.

### 1. `SKILL.md` — frontmatter `description`

**Original:**
```
description: Create or update Hyrax dataset classes. Use when the user asks to "create a dataset class", "add a HyraxDataset", "load my data through Hyrax", "add dataset getter methods", "wire dataset defaults", "add dataset tests", or "make a notebook example" for a Hyrax dataset. Also use when a task involves data_request fields, primary_id_field, hyrax_default_config.toml defaults, or dataset code under src/hyrax/datasets.
```

**Change:** Remove `hyrax_default_config.toml defaults` and `dataset code under src/hyrax/datasets` (both internal references). Suggested replacement for the last clause:

> Also use when a task involves data_request fields, primary_id_field, or dataset config for use with Hyrax from an external package.

### 2. `SKILL.md` — "First Read" section

**Original:**
```markdown
## First Read

Read `docs/dataset_class_reference.rst` before implementing. Treat it as the interface contract.

Read `src/hyrax/hyrax_default_config.toml` before adding config keys. Match the existing TOML style and put dataset-specific defaults under `[dataset.<ClassName>]`.
```

**Change:** The file paths are Hyrax-internal. Replace with:

```markdown
## First Read

Read the [Hyrax Dataset Class Reference](https://hyrax.readthedocs.io/en/stable/dataset_class_reference.html) before implementing. Treat it as the interface contract.

Read the [external dataset class notebook](https://hyrax.readthedocs.io/en/stable/pre_executed/external_dataset_class.html) for the recommended notebook-first workflow and the `data_request` config structure.

Config defaults for your dataset go in your own project's TOML config file (passed to Hyrax at runtime). Match the `[dataset.<ClassName>]` table structure. See [references/config-rules.md](references/config-rules.md) for details.
```

### 3. `SKILL.md` — Implementation Workflow, step 1

**Original:**
```
1. Choose a class name ending in `Dataset` and a module under `src/hyrax/datasets/`.
```

**Change:**
```
1. Choose a class name ending in `Dataset` and place it in an appropriate module in the user's own project (e.g. `src/my_package/datasets/my_dataset.py`).
```

### 4. `SKILL.md` — Implementation Workflow, step 2

**Original:**
```
2. Import `HyraxDataset` from `hyrax.datasets` (the canonical import path).
```

**Change:** Add a note about the fully-qualified class reference needed in config:
```
2. Import `HyraxDataset` from `hyrax.datasets` (the canonical import path — requires `hyrax` to be installed as a dependency). When wiring into Hyrax config, reference the class by its fully-qualified import path, e.g. `"my_package.datasets.my_dataset.MyDataset"`.
```

### 5. `SKILL.md` — Implementation Workflow, step 10

**Original:**
```
10. Add focused tests under `tests/hyrax/` that create minimal sample data and assert length, primary IDs, requested fields, and config/pass-through behavior.
```

**Change:**
```
10. Add focused tests under the user's own project test directory that create minimal sample data and assert length, primary IDs, requested fields, and config/pass-through behavior.
```

### 6. `references/config-rules.md` — TOML defaults location

**Original:**
```
Add every Hyrax-owned key the dataset reads to `src/hyrax/hyrax_default_config.toml`. Missing defaults should fail loudly with `KeyError` during development.
```

**Change:**
```
Add every config key your dataset reads to your own project's TOML config file (passed to Hyrax at runtime). Use the `[dataset.<ClassName>]` table structure. Missing defaults should fail loudly with `KeyError` during development.
```

---

## `install.sh` Spec

The script should:
1. Check it's running on macOS; if not, print an error and point to the README
2. Check that `./.claude/` exists in the current working directory (i.e., they're running from inside their project); if not, print an error and point to the README
3. Copy the `hyrax-dataset-class` skill folder into `./.claude/skills/`
4. Print a success message with instructions on how to invoke the skill

```bash
#!/usr/bin/env bash
set -euo pipefail

# --- hyrax-workshop-skill installer ---
# Copies the hyrax-dataset-class skill into your project's .claude/skills/ directory.
# Run this from the ROOT of your project (where your .claude/ directory lives).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$SCRIPT_DIR/.claude/skills/hyrax-dataset-class"
SKILL_DEST="./.claude/skills/hyrax-dataset-class"

# macOS only
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: This installer only supports macOS with a default Claude Code setup."
  echo "Please follow the manual instructions in README.md."
  exit 1
fi

# Must be run from inside a project with a .claude directory
if [[ ! -d "./.claude" ]]; then
  echo "ERROR: No .claude/ directory found in the current directory."
  echo "Make sure you are running this script from the root of your project,"
  echo "not from inside the hyrax-workshop-skill folder."
  echo ""
  echo "See README.md for manual installation instructions."
  exit 1
fi

mkdir -p "./.claude/skills"
cp -r "$SKILL_SRC" "$SKILL_DEST"

echo "✓ Skill installed to $SKILL_DEST"
echo ""
echo "To use it, open Claude Code in your project and say:"
echo "  Use \$hyrax-dataset-class to create a dataset class for my data."
```

---

## `README.md` Spec

### What this is
One paragraph: This repo contains a Claude Code skill for creating Hyrax dataset classes in external Python projects. It is intended for workshop participants who are building dataset classes in their own projects (not inside the Hyrax source repo). The skill guides Claude Code through the correct interface contract, config patterns, and test structure for external Hyrax dataset classes.

### Prerequisites
- Claude Code installed (link: https://docs.claude.ai/en/docs/claude-code)
- Your own project directory with a `.claude/` folder (created when you first run `claude` inside a project)
- Hyrax installed: `pip install hyrax`

### Quick Install (macOS, default Claude Code setup)
Run the installer **from your project's root directory** (not from inside this repo):
```bash
git clone https://github.com/<your-org>/hyrax-workshop-skill.git
cd /path/to/my-astronomy-project   # ← your project, not the cloned repo
bash /path/to/hyrax-workshop-skill/install.sh
```

### Manual Install (all platforms / non-default setups)
1. Clone or download this repo
2. Copy `.claude/skills/hyrax-dataset-class/` into `.claude/skills/` inside your project root:

```
my-project/
└── .claude/
    └── skills/
        └── hyrax-dataset-class/   ← copy this folder here
```

If `.claude/skills/` doesn't exist yet, create it first.

### How to use the skill
Open Claude Code from your project directory and say:
> Use $hyrax-dataset-class to create a dataset class for my data.

Then describe your data format, file layout, and which fields you need. Claude Code will guide you through building the class.

### Helpful Links
- Hyrax GitHub: https://github.com/lincc-frameworks/hyrax
- Hyrax docs: https://hyrax.readthedocs.io/en/stable/
- Dataset class reference: https://hyrax.readthedocs.io/en/stable/dataset_class_reference.html
- External dataset class notebook: https://hyrax.readthedocs.io/en/stable/pre_executed/external_dataset_class.html
- External package setup guide: https://hyrax.readthedocs.io/en/stable/external_library_package.html
- Reference example repo: https://github.com/lincc-frameworks/external_hyrax_example

---

## Implementation Notes for the Coding Agent

- Initialize an empty GitHub repo, then create all files per the structure above
- All skill content should be copied verbatim from `lincc-frameworks/hyrax` at `.claude/skills/hyrax-dataset-class/`, then edited per the surgical changes listed above
- The `session-start.sh` hook and `settings.json` from the HYRAX repo are Hyrax-internal and should **not** be included
- The `agents/openai.yaml` file can be included as-is; it's just display metadata
- The external dataset class notebook content (summarized in the "Reference Material" section above) provides important context for what the skill should help users build — the agent may want to read it before making edits to ensure the framing is right
- Suggested repo name: `hyrax-workshop-skill`

